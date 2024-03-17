// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console2} from "forge-std/Script.sol";
import "forge-std/Test.sol";
import {EntryPoint} from "src/Entry.sol";
import {ExitPoint} from "src/Exit.sol";
import {NFTDCAPosition} from "src/NFTPosition.sol";
import {PositionHandler} from "src/PositionHandler.sol";
import {CBBIOracle} from "src/Oracle.sol";

contract BaseDeployer is Script {
    uint256 DEPLOYER_KEY;
    uint256[] chainIds = [8453, 42161];
    mapping(uint256 => string) chainIdToRPC;
    mapping(uint256 => address) chainIdToMailbox;
    mapping(uint256 => address) chainIdToEntry;
    mapping(uint256 => address) chainIdToExit;
    mapping(uint256 => address) chainIdToDcaHub;
    mapping(uint256 => uint256) chainIdToFork;
    mapping(uint256 => address) chainIdToOracle;
    mapping(uint256 => address) chainIdToChainlinkRouter;
    mapping(uint256 => address) chainIdToWarpRoute;
    mapping(uint256 => address) chainIdToSwapRouter;

    function setupFillData() public {
        DEPLOYER_KEY = vm.envUint("DEPLOYER_KEY");

        chainIdToRPC[42161] = "https://arbitrum.llamarpc.com";
        chainIdToMailbox[42161] = 0x979Ca5202784112f4738403dBec5D0F3B9daabB9;
        chainIdToChainlinkRouter[42161] = 0x141fa059441E0ca23ce184B6A78bafD2A517DdE8;
        chainIdToSwapRouter[42161] = 0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb;
        chainIdToRPC[8453] = "https://base.llamarpc.com";
        chainIdToMailbox[8453] = 0xeA87ae93Fa0019a82A727bfd3eBd1cFCa8f64f1D;
        chainIdToChainlinkRouter[8453] = 0x881e3A65B4d4a04dD529061dd0071cf975F58bCD;
        chainIdToSwapRouter[8453] = 0x8cFe327CEc66d1C090Dd72bd0FF11d690C33a2Eb;
    }

    function setUp() public {setupFillData();
    }

    function run() public {

        for (uint i; i < chainIds.length; i++){
            uint256 chainId = chainIds[i];
            chainIdToFork[chainId] = vm.createSelectFork(chainIdToRPC[chainId]);
            console.log("start broadcasting");
            vm.startBroadcast(DEPLOYER_KEY);
            console.log("deploying");
            chainIdToEntry[chainId] = address(new EntryPoint(chainIdToChainlinkRouter[chainId],
            chainIdToSwapRouter[chainId]));
            chainIdToOracle[chainId] = address(new CBBIOracle());
            vm.stopBroadcast();
        }
        
        vm.selectFork(chainIdToFork[42161]);
        vm.startBroadcast(DEPLOYER_KEY);
        chainIdToDcaHub[42161] = address(new PositionHandler(chainIdToOracle[42161], 
        chainIdToChainlinkRouter[42161],
        chainIdToMailbox[42161],
        address(chainIdToEntry[8453]), 8453));
        chainIdToExit[42161] = address(new ExitPoint(chainIdToMailbox[42161], chainIdToDcaHub[42161], chainIdToWarpRoute[42161], 8453));
        vm.stopBroadcast();

        vm.selectFork(chainIdToFork[8453]);
        vm.startBroadcast(DEPLOYER_KEY);
        chainIdToDcaHub[8453] = address(new PositionHandler(chainIdToOracle[8453], 
        chainIdToChainlinkRouter[8453],
        chainIdToMailbox[8453],
        address(chainIdToEntry[42161]), 42161));
        chainIdToExit[42161] = address(new ExitPoint(chainIdToMailbox[8453], chainIdToDcaHub[8453], chainIdToWarpRoute[8453], 42161));
        vm.stopBroadcast();

        for (uint i; i < chainIds.length; i++){
            uint256 chainId = chainIds[i];
            console.log("chainId:", chainId);
            console.log(chainIdToDcaHub[chainId]);
        }
    } 
}
