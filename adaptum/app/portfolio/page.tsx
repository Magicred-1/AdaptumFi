'use client';
import React, { useState } from 'react'
import BalanceCard from '@/src/_components/portfolio/balance-card';
import PositionCard from '@/src/_components/portfolio/position-card';
import RenderLineChart from '@/src/_components/charts/portfolio-chart';

const positions = {
    opened: [
      { id: 1, from: 'USDC', to: 'ETH', amount: '50', tokensBought: '0.08', interval: '5 days', end: 'February 15, 2024, 1:36 AM', remainingThreshold: '7.5' },
      { id: 2, from: 'USDC', to: 'ETH', amount: '75', tokensBought: '0.12', interval: '5 days', end: 'March 20, 2024, 10:00 AM', remainingThreshold: '11.25' },
      { id: 3, from: 'USDC', to: 'ETH', amount: '100', tokensBought: '0.15', interval: '5 days', end: 'April 25, 2024, 2:45 PM', remainingThreshold: '15' },
      { id: 4, from: 'USDC', to: 'ETH', amount: '200', tokensBought: '0.3', interval: '5 days', end: 'May 30, 2024, 4:30 PM', remainingThreshold: '30' },
      { id: 5, from: 'USDC', to: 'ETH', amount: '300', tokensBought: '0.45', interval: '5 days', end: 'June 15, 2024, 9:15 AM', remainingThreshold: '45' },
    ],
    closed: [

      { id: 6, from: 'USDC', to: 'ETH', amount: '60', tokensBought: '0.09', interval: '5 days', end: 'February 25, 2024, 3:30 AM', remainingThreshold: '9' },
      { id: 7, from: 'USDC', to: 'ETH', amount: '80', tokensBought: '0.11', interval: '5 days', end: 'March 22, 2024, 11:00 AM', remainingThreshold: '12' },
      { id: 8, from: 'USDC', to: 'ETH', amount: '120', tokensBought: '0.18', interval: '5 days', end: 'April 27, 2024, 5:00 PM', remainingThreshold: '18' },
      { id: 9, from: 'USDC', to: 'ETH', amount: '250', tokensBought: '0.35', interval: '5 days', end: 'May 31, 2024, 7:45 PM', remainingThreshold: '35' },
      { id: 10, from: 'USDC', to: 'ETH', amount: '350', tokensBought: '0.5', interval: '5 days', end: 'June 20, 2024, 12:00 PM', remainingThreshold: '50' },
    ]
  };
  

const Portfolio = () => {
    const [activeTab, setActiveTab] = useState('opened');

    const balance = '977.98274904'; // Example balance value
    const currency = 'USDC'; // Example currency

    return (
        <div className="p-4 bg-gray-900 min-h-screen text-white grid grid-cols-12 md:gap-8 md:pt-8">
            {/* Balance and Graph Section */}
            <div className="col-span-12 md:col-span-4">
              <BalanceCard balance={balance} currency={currency} />
        </div>
        <div className='col-span-12 md:col-span-8'>
            <span className="text-white text-base">Positions</span>
                    {/* Position Tabs */}
                    <div className="w-full justify-center items-start gap-2.5 inline-flex mt-2 mb-4">
            <div className={`grow shrink basis-0 px-1 py-2 rounded-full shadow border border-white border-opacity-50 justify-center items-center gap-2.5 flex hover:bg-indigo-600 hover:bg-opacity-30 cursor-pointer ${activeTab === 'opened' ? 'bg-indigo-600 bg-opacity-30' : ''}`}
            onClick={() => setActiveTab('opened')}
            >
                <div className="text-white text-xs font-normal ">Opened</div>
            </div>
            <div className={`grow shrink basis-0 px-1 py-2 rounded-full shadow border border-white border-opacity-50 justify-center items-center gap-2.5 flex hover:bg-indigo-600 hover:bg-opacity-30 cursor-pointer ${activeTab === 'closed' ? 'bg-indigo-600 bg-opacity-30' : ''}`}
            onClick={() => setActiveTab('closed')}
            >
                <div className="text-white text-xs font-normal ">Closed</div>
            </div>
            </div>

            <div>
               
            </div>
            {positions[activeTab as keyof typeof positions].map(position => (
              <PositionCard key={position.id} position={position} isOpened={activeTab === 'opened'} />
            ))}
            </div>
            </div> 
    );
  };

export default Portfolio