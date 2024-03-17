export const abiDCA = [
  {
    inputs: [
      { internalType: "address", name: "_oracleAddress", type: "address" },
      {
        internalType: "address",
        name: "_nftPositionFactoryAddress",
        type: "address",
      },
    ],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [
      { internalType: "address", name: "_tokenA", type: "address" },
      { internalType: "address", name: "_tokenB", type: "address" },
      { internalType: "address", name: "_owner", type: "address" },
      { internalType: "uint256", name: "_amount_in", type: "uint256" },
    ],
    name: "ZeroSwapAmountError",
    type: "error",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "tokenA",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "tokenB",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "positionID",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "owner",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amount_in",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amountSwaps",
        type: "uint256",
      },
    ],
    name: "Deposit",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "tokenA",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "tokenB",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amountSwapped",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "exchangeRate",
        type: "uint256",
      },
    ],
    name: "SwapExecuted",
    type: "event",
  },
  {
    anonymous: false,
    inputs: [
      {
        indexed: false,
        internalType: "address",
        name: "tokenA",
        type: "address",
      },
      {
        indexed: false,
        internalType: "address",
        name: "tokenB",
        type: "address",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "positionID",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amountTokenARemaining",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "uint256",
        name: "amountTokenB",
        type: "uint256",
      },
      {
        indexed: false,
        internalType: "address",
        name: "destinationAddress",
        type: "address",
      },
    ],
    name: "Withdraw",
    type: "event",
  },
  {
    inputs: [
      { internalType: "address", name: "_tokenA", type: "address" },
      { internalType: "address", name: "_tokenB", type: "address" },
      { internalType: "address", name: "_owner", type: "address" },
      { internalType: "uint256", name: "_amount_in", type: "uint256" },
      { internalType: "uint256", name: "_amount_swaps", type: "uint256" },
    ],
    name: "deposit",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "_tokenA", type: "address" },
      { internalType: "address", name: "_tokenB", type: "address" },
    ],
    name: "execute",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [
      { internalType: "address", name: "_tokenA", type: "address" },
      { internalType: "address", name: "_tokenB", type: "address" },
      { internalType: "address", name: "_destinationAddress", type: "address" },
      { internalType: "uint256", name: "_indexDeposit", type: "uint256" },
    ],
    name: "withdraw",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];
