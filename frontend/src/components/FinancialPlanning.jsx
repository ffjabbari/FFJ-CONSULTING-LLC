import { useMemo, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Navigation from './Navigation'
import Footer from './Footer'
import './FinancialPlanning.css'

const STORAGE_KEY = 'ffj.financialPlanning.portfolios.v1'
const FP_BUILD = 'fp-parser-2026-01-31-2'

function safeParseJson(value, fallback) {
  try {
    return JSON.parse(value)
  } catch {
    return fallback
  }
}

function toNumber(value) {
  // Allow common formats: "$1,234.56" / "1,234.56" / " 123 "
  const cleaned = String(value ?? '')
    .replace(/,/g, '')
    .replace(/[^0-9.\-]/g, '')
    .trim()
  const n = Number(cleaned)
  return Number.isFinite(n) ? n : 0
}

function round2(n) {
  return Math.round(Number(n) * 100) / 100
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

function normalizeTicker(t) {
  return String(t || '')
    .trim()
    .toUpperCase()
    .replace(/[^A-Z0-9.\-]/g, '')
}

function isLikelyTicker(t) {
  const s = normalizeTicker(t)
  // Keep it conservative to avoid false positives from pasted UI text.
  // Covers: GOOG, GOOGL, FXAIX, BRK.B, RDS-A (rare), etc.
  const tickerRegex = /^[A-Z]{2,6}([.\-][A-Z0-9]{1,2})?$/
  if (!s) return false
  if (s.length > 9) return false
  return tickerRegex.test(s)
}

function parseCsvToRows(csvText) {
  const text = String(csvText || '').trim()
  if (!text) return []
  const lines = text.split(/\r?\n/).map((l) => l.trim()).filter(Boolean)
  if (!lines.length) return []

  // Accept optional header row.
  const header = lines[0].toLowerCase()
  const hasHeader = header.includes('ticker') || header.includes('shares')

  const dataLines = hasHeader ? lines.slice(1) : lines
  const rows = []

  for (const line of dataLines) {
    const parts = line.split(',').map((p) => p.trim())
    if (!parts.length) continue
    const [ticker, shares, costBasis, currentPrice] = parts
    if (!ticker && !shares && !costBasis && !currentPrice) continue
    rows.push({
      ticker: normalizeTicker(ticker),
      shares: shares ?? '',
      costBasis: costBasis ?? '',
      currentPrice: currentPrice ?? '',
    })
  }

  return rows
}

function splitLooseLine(line) {
  const l = String(line || '')
  if (l.includes('\t')) return l.split('\t').map((p) => p.trim())
  // Many brokerage UIs copy as fixed-width columns (2+ spaces)
  return l.split(/\s{2,}/).map((p) => p.trim())
}

function findColIndex(headers, candidates) {
  const hs = headers.map((h) => String(h || '').toLowerCase().trim())
  for (const cand of candidates) {
    const c = cand.toLowerCase()
    const idx = hs.findIndex((h) => h === c || h.includes(c))
    if (idx >= 0) return idx
  }
  return -1
}

function looksLikeHeaderRow(cells) {
  const joined = cells.join(' ').toLowerCase()
  return (
    joined.includes('symbol') ||
    joined.includes('ticker') ||
    joined.includes('quantity') ||
    joined.includes('shares') ||
    joined.includes('price') ||
    joined.includes('last') ||
    joined.includes('cost') ||
    joined.includes('basis')
  )
}

function extractTickersFromText(pasteText) {
  const text = String(pasteText || '')
  const lines = text.split(/\r?\n/)

  const stop = new Set([
    'CASH',
    'ACCOUNT',
    'TOTAL',
    'GRAND',
    'LOW',
    'HIGH',
    'NOT',
    'PRICED',
    'TODAY',
    'AS',
    'OF',
    'ET',
    'REFRESH',
    'POSITIONS',
    'SEARCH',
    'FILTER',
    'AVAILABLE',
    'ACTIONS',
    'MANAGE',
    'DIVIDENDS',
    'FULL',
    'VIEW',
    'POSITION',
    'INFORMATION',
    'LAST',
    'UPDATED',
    'MONEY',
    'MARKET',
    'HELD',
    'IN',
  ])

  const found = []
  for (const line of lines) {
    const s = line.trim().toUpperCase()
    if (!s) continue
    if (s.length > 12) continue
    if (!isLikelyTicker(s)) continue
    if (stop.has(s)) continue
    found.push(s)
  }

  return Array.from(new Set(found))
}

function parseFidelityPasteToRows(pasteText) {
  const text = String(pasteText || '').trim()
  if (!text) return []

  const lines = text.split(/\r?\n/).map((l) => l.trim()).filter(Boolean)
  if (!lines.length) return []

  // If it's not tabular (no tabs and no fixed-width multi-column lines),
  // don't try to "column-parse" each line — just extract tickers.
  const hasTabularSignals =
    text.includes('\t') || lines.some((l) => splitLooseLine(l).length >= 3)
  if (!hasTabularSignals) {
    const tickers = extractTickersFromText(text)
    return tickers.map((t) => ({ ticker: t, shares: '', costBasis: '', currentPrice: '' }))
  }

  const firstCells = splitLooseLine(lines[0])
  const hasHeader = looksLikeHeaderRow(firstCells)

  const headers = hasHeader ? firstCells : []
  const dataLines = hasHeader ? lines.slice(1) : lines

  // Map columns by common Fidelity labels (best-effort)
  const symbolIdx = hasHeader
    ? findColIndex(headers, ['symbol', 'ticker'])
    : 0
  const sharesIdx = hasHeader
    ? findColIndex(headers, ['quantity', 'qty', 'shares'])
    : 1
  const priceIdx = hasHeader
    ? findColIndex(headers, ['last price', 'last', 'price', 'current price', 'market price'])
    : 2
  const costBasisIdx = hasHeader
    ? findColIndex(headers, ['cost basis', 'basis', 'avg cost', 'average cost'])
    : -1

  const rows = []

  for (const line of dataLines) {
    const parts = splitLooseLine(line)
    if (!parts.length) continue

    const rawSymbol = parts[symbolIdx] ?? parts[0] ?? ''
    const ticker = normalizeTicker(rawSymbol)
    if (!isLikelyTicker(ticker)) continue

    // Try to read in any order; fall back to searching numeric-like tokens
    const shares = parts[sharesIdx] ?? ''
    const currentPrice = parts[priceIdx] ?? ''
    const costBasis = costBasisIdx >= 0 ? (parts[costBasisIdx] ?? '') : ''

    // If we didn't really find a price column, try to find the first "$" token after shares.
    let inferredPrice = currentPrice
    if (!toNumber(inferredPrice)) {
      const candidate = parts.find((p) => String(p).includes('$')) || ''
      if (toNumber(candidate)) inferredPrice = candidate
    }

    // Safety: avoid importing random page/UI text as a "holding".
    // If the row doesn't contain ANY numeric values (shares/price/cost), skip it.
    // Users who only have symbols can use "Import Symbols Only".
    const hasAnyNumeric =
      toNumber(shares) > 0 || toNumber(inferredPrice) > 0 || toNumber(costBasis) > 0
    if (!hasAnyNumeric) continue

    rows.push({
      ticker,
      shares: String(shares ?? '').trim(),
      costBasis: String(costBasis ?? '').trim(),
      currentPrice: String(inferredPrice ?? '').trim(),
    })
  }

  // Fallback: if we couldn't parse tabular data, at least extract tickers so users can start.
  if (rows.length === 0) {
    const tickers = extractTickersFromText(text)
    return tickers.map((t) => ({ ticker: t, shares: '', costBasis: '', currentPrice: '' }))
  }

  // De-dupe by ticker (keep first occurrence)
  const seen = new Set()
  const deduped = []
  for (const r of rows) {
    if (!r?.ticker) continue
    if (seen.has(r.ticker)) continue
    seen.add(r.ticker)
    deduped.push(r)
  }
  return deduped
}

function rowsToCsv(rows) {
  const header = 'ticker,shares,costBasis,currentPrice'
  const lines = (rows || []).map((r) => {
    const ticker = normalizeTicker(r.ticker)
    const shares = String(r.shares ?? '').trim()
    const costBasis = String(r.costBasis ?? '').trim()
    const currentPrice = String(r.currentPrice ?? '').trim()
    return [ticker, shares, costBasis, currentPrice].join(',')
  })
  return [header, ...lines].join('\n')
}

function downloadTextFile(filename, content) {
  const blob = new Blob([content], { type: 'text/plain;charset=utf-8' })
  const url = URL.createObjectURL(blob)
  const a = document.createElement('a')
  a.href = url
  a.download = filename
  document.body.appendChild(a)
  a.click()
  a.remove()
  URL.revokeObjectURL(url)
}

function FinancialPlanning() {
  const navigate = useNavigate()
  const fileInputRef = useRef(null)
  const tableWrapRef = useRef(null)

  const [state, setState] = useState(() => {
    const saved = localStorage.getItem(STORAGE_KEY)
    const parsed = saved ? safeParseJson(saved, null) : null
    if (parsed && typeof parsed === 'object' && parsed.portfolios && parsed.active) return parsed

    return {
      active: 'My Portfolio',
      portfolios: {
        'My Portfolio': [newRow()],
      },
    }
  })

  const [newPortfolioName, setNewPortfolioName] = useState('')
  const [status, setStatus] = useState('')
  const [importText, setImportText] = useState('')
  const [pasteText, setPasteText] = useState('')

  const rows = state.portfolios?.[state.active] || [newRow()]

  const computed = useMemo(() => {
    const items = rows.map((r) => {
      const ticker = normalizeTicker(r.ticker)
      const shares = toNumber(r.shares)
      const costBasis = toNumber(r.costBasis)
      const currentPrice = toNumber(r.currentPrice)

      const cost = shares * costBasis
      const value = shares * currentPrice
      const gain = value - cost
      const gainPct = cost > 0 ? (gain / cost) * 100 : 0

      const hasShares = shares > 0
      const hasPrice = currentPrice > 0
      const hasCost = costBasis > 0

      const warnings = []
      if (!ticker) warnings.push('Missing ticker')
      if (!hasShares) warnings.push('Missing shares')
      if (!hasPrice) warnings.push('Missing current price')
      if (!hasCost) warnings.push('Missing cost basis')

      return {
        ...r,
        ticker,
        shares,
        costBasis,
        currentPrice,
        cost,
        value,
        gain,
        gainPct,
        warnings,
      }
    })

    const totalValue = items.reduce((sum, i) => sum + i.value, 0)
    const totalCost = items.reduce((sum, i) => sum + i.cost, 0)
    const totalGain = totalValue - totalCost
    const totalGainPct = totalCost > 0 ? (totalGain / totalCost) * 100 : 0

    const withAlloc = items.map((i) => ({
      ...i,
      allocationPct: totalValue > 0 ? (i.value / totalValue) * 100 : 0,
    }))

    const warningCount = withAlloc.reduce((sum, i) => sum + (i.warnings?.length || 0), 0)

    const topHoldings = [...withAlloc]
      .filter((i) => i.value > 0)
      .sort((a, b) => b.value - a.value)
      .slice(0, 8)

    return { items: withAlloc, totalValue, totalCost, totalGain, totalGainPct, warningCount, topHoldings }
  }, [rows])

  const persist = (nextState) => {
    localStorage.setItem(STORAGE_KEY, JSON.stringify(nextState))
  }

  const setRowsForActive = (nextRows) => {
    setState((prev) => {
      const next = {
        ...prev,
        portfolios: {
          ...(prev.portfolios || {}),
          [prev.active]: nextRows,
        },
      }
      persist(next)
      return next
    })
  }

  const mutateActiveRows = (mutator) => {
    setState((prev) => {
      const currentRows = prev.portfolios?.[prev.active] || [newRow()]
      const nextRows = mutator(currentRows)
      const next = {
        ...prev,
        portfolios: {
          ...(prev.portfolios || {}),
          [prev.active]: nextRows,
        },
      }
      persist(next)
      return next
    })
  }

  const updateRow = (idx, patch) => {
    mutateActiveRows((current) => current.map((r, i) => (i === idx ? { ...r, ...patch } : r)))
  }

  const addRow = () => {
    setStatus('')
    mutateActiveRows((current) => [...current, newRow()])
    setStatus('Added position.')
    setTimeout(() => {
      tableWrapRef.current?.scrollTo({ top: tableWrapRef.current.scrollHeight, behavior: 'smooth' })
    }, 0)
  }

  const removeRow = (idx) => {
    setStatus('')
    mutateActiveRows((current) => {
      const next = current.filter((_, i) => i !== idx)
      return next.length ? next : [newRow()]
    })
  }

  const setActive = (name) => {
    setState((prev) => {
      const next = { ...prev, active: name }
      persist(next)
      return next
    })
    setStatus('')
  }

  const createPortfolio = () => {
    const name = newPortfolioName.trim()
    if (!name) {
      setStatus('Enter a portfolio name.')
      return
    }
    if (state.portfolios?.[name]) {
      setStatus('That portfolio name already exists.')
      return
    }
    const next = {
      ...state,
      active: name,
      portfolios: {
        ...(state.portfolios || {}),
        [name]: [newRow()],
      },
    }
    setState(next)
    persist(next)
    setNewPortfolioName('')
    setStatus('Portfolio created.')
  }

  const deleteActivePortfolio = () => {
    const names = Object.keys(state.portfolios || {})
    if (names.length <= 1) {
      setStatus('You must keep at least one portfolio.')
      return
    }
    const nextPortfolios = { ...(state.portfolios || {}) }
    delete nextPortfolios[state.active]
    const nextActive = Object.keys(nextPortfolios)[0]
    const next = { ...state, active: nextActive, portfolios: nextPortfolios }
    setState(next)
    persist(next)
    setStatus('Portfolio deleted.')
  }

  const exportCsv = () => {
    const csv = rowsToCsv(rows)
    const filename = `${state.active.replace(/\s+/g, '-')}-portfolio.csv`
    downloadTextFile(filename, csv)
    setStatus('Exported CSV.')
  }

  const loadExample = () => {
    const example = [
      { ticker: 'AAPL', shares: '10', costBasis: '150', currentPrice: '185' },
      { ticker: 'MSFT', shares: '6', costBasis: '320', currentPrice: '395' },
      { ticker: 'AMZN', shares: '8', costBasis: '120', currentPrice: '155' },
    ]
    setRowsForActive(example)
    setStatus('Loaded example portfolio.')
  }

  const importFidelityPaste = () => {
    const parsed = parseFidelityPasteToRows(pasteText)
    if (!parsed.length) {
      setStatus('No rows found. Try copying the holdings table again.')
      return
    }
    setRowsForActive(parsed)
    setPasteText('')
    const filled = parsed.filter((r) => toNumber(r.shares) > 0 && toNumber(r.currentPrice) > 0).length
    if (filled === 0) {
      setStatus(`Imported ${parsed.length} tickers. Add shares/prices (or use CSV) to compute totals.`)
    } else {
      setStatus(`Imported ${parsed.length} rows from pasted holdings.`)
    }
  }

  const importFidelitySymbolsOnly = () => {
    const tickers = extractTickersFromText(pasteText)
    if (!tickers.length) {
      setStatus('No tickers found in the pasted text.')
      return
    }
    const parsed = tickers.map((t) => ({ ticker: t, shares: '', costBasis: '', currentPrice: '' }))
    setRowsForActive(parsed)
    setPasteText('')
    setStatus(`Imported ${parsed.length} tickers (symbols only).`)
  }

  const importCsv = () => {
    const parsed = parseCsvToRows(importText)
    if (!parsed.length) {
      setStatus('No rows found to import.')
      return
    }
    setRowsForActive(parsed)
    setImportText('')
    setStatus(`Imported ${parsed.length} rows.`)
  }

  const handleCsvFile = async (file) => {
    if (!file) return
    const text = await file.text()
    setImportText(text)
    setStatus('CSV loaded. Click “Import CSV”.')
  }

  const reset = () => {
    const next = {
      ...state,
      portfolios: {
        ...(state.portfolios || {}),
        [state.active]: [newRow()],
      },
    }
    setState(next)
    persist(next)
    setStatus('Reset active portfolio.')
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
          <div className="fp-build">Build: {FP_BUILD}</div>
          <p>
            Portfolio Analysis (delayed/manual friendly). Enter positions and prices to compute allocations and
            gain/loss. We can add delayed quote lookups later.
          </p>
        </header>

        <div className="fp-help">
          Enter <strong>Shares</strong>, <strong>Cost basis</strong>, and <strong>Current price</strong> to see calculations
          update instantly. This version does not fetch live quotes yet (manual/delayed data is fine).
        </div>

        <div className="fp-portfolio-bar">
          <label className="fp-field">
            <span>Portfolio</span>
            <select value={state.active} onChange={(e) => setActive(e.target.value)}>
              {Object.keys(state.portfolios || {}).map((name) => (
                <option key={name} value={name}>
                  {name}
                </option>
              ))}
            </select>
          </label>

          <div className="fp-portfolio-create">
            <input
              value={newPortfolioName}
              onChange={(e) => setNewPortfolioName(e.target.value)}
              placeholder="New portfolio name"
            />
            <button type="button" className="fp-btn fp-btn-secondary" onClick={createPortfolio}>
              Create
            </button>
            <button type="button" className="fp-btn fp-btn-ghost" onClick={deleteActivePortfolio}>
              Delete
            </button>
          </div>
        </div>

        <div className="fp-actions">
          <button type="button" className="fp-btn" onClick={addRow}>
            Add position
          </button>
          <button type="button" className="fp-btn fp-btn-secondary" onClick={exportCsv}>
            Export CSV
          </button>
          <button type="button" className="fp-btn fp-btn-ghost" onClick={loadExample}>
            Load example
          </button>
          <button type="button" className="fp-btn fp-btn-ghost" onClick={reset}>
            Reset
          </button>
          <div className="fp-status">
            {computed.warningCount > 0 ? (
              <span className="fp-warn">{computed.warningCount} input warnings</span>
            ) : (
              <span className="fp-ok">No warnings</span>
            )}
            {status ? <span className="fp-status-msg">{status}</span> : null}
          </div>
        </div>

        <div className="fp-import">
          <div className="fp-import-header">
            <h2>Paste from Fidelity (Holdings)</h2>
            <div className="fp-import-actions">
              <button type="button" className="fp-btn fp-btn-secondary" onClick={importFidelityPaste}>
                Import Paste
              </button>
              <button type="button" className="fp-btn fp-btn-ghost" onClick={importFidelitySymbolsOnly}>
                Import Symbols Only
              </button>
            </div>
          </div>
          <textarea
            value={pasteText}
            onChange={(e) => setPasteText(e.target.value)}
            placeholder="Copy your Fidelity holdings table and paste here…"
            rows={4}
          />
          <div className="fp-import-help">
            Tip: Copy the holdings table (it may paste as tab-separated text). We’ll extract ticker, shares, and price when possible. If the paste
            only contains tickers (no quantities/prices), use “Import Symbols Only” and fill in shares/prices later or import a CSV export.
          </div>
        </div>

        <div className="fp-import">
          <div className="fp-import-header">
            <h2>Import (CSV)</h2>
            <div className="fp-import-actions">
              <button type="button" className="fp-btn fp-btn-secondary" onClick={importCsv}>
                Import CSV
              </button>
              <button type="button" className="fp-btn fp-btn-ghost" onClick={() => fileInputRef.current?.click()}>
                Choose file…
              </button>
              <input
                ref={fileInputRef}
                type="file"
                accept=".csv,text/csv"
                style={{ display: 'none' }}
                onChange={(e) => handleCsvFile(e.target.files?.[0])}
              />
            </div>
          </div>
          <textarea
            value={importText}
            onChange={(e) => setImportText(e.target.value)}
            placeholder="Paste CSV here (ticker,shares,costBasis,currentPrice)…"
            rows={4}
          />
          <div className="fp-import-help">
            Example:
            <code>ticker,shares,costBasis,currentPrice</code>
          </div>
        </div>

        <div className="fp-summary-grid">
          <div className="fp-card">
            <div className="fp-card-label">Portfolio value</div>
            <div className="fp-card-value">{formatMoney(computed.totalValue)}</div>
          </div>
          <div className="fp-card">
            <div className="fp-card-label">Total cost</div>
            <div className="fp-card-value">{formatMoney(computed.totalCost)}</div>
          </div>
          <div className="fp-card">
            <div className="fp-card-label">Gain / Loss</div>
            <div className={`fp-card-value ${computed.totalGain >= 0 ? 'fp-pos' : 'fp-neg'}`}>
              {formatMoney(computed.totalGain)} ({formatPercent(computed.totalGainPct)})
            </div>
          </div>
        </div>

        <div className="fp-chart">
          <h2>Allocation (Top Holdings)</h2>
          {computed.topHoldings.length === 0 ? (
            <div className="fp-empty">Enter current prices to see allocation.</div>
          ) : (
            <div className="fp-bars">
              {computed.topHoldings.map((h) => (
                <div key={h.ticker || Math.random()} className="fp-bar-row">
                  <div className="fp-bar-label">{h.ticker || '(no ticker)'}</div>
                  <div className="fp-bar-track">
                    <div className="fp-bar-fill" style={{ width: `${Math.max(0, Math.min(100, h.allocationPct))}%` }} />
                  </div>
                  <div className="fp-bar-val">{formatPercent(round2(h.allocationPct))}</div>
                </div>
              ))}
            </div>
          )}
        </div>

        <div className="fp-table-wrap" ref={tableWrapRef}>
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
                      className={!r.ticker ? 'fp-invalid' : ''}
                    />
                  </td>
                  <td>
                    <input
                      value={rows[idx].shares}
                      onChange={(e) => updateRow(idx, { shares: e.target.value })}
                      className={r.shares <= 0 ? 'fp-invalid' : ''}
                      placeholder="e.g. 10"
                    />
                  </td>
                  <td>
                    <input
                      value={rows[idx].costBasis}
                      onChange={(e) => updateRow(idx, { costBasis: e.target.value })}
                      placeholder="e.g. 123.45"
                      className={r.costBasis <= 0 ? 'fp-invalid' : ''}
                    />
                  </td>
                  <td>
                    <input
                      value={rows[idx].currentPrice}
                      onChange={(e) => updateRow(idx, { currentPrice: e.target.value })}
                      placeholder="e.g. 150.12"
                      className={r.currentPrice <= 0 ? 'fp-invalid' : ''}
                    />
                  </td>
                  <td className="fp-num">{formatMoney(r.value)}</td>
                  <td className="fp-num">{formatPercent(r.allocationPct)}</td>
                  <td className={`fp-num ${r.gain >= 0 ? 'fp-pos' : 'fp-neg'}`}>{formatMoney(r.gain)}</td>
                  <td className={`fp-num ${r.gainPct >= 0 ? 'fp-pos' : 'fp-neg'}`}>{formatPercent(r.gainPct)}</td>
                  <td className="fp-actions-cell">
                    <button type="button" className="fp-remove" onClick={() => removeRow(idx)} title="Remove row">
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

