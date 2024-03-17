import { sepolia } from "viem/chains";

export const sepoliaTokens = {
  [sepolia.id]: [
    {
      symbol: "USDC",
      name: "USD Coin",
      decimals: 6,
      address: "0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238",
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
