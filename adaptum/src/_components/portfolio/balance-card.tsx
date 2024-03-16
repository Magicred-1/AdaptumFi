import React from 'react';

interface BalanceCardProps {
    balance: string;
    currency: string;
    }

const BalanceCard = ({ balance, currency }: BalanceCardProps) => (
    <div className="bg-gray-800 p-6 rounded-2xl shadow-lg mb-4">
      <h3 className="text-lg text-gray-300 mb-4">Estimated Balance</h3>
      <div className="flex items-center justify-between mb-4">
        <div className="flex items-center">
          <span className="bg-blue-500 text-white px-3 py-1 rounded-full text-sm font-medium mr-3">
            {balance} {currency}
          </span>
          <svg xmlns="http://www.w3.org/2000/svg" className="h-5 w-5 text-blue-500" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 9l-7 7-7-7" />
          </svg>
        </div>
      </div>
      {/* Placeholder for the chart */}
      <div className="w-full h-48 bg-gray-700 rounded-xl flex items-center justify-center">
        <span className="text-gray-400">Chart Placeholder</span>
      </div>
    </div>
  );
  
  export default BalanceCard;
  