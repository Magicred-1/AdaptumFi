'use client'
import React, {useState} from 'react';

interface Position {
    from: string;
    to: string;
    amount: string;
    tokensBought: string;
    interval: string;
    end: string;
    remainingThreshold: string;
  }

const PositionCard = ({ position, isOpened }: { position: Position, isOpened: boolean }) => {
  const [modalOpen, setModalOpen] = useState(false);
  const handleClose = () => setModalOpen(false);
  return(
    <>
      <div className="bg-gray-800 p-6 rounded-xl shadow-lg mb-4 flex flex-col space-y-4">
        <div className="flex justify-between items-center">
          <div className="flex items-center">
            <span className="bg-blue-500 text-white px-3 py-1 rounded-full text-xs font-medium mr-3">
              {position.from} → {position.to}
            </span>
            <span className="text-gray-300">{isOpened ? 'Active' : 'Finished'}</span>
          </div>
          <button className={`text-xs font-semibold py-2 px-4 rounded-full ${isOpened ? 'bg-red-400 hover:bg-red-600' : 'bg-blue-600'} text-white transition duration-150 ease-in-out`}>

            {
              isOpened ? (
                <span>Cancel Order</span> ) : (
                <span onClick={() => setModalOpen(true)}>Claim funds</span>
                )
            }
          </button>
        </div>
        <div className="flex justify-between items-center text-xs text-gray-400">
          <div>Amount</div>
          <div>{position.amount} USDC</div>
        </div>
        <div className="flex justify-between items-center text-xs text-gray-400">
          <div>Tokens Bought</div>
          <div>{position.tokensBought} ETH</div>
        </div>
        <div className="flex justify-between items-center text-xs text-gray-400">
          <div>Interval</div>
          <div>{position.interval}</div>
        </div>
        <div className="flex justify-between items-center text-xs text-gray-400">
          <div>End</div>
          <div>{position.end}</div>
        </div>
        <div className="flex justify-between items-center text-xs text-gray-400">
          <div>Remaining Threshold</div>
          <div>{position.remainingThreshold} USDC</div>
        </div>
      </div>
    </>
    );
}
  
  export default PositionCard;
  