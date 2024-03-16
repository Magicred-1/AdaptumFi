
pragma solidity 0.8.17^;
import {IPositionHandler} from "./interfaces/IPositionHandler.sol";
import {PositionData} from "./lib/PositionData.sol";


contract PositionHandkler is IPositionHandler{


    mapping(address tokenA => mapping (address tokenB => mapping(uint256 positionID => PositionData.UserData userPosData))) userPosTracker;
    mapping(address tokenA => mapping(address tokenB => mapping(uint256 nSwapExecuted => PositionData.CumData))) cumulativePosData;

    function deposit(
        address tokenA,
        address tokenB,
        address owner,
        uint256 amount_in
    ) external;

    function withdraw(
        uint256 positionID,
        address destinationAddress
    ) external;

    function execute(
        address tokenA,
        address tokenB
    ) external;

    
}
