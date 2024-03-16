'use client'
import React, { useState } from 'react'
import InvestChart from '@/src/_components/charts/invest-chart';
import ComparisonChart from '@/src/_components/charts/comparison-chart';

export const Invest = () => {
  const [network, setNetwork] = useState('');
  const [sellCurrency, setSellCurrency] = useState('USDC');
  const [receiveCurrency, setReceiveCurrency] = useState('ETH');
  const [amount, setAmount] = useState('');
  const [interval, setInterval] = useState('');
  const [indicator, setIndicator] = useState('');
  const [hyperplaneOption, setHyperplaneOption] = useState('');

  const handleMaxClick = () => {
    // Assuming 123.23 is the max amount available for simplicity
    setAmount('123.23');
  };

  const handleHalfClick = () => {
    // Assuming 123.23 is the max amount available for simplicity
    setAmount((123.23 / 2).toString());
  };

  return (
    <div className="bg-gray-800 min-h-screen flex flex-col md:flex-row p-4 md:p-8">
      <div className="flex flex-col w-full md:w-1/3 md:mr-8">
        {/* Network Selector */}
        <div className="mb-4 bg-gray-900 rounded-xl p-2">
          <label className="block text-gray-400 mb-2">Choose network :</label>
          <select className="w-full bg-gray-700 text-white p-3 rounded-lg focus:outline-none" value={network} onChange={(e) => setNetwork(e.target.value)}>
            <option value="">Select Network</option>
            <option value="Sepolia">Sepolia</option>
            <option value="Arbitrum">Arbitrum One</option>
            <option value="ArbitrumSepolia">Arbitrum Sepolia</option>
            <option value="BaseSepolia">Base Sepolia</option>
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
          <div className="text-gray-400 mt-2">Available: 123.23 USDC</div>
        </div>

        {/* Intervals */}
        <div className="mb-4 bg-gray-900 rounded-xl p-2">
          <label className="block text-gray-400 mb-2">Intervals</label>
          <div className="flex space-x-2">
            <button className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-blue-600" onClick={() => setInterval('Daily')}>Daily</button>
            <button className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-blue-600" onClick={() => setInterval('Weekly')}>Weekly</button>
          </div>
          <div className="flex mt-4 space-x-2">
            {/* Custom Days Buttons */}
            <button className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-blue-600" onClick={() => setInterval('7')}>7</button>
            <button className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-blue-600" onClick={() => setInterval('15')}>15</button>
            <button className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-blue-600" onClick={() => setInterval('30')}>30</button>
          </div>
        </div>

        {/* Indicator Selector */}
        <div className="mb-4 bg-gray-900 rounded-xl p-2">
          <label className="block text-gray-400 mb-2">Choose an indicator</label>
          <div className="flex space-x-2">
            <button className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-red-600" onClick={() => setIndicator('CBBI Index')}>CBBI Index</button>
            <button className="bg-gray-600 text-white px-4 py-2 rounded-lg hover:bg-red-600" onClick={() => setIndicator('None')}>None</button>
          </div>
        </div>

        {/* Network Info and Actions */}
        <div className='bg-gray-900 rounded-xl p-2'>
          <label className="block text-gray-400 mb-2">Use Hyperplane to get the tokens from another chain</label>
          <div className="flex space-x-2 mb-4">
            <button className="bg-blue-600 text-white px-4 py-2 rounded-lg" onClick={() => setHyperplaneOption('Arbitrum Sepolia')}>Arbitrum Sepolia</button>
            <button className="bg-gray-600 text-white px-4 py-2 rounded-lg" onClick={() => setHyperplaneOption('Base Sepolia')}>Base Sepolia</button>
          </div>
        </div>
          <button className="bg-blue-600 text-white px-4 py-2 rounded-lg w-full mt-4" onClick={() => setNetwork('')}>Change network</button>
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
};

export default Invest;