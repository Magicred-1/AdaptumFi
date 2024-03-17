pragma solidity ^0.8.17;

import {IPositionHandler} from "./interfaces/IPositionHandler.sol";
import {PositionData} from "./lib/PositionData.sol";
import {Constants} from "./lib/Constants.sol";
import {IMailbox} from "lib/hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";

import {Math} from "openzeppelin-contracts/contracts/utils/math/Math.sol";
import {IERC20} from "openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts/contracts/token/ERC721/IERC721.sol";

import {ICBBIOracle} from "./interfaces/ICBBIOracle.sol";
import {NFTDCAPosition} from "./NFTPosition.sol";
import {EntryPoint} from "./Entry.sol";

contract PositionHandler is IPositionHandler {

    uint256 indexDeposit;
    uint256 oracleValue;
    uint32 destinationChainId;

    address oracleAddress;
    address nftPositionFactoryAddress;
    address mailboxAddress;
    address destinationSwapAddress;

    address public constant zeroAddress = address(0);

    EntryPoint entryPoint;

    mapping(address tokenA => mapping(address tokenB => mapping(uint256 positionID => PositionData.UserData userPosData))) userPosTracker;
    mapping(address tokenA => mapping(address tokenB => mapping(uint256 nSwapsExecuted => PositionData.CumData cumData))) cumulativePosData;
    mapping(address tokenA => mapping(address tokenB => PositionData.GlobalData globalData)) counterSwapsExecuted;

    using Math for uint256;

    constructor(
        address _oracleAddress,
        address _chainlinkRouterAddress,
        address _mailboxAddress,
        address _destinationSwapAddress,
        uint32 _destinationChaidId
    ) {
        oracleAddress = _oracleAddress;
        nftPositionFactoryAddress = address(new NFTDCAPosition());

        entryPoint = new EntryPoint(_chainlinkRouterAddress, zeroAddress);

        mailboxAddress = _mailboxAddress;
        destinationSwapAddress = _destinationSwapAddress;
        destinationChainId = _destinationChaidId;
    }

    function handle(
        uint32 _origin,
        bytes32 _sender,
        bytes calldata _message
    ) external payable {
        require(msg.sender == mailboxAddress, "Not the MailBox");

        (
            address _tokenA,
            address _tokenB,
            uint256 swapsExecuted,
            uint256 amountToSwap,
            uint256 exchangeRate,
            uint256 boost
        ) = abi.decode(
                _message,
                (address, address, uint256, uint256, uint256, uint256)
            );

        updateState(
            _tokenA,
            _tokenB,
            swapsExecuted,
            amountToSwap,
            exchangeRate,
            boost
        );
    }

    function deposit(
        address _tokenA,
        address _tokenB,
        address _owner,
        uint256 _amount_in,
        uint256 _amount_swaps
    ) external {
        if (_amount_swaps == 0) {
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
            isInsolvent: false
        });

        userPosTracker[_tokenA][_tokenB][indexDeposit] = userPosData;

        IERC20(_tokenA).transferFrom(msg.sender, address(this), _amount_in);
        NFTDCAPosition(nftPositionFactoryAddress).mint(_owner, indexDeposit);
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
        uint256 boost = getBoost(ICBBIOracle(oracleAddress).getCBBIIndex());
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

        swap(_tokenA, _tokenB, amountToSwap, boost);
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

        require(
            NFTDCAPosition(nftPositionFactoryAddress).ownerOf(_indexDeposit) ==
                msg.sender,
            "not the owner of this DCA"
        );

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

        NFTDCAPosition(nftPositionFactoryAddress).burn(_indexDeposit);

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

    function updateState(
        address _tokenA,
        address _tokenB,
        uint256 swapsExecuted,
        uint256 amountToSwap,
        uint256 exchangeRate,
        uint256 boost
    ) internal {
        cumulativePosData[_tokenA][_tokenB][swapsExecuted].cumBoost =
            boost +
            getPreviousBoost(_tokenA, _tokenB, swapsExecuted);

        cumulativePosData[_tokenA][_tokenB][swapsExecuted].cumBoostedPrice =
            exchangeRate.mulDiv(boost, Constants.UNIT) +
            getPreviousPrice(_tokenA, _tokenB, swapsExecuted);

        counterSwapsExecuted[_tokenA][_tokenB].nSwapsExecuted += 1;

        emit SwapExecuted(_tokenA, _tokenB, amountToSwap, exchangeRate);
    }

    function swap(
        address _tokenA,
        address _tokenB,
        uint256 _amountIn,
        uint256 boost
    ) internal {
        entryPoint.executeCrossChainSwap(
            destinationChainId,
            address(entryPoint),
            abi.encode(
                boost,
                _tokenA,
                _tokenB,
                _amountIn,
                counterSwapsExecuted[_tokenA][_tokenB].nSwapsExecuted,
                1
            )
        );
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
            setInsolvent(_tokenA, _tokenB, _indexDeposit, currentCounterSwaps);
            return true;
        }
        return false;
    }

    /* -------------------------- SETTER FUNCTION ------------------------- */

    function setInsolvent(
        address _tokenA,
        address _tokenB,
        uint256 _indexDeposit,
        uint256 _currentCounterSwaps
    ) internal {
        userPosTracker[_tokenA][_tokenB][_indexDeposit].isInsolvent = true;
        userPosTracker[_tokenA][_tokenB][_indexDeposit]
            .nbSwapsEnd = _currentCounterSwaps;
    }

    /* -------------------------- GETTER FUNCTION ------------------------- */

    function getPreviousBoost(
        address _tokenA,
        address _tokenB,
        uint256 _swapsExecuted
    ) internal view returns (uint256) {
        return
            (_swapsExecuted == 0)
                ? 0
                : cumulativePosData[_tokenA][_tokenB][_swapsExecuted - 1]
                    .cumBoost;
    }

    function getPreviousPrice(
        address _tokenA,
        address _tokenB,
        uint256 _swapsExecuted
    ) internal view returns (uint256) {
        return
            (_swapsExecuted == 0)
                ? 0
                : cumulativePosData[_tokenA][_tokenB][_swapsExecuted - 1]
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
        uint256 cumBoost = getCumulativeBoost(
            _nbSwapsStart,
            _nbSwapsEnd,
            _tokenA,
            _tokenB
        );

        uint256 boosted_price_end = cumulativePosData[_tokenA][_tokenB][
            _nbSwapsEnd
        ].cumBoostedPrice;
        uint256 boosted_price_start = cumulativePosData[_tokenA][_tokenB][
            _nbSwapsStart
        ].cumBoostedPrice;

        uint256 average_price = (boosted_price_end - boosted_price_start)
            .mulDiv(Constants.UNIT, cumBoost);

        return average_price;
    }
}
