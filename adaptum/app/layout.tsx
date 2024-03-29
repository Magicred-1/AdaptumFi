"use client";

import { DynamicContextProvider } from "@dynamic-labs/sdk-react-core";
import "./globals.css";
import { type ReactNode } from "react";
import { EthereumWalletConnectors } from "@dynamic-labs/ethereum";
import { DynamicWagmiConnector } from "@dynamic-labs/wagmi-connector";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createConfig, WagmiProvider } from "wagmi";
import { http } from "viem";
import { arbitrum, baseSepolia, arbitrumSepolia, sepolia } from "viem/chains";
import Navbar from "@/src/_components/navbar";
import Footer from "@/src/_components/footer"
import localfont from 'next/font/local'

const Lexend = localfont({ src: '../src/assets/fonts/Lexend.ttf' });

const config = createConfig({
  chains: [sepolia, baseSepolia, arbitrum, arbitrumSepolia],
  multiInjectedProviderDiscovery: false,
  transports: {
    [sepolia.id]: http(),
    [arbitrum.id]: http(),
    [baseSepolia.id]: http(),
    [arbitrumSepolia.id]: http()
  },
});

const queryClient = new QueryClient();

// const evmNetworks = [
//   //sepolia, baseSepolia, arbitrum, arbitrumSepolia

//   {
//     blockExplorerUrls: ['https://polygonscan.com/'],
//     chainId: 137,
//     chainName: 'Matic Mainnet',
//     iconUrls: ["https://app.dynamic.xyz/assets/networks/polygon.svg"],
//     name: 'Polygon',
//     nativeCurrency: {
//       decimals: 18,
//       name: 'MATIC',
//       symbol: 'MATIC',
//     },
//     networkId: 137,
//     rpcUrls: ['https://polygon-rpc.com'],    
//     vanityName: 'Polygon',
//   },
// ];

/**
 * Update your environmentId
 */
const environmentId = process.env.NEXT_PUBLIC_DYNAMIC_ENVIRONMENT_ID || "730d3c14-9058-42c8-8a1b-9e4475a659ef";

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className={`${Lexend.className}`}>
        <DynamicContextProvider
          settings={{
            // overrides: {
            //   evmNetworks
            // },
            environmentId,
            walletConnectors: [
              EthereumWalletConnectors,
              // ZeroDevSmartWalletConnectors,
              
            ],

          }}
        >
          <WagmiProvider config={config}>
            <QueryClientProvider client={queryClient}>
              <DynamicWagmiConnector>
                <Navbar />
                  {props.children}
                <Footer />
              </DynamicWagmiConnector>
            </QueryClientProvider>
          </WagmiProvider>
        </DynamicContextProvider>
      </body>
    </html>
  );
}