// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HypERC20Collateral} from "lib/hyperlane-monorepo/solidity/contracts/token/HypERC20Collateral.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IMailbox} from "lib/hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";

contract ExitPoint {

    HypERC20Collateral hype20Collat;
    IMailbox mailBox;
    uint32 destinationChain;

    constructor(address _mailbox, address _hype20Collat, uint32 _destinationChain) {
        hype20Collat = HypERC20Collateral(payable(_hype20Collat));
        mailBox = IMailbox(_mailbox);
        destinationChain = _destinationChain;
    }

    function sendBackTokens(address _token, uint256 amount, address _target, bytes calldata data) external payable {
        IERC20 token = IERC20(_token);
        token.transferFrom(msg.sender, address(this), amount);
        /* message */
        bytes32 recipientAddress = bytes32(uint256(uint160(_target)) << 96);
        mailBox.dispatch(destinationChain, recipientAddress, data);
        /* warp route */
        hype20Collat.transferRemote(
            destinationChain,
            recipientAddress,
            amount);
    }

}