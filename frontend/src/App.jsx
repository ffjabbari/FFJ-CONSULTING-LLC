import { useState, useEffect } from 'react'
import { BrowserRouter as Router, Routes, Route, useNavigate, useLocation } from 'react-router-dom'
import axios from 'axios'
import LandingPage from './components/LandingPage'
import Navigation from './components/Navigation'
import Hero from './components/Hero'
import AITechnologies from './components/AITechnologies'
import Articles from './components/Articles'
import Tools from './components/Tools'
import Footer from './components/Footer'
import ArticleDetail from './components/ArticleDetail'
import Resume from './components/Resume'
import './App.css'

function MainSite() {
  return (
    <div className="app">
      <Navigation />
      <Hero />
      <AITechnologies />
      <Articles />
      <Tools />
      <Footer />
    </div>
  )
}

function AppContent() {
  const [showLanding, setShowLanding] = useState(true)
  const navigate = useNavigate()
  const location = useLocation()

  useEffect(() => {
    // Check if user has visited before (stored in sessionStorage)
    const hasVisited = sessionStorage.getItem('hasVisited')
    
    // Only show landing page on root path if user hasn't visited
    if (location.pathname !== '/' || hasVisited) {
      setShowLanding(false)
    }
  }, [location.pathname])

  const handleEnterSite = () => {
    setShowLanding(false)
    sessionStorage.setItem('hasVisited', 'true')
    navigate('/')
    window.scrollTo({ top: 0, behavior: 'smooth' })
  }

  // Don't show landing page for non-root routes
  if (showLanding && location.pathname === '/') {
    return <LandingPage onEnter={handleEnterSite} />
  }

  return (
    <Routes>
      <Route path="/" element={<MainSite />} />
      <Route path="/article/:articleId" element={<ArticleDetail />} />
      <Route path="/resume" element={<Resume />} />
    </Routes>
  )
}

function App() {
  return (
    <Router>
      <AppContent />
    </Router>
  )
}

export default App
