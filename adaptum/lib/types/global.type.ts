export type Token = {
  symbol: string;
  name: string;
  decimals: number;
  address: string;
  isStableCoins: boolean;
};
export type AllTokens = {
  [chain: string]: Token[];
};
