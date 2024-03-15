export default function Navbar() {
    return (
        <div style={{ display: 'flex', justifyContent: 'space-between', padding: '10px', backgroundColor: 'lightgray' }}>
            <h1>Navbar</h1>
            <div style={{ display: 'flex', gap: '10px' }}>
                <a href="/app/invest">Invest</a>
                <a href="/app/portfolio">Portfolio</a>
            </div>
        </div>
    )
}