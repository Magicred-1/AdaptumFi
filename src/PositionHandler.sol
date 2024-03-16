
pragma solidity 0.8.17^;
import {IPositionHandler} from "./interfaces/IPositionHandler.sol";
import {PositionData} from "./lib/PositionData.sol";
import {Constants} from "./lib/Constants.sol";

contract PositionHandkler is IPositionHandler{


    uint235 indexDeposit = 0;
    mapping(address tokenA => mapping (address tokenB => mapping(uint256 positionID => PositionData.UserData userPosData))) userPosTracker;
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
        uint256 swapExecuted = counterSwapsExecuted[tokenA][tokenB].nSwapsExecuted;
        PositionData.UserData memory userPosData = PositionData.UserData({
        tokenIn: tokenA,
        tokenOut: tokenB,
        nbSwapsStart: swapExecuted,
        nbSwapsEnd: 0,
        amountIn: amount_in,
        amountSwaps: amount_swaps,
        isInsolvent: false,
        owner : owner
    });

    userPosTracker[tokenA][tokenB][indexDeposit] = userPosData;
    indexDeposit += 1;
    emit Deposit(tokenA, tokenB,indexDeposit, owner, amount_in);

    }

    
    function execute(
        address tokenA,
        address tokenB
    ) external {
        uint256 oracleValue = 78; 
        uint256 boost = getBoost(oracleValue);
        uint256 swapsExecuted = counterSwapsExecuted[tokenA][tokenB].nSwapsExecuted;
        uint256 amountToSwap = 0;
        
        for (uint256 i = 0; i <= swapsExecuted; i++) {
        PositionData.UserData userPosData = userPosTracker[tokenA][tokenB][i];
        if(userPosData.isInsolvent){
            continue;
        }
        //do the verify Insolvent with the boost - nbSwapsEnd

        uint256 baseAmountToSwap = getBaseSwapAmount(userPosData.amountIn,userPosData.amountSwaps);
        amountToSwap += baseAmountToSwap*boost;
    }
        uint256 priceRatio = swap(tokenA, tokenB, amountToSwap);

        cumulativePosData[tokenA][tokenB][swapsExecuted].cumBoost += boost;
        cumulativePosData[tokenA][tokenB][swapsExecuted].cumPrice += priceRatio;
        counterSwapsExecuted[tokenA][tokenB].nSwapsExecuted +=1;
    }

    function swap(address tokenA, address tokenB, uint256 amountIn) private pure returns(uint256 priceRatio) {
        //call the swap function of the pool
        uint256 amountTokensOut = 10 ; 
        uint256 priceRatio = amountTokensOut / amountIn;
    }

    function getBaseSwapAmount(uint256 amountIn, uint256 amountSwaps) private pure returns(uint256) {
        return amountIn/amountSwaps;
    }

    function getBoost(uint256 oracleVal) private pure returns (uint256) {
    if (oracleVal > Constants.ThresholdUp) {
        return Constants.BOOST_UP;
    } else if (oracleVal < Constants.ThresholdDown) {
        return Constants.BOOST_DOWN;
    } else {
        return Constants.NO_BOOST;
    }
    }   

    function withdraw(
        uint256 positionID,
        address destinationAddress,
        uint256 indexDeposit, // select the position to withdraw 
    ) external {
        PositionData.UserData userPosData = userPosTracker[tokenA][tokenB][indexDeposit];
        require(userPosData.owner === msg.sender, "not the owner of this DCA");
        
        uint256 nbSwapsEnd;
        if(userPosData.nbSwapsEnd != 0 ){
            nbSwapsEnd = userPosData.nbSwapsEnd 
        } else {
            nbSwapsEnd = counterSwapsExecuted[tokenA][tokenB].nSwapsExecuted
        }
        uint256 cumulativeBoost  = getCumulativeBoost(userPosData.nbSwapsStart ,nbSwapsEnd);
        uint256 baseAmountToSwap = getBaseSwapAmount(userPosData.amountIn,userPosData.amountSwaps);


        uint256 numberRemainSwap =  userPosData.amountSwaps - cumulativeBoost;
        uint256 amountTokenARemain = numberRemainSwap * baseAmountToSwap;

        //save left here
        
    }
    
    function getCumulativeBoost(uint256 nbSwapsStart,uint256 nbSwapsEnd) internal pure  returns(uint256 cumulativeBoost) {
            uint256 cumulativeBoost = cumulativePosData[tokenA][tokenB][nbSwapsEnd].cumBoost - cumulativePosData[tokenA][tokenB][nbSwapsStart].cumBoost
    }



   

}
