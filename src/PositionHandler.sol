pragma solidity ^0.8.17;

import {IPositionHandler} from "./interfaces/IPositionHandler.sol";
import {PositionData} from "./lib/PositionData.sol";
import {Constants} from "./lib/Constants.sol";

interface IERC20 {
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract PositionHandkler is IPositionHandler {
    uint256 indexDeposit = 0;
    mapping(
        address tokenA => mapping(address tokenB => mapping(uint256 positionID => PositionData.UserData userPosData))
    ) userPosTracker;
    mapping(
        address tokenA => mapping(address tokenB => mapping(uint256 nSwapsExecuted => PositionData.CumData cumData))
    ) cumulativePosData;
    mapping(address tokenA => mapping(address tokenB => PositionData.GlobalData globalData)) counterSwapsExecuted;

    function deposit(address _tokenA, address _tokenB, address _owner, uint256 _amount_in, uint256 _amount_swaps)
        external
    {
        require(_amount_swaps != 0, "amount_swaps must be a positive number");

        uint256 swapExecuted = counterSwapsExecuted[_tokenA][_tokenB].nSwapsExecuted;

        PositionData.UserData memory userPosData = PositionData.UserData({
            tokenIn: _tokenA,
            tokenOut: _tokenB,
            nbSwapsStart: swapExecuted,
            nbSwapsEnd: 0,
            amountIn: _amount_in,
            amountSwaps: _amount_swaps,
            isInsolvent: false,
            owner: _owner
        });

        userPosTracker[_tokenA][_tokenB][indexDeposit] = userPosData;
        indexDeposit += 1;

        emit Deposit(_tokenA, _tokenB, indexDeposit, _owner, _amount_in, _amount_swaps);
    }

    function execute(address _tokenA, address _tokenB) external {
        uint256 oracleValue = getOracleValue(_tokenA, _tokenB);
        uint256 boost = getBoost(oracleValue);
        uint256 swapsExecuted = counterSwapsExecuted[_tokenA][_tokenB].nSwapsExecuted;
        uint256 amountToSwap = 0;

        for (uint256 i = 0; i <= swapsExecuted; i++) {
            PositionData.UserData memory userPosData = userPosTracker[_tokenA][_tokenB][i];
            if (userPosData.isInsolvent) {
                continue;
            }
            //do the verify Insolvent with the boost - nbSwapsEnd

            bool isInsolvent = verifyInsolvability(_tokenA, _tokenB, i, boost);
            if (isInsolvent) {
                continue;
            }

            uint256 baseAmountToSwap = getBaseSwapAmount(userPosData.amountIn, userPosData.amountSwaps);
            amountToSwap += baseAmountToSwap * boost;
        }
        uint256 priceRatio = swap(_tokenA, _tokenB, amountToSwap);

        cumulativePosData[_tokenA][_tokenB][swapsExecuted].cumBoost += boost;
        cumulativePosData[_tokenA][_tokenB][swapsExecuted].cumPrice += priceRatio;
        counterSwapsExecuted[_tokenA][_tokenB].nSwapsExecuted += 1;
    }

    function swap(address _tokenA, address _tokenB, uint256 _amountIn) private pure returns (uint256) {
        //call the swap function of the pool
        uint256 amountTokensOut = 10;

        uint256 priceRatio = amountTokensOut / _amountIn;
        return priceRatio;
    }

    function getBaseSwapAmount(uint256 _amountIn, uint256 _amountSwaps) private pure returns (uint256) {
        return _amountIn / _amountSwaps;
    }

    function getOracleValue(address _tokenA, address _tokenB) private pure returns (uint256) {
        return 78;
    }

    function getBoost(uint256 _oracleVal) private pure returns (uint256) {
        if (_oracleVal > Constants.ThresholdUp) {
            return Constants.BOOST_UP;
        } else if (_oracleVal < Constants.ThresholdDown) {
            return Constants.BOOS_DOWN;
        } else {
            return Constants.NO_BOOST;
        }
    }

    function withdraw(
        address _tokenA,
        address _tokenB,
        address _destinationAddress,
        uint256 _indexDeposit // select the position to withdraw
    ) external {
        PositionData.UserData memory userPosData = userPosTracker[_tokenA][_tokenB][_indexDeposit];
        require(userPosData.owner == msg.sender, "not the owner of this DCA");

        uint256 nbSwapsEnd;
        if (userPosData.nbSwapsEnd != 0) {
            nbSwapsEnd = userPosData.nbSwapsEnd;
        } else {
            nbSwapsEnd = counterSwapsExecuted[_tokenA][_tokenB].nSwapsExecuted;
        }
        uint256 cumulativeBoost = getCumulativeBoost(userPosData.nbSwapsStart, nbSwapsEnd, _tokenA, _tokenB);
        uint256 baseAmountToSwap = getBaseSwapAmount(userPosData.amountIn, userPosData.amountSwaps);

        uint256 numberRemainSwap = userPosData.amountSwaps - cumulativeBoost;
        uint256 amountTokenARemain = numberRemainSwap * baseAmountToSwap;

        uint256 averagePrice = getAveragePrice(userPosData.nbSwapsStart, nbSwapsEnd, _tokenA, _tokenB);

        uint256 amountTokenB = baseAmountToSwap * cumulativeBoost * averagePrice;

        delete userPosTracker[_tokenA][_tokenB][_indexDeposit];

        IERC20(_tokenA).transfer(_destinationAddress, amountTokenARemain);
        IERC20(_tokenB).transfer(_destinationAddress, amountTokenB);
    }

    function getCumulativeBoost(uint256 _nbSwapsStart, uint256 _nbSwapsEnd, address _tokenA, address _tokenB)
        internal
        view
        returns (uint256)
    {
        return cumulativePosData[_tokenA][_tokenB][_nbSwapsEnd].cumBoost
            - cumulativePosData[_tokenA][_tokenB][_nbSwapsStart].cumBoost;
    }

    function getAveragePrice(uint256 _nbSwapsStart, uint256 _nbSwapsEnd, address _tokenA, address _tokenB)
        internal
        view
        returns (uint256)
    {
        uint256 relativePrice;

        for (uint256 i = _nbSwapsStart; i <= _nbSwapsEnd; i++) {
            relativePrice +=
                cumulativePosData[_tokenA][_tokenB][i].cumPrice * cumulativePosData[_tokenA][_tokenB][i].cumBoost;
        }

        uint256 cumulativeBoost = getCumulativeBoost(_nbSwapsStart, _nbSwapsEnd, _tokenA, _tokenB);

        uint256 averagePrice = relativePrice / cumulativeBoost;

        return averagePrice;
    }

    function verifyInsolvability(address _tokenA, address _tokenB, uint256 _indexDeposit, uint256 _boost)
        internal
        returns (bool)
    {
        uint256 currentCounterSwaps = counterSwapsExecuted[_tokenA][_tokenB].nSwapsExecuted - 1;
        uint256 cumulativeBoost = getCumulativeBoost(
            userPosTracker[_tokenA][_tokenB][_indexDeposit].nbSwapsStart, currentCounterSwaps, _tokenA, _tokenB
        );
        uint256 numberRemainSwap = userPosTracker[_tokenA][_tokenB][_indexDeposit].amountSwaps - cumulativeBoost;
        if (_boost > numberRemainSwap) {
            userPosTracker[_tokenA][_tokenB][_indexDeposit].isInsolvent = true;
            userPosTracker[_tokenA][_tokenB][_indexDeposit].nbSwapsEnd = currentCounterSwaps;
            return true;
        }
        return false;
    }
}
