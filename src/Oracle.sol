// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {FunctionsClient} from "chainlink/src/v0.8/functions/v1_0_0/FunctionsClient.sol";
import {ConfirmedOwner} from "chainlink/src/v0.8/shared/access/ConfirmedOwner.sol";
import {FunctionsRequest} from "chainlink/src/v0.8/functions/v1_0_0/libraries/FunctionsRequest.sol";
import {ICBBIOracle} from "./interfaces/ICBBIOracle.sol";

/**
 * Request testnet LINK and ETH here: https://faucets.chain.link/
 * Find information on LINK Token Contracts and get the latest ETH and LINK faucets here: https://docs.chain.link/resources/link-token-contracts/
 */

/**
 * @title GettingStartedFunctionsConsumer
 * @notice This is an example contract to show how to make HTTP requests using Chainlink
 * @dev This contract uses hardcoded values and should not be used in production.
 */

contract CBBIOracle is FunctionsClient, ConfirmedOwner, ICBBIOracle {
    using FunctionsRequest for FunctionsRequest.Request;

    // State variables to store the last request ID, response, and error
    bytes32 public s_lastRequestId;
    bytes public s_lastResponse;
    bytes public s_lastError;

    // Custom error type
    error UnexpectedRequestID(bytes32 requestId);

    // Event to log responses
    event Response(
        bytes32 indexed requestId,
        string cbbiIndex,
        bytes response,
        bytes err
    );

    // Router address - Hardcoded for Sepolia
    // Check to get the router address for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    address router = 0x97083E831F8F0638855e2A515c90EdCF158DF238;

    // JavaScript source code
    // Fetch character name from the CBBI Index
    // Documentation: https://colintalkscrypto.com/cbbi/data/latest.json
    string source =
        "const characterId = args[0];"
        "const apiResponse = await Functions.makeHttpRequest({"
        "url: https://colintalkscrypto.com/cbbi/data/latest.json"
        "});"
        "const { data } = apiResponse;"
        "const timestamps = Object.keys(data.RUPL);"
        "const latestTimestamp = Math.max(...timestamps);"
        "const lastPrice = data.Confidence[latestTimestamp];"
        "console.log('Last Price:', lastPrice);"
        "const priceWithoutDecimal = Math.floor(lastPrice * 100);"
        "console.log('Price without decimal:', priceWithoutDecimal);"
        "return Functions.encodeUint256(priceWithoutDecimal);";

    //Callback gas limit
    uint32 gasLimit = 300000;

    // donID - Hardcoded for Sepolia
    // Check to get the donID for your supported network https://docs.chain.link/chainlink-functions/supported-networks
    bytes32 donID =
        0x66756e2d617262697472756d2d6d61696e6e65742d3100000000000000000000;

    // State variable to store the returned character information
    uint256 public cbbiIndex;

    /**
     * @notice Initializes the contract with the Chainlink router address and sets the contract owner
     */
    constructor() FunctionsClient(router) ConfirmedOwner(msg.sender) {}

    /**
     * @notice Sends an HTTP request for cbbiIndex information
     * @param subscriptionId The ID for the Chainlink subscription
     * @param args The arguments to pass to the HTTP request
     * @return requestId The ID of the request
     */
    function sendRequest(
        uint64 subscriptionId,
        string[] calldata args
    ) external onlyOwner returns (bytes32 requestId) {
        FunctionsRequest.Request memory req;
        req.initializeRequestForInlineJavaScript(source); // Initialize the request with JS code
        if (args.length > 0) req.setArgs(args); // Set the arguments for the request

        // Send the request and store the request ID
        s_lastRequestId = _sendRequest(
            req.encodeCBOR(),
            subscriptionId,
            gasLimit,
            donID
        );

        return s_lastRequestId;
    }

    /**
     * @notice Callback function for fulfilling a request
     * @param requestId The ID of the request to fulfill
     * @param response The HTTP response data
     * @param err Any errors from the Functions request
     */
    function fulfillRequest(
        bytes32 requestId,
        bytes memory response,
        bytes memory err
    ) internal override {
        if (s_lastRequestId != requestId) {
            revert UnexpectedRequestID(requestId); // Check if request IDs match
        }
        // Update the contract's state variables with the response and any errors
        s_lastResponse = response;
        cbbiIndex = abi.decode(response, (uint256));
        s_lastError = err;

        emit Response(requestId, "", s_lastResponse, s_lastError);
    }

    /**
     * @notice Getter function to retrieve the CBBI index
     * @return The CBBI index value
     */
    function getCBBIIndex() public view returns (uint256) {
        return cbbiIndex;
    }
}
