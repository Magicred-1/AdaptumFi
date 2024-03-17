// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {HypERC20Collateral} from "lib/hyperlane-monorepo/solidity/contracts/token/HypERC20Collateral.sol";
import {IERC20} from "lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {IMailbox} from "lib/hyperlane-monorepo/solidity/contracts/interfaces/IMailbox.sol";

contract CallbackPoint {

    IMailbox mailBox;
    address dcaHub;

    constructor(address _mailbox, address _dcaHub) {
        mailBox = IMailbox(_mailbox);
        dcaHub = _dcaHub;
    }

    function handle(
        uint32 _origin, bytes32 _sender,
        bytes calldata _message) external payable {
        require(msg.sender == address(mailBox), "Not the MailBox");
    }
}