'use client'
import React, { useEffect, useMemo, useState } from 'react'
import InvestChart from '@/src/_components/charts/invest-chart';
import ComparisonChart from '@/src/_components/charts/comparison-chart';
import { useAccount, useChainId, useReadContracts, useSwitchChain, useWaitForTransactionReceipt, useWriteContract } from 'wagmi';
import { allTokens } from '@/lib/constants/tokens.constants';
import { erc20Abi, zeroAddress } from 'viem';
import { displayDecimalNumber, stringToBigIntWithDecimals } from '@/lib/helpers/global.helper';
import { useDynamicContext } from '@dynamic-labs/sdk-react-core';
import { addressDCA } from '@/lib/constants/global.constant';
import { abiDCA } from '@/lib/constants/abis/abidca';
import useProcessTxState from '@/lib/stores/processTxStateStore';

export default function Invest() {
  const { address ,chainId} = useAccount();
  const { walletConnector } = useDynamicContext();
  const usdcAddress = useMemo(()=>{
    return chainId && allTokens[chainId.toString()] ? allTokens[chainId.toString()][0].address as `0x${string}` : undefined
  },[chainId])
  const {  removePendingTx, addPendingTx } =
		useProcessTxState();

  const [amount, setAmount] = useState('');

  const erc20Contract = {
		address: usdcAddress ,
		abi: erc20Abi,
	} as const;

  const {
		data: balanceUSDC,
		isSuccess: isSuccessBalanceWallet,
		error,
	} = useReadContracts({
		allowFailure: false,
		contracts: [
			{
        ...erc20Contract,
				functionName: "balanceOf",
				args: [`${address || zeroAddress}`]
			},
      {
				...erc20Contract,
				functionName: "decimals",
			},
      {
        ...erc20Contract,
        functionName: "allowance",
        args: [`${address || zeroAddress}`, addressDCA],
      },
		],
		query: {
			refetchInterval: 5000,
		},
	});

  const balanceUSDCWallet = useMemo(() => {
		if (isSuccessBalanceWallet) {
			const balance = Number(
				displayDecimalNumber(balanceUSDC?.[0], balanceUSDC?.[1]),
			);
			return balance.toFixed(2);
		}
		return "0";
	}, [isSuccessBalanceWallet, balanceUSDC,address]);

  const amountTokenBigInt = useMemo(() => {
		return stringToBigIntWithDecimals(
			amount,
			balanceUSDC?.[1] as number,
		);
	}, [amount, balanceUSDC]);

  
 
  const isApproveNeeded = useMemo(() => {
		if (isSuccessBalanceWallet) {
			return amountTokenBigInt > balanceUSDC?.[2];
		}
	}, [isSuccessBalanceWallet, amountTokenBigInt, balanceUSDC?.[2]]);


  console.log(balanceUSDC?.[2])

  const {
		data: hash,
		isPending,
		writeContract,
	} = useWriteContract({
		mutation: {
			onSuccess() {
        addPendingTx();
			},
      onError(data) {
        console.log(data)
      }
		},
	});

  const { isLoading: isConfirming, isSuccess: isConfirmed } =
		useWaitForTransactionReceipt({
			hash,
		});

  
  useEffect(() => {
    console.log(isConfirmed,isConfirming)
		if (isConfirmed) removePendingTx();
	}, [isConfirming,isConfirmed, removePendingTx]);

  const [sellCurrency, setSellCurrency] = useState('USDC');
  const [receiveCurrency, setReceiveCurrency] = useState('ETH');  
  const [interval, setInterval] = useState('');
  const [indicator, setIndicator] = useState('');
  const [hyperplaneOption, setHyperplaneOption] = useState('');

  const handleMaxClick = () => {
    setAmount(balanceUSDCWallet);
  };

  const handleHalfClick = () => {
    setAmount((Number(balanceUSDCWallet) / 2).toString());
  };



  return (
    <div className="bg-gray-800 min-h-screen flex flex-col md:flex-row p-4 md:p-8">
      <div className="flex flex-col w-full md:w-1/3 md:mr-8">
        {/* Network Selector */}
        <div className="mb-4 bg-gray-900 rounded-xl p-2">
          <label className="block text-gray-400 mb-2">Choose network :</label>
          <select className="w-full bg-gray-700 text-white p-3 rounded-lg focus:outline-none" value={chainId?.toString()} onChange={async(e) => {
            console.log(walletConnector?.supportsNetworkSwitching())
            if (walletConnector?.supportsNetworkSwitching()) {
              await walletConnector.switchNetwork({ networkChainId : e.target.value });
            }
          }}>
            <option value="">Select Network</option>
            <option value="11155111" >Sepolia</option>
            <option value="42161">Arbitrum One</option>
            <option value="421614">Arbitrum Sepolia</option>
            <option value="84532">Base Sepolia</option>
          </select>
        </div>

        {/* Currency Selectors */}
        <div className="flex justify-between mb-4 bg-gray-900 rounded-xl p-2">
          <div className="w-1/2 mr-2">
            <label className="block text-gray-400 mb-2">Sell</label>
            <select className="w-full bg-gray-700 text-white p-3 rounded-lg focus:outline-none" value={sellCurrency} onChange={(e) => setSellCurrency(e.target.value)}>
              <option value="">Select Currency</option>
              <option value="USDC">USDC</option>
              {/* More options here */}
            </select>
          </div>
          <div className="w-1/2 ml-2">
            <label className="block text-gray-400 mb-2">Receive</label>
            <select className="w-full bg-gray-700 text-white p-3 rounded-lg focus:outline-none" value={receiveCurrency} onChange={(e) => setReceiveCurrency(e.target.value)}>
              <option value="">Select Currency</option>
              <option value="ETH">ETH</option>
              {/* More options here */}
            </select>
          </div>
        </div>

        {/* Amount Input */}
        <div className="mb-4 bg-gray-900 rounded-xl p-2">
          <label className="block text-gray-400 mb-2">Amount of USDC to invest</label>
          <div className="flex">
            <input type="number" placeholder="0$" className="w-full bg-gray-700 text-white p-3 rounded-l-lg focus:outline-none" value={amount} onChange={(e) => setAmount(e.target.value)} />
            <button className="bg-gray-600 text-white px-4 rounded-r-lg" onClick={handleMaxClick}>Max</button>
            <button className="bg-gray-600 text-white px-4 rounded-lg" onClick={handleHalfClick}>Half</button>
          </div>
          <div className="text-gray-400 mt-2">Available: {balanceUSDCWallet} USDC</div>
        </div>

        {/* Intervals */}
        <div className="mb-4 bg-gray-900 rounded-xl p-2">
          <label className="block text-gray-400 mb-2">Intervals</label>
          <div className="flex space-x-2">
            <button className={` text-white px-4 py-2 rounded-lg hover:bg-blue-600 ${interval === "Daily" ? "bg-blue-600 " : "bg-gray-600"}`} onClick={() => setInterval('Daily')}>Daily</button>
            <button className={` text-white px-4 py-2 rounded-lg hover:bg-blue-600 ${interval === "Weekly" ? "bg-blue-600 " : "bg-gray-600"}`} onClick={() => setInterval('Weekly')}>Weekly</button>
            <button className={` text-white px-4 py-2 rounded-lg hover:bg-blue-600 ${interval === "7" ? "bg-blue-600 " : "bg-gray-600"}`} onClick={() => setInterval('7')}>7</button>
            <button className={` text-white px-4 py-2 rounded-lg hover:bg-blue-600 ${interval === "15" ? "bg-blue-600 " : "bg-gray-600"}`} onClick={() => setInterval('15')}>15</button>
            <button className={` text-white px-4 py-2 rounded-lg hover:bg-blue-600 ${interval === "30" ? "bg-blue-600 " : "bg-gray-600"}`} onClick={() => setInterval('30')}>30</button>
          </div>
        </div>

        {/* Indicator Selector */}
        <div className="mb-4 bg-gray-900 rounded-xl p-2">
          <label className="block text-gray-400 mb-2">Choose an indicator</label>
          <div className="flex space-x-2">
            <button className={` text-white px-4 py-2 rounded-lg  hover:bg-blue-600 ${indicator === 'CBBI Index' ? "bg-blue-600" : "bg-gray-600" }`} onClick={() => setIndicator('CBBI Index')}>CBBI Index</button>
            <button className={` text-white px-4 py-2 rounded-lg  hover:bg-blue-600 ${indicator === 'None' ? "bg-blue-600" : "bg-gray-600" }`} onClick={() => {
              setIndicator('None')}}>None</button>
          </div>
        </div>

        {/* Network Info and Actions */}
        <div className='bg-gray-900 rounded-xl p-2'>
          <label className="block text-gray-400 mb-2">Use Hyperplane to get the tokens from another chain</label>
          <div className="flex space-x-2 mb-4">
            <button className={` text-white px-4 py-2 rounded-lg  hover:bg-blue-600 ${hyperplaneOption === 'Arbitrum Sepolia' ? "bg-blue-600" : "bg-gray-600" }`} onClick={() => setHyperplaneOption('Arbitrum Sepolia')}>Arbitrum Sepolia</button>
            <button className={` text-white px-4 py-2 rounded-lg  hover:bg-blue-600 ${hyperplaneOption === 'Base Sepolia' ? "bg-blue-600" : "bg-gray-600" }`} onClick={() => setHyperplaneOption('Base Sepolia')}>Base Sepolia</button>
          </div>
        </div>
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg w-full mt-4" onClick={() => {
            
            isApproveNeeded
            ? writeContract({
                address: usdcAddress as any ,
                abi: erc20Abi,
                functionName: "approve",
                args: [addressDCA, amountTokenBigInt], 
              }) : writeContract({
                address: addressDCA as any ,
                abi: abiDCA,
                functionName: "deposit",
                args: ["0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238", "0xb16F35c0Ae2912430DAc15764477E179D9B9EbEa" , "0x3C0067736ee2694d312A44deD0D83Ba6a53cFA83" , 1000 ,10 ], 
              });
            
          }}>{ isApproveNeeded ? "Approve": "Deposit" }</button>
      </div>

      <div className="flex flex-col w-full md:w-2/3 mt-8 md:mt-0">
        {/* Trading View Placeholder */}
        <div className="bg-gray-700 p-4 rounded-lg flex-1 mb-4">
          <div className="text-white">
            {/* Placeholder for TradingView Widget */}
            <div className="flex justify-between mb-4">
              <h2>{sellCurrency} / {receiveCurrency}</h2>
              <div>
                <span className="bg-blue-600 px-2 py-1 rounded-lg mr-2">2778.7 +4.5</span>
                <span className="bg-blue-600 px-2 py-1 rounded-lg">2783.2</span>
              </div>
            </div>
            <div className="h-96 bg-gray-800 rounded-lg flex items-center justify-center">
              {/* <span className="text-gray-400">TradingView Widget Placeholder</span> */}
              <InvestChart />
            </div>
          </div>
        </div>

        {/* Comparison Placeholder */}
        <div className="bg-gray-700 p-4 rounded-lg flex-1">
          <div className="text-white">
            {/* Placeholder for Comparison Chart or Info */}
            <h2>With Adaptum VS Without it</h2>
            <div className="h-64 bg-gray-800 rounded-lg mt-4 flex items-center justify-center">
              {/* <span className="text-gray-400">Comparison Chart Placeholder</span> */}
              <ComparisonChart />
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}