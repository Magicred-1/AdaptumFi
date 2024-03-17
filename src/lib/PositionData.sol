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
        uint256 cumBoost; // boost[0] + ... + boost[N]
        uint256 cumBoostedPrice; // price[0] * boost[0] + .. + price[N] * boost[N]
        uint256 cumWeightedPrice; // (price[0] * boost[0] + .. + price[N] * boost[N]) / (boost[0] + ... + boost[N])
        // amount_out = amount_in * avgPrice[(start, end)]

        //
    }

    struct GlobalData {
        uint256 nSwapsExecuted;
    }
}
