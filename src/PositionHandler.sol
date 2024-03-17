pragma solidity ^0.8.17;

import {IPositionHandler} from "./interfaces/IPositionHandler.sol";
import {PositionData} from "./lib/PositionData.sol";
import {Constants} from "./lib/Constants.sol";

import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

contract PositionHandkler is IPositionHandler {
    // INTEGRATION:

    // TODO: integrate the Oracle contract fetching indicator
    // TODO: add the call to contract making the swap
    // TODO: implement the cross-chain logic

    uint256 indexDeposit;
    uint256 oracleValue;

    mapping(address tokenA => mapping(address tokenB => mapping(uint256 positionID => PositionData.UserData userPosData))) userPosTracker;
    mapping(address tokenA => mapping(address tokenB => mapping(uint256 nSwapsExecuted => PositionData.CumData cumData))) cumulativePosData;
    mapping(address tokenA => mapping(address tokenB => PositionData.GlobalData globalData)) counterSwapsExecuted;

    using Math for uint256;

    /**
     */
    function deposit(
        address _tokenA,
        address _tokenB,
        address _owner,
        uint256 _amount_in,
        uint256 _amount_swaps
    ) external {
        if (_amount_swaps != 0) {
            revert ZeroSwapAmountError(_tokenA, _tokenB, _owner, _amount_in);
        }
        uint256 swapExecuted = counterSwapsExecuted[_tokenA][_tokenB]
            .nSwapsExecuted;

        PositionData.UserData memory userPosData = PositionData.UserData({
            tokenIn: _tokenA,
            tokenOut: _tokenB,
            nbSwapsStart: swapExecuted,
            nbSwapsEnd: type(uint256).max,
            amountIn: _amount_in,
            amountSwaps: _amount_swaps,
            isInsolvent: false,
            owner: _owner
        });

        userPosTracker[_tokenA][_tokenB][indexDeposit] = userPosData;
        indexDeposit++;

        emit Deposit(
            _tokenA,
            _tokenB,
            indexDeposit,
            _owner,
            _amount_in,
            _amount_swaps
        );
    }

    function execute(address _tokenA, address _tokenB) external {
        uint256 boost = getBoost(oracleValue);
        uint256 swapsExecuted = counterSwapsExecuted[_tokenA][_tokenB]
            .nSwapsExecuted;
        uint256 amountToSwap;

        for (uint256 i = 0; i <= swapsExecuted; i++) {
            PositionData.UserData memory userPosData = userPosTracker[_tokenA][
                _tokenB
            ][i];

            if (userPosData.isInsolvent) {
                continue;
            }
            //do the verify Insolvent with the boost - nbSwapsEnd
            bool isInsolvent = verifyInsolvability(_tokenA, _tokenB, i, boost);
            if (isInsolvent) {
                continue;
            }

            uint256 baseAmountToSwap = getBaseSwapAmount(
                userPosData.amountIn,
                userPosData.amountSwaps
            );

            amountToSwap += baseAmountToSwap.mulDiv(boost, Constants.UNIT);
        }

        uint256 price = swap(_tokenA, _tokenB, amountToSwap);

        cumulativePosData[_tokenA][_tokenB][swapsExecuted].cumBoost =
            boost +
            getPreviousBoost(_tokenA, _tokenB, _swapsExecuted);

        cumulativePosData[_tokenA][_tokenB][swapsExecuted].cumBoostedPrice =
            price.mulDiv(boost, Constants.UNIT) +
            getPreviousPrice(_tokenA, _tokenB, _swapsExecuted);

        counterSwapsExecuted[_tokenA][_tokenB].nSwapsExecuted += 1;
    }

    function withdraw(
        address _tokenA,
        address _tokenB,
        address _destinationAddress,
        uint256 _indexDeposit // select the position to withdraw
    ) external {
        PositionData.UserData memory userPosData = userPosTracker[_tokenA][
            _tokenB
        ][_indexDeposit];

        // TODO: use Solmate for this
        require(userPosData.owner == msg.sender, "not the owner of this DCA");

        uint256 nbSwapsEnd;

        if (userPosData.nbSwapsEnd < type(uint256).max) {
            // Only if pos expired

            nbSwapsEnd = userPosData.nbSwapsEnd;
        } else {
            nbSwapsEnd = counterSwapsExecuted[_tokenA][_tokenB].nSwapsExecuted;
        }

        uint256 cumulativeBoost = getCumulativeBoost(
            userPosData.nbSwapsStart,
            nbSwapsEnd,
            _tokenA,
            _tokenB
        );

        uint256 baseAmountToSwap = getBaseSwapAmount(
            userPosData.amountIn,
            userPosData.amountSwaps
        );

        uint256 numberRemainSwap = userPosData.amountSwaps - cumulativeBoost;
        uint256 amountTokenARemain = numberRemainSwap * baseAmountToSwap;

        uint256 averagePrice = getAveragePrice(
            userPosData.nbSwapsStart,
            nbSwapsEnd,
            _tokenA,
            _tokenB
        );

        uint256 amountTokenB = baseAmountToSwap
            .mulDiv(cumulativeBoost, Constants.UNIT)
            .mulDiv(averagePrice, Constants.UNIT);

        delete userPosTracker[_tokenA][_tokenB][_indexDeposit];

        IERC20(_tokenA).transfer(_destinationAddress, amountTokenARemain);

        IERC20(_tokenB).transfer(_destinationAddress, amountTokenB);

        emit Withdraw(
            _tokenA,
            _tokenB,
            _indexDeposit,
            amountTokenARemain,
            amountTokenB,
            _destinationAddress
        );
    }

    /* ------------------------- INTERNAL FUNCTION ------------------------- */

    function swap(
        address _tokenA,
        address _tokenB,
        uint256 _amountIn
    ) internal returns (uint256) {
        // call the swap function of the pool
        uint256 amountTokensOut = 10;
        uint256 priceRatio = amountTokensOut.mulDiv(Constants.UNIT, _amountIn);
        return priceRatio;
    }

    function verifyInsolvability(
        address _tokenA,
        address _tokenB,
        uint256 _indexDeposit,
        uint256 _boost
    ) internal returns (bool) {
        uint256 currentCounterSwaps = counterSwapsExecuted[_tokenA][_tokenB]
            .nSwapsExecuted;
        uint256 cumulativeBoost = getCumulativeBoost(
            userPosTracker[_tokenA][_tokenB][_indexDeposit].nbSwapsStart,
            currentCounterSwaps,
            _tokenA,
            _tokenB
        );

        uint256 numberRemainSwap = userPosTracker[_tokenA][_tokenB][
            _indexDeposit
        ].amountSwaps - cumulativeBoost;
        if (_boost > numberRemainSwap) {
            setInsolvent(_tokenA, _tokenB, _indexDeposit);
            return true;
        }
        return false;
    }

    /* -------------------------- SETTER FUNCTION ------------------------- */

    function setInsolvent(
        address _tokenA,
        address _tokenB,
        uint256 _indexDeposit
    ) internal {
        userPosTracker[_tokenA][_tokenB][_indexDeposit].isInsolvent = true;
        userPosTracker[_tokenA][_tokenB][_indexDeposit]
            .nbSwapsEnd = currentCounterSwaps;
    }

    /* -------------------------- GETTER FUNCTION ------------------------- */

    function getPreviousBoost(
        address _tokenA,
        address _tokenB,
        uint256 _swapsExecuted
    ) internal returns (uint256) {
        return
            (_swapsExecuted == 0)
                ? 0
                : cumulativePosData[_tokenA][_tokenB][swapsExecuted - 1]
                    .cumBoost;
    }
    function getPreviousPrice(
        address _tokenA,
        address _tokenB,
        uint256 _swapsExecuted
    ) internal returns (uint256) {
        return
            (_swapsExecuted == 0)
                ? 0
                : cumulativePosData[_tokenA][_tokenB][swapsExecuted - 1]
                    .cumBoostedPrice;
    }

    function getBaseSwapAmount(
        uint256 _amountIn,
        uint256 _amountSwaps
    ) private pure returns (uint256) {
        return _amountIn.mulDiv(Constants.UNIT, _amountSwaps);
    }

    function getBoost(uint256 _oracleVal) private pure returns (uint256) {
        if (_oracleVal > Constants.THRESHOLD_UP) {
            return Constants.BOOST_UP;
        } else if (_oracleVal < Constants.THRESHOLD_DOWN) {
            return Constants.BOOST_DOWN;
        } else {
            return Constants.NO_BOOST;
        }
    }

    function getCumulativeBoost(
        uint256 _nbSwapsStart,
        uint256 _nbSwapsEnd,
        address _tokenA,
        address _tokenB
    ) internal view returns (uint256) {
        return
            cumulativePosData[_tokenA][_tokenB][_nbSwapsEnd].cumBoost -
            cumulativePosData[_tokenA][_tokenB][_nbSwapsStart].cumBoost;
    }

    function getAveragePrice(
        uint256 _nbSwapsStart,
        uint256 _nbSwapsEnd,
        address _tokenA,
        address _tokenB
    ) internal view returns (uint256) {
        boost_start = cumulativePosData[_tokenA][_tokenB][_nbSwapsStart]
            .cumBoost;
        boost_end = cumulativePosData[_tokenA][_tokenB][_nbSwapsEnd].cumBoost;

        boosted_price_start = cumulativePosData[_tokenA][_tokenB][_nbSwapsStart]
            .cumBoostedPrice;

        boosted_price_end = cumulativePosData[_tokenA][_tokenB][_nbSwapsEnd]
            .cumBoostedPrice;

        uint256 average_price = (boosted_price_end - boosted_price_start)
            .mulDiv(Constants.UNIT, boost_end - boost_start);

        return average_price;
    }
    function withdraw(uint256 positionID, address destinationAddress) external;

    function execute(address tokenA, address tokenB) external;
}
