"use client";

import { DynamicContextProvider } from "@dynamic-labs/sdk-react-core";
import "./globals.css";
import { Inter } from "next/font/google";
import { type ReactNode } from "react";
import { EthereumWalletConnectors } from "@dynamic-labs/ethereum";
import { DynamicWagmiConnector } from "@dynamic-labs/wagmi-connector";
import { QueryClient, QueryClientProvider } from "@tanstack/react-query";
import { createConfig, WagmiProvider } from "wagmi";
import { http } from "viem";
import { arbitrum, baseSepolia, arbitrumSepolia, sepolia } from "viem/chains";
import Navbar from "@/src/_components/navbar";
// import Footer from "@/src/_components/footer"

const inter = Inter({ subsets: ["latin"] });

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

/**
 * Update your environmentId
 */
const environmentId = process.env.NEXT_PUBLIC_DYNAMIC_ENVIRONMENT_ID || "730d3c14-9058-42c8-8a1b-9e4475a659ef";

export default function RootLayout(props: { children: ReactNode }) {
  return (
    <html lang="en">
      <body className={inter.className}>
        <DynamicContextProvider
          settings={{
            environmentId,
            walletConnectors: [EthereumWalletConnectors],
          }}
        >
          <WagmiProvider config={config}>
            <QueryClientProvider client={queryClient}>
              <DynamicWagmiConnector>
                <Navbar />
                  {props.children}
                {/* <Footer /> */}
              </DynamicWagmiConnector>
            </QueryClientProvider>
          </WagmiProvider>
        </DynamicContextProvider>
      </body>
    </html>
  );
}