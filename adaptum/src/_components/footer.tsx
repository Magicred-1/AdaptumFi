import Image from 'next/image'
import logo from '../assets/logos/logo.png'

const Footer = () => {
  return (
    <div className="flex items-center justify-between text-white bg-gray-900 px-4 md:px-10 py-4 border-t border-gray-700">
        <div className="flex items-center md:gap-2">
            <Image src={logo} alt="logo" width={50} height={50} className='w-8 md:w-12' />
            <span className='text-sm md:text-base'>AdaptumFi</span>
        </div>
        <span className='text-xs md:text-sm'>
        © 2024 AdaptumFi. All right reserved
        </span>
    </div>
  )
}

export default Footer