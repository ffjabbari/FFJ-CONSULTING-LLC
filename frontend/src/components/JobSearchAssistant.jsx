import { useMemo, useRef, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Navigation from './Navigation'
import Footer from './Footer'
import './JobSearchAssistant.css'

function uniq(arr) {
  return Array.from(new Set(arr))
}

function normalizeText(s) {
  return (s || '').toLowerCase().replace(/\s+/g, ' ').trim()
}

function encodeQueryParam(value) {
  return encodeURIComponent(value || '')
}

function guessQueryTitleFromResumeText(resumeText) {
  const raw = (resumeText || '').trim()
  if (!raw) return ''

  // If the user pasted a full resume, we shouldn't treat the whole thing as a title query.
  // Heuristic: short single-line inputs are treated as a "job title / keywords" query.
  const firstLine = raw.split('\n')[0].trim()
  const looksLikeShortQuery = firstLine.length > 0 && firstLine.length <= 80
  const singleLine = raw.split('\n').filter(Boolean).length <= 2

  if (looksLikeShortQuery && singleLine) return firstLine
  return ''
}

function buildLinkedInSearchUrl({ keywords, location, easyApply, remoteOnly }) {
  const base = 'https://www.linkedin.com/jobs/search/'
  const params = new URLSearchParams()
  if (keywords) params.set('keywords', keywords)
  if (location) params.set('location', location)

  // These params are not official/stable APIs; LinkedIn can change them anytime.
  // They are included as best-effort convenience toggles.
  if (easyApply) params.set('f_AL', 'true')
  if (remoteOnly) params.set('f_WT', '2') // often "remote"

  const qs = params.toString()
  return qs ? `${base}?${qs}` : base
}

function extractSignals(resumeText) {
  const t = normalizeText(resumeText)

  const titleCandidates = [
    'enterprise cloud architect',
    'cloud architect',
    'principal engineer',
    'solutions architect',
    'platform engineer',
    'devops engineer',
    'site reliability engineer',
    'full-stack engineer',
    'full stack engineer',
    'software engineer',
    'backend engineer',
    'frontend engineer',
    'data engineer',
    'ml engineer',
  ]

  const skillCandidates = [
    'aws',
    'kubernetes',
    'eks',
    'ecs',
    'lambda',
    'api gateway',
    's3',
    'cloudfront',
    'iam',
    'cloudwatch',
    'terraform',
    'cloudformation',
    'cdk',
    'jenkins',
    'github actions',
    'docker',
    'helm',
    'python',
    'java',
    'c#',
    '.net',
    'react',
    'node',
    'typescript',
    'microservices',
    'oauth',
    'okta',
    'bedrock',
  ]

  const titlesFound = titleCandidates.filter((c) => t.includes(c))
  const skillsFound = skillCandidates.filter((c) => t.includes(c))

  // Prefer a small, readable set.
  const topTitles = uniq(titlesFound).slice(0, 3)
  const topSkills = uniq(skillsFound).slice(0, 8)

  return { topTitles, topSkills }
}

function JobSearchAssistant() {
  const navigate = useNavigate()
  const resultsRef = useRef(null)

  const [resumeText, setResumeText] = useState('')
  const [location, setLocation] = useState('United States')
  const [easyApply, setEasyApply] = useState(true)
  const [remoteOnly, setRemoteOnly] = useState(false)
  const [preferredTitle, setPreferredTitle] = useState('')
  const [actionStatus, setActionStatus] = useState('')

  const signals = useMemo(() => extractSignals(resumeText), [resumeText])

  const hasCriteria = useMemo(() => {
    // Start with no results until the user provides either a title or resume text.
    return preferredTitle.trim() !== '' || resumeText.trim() !== ''
  }, [preferredTitle, resumeText])

  const searches = useMemo(() => {
    if (!hasCriteria) return []

    const queryTitleFromResume = guessQueryTitleFromResumeText(resumeText)

    const titles =
      preferredTitle.trim() !== ''
        ? [preferredTitle.trim()]
        : queryTitleFromResume
          ? [
              queryTitleFromResume,
              // Add a couple of reasonable variants for breadth (while staying relevant)
              'Cloud Architect',
              'DevOps Engineer',
            ]
          : signals.topTitles.length
            ? signals.topTitles
            : ['Cloud Architect', 'Platform Engineer', 'DevOps Engineer']

    const skills = signals.topSkills.length ? signals.topSkills : ['AWS', 'Kubernetes', 'Terraform']

    const locationValue = location.trim()

    const queries = []

    // Title-focused searches
    for (const title of titles) {
      queries.push({
        label: `Title: ${title}`,
        reason: 'Search by likely role title derived from the resume.',
        url: buildLinkedInSearchUrl({
          keywords: title,
          location: locationValue,
          easyApply,
          remoteOnly,
        }),
      })
    }

    // Skill-focused searches (3 variations)
    const skillGroups = [
      skills.slice(0, 3),
      skills.slice(3, 6),
      skills.slice(0, 2).concat(skills.slice(6, 8)),
    ].filter((g) => g.length)

    for (const group of skillGroups) {
      const kw = group.join(' ')
      queries.push({
        label: `Skills: ${group.join(', ')}`,
        reason: 'Search by core skills found in the resume.',
        url: buildLinkedInSearchUrl({
          keywords: kw,
          location: locationValue,
          easyApply,
          remoteOnly,
        }),
      })
    }

    // Combined searches (title + skills)
    const combinedTitle = titles[0]
    const combinedSkills = skills.slice(0, 4).join(' ')
    queries.push({
      label: `Combined: ${combinedTitle} + top skills`,
      reason: 'Most targeted: role title plus your strongest skills.',
      url: buildLinkedInSearchUrl({
        keywords: `${combinedTitle} ${combinedSkills}`.trim(),
        location: locationValue,
        easyApply,
        remoteOnly,
      }),
    })

    // De-dup by URL
    const seen = new Set()
    return queries.filter((q) => {
      if (seen.has(q.url)) return false
      seen.add(q.url)
      return true
    })
  }, [hasCriteria, signals.topTitles, signals.topSkills, preferredTitle, location, easyApply, remoteOnly])

  const openTopThree = () => {
    setActionStatus('')

    const top = searches.slice(0, 3)
    let opened = 0
    for (const s of top) {
      const win = window.open(s.url, '_blank', 'noopener,noreferrer')
      if (win) opened += 1
    }

    if (opened === 0) {
      setActionStatus('Popup blocked. Please allow popups or click links below.')
    } else if (opened < top.length) {
      setActionStatus(`Opened ${opened}/${top.length}. Some tabs may have been blocked.`)
    } else {
      setActionStatus(`Opened ${opened} tabs.`)
    }
  }

  return (
    <div className="job-search-page">
      <Navigation />
      <div className="job-search-container">
        <button className="back-button" onClick={() => navigate('/')}>
          ← Back to Home
        </button>

        <header className="job-search-header">
          <h1>Job Search Assistant</h1>
          <p>
            Generate LinkedIn job search links from a short keyword phrase or pasted resume text. This tool does not
            scrape LinkedIn — it creates clickable searches you can open in new tabs.
          </p>
        </header>

        <div className="job-search-form">
          <div className="job-search-row">
            <label>
              <span>Preferred title (optional)</span>
              <input
                value={preferredTitle}
                onChange={(e) => setPreferredTitle(e.target.value)}
                placeholder="e.g., Cloud Architect"
              />
            </label>
            <label>
              <span>Location</span>
              <input
                value={location}
                onChange={(e) => setLocation(e.target.value)}
                placeholder="e.g., St. Louis, MO"
              />
            </label>
          </div>

          <div className="job-search-toggles">
            <label className="toggle">
              <input
                type="checkbox"
                checked={easyApply}
                onChange={(e) => setEasyApply(e.target.checked)}
              />
              <span>Try Easy Apply filter (best-effort)</span>
            </label>
            <label className="toggle">
              <input
                type="checkbox"
                checked={remoteOnly}
                onChange={(e) => setRemoteOnly(e.target.checked)}
              />
              <span>Remote only (best-effort)</span>
            </label>
          </div>

          <label className="job-search-resume">
            <span>Resume text</span>
            <textarea
              value={resumeText}
              onChange={(e) => setResumeText(e.target.value)}
              placeholder="Paste resume text here…"
              rows={10}
            />
          </label>

          <div className="job-search-signals">
            <div>
              <strong>Detected titles:</strong>{' '}
              {signals.topTitles.length ? signals.topTitles.join(', ') : '—'}
            </div>
            <div>
              <strong>Detected skills:</strong>{' '}
              {signals.topSkills.length ? signals.topSkills.join(', ') : '—'}
            </div>
          </div>

          <div className="job-search-live-hint">Results update automatically as you type.</div>
        </div>

        <div className="job-search-results" id="job-search-results" ref={resultsRef}>
          <div className="job-search-results-header">
            <h2>Generated searches</h2>
            <div className="job-search-actions">
              <button
                className="job-search-btn job-search-btn-secondary"
                onClick={openTopThree}
                disabled={searches.length === 0}
              >
                Open top 3
              </button>
              {actionStatus && <div className="job-search-copy-status">{actionStatus}</div>}
            </div>
          </div>

          <div className="job-search-generated-title">
            Generated <strong>{searches.length}</strong> searches.
          </div>

          {!hasCriteria ? (
            <div className="job-search-empty">
              Start typing a <strong>Preferred title</strong> or paste <strong>Resume text</strong> to generate links.
            </div>
          ) : (
            <ul className="job-search-list">
              {searches.map((s) => (
                <li key={s.url} className="job-search-item">
                  <div className="job-search-item-title">
                    <a href={s.url} target="_blank" rel="noopener noreferrer">
                      {s.label} →
                    </a>
                  </div>
                  <div className="job-search-item-reason">{s.reason}</div>
                  <div className="job-search-item-url">
                    <code>{decodeURIComponent(s.url)}</code>
                  </div>
                </li>
              ))}
            </ul>
          )}

          <div className="job-search-note">
            Note: LinkedIn may change search URL parameters over time. If a filter link doesn’t work, re-run the
            search and apply filters directly in LinkedIn.
          </div>
        </div>
      </div>
      <Footer />
    </div>
  )
}

export default JobSearchAssistant

