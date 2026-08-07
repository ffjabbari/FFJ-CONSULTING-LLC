import { useState, useEffect } from 'react'
import { useNavigate } from 'react-router-dom'
import ReactMarkdown from 'react-markdown'
import Navigation from './Navigation'
import Footer from './Footer'
import './Resume.css'

function Resume() {
  const navigate = useNavigate()
  // Resume content will be loaded from markdown file
  const [resumeContent, setResumeContent] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    loadResume()
  }, [])

  const loadResume = async () => {
    try {
      // Try loading from public folder first (for production)
      let response = await fetch('/content/resume.md')
      
      // If not found, try src path (for development)
      if (!response.ok) {
        response = await fetch('/src/content/resume.md')
      }
      
      if (response.ok) {
        const text = await response.text()
        setResumeContent(text)
      } else {
        setResumeContent('# Resume\n\nResume content will be loaded here.')
      }
    } catch (error) {
      console.error('Error loading resume:', error)
      setResumeContent('# Resume\n\nError loading resume content.')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return <div className="resume-loading">Loading resume...</div>
  }

  return (
    <div className="resume-page">
      <Navigation />
      <div className="resume-container">
        <button className="back-button" onClick={() => navigate('/')}>
          ← Back to Home
        </button>
        
        <header className="resume-header">
          <h1>Fred Jabbari - Resume</h1>
          <p className="resume-subtitle">Professional Experience & Expertise</p>
        </header>
        
        <div className="resume-content">
          <ReactMarkdown>{resumeContent}</ReactMarkdown>
        </div>
      </div>
      <Footer />
    </div>
  )
}

export default Resume
