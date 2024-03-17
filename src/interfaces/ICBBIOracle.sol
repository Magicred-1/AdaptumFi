// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICBBIOracle {
    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external returns (bytes32);
    function getCBBIIndex() external view returns (uint256);
}
