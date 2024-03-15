"use client";

import Image from "next/image";
import blockicon from "@/src/assets/home/BlockIcon.png";
import blockicon1 from "@/src/assets/home/BlockIcon-1.png";
import blockicon2 from "@/src/assets/home/BlockIcon-2.png";
import blockicon3 from "@/src/assets/home/BlockIcon-3.png";
import blockicon4 from '@/src/assets/home/BlockIcon-4.png'
import Spline from '@splinetool/react-spline';
// import { Metadata } from "next";

// export const metadata: Metadata = {
//   title: "Adaptum Finance",
//   description: "Adaptum Finance is a decentralized finance DCA On Chain - Cross Chain platform that allows you to invest in a diversified portfolio of assets.",
// };

export default function Home() {
  const features = [
    {
      title: "Easy to set up",
      description: "Once logged in creating a DCA order is easy and then it works by itself.",
      icon: blockicon,
    },
    {
      title: "Track your balance",
      description: "A dashboard is available to manage and track all your investments.",
      icon: blockicon1,
    },
    {
      title: "Cross Chain",
      description: "The swaps can be made on another chains to maximize your gains.",
      icon: blockicon2,
    },
    {
      title: "Fully On-Chain",
      description: "Full control over your investments with our on-chain solutions.",
      icon: blockicon3,
    },
    {
      title: "Automatic",
      description: "Your investments are automatically managed for optimal performance.",
      icon: blockicon4,
    },
  ];

  return (
    <main className="bg-gray-900 text-white p-8">
      {/* Hero section */}
      { /* Two Grids */}
      <div className="grid grid-cols-1 md:grid-cols-2 gap-8">
        <div className="flex flex-col justify-center items-start">
        <h1 className="text-3xl md:text-4xl font-normal mb-4">Unlocking the Future of AMM On-Chain DCA with Adaptum Finance</h1>
        <p className="text-xl font-extralight mb-6">DCA Investing made easy using indicators trading.</p>
        <button className="w-32 h-9 bg-indigo-700 bg-opacity-40 rounded-lg shadow border border-white border-opacity-50 flex justify-center items-center gap-2.5">
          <span className="text-xs font-normal">Get Started</span>
        </button>
        </div>
        <Spline scene="https://prod.spline.design/vGW0WyFt3OyhKp9x/scene.splinecode" />
      </div>

      {/* Features section */}
      <div className="mb-10">
        <h3 className="text-3xl font-normal mb-8">Why Adaptum Finance is for you?</h3>
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
          {features.map((feature, index) => (
            <div key={index} className="bg-black/40 p-7 rounded-lg shadow-lg flex flex-col items-center">
              <Image src={feature.icon} alt={feature.title} width={75} height={75} className="mb-4" />
              <h4 className="text-xl font-semibold mb-2">{feature.title}</h4>
              <p className="text-sm">{feature.description}</p>
            </div>
          ))}
        </div>
      </div>
    </main>
  );
}