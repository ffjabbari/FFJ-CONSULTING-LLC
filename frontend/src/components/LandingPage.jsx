import { useState, useEffect } from 'react'
import './LandingPage.css'

/**
 * Landing hero — positions FFJ Consulting as an Agentic AI practice.
 *
 * Replaces the earlier GPU/TPU hardware animation. Hardware is a commodity story;
 * the differentiator is orchestrating agents against enterprise systems, so the
 * animation shows a reasoning core delegating to tools and sub-agents.
 */

const AGENTS = [
  { name: 'Kiro',        role: 'Spec-driven agentic IDE',  icon: '◆' },
  { name: 'Amazon Q',    role: 'AWS-native assistant',     icon: '◇' },
  { name: 'Claude',      role: 'Reasoning & code',         icon: '✦' },
  { name: 'Cursor',      role: 'Inline agentic editing',   icon: '▲' },
  { name: 'ChatGPT',     role: 'OpenAI API',               icon: '●' },
  { name: 'Bedrock',     role: 'Managed model runtime',    icon: '■' },
]

const CAPABILITIES = [
  'Model Context Protocol (MCP)',
  'Sub-agent orchestration',
  'Human-in-the-loop approval gates',
  'Vector search & RAG',
  'Steering-driven standards',
  'Governed tool access',
]

function LandingPage({ onEnter }) {
  const [step, setStep] = useState(0)
  const [showPrompt, setShowPrompt] = useState(false)

  useEffect(() => {
    if (step < 4) {
      const timer = setTimeout(() => setStep(step + 1), 1100)
      return () => clearTimeout(timer)
    }
    const timer = setTimeout(() => setShowPrompt(true), 700)
    return () => clearTimeout(timer)
  }, [step])

  return (
    <div className="landing-page" onClick={onEnter}>
      <div className="landing-content">

        <p className={`landing-eyebrow ${step >= 0 ? 'visible' : ''}`}>
          FFJ Consulting LLC
        </p>

        <h1 className="landing-title">Agentic AI Engineering</h1>
        <p className="landing-subtitle">
          Principal-level consulting on autonomous agents, MCP architectures and
          AI-native software delivery — built on AWS, in production, at enterprise scale.
        </p>

        {/* Orbiting agent ecosystem around a reasoning core */}
        <div className="agent-system" aria-hidden="true">
          <div className={`agent-core ${step >= 1 ? 'visible' : ''}`}>
            <div className="core-ring" />
            <div className="core-ring core-ring-2" />
            <div className="core-label">
              <span className="core-label-top">AGENT</span>
              <span className="core-label-bottom">ORCHESTRATION</span>
            </div>
          </div>

          <div className={`agent-orbit ${step >= 2 ? 'visible' : ''}`}>
            {AGENTS.map((a, i) => (
              <div
                key={a.name}
                className="agent-node"
                style={{
                  '--i': i,
                  '--total': AGENTS.length,
                  animationDelay: `${i * 0.15}s`,
                }}
              >
                <span className="agent-icon">{a.icon}</span>
                <span className="agent-name">{a.name}</span>
                <span className="agent-role">{a.role}</span>
              </div>
            ))}
          </div>
        </div>

        <div className={`capability-strip ${step >= 3 ? 'visible' : ''}`}>
          {CAPABILITIES.map((c) => (
            <span className="capability" key={c}>{c}</span>
          ))}
        </div>

        <div className={`landing-proof ${step >= 4 ? 'visible' : ''}`}>
          <div className="proof-item">
            <strong>25+ yrs</strong>
            <span>Enterprise engineering</span>
          </div>
          <div className="proof-item">
            <strong>M.S. AI</strong>
            <span>Washington University</span>
          </div>
          <div className="proof-item">
            <strong>AWS</strong>
            <span>Bedrock · EKS · OpenSearch</span>
          </div>
        </div>

        {showPrompt && (
          <div className="click-prompt">
            <p>Click anywhere to explore the practice</p>
            <div className="arrow-down">↓</div>
          </div>
        )}
      </div>
    </div>
  )
}

export default LandingPage
