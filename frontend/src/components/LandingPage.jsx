import { useState, useEffect } from 'react'
import './LandingPage.css'

function LandingPage({ onEnter }) {
  const [animationStep, setAnimationStep] = useState(0)
  const [showClickPrompt, setShowClickPrompt] = useState(false)

  useEffect(() => {
    // Animation sequence
    const timer = setTimeout(() => {
      if (animationStep < 4) {
        setAnimationStep(animationStep + 1)
      } else {
        setShowClickPrompt(true)
      }
    }, 2000)

    return () => clearTimeout(timer)
  }, [animationStep])

  const handleClick = () => {
    onEnter()
  }

  return (
    <div className="landing-page" onClick={handleClick}>
      <div className="landing-content">
        <h1 className="landing-title">Understanding AI Hardware</h1>
        <p className="landing-subtitle">How GPUs and TPUs Power Modern AI</p>
        
        <div className="animation-container">
          <div className={`chip gpu ${animationStep >= 1 ? 'visible' : ''}`}>
            <div className="chip-label">GPU</div>
            <div className="chip-structure">
              <div className="core"></div>
              <div className="core"></div>
              <div className="core"></div>
              <div className="core"></div>
            </div>
          </div>
          
          <div className={`chip tpu ${animationStep >= 2 ? 'visible' : ''}`}>
            <div className="chip-label">TPU</div>
            <div className="chip-structure">
              <div className="matrix"></div>
            </div>
          </div>
          
          <div className={`data-flow ${animationStep >= 3 ? 'visible' : ''}`}>
            <div className="data-stream"></div>
            <div className="data-stream"></div>
            <div className="data-stream"></div>
          </div>
        </div>

        {showClickPrompt && (
          <div className="click-prompt">
            <p>Click anywhere to explore AI technologies</p>
            <div className="arrow-down">↓</div>
          </div>
        )}
      </div>
    </div>
  )
}

export default LandingPage
