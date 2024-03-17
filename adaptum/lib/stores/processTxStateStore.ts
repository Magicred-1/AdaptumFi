import { create } from "zustand";

interface ProcessTxState {
  amountPendingTx: number;
  waitingConformation: boolean;
  addPendingTx: () => void;
  removePendingTx: () => void;
  setWaitingConformation: (value: boolean) => void;
}

const useProcessTxState = create<ProcessTxState>((set) => ({
  amountPendingTx: 0,
  waitingConformation: false,
  setWaitingConformation: (value: boolean) =>
    set((state) => ({
      waitingConformation: value,
    })),
  addPendingTx: () =>
    set((state) => ({
      amountPendingTx: state.amountPendingTx + 1,
    })),
  removePendingTx: () =>
    set((state) => ({
      amountPendingTx: state.amountPendingTx - 1,
    })),
}));

export default useProcessTxState;
