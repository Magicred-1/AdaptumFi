pragma solidity ^0.8.19;

library PositionData {
    struct UserData {
        address tokenIn;
        address tokenOut;
        uint256 nbSwapsStart;
        uint256 nbSwapsEnd;
        uint256 amountIn;
        uint256 amountSwaps;
        bool isInsolvent;
        address owner;
    }

    struct CumData {
        uint256 cumBoost;
        uint256 cumPrice;
    }

    struct GlobalData {
        uint256 nSwapsExecuted;
    }
}
