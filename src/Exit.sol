// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HypERC20Collateral} from "lib/hyperlane-monorepo/solidity/contracts/token/HypERC20Collateral.sol";

contract ExitPoint {

    HypERC20Collateral hype20Collat;

    constructor(address _hype20Collat) {
        hype20Collat = HypERC20Collateral(payable(_hype20Collat));
    }

    function sendBackTokens(address _token, uint256 amount, bytes calldata data){
        IERC20 token = IERC20(_token);
        token.transferFrom(msg.sender, amount);
        /* TODO: Wrap route + message */
        
    }

}