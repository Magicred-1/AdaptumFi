export const copyToClipboard = async (text?: string): Promise<void> => {
  try {
    if (text) {
      return navigator.clipboard.writeText(text);
    }
  } catch (error) {
    throw new Error("Error while copying address");
  }
};

export const displayDecimalNumber = (
  weiBalanceBigInt: bigint,
  decimals: number
) => {
  let weiBalanceStr = weiBalanceBigInt.toString();
  weiBalanceStr = weiBalanceStr.padStart(decimals + 1, "0");

  const position = weiBalanceStr.length - decimals;
  const etherStr = `${weiBalanceStr.substring(
    0,
    position
  )}.${weiBalanceStr.substring(position)}`;

  const trimmedEtherStr = etherStr.replace(/\.?0+$/, "");

  return trimmedEtherStr;
};

export const stringToBigIntWithDecimals = (
  amountStr: string,
  decimalPlaces: number
) => {
  const dotIndex = amountStr.indexOf(".");
  let integralPart = amountStr;
  let fractionalPart = "";

  if (dotIndex !== -1) {
    integralPart = amountStr.substring(0, dotIndex);
    fractionalPart = amountStr.substring(dotIndex + 1);
  }

  if (fractionalPart.length > decimalPlaces) {
    fractionalPart = fractionalPart.substring(0, decimalPlaces);
  } else {
    fractionalPart = fractionalPart.padEnd(decimalPlaces, "0");
  }

  const combined = integralPart + fractionalPart;

  return BigInt(combined);
};
