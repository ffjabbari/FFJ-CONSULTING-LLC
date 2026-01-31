import { useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Navigation from './Navigation'
import Footer from './Footer'
import './FinancialPlanning.css'

const STORAGE_KEY = 'ffj.financialPlanning.portfolio.v1'

function safeParseJson(value, fallback) {
  try {
    return JSON.parse(value)
  } catch {
    return fallback
  }
}

function toNumber(value) {
  const n = Number(String(value ?? '').replace(/,/g, '').trim())
  return Number.isFinite(n) ? n : 0
}

function formatMoney(value) {
  const n = Number(value)
  if (!Number.isFinite(n)) return '$0.00'
  return n.toLocaleString(undefined, { style: 'currency', currency: 'USD' })
}

function formatPercent(value) {
  const n = Number(value)
  if (!Number.isFinite(n)) return '0.00%'
  return `${n.toFixed(2)}%`
}

function newRow() {
  return { ticker: '', shares: '', costBasis: '', currentPrice: '' }
}

function FinancialPlanning() {
  const navigate = useNavigate()
  const [rows, setRows] = useState(() => {
    const saved = localStorage.getItem(STORAGE_KEY)
    const parsed = saved ? safeParseJson(saved, null) : null
    if (Array.isArray(parsed) && parsed.length) return parsed
    return [newRow()]
  })

  const computed = useMemo(() => {
    const items = rows.map((r) => {
      const shares = toNumber(r.shares)
      const costBasis = toNumber(r.costBasis)
      const currentPrice = toNumber(r.currentPrice)

      const cost = shares * costBasis
      const value = shares * currentPrice
      const gain = value - cost
      const gainPct = cost > 0 ? (gain / cost) * 100 : 0

      return { ...r, shares, costBasis, currentPrice, cost, value, gain, gainPct }
    })

    const totalValue = items.reduce((sum, i) => sum + i.value, 0)
    const totalCost = items.reduce((sum, i) => sum + i.cost, 0)
    const totalGain = totalValue - totalCost
    const totalGainPct = totalCost > 0 ? (totalGain / totalCost) * 100 : 0

    const withAlloc = items.map((i) => ({
      ...i,
      allocationPct: totalValue > 0 ? (i.value / totalValue) * 100 : 0,
    }))

    return { items: withAlloc, totalValue, totalCost, totalGain, totalGainPct }
  }, [rows])

  const updateRow = (idx, patch) => {
    setRows((prev) => prev.map((r, i) => (i === idx ? { ...r, ...patch } : r)))
  }

  const addRow = () => setRows((prev) => [...prev, newRow()])
  const removeRow = (idx) =>
    setRows((prev) => prev.filter((_, i) => i !== idx).length ? prev.filter((_, i) => i !== idx) : [newRow()])

  const save = () => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(rows))
    alert('Portfolio saved in this browser.')
  }

  const reset = () => {
    localStorage.removeItem(STORAGE_KEY)
    setRows([newRow()])
  }

  return (
    <div className="fp-page">
      <Navigation />
      <div className="fp-container">
        <button className="back-button" onClick={() => navigate('/')}>
          ← Back to Home
        </button>

        <header className="fp-header">
          <h1>Financial Planning</h1>
          <p>
            Starter Portfolio Analysis (manual / delayed-friendly). Enter positions and prices to compute allocation
            and gain/loss. We can add delayed quote lookups later.
          </p>
        </header>

        <div className="fp-actions">
          <button className="fp-btn" onClick={addRow}>
            Add position
          </button>
          <button className="fp-btn fp-btn-secondary" onClick={save}>
            Save
          </button>
          <button className="fp-btn fp-btn-ghost" onClick={reset}>
            Reset
          </button>
        </div>

        <div className="fp-table-wrap">
          <table className="fp-table">
            <thead>
              <tr>
                <th style={{ width: '16%' }}>Ticker</th>
                <th style={{ width: '12%' }}>Shares</th>
                <th style={{ width: '14%' }}>Cost basis</th>
                <th style={{ width: '14%' }}>Current price</th>
                <th style={{ width: '14%' }}>Market value</th>
                <th style={{ width: '10%' }}>Alloc</th>
                <th style={{ width: '10%' }}>Gain/Loss</th>
                <th style={{ width: '10%' }}>%</th>
                <th style={{ width: '8%' }}></th>
              </tr>
            </thead>
            <tbody>
              {computed.items.map((r, idx) => (
                <tr key={idx}>
                  <td>
                    <input
                      value={r.ticker}
                      onChange={(e) => updateRow(idx, { ticker: e.target.value.toUpperCase() })}
                      placeholder="AAPL"
                    />
                  </td>
                  <td>
                    <input value={rows[idx].shares} onChange={(e) => updateRow(idx, { shares: e.target.value })} />
                  </td>
                  <td>
                    <input
                      value={rows[idx].costBasis}
                      onChange={(e) => updateRow(idx, { costBasis: e.target.value })}
                      placeholder="e.g. 123.45"
                    />
                  </td>
                  <td>
                    <input
                      value={rows[idx].currentPrice}
                      onChange={(e) => updateRow(idx, { currentPrice: e.target.value })}
                      placeholder="e.g. 150.12"
                    />
                  </td>
                  <td className="fp-num">{formatMoney(r.value)}</td>
                  <td className="fp-num">{formatPercent(r.allocationPct)}</td>
                  <td className={`fp-num ${r.gain >= 0 ? 'fp-pos' : 'fp-neg'}`}>{formatMoney(r.gain)}</td>
                  <td className={`fp-num ${r.gainPct >= 0 ? 'fp-pos' : 'fp-neg'}`}>{formatPercent(r.gainPct)}</td>
                  <td className="fp-actions-cell">
                    <button className="fp-remove" onClick={() => removeRow(idx)} title="Remove row">
                      Remove
                    </button>
                  </td>
                </tr>
              ))}
            </tbody>
            <tfoot>
              <tr>
                <td colSpan={4} className="fp-total-label">
                  Totals
                </td>
                <td className="fp-num fp-total">{formatMoney(computed.totalValue)}</td>
                <td className="fp-num">100.00%</td>
                <td className={`fp-num fp-total ${computed.totalGain >= 0 ? 'fp-pos' : 'fp-neg'}`}>
                  {formatMoney(computed.totalGain)}
                </td>
                <td className={`fp-num fp-total ${computed.totalGainPct >= 0 ? 'fp-pos' : 'fp-neg'}`}>
                  {formatPercent(computed.totalGainPct)}
                </td>
                <td></td>
              </tr>
            </tfoot>
          </table>
        </div>

        <div className="fp-note">
          Note: This is for educational purposes only and is not financial advice.
        </div>
      </div>
      <Footer />
    </div>
  )
}

export default FinancialPlanning

