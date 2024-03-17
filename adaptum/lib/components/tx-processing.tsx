"use client";
import React from "react";
import useProcessTxState from "../stores/processTxStateStore";
import { Loader2 } from "lucide-react";

const TxProcessing = () => {
	const { amountPendingTx } = useProcessTxState();

	return (
		<>
		
			{amountPendingTx > 0 && (
                <div className="flex px-2 py-1 text-xs font-semibold leading-none text-white rounded-full capitalize">
                    {amountPendingTx}&nbsp;
					{amountPendingTx > 1 ? "TRANSACTION PENDING" : "TRANSACTION PENDING"}
					&nbsp; <Loader2 className=" animate-spin" height={15} />
                </div>
			)}
		</>
	);
};

export default TxProcessing;