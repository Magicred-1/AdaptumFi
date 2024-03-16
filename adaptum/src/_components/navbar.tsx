"use client";

import { DynamicWidget } from '@dynamic-labs/sdk-react-core';
import logo from '../assets/logos/logo.png'
import Image from 'next/image';
import light from '../assets/light_icon.png'
import Link from 'next/link';

const Navbar = () => {
  return (
    <div>
        <nav className="flex items-center justify-between p-4 bg-gray-900 border-b border-gray-700">
            <div className="flex items-center justify-between gap-8">
                <Link href="/">
            <Image src={logo} alt="logo" width={50} height={50} />
            </Link>
            <ul className="flex items-center text-white gap-8">
                <Link href="/" className='hidden md:flex'>
                    Home
                </Link>
                <Link href="/invest">
                    Invest
                </Link>
                <Link href="/portfolio">
                    Portfolio
                </Link>
            </ul>
            </div>
            <div className="flex items-center gap-4">
            <Image src={light} alt="light" width={30} height={30} />
            <DynamicWidget
                innerButtonComponent={<button>Connect Wallet</button>}
            />
            </div>
        </nav>
    </div>
  )
}

export default Navbar