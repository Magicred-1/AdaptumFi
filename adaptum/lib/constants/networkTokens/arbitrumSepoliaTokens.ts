import { arbitrumSepolia } from "viem/chains";

export const arbitrumSepoliaTokens = {
  [arbitrumSepolia.id]: [
    {
      symbol: "USDC",
      name: "USD Coin",
      decimals: 6,
      address: "0x75faf114eafb1BDbe2F0316DF893fd58CE46AA4d",
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
