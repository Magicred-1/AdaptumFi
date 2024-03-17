import { baseSepolia } from "viem/chains";

export const baseSepoliaTokens = {
  [baseSepolia.id]: [
    {
      symbol: "USDC",
      name: "USD Coin",
      decimals: 6,
      address: "0x036CbD53842c5426634e7929541eC2318f3dCF7e",
      isStableCoins: true,
    },
    {
      symbol: "WETH",
      name: "Wrapped Ether",
      decimals: 18,
      address: "0x4200000000000000000000000000000000000006",
      isStableCoins: false,
    },
  ],
};
