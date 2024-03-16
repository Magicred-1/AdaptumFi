pragma solidity ^0.8.17;
import {IPositionHandler} from "./interfaces/IPositionHandler.sol";
import {PositionData} from "./lib/PositionData.sol";
import {Constants} from "./lib/Constants.sol";

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract PositionHandkler is IPositionHandler {
    uint256 indexDeposit = 0;
    mapping(address tokenA => mapping(address tokenB => mapping(uint256 positionID => PositionData.UserData userPosData))) userPosTracker;
    mapping(address tokenA => mapping(address tokenB => mapping(uint256 nSwapsExecuted => PositionData.CumData cumData))) cumulativePosData;
    mapping(address tokenA => mapping(address tokenB => PositionData.GlobalData globalData)) counterSwapsExecuted;

    function deposit(
        address tokenA,
        address tokenB,
        address owner,
        uint256 amount_in,
        uint256 amount_swaps
    ) external {
        require(amount_swaps != 0, "amount_swaps must be a positive number");
        uint256 swapExecuted = counterSwapsExecuted[tokenA][tokenB]
            .nSwapsExecuted;
        PositionData.UserData memory userPosData = PositionData.UserData({
            tokenIn: tokenA,
            tokenOut: tokenB,
            nbSwapsStart: swapExecuted,
            nbSwapsEnd: 0,
            amountIn: amount_in,
            amountSwaps: amount_swaps,
            isInsolvent: false,
            owner: owner
        });

        userPosTracker[tokenA][tokenB][indexDeposit] = userPosData;
        indexDeposit += 1;
        emit Deposit(
            tokenA,
            tokenB,
            indexDeposit,
            owner,
            amount_in,
            amount_swaps
        );
    }

    function execute(address tokenA, address tokenB) external {
        uint256 oracleValue = getOracleValue(tokenA, tokenB);
        uint256 boost = getBoost(oracleValue);
        uint256 swapsExecuted = counterSwapsExecuted[tokenA][tokenB]
            .nSwapsExecuted;
        uint256 amountToSwap = 0;

        for (uint256 i = 0; i <= swapsExecuted; i++) {
            PositionData.UserData memory userPosData = userPosTracker[tokenA][
                tokenB
            ][i];
            if (userPosData.isInsolvent) {
                continue;
            }
            //do the verify Insolvent with the boost - nbSwapsEnd

            bool isInsolvent = verifyInsolvability(tokenA, tokenB, i, boost);
            if (isInsolvent) {
                continue;
            }

            uint256 baseAmountToSwap = getBaseSwapAmount(
                userPosData.amountIn,
                userPosData.amountSwaps
            );
            amountToSwap += baseAmountToSwap * boost;
        }
        uint256 priceRatio = swap(tokenA, tokenB, amountToSwap);

        cumulativePosData[tokenA][tokenB][swapsExecuted].cumBoost += boost;
        cumulativePosData[tokenA][tokenB][swapsExecuted].cumPrice += priceRatio;
        counterSwapsExecuted[tokenA][tokenB].nSwapsExecuted += 1;
    }

    function swap(
        address tokenA,
        address tokenB,
        uint256 amountIn
    ) private pure returns (uint256) {
        //call the swap function of the pool
        uint256 amountTokensOut = 10;
        uint256 priceRatio = amountTokensOut / amountIn;
        return priceRatio;
    }

    function getBaseSwapAmount(
        uint256 amountIn,
        uint256 amountSwaps
    ) private pure returns (uint256) {
        return amountIn / amountSwaps;
    }

    function getOracleValue(
        address tokenA,
        address tokenB
    ) private pure returns (uint256) {
        return 78;
    }

    function getBoost(uint256 oracleVal) private pure returns (uint256) {
        if (oracleVal > Constants.ThresholdUp) {
            return Constants.BOOST_UP;
        } else if (oracleVal < Constants.ThresholdDown) {
            return Constants.BOOS_DOWN;
        } else {
            return Constants.NO_BOOST;
        }
    }

    function withdraw(
        address tokenA,
        address tokenB,
        address destinationAddress,
        uint256 indexDeposit // select the position to withdraw
    ) external {
        PositionData.UserData memory userPosData = userPosTracker[tokenA][
            tokenB
        ][indexDeposit];
        require(userPosData.owner == msg.sender, "not the owner of this DCA");

        uint256 nbSwapsEnd;
        if (userPosData.nbSwapsEnd != 0) {
            nbSwapsEnd = userPosData.nbSwapsEnd;
        } else {
            nbSwapsEnd = counterSwapsExecuted[tokenA][tokenB].nSwapsExecuted;
        }
        uint256 cumulativeBoost = getCumulativeBoost(
            userPosData.nbSwapsStart,
            nbSwapsEnd,
            tokenA,
            tokenB
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
            tokenA,
            tokenB
        );

        uint256 amountTokenB = baseAmountToSwap *
            cumulativeBoost *
            averagePrice;

        delete userPosTracker[tokenA][tokenB][indexDeposit];

        IERC20(tokenA).transfer(destinationAddress, amountTokenARemain);
        IERC20(tokenB).transfer(destinationAddress, amountTokenB);
    }

    function getCumulativeBoost(
        uint256 nbSwapsStart,
        uint256 nbSwapsEnd,
        address tokenA,
        address tokenB
    ) internal pure returns (uint256) {
        return
            cumulativePosData[tokenA][tokenB][nbSwapsEnd].cumBoost -
            cumulativePosData[tokenA][tokenB][nbSwapsStart].cumBoost;
    }

    function getAveragePrice(
        uint256 nbSwapsStart,
        uint256 nbSwapsEnd,
        address tokenA,
        address tokenB
    ) internal pure returns (uint256) {
        uint256 relativePrice;

        for (uint256 i = nbSwapsStart; i <= nbSwapsEnd; i++) {
            relativePrice +=
                cumulativePosData[tokenA][tokenB][i].cumPrice *
                cumulativePosData[tokenA][tokenB][i].cumBoost;
        }

        uint256 cumulativeBoost = getCumulativeBoost(
            nbSwapsStart,
            nbSwapsEnd,
            tokenA,
            tokenB
        );

        uint256 averagePrice = relativePrice / cumulativeBoost;

        return averagePrice;
    }

    function verifyInsolvability(
        address tokenA,
        address tokenB,
        uint256 indexDeposit,
        uint256 boost
    ) internal pure returns (bool) {
        uint256 currentCounterSwaps = counterSwapsExecuted[tokenA][tokenB]
            .nSwapsExecuted - 1;
        uint256 cumulativeBoost = getCumulativeBoost(
            userPosTracker[tokenA][tokenB][indexDeposit].nbSwapsStart,
            currentCounterSwaps,
            tokenA,
            tokenB
        );
        uint256 numberRemainSwap = userPosTracker[tokenA][tokenB][indexDeposit]
            .amountSwaps - cumulativeBoost;
        if (boost > numberRemainSwap) {
            userPosTracker[tokenA][tokenB][indexDeposit].isInsolvent = true;
            userPosTracker[tokenA][tokenB][indexDeposit]
                .nbSwapsEnd = currentCounterSwaps;
            return true;
        }
        return false;
    }
}
