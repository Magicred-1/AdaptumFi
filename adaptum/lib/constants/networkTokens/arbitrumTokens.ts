import { arbitrum } from "viem/chains";

export const arbitrumTokens = {
  [arbitrum.id]: [
    {
      symbol: "USDC",
      name: "USD Coin",
      decimals: 6,
      address: "0xaf88d065e77c8cC2239327C5EDb3A432268e5831",
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
