import { AreaChart, Area, XAxis, YAxis, Tooltip } from 'recharts';
const data = [
    {
      name: '23/08/2021',
      price: 100,
    },
    {
      name: '24/08/2021',
      price: 234.3,
    },
    {
      name: '26/08/2021',
      price: 345.3,
    },
    {
      name: '27/08/2021',
      price: 560,
    },
    {
      name: '28/08/2021',
      price: 653,
    },
    {
      name: '29/08/2021',
      price: 977.98274904,
    },
  ];

export const RenderLineChart = () => (
    <AreaChart
    width={500}
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

export default RenderLineChart;