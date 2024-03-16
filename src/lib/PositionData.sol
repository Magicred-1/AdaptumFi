pragma solidity 0.8.19^;

library PositionData {

    struct UserData {
        address tokenIn;
        address tokenOut;
        uint256 startTime;
        uint256 endTime;
        uint256 amountIn;
        bool isInsolvent; 
        }
    
    struct CumData { 
        uint256 cumBoost;
        uint256 cumPrice;
    }

    struct GlobalData {
        uint256 nSwapsExecuted;
    }
}
