import { AreaChart, Area, XAxis, YAxis, Tooltip } from 'recharts';
const data = [
    {
      name: '23/08/2021',
      us: 4000,
      others: 2400,
    },
    {
      name: '24/08/2021',
      us: 3000,
      others: 1398,
    },
    {
      name: '25/08/2021',
      us: 2000,
      others: 300,
    },
    {
      name: '26/08/2021',
      us: 2780,
      others: 2000,
    },
  ];

export const ComparisonChart = () => (
    <AreaChart
    width={1000}
    height={200}
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
    <Area type="monotone" dataKey="us" stroke="#8884d8" fill="#8884d8" />
    <Area type="monotone" dataKey="others" stroke="#82ca9d" fill="#82ca9d" />
  </AreaChart>
);

export default ComparisonChart;