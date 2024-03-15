'use client';

import { DynamicContextProvider}  from '@dynamic-labs/sdk-react-core';
import { EthereumWalletConnectors } from '@dynamic-labs/ethereum';
import { DynamicWagmiConnector } from '@dynamic-labs/wagmi-connector';
import {
  createConfig,
  WagmiProvider,
} from 'wagmi';
import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { http } from 'viem';
import { sepolia, baseSepolia, arbitrum, arbitrumSepolia } from 'viem/chains';

const config = createConfig({
  chains: [sepolia, baseSepolia, arbitrum, arbitrumSepolia],
  multiInjectedProviderDiscovery: false,
  transports: {
      [sepolia.id]: http(),
      [baseSepolia.id]: http(),
      [arbitrum.id]: http(),
      [arbitrumSepolia.id]: http(),
  },
});

const queryClient = new QueryClient();
  
export function Provider({ children }: { children: React.ReactNode }) {
  return (
      <DynamicContextProvider
      settings={{
          environmentId: process.env.NEXT_PUBLIC_DYNAMIC_ENVIRONMENT_ID || '730d3c14-9058-42c8-8a1b-9e4475a659ef',
          walletConnectors: [EthereumWalletConnectors],
      }}>
      <WagmiProvider config={config}>
          <QueryClientProvider client={queryClient}>
            <DynamicWagmiConnector>
                {children}
            </DynamicWagmiConnector>
          </QueryClientProvider>
      </WagmiProvider>
      </DynamicContextProvider>
  );
}
  