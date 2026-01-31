import { useState } from 'react'
import { useNavigate, useLocation } from 'react-router-dom'
import './Navigation.css'

function Navigation() {
  const [isMenuOpen, setIsMenuOpen] = useState(false)
  const navigate = useNavigate()
  const location = useLocation()

  const scrollToSection = (sectionId) => {
    // If we're not on the home page, navigate there first
    if (location.pathname !== '/') {
      navigate('/')
      // Wait a bit for navigation, then scroll
      setTimeout(() => {
        const element = document.getElementById(sectionId)
        if (element) {
          element.scrollIntoView({ behavior: 'smooth' })
        }
      }, 100)
    } else {
      // We're already on home page, just scroll
      const element = document.getElementById(sectionId)
      if (element) {
        element.scrollIntoView({ behavior: 'smooth' })
      }
    }
    setIsMenuOpen(false)
  }

  const handleResumeClick = (e) => {
    e.preventDefault()
    navigate('/resume')
    setIsMenuOpen(false)
  }

  const handleAgenticAIClick = (e) => {
    e.preventDefault()
    navigate('/agentic-ai')
    setIsMenuOpen(false)
  }

  const handleGenerativeAIClick = (e) => {
    e.preventDefault()
    navigate('/generative-ai')
    setIsMenuOpen(false)
  }

  const handleJobSearchClick = (e) => {
    e.preventDefault()
    navigate('/job-search')
    setIsMenuOpen(false)
  }

  const handleFinancialPlanningClick = (e) => {
    e.preventDefault()
    navigate('/financial-planning')
    setIsMenuOpen(false)
  }

  const handleHomeClick = (e) => {
    e.preventDefault()
    if (location.pathname !== '/') {
      navigate('/')
      // Wait for navigation, then scroll to top
      setTimeout(() => {
        window.scrollTo({ top: 0, behavior: 'smooth' })
      }, 100)
    } else {
      // Already on home, just scroll to top
      window.scrollTo({ top: 0, behavior: 'smooth' })
    }
    setIsMenuOpen(false)
  }

  return (
    <nav className="navigation">
      <div className="nav-container">
        <div className="nav-logo" onClick={handleHomeClick} style={{ cursor: 'pointer', display: 'flex', alignItems: 'center', gap: '0.8rem' }}>
          <img 
            src="/images/fred-picture.png" 
            alt="Fred Jabbari" 
            className="nav-owner-image"
            style={{ width: '40px', height: '40px', borderRadius: '50%', objectFit: 'cover', border: '2px solid rgba(102, 126, 234, 0.3)' }}
          />
          <h2>FFJ Consulting</h2>
        </div>
        
        <button 
          className="menu-toggle"
          onClick={() => setIsMenuOpen(!isMenuOpen)}
          aria-label="Toggle menu"
        >
          <span></span>
          <span></span>
          <span></span>
        </button>
        
        <ul className={`nav-links ${isMenuOpen ? 'open' : ''}`}>
          <li><a href="/" onClick={handleHomeClick}>Home</a></li>
          <li><a href="/#technologies" onClick={(e) => { e.preventDefault(); scrollToSection('technologies') }}>AI Technologies</a></li>
          <li><a href="/agentic-ai" onClick={handleAgenticAIClick}>Agentic AI</a></li>
          <li><a href="/generative-ai" onClick={handleGenerativeAIClick}>Generative AI</a></li>
          <li><a href="/job-search" onClick={handleJobSearchClick}>Job Search</a></li>
          <li><a href="/financial-planning" onClick={handleFinancialPlanningClick}>Financial Planning</a></li>
          <li><a href="/#articles" onClick={(e) => { e.preventDefault(); scrollToSection('articles') }}>Articles</a></li>
          <li><a href="/#tools" onClick={(e) => { e.preventDefault(); scrollToSection('tools') }}>Tools</a></li>
          <li><a href="/resume" onClick={handleResumeClick}>Resume</a></li>
          <li><a href="/docs" target="_blank" rel="noopener noreferrer">Documentation</a></li>
          <li><a href="/#about" onClick={(e) => { e.preventDefault(); scrollToSection('about') }}>About</a></li>
        </ul>
      </div>
    </nav>
  )
}

export default Navigation
