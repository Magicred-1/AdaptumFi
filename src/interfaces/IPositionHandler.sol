pragma solidity ^0.8.17;

interface IPositionHandler {
    /* -------------------- EVENTS -------------------------*/
    event Deposit(
        address tokenA,
        address tokenB,
        uint256 positionID,
        address owner,
        uint256 amount_in,
        uint256 amountSwaps
    );
    event Withdraw(
        address tokenA,
        address tokenB,
        uint256 positionID,
        uint256 amountTokenARemaining,
        uint256 amountTokenB,
        address destinationAddress
    );

    event SwapExecuted(
        address tokenA,
        address tokenB,
        uint256 amountSwapped,
        uint256 exchangeRate
    );

    /* -------------------- ERRORS -------------------------*/

    error ZeroSwapAmountError(
        address _tokenA,
        address _tokenB,
        address _owner,
        uint256 _amount_in
    );

    /* -------------------- EXTERNAL FNS -------------------------*/

    function deposit(
        address _tokenA,
        address _tokenB,
        address _owner,
        uint256 _amount_in,
        uint256 _amount_swaps
    ) external;

    function withdraw(
        address _tokenA,
        address _tokenB,
        address _destinationAddress,
        uint256 _indexDeposit
    ) external;

    function execute(address _tokenA, address _tokenB) external;
}
