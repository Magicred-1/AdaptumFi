// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

interface ICBBIOracle {
    function getCBBIIndex() external view returns (uint256);
}
