import { AllTokens } from "../types/global.type";
import { arbitrumTokens } from "./networkTokens/arbitrumTokens";
import { baseSepoliaTokens } from "./networkTokens/baseSepoliaTokens";
import { sepoliaTokens } from "./networkTokens/ethereumSepolia";

export const allTokens: AllTokens = {
  ...arbitrumTokens,
  ...sepoliaTokens,
  ...arbitrumTokens,
  ...baseSepoliaTokens,
};
