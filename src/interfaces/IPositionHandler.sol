pragma solidity ^0.8.17;

interface IPositionHandler {
    event Deposit(
        address tokenA, address tokenB, uint256 positionID, address owner, uint256 amount_in, uint256 amountSwaps
    );

    event Withdraw(address tokenA, address tokenB, uint256 positionID, uint256 amount, address destinationAddress);

    event SwapExecuted(address tokenA, address tokenB, uint256 amountSwapped);

    function deposit(address tokenA, address tokenB, address owner, uint256 amount_in, uint256 amount_swaps) external;

    function withdraw(address tokenA, address tokenB, address destinationAddress, uint256 indexDeposit) external;

    function execute(address tokenA, address tokenB) external;
}
