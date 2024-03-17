// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import {EntryPoint} from "src/Entry.sol";
import {ExitPoint} from "src/Exit.sol";

contract BaseDeployer is Script {
    uint256 DEPLOYER_KEY = vm.envUint("DEPLOYER_KEY");
    mapping(uint256 => string) chainIdToRPC;
    mapping(uint256 => address) chainIdToMailbox;
    mapping(uint256 => EntryPoint) chainIdToEntry;
    mapping(uint256 => ExitPoint) chainIdToExit;
    mapping(uint256 => DcaHub) chainIdToDcaHub;
    mapping(uint256 => uint256) chainIdToFork;

    modifier broadcast(uint256 pk) {
        vm.startBroadcast(pk);

        _;

        vm.stopBroadcast();
    }

    constructor() {
        setupFillData();
    }

    function setupFillData() public {
        chainIdToRPC[42161] = "https://arbitrum.llamarpc.com";
        chainIdToMailbox[42161] = 0x979Ca5202784112f4738403dBec5D0F3B9daabB9;
        chainIdToRPC[42161] = "https://base.llamarpc.com";
        chainIdToMailbox[42161] = 0xeA87ae93Fa0019a82A727bfd3eBd1cFCa8f64f1D;
    }

    function setUp() public {}

    function run() public {
        chainIdToFork[42161] = vm.createSelectFork(chainIdToRPC[42161]);
        console.log("start broadcasting");
        vm.startBroadcast(DEPLOYER_KEY);
        console.log("deploying");
        //TODO
        console.log(address(chainIdToEscrow[chainId]));
        vm.stopBroadcast();
    }
}
