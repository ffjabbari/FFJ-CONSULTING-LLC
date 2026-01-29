import { useEffect, useMemo, useState } from 'react'

function safeParseJson(value, fallback) {
  try {
    return JSON.parse(value)
  } catch {
    return fallback
  }
}

function isValidHttpUrl(value) {
  try {
    const u = new URL(value)
    return u.protocol === 'http:' || u.protocol === 'https:'
  } catch {
    return false
  }
}

function AILinksDirectory({ storageKey, defaultApps, title }) {
  const [query, setQuery] = useState('')
  const [customApps, setCustomApps] = useState([])
  const [showAdd, setShowAdd] = useState(false)
  const [name, setName] = useState('')
  const [description, setDescription] = useState('')
  const [url, setUrl] = useState('')
  const [error, setError] = useState('')

  useEffect(() => {
    const raw = localStorage.getItem(storageKey)
    const parsed = raw ? safeParseJson(raw, []) : []
    setCustomApps(Array.isArray(parsed) ? parsed : [])
  }, [storageKey])

  useEffect(() => {
    localStorage.setItem(storageKey, JSON.stringify(customApps))
  }, [customApps, storageKey])

  const apps = useMemo(() => {
    const sanitizedCustom = (customApps || []).filter(
      (a) => a && typeof a === 'object' && a.name && a.url && a.description
    )
    return [...sanitizedCustom, ...defaultApps]
  }, [customApps, defaultApps])

  const filteredApps = useMemo(() => {
    const q = query.trim().toLowerCase()
    if (!q) return apps
    return apps.filter((a) => {
      const haystack = `${a.name} ${a.description}`.toLowerCase()
      return haystack.includes(q)
    })
  }, [apps, query])

  const addLink = (e) => {
    e.preventDefault()
    setError('')

    const trimmedName = name.trim()
    const trimmedDesc = description.trim()
    const trimmedUrl = url.trim()

    if (!trimmedName || !trimmedDesc || !trimmedUrl) {
      setError('Please fill in App Name, Description, and URL.')
      return
    }
    if (!isValidHttpUrl(trimmedUrl)) {
      setError('Please enter a valid http(s) URL.')
      return
    }

    const exists = apps.some((a) => a.url === trimmedUrl)
    if (exists) {
      setError('That link already exists in the table.')
      return
    }

    setCustomApps((prev) => [
      { name: trimmedName, description: trimmedDesc, url: trimmedUrl },
      ...(prev || []),
    ])
    setName('')
    setDescription('')
    setUrl('')
    setShowAdd(false)
  }

  const removeCustomLink = (linkUrl) => {
    setCustomApps((prev) => (prev || []).filter((a) => a.url !== linkUrl))
  }

  const resetCustomLinks = () => {
    setCustomApps([])
  }

  return (
    <section className="ai-links" aria-label={`${title} links`}>
      <div className="ai-links-toolbar">
        <label className="ai-search">
          <span className="ai-search-label">Search</span>
          <input
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder="Filter by app name or description…"
            aria-label={`Search ${title} apps`}
          />
        </label>

        <div className="ai-links-actions">
          <button
            type="button"
            className="ai-button"
            onClick={() => setShowAdd((v) => !v)}
          >
            {showAdd ? 'Cancel' : 'Add Link'}
          </button>
          <button
            type="button"
            className="ai-button ai-button-secondary"
            onClick={resetCustomLinks}
            disabled={customApps.length === 0}
            title="Clears only the links you added in this browser"
          >
            Reset My Links
          </button>
          <div className="ai-links-count">{filteredApps.length} results</div>
        </div>
      </div>

      {showAdd && (
        <form className="ai-add-form" onSubmit={addLink}>
          <div className="ai-add-grid">
            <label className="ai-field">
              <span>App Name</span>
              <input value={name} onChange={(e) => setName(e.target.value)} />
            </label>
            <label className="ai-field">
              <span>URL</span>
              <input
                value={url}
                onChange={(e) => setUrl(e.target.value)}
                placeholder="https://..."
              />
            </label>
            <label className="ai-field ai-field-full">
              <span>Description</span>
              <input
                value={description}
                onChange={(e) => setDescription(e.target.value)}
                placeholder="What should users learn here?"
              />
            </label>
          </div>
          <div className="ai-add-actions">
            <button type="submit" className="ai-button">
              Add to Table
            </button>
            {error && <div className="ai-error" role="alert">{error}</div>}
            <div className="ai-add-hint">
              Saved in this browser only (localStorage).
            </div>
          </div>
        </form>
      )}

      <div className="ai-table-wrap">
        <table className="ai-table">
          <thead>
            <tr>
              <th style={{ width: '32%' }}>App Name</th>
              <th>Description</th>
            </tr>
          </thead>
          <tbody>
            {filteredApps.map((app) => {
              const isCustom = customApps.some((c) => c.url === app.url)
              return (
                <tr key={app.url}>
                  <td>
                    <div className="ai-app-name">
                      <a href={app.url} target="_blank" rel="noopener noreferrer">
                        {app.name}
                      </a>
                      {isCustom && (
                        <button
                          type="button"
                          className="ai-link-remove"
                          onClick={() => removeCustomLink(app.url)}
                          title="Remove (only from your browser)"
                        >
                          Remove
                        </button>
                      )}
                    </div>
                  </td>
                  <td>{app.description}</td>
                </tr>
              )
            })}
          </tbody>
        </table>
      </div>
    </section>
  )
}

export default AILinksDirectory

