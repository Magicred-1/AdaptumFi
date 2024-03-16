import { AreaChart, Area, XAxis, YAxis, CartesianGrid, Tooltip } from 'recharts';
const data = [
    {
      name: '23/08/2021',
      price: 4000,
    },
    {
      name: '24/08/2021',
      price: 3000,
    },
    {
      name: '25/08/2021',
      price: 2000,
    },
    {
      name: '26/08/2021',
      price: 2780,
    },
    {
      name: '27/08/2021',
      price: 1890,
    },
    {
      name: '28/08/2021',
      price: 2390,
    },
    {
      name: '29/08/2021',
      price: 3490,
    },
  ];

export const InvestChart = () => (
    <AreaChart
    width={1000}
    height={400}
    data={data}
    margin={{
      top: 10,
      right: 30,
      left: 0,
      bottom: 0,
    }}
  >
    <XAxis dataKey="name" />
    <YAxis />
    <Tooltip />
    <Area type="monotone" dataKey="price" stroke="#8884d8" fill="#8884d8" />
  </AreaChart>
);

export default InvestChart;