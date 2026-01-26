import toolsData from '../data/tools.json'
import './Tools.css'

function Tools() {
  const tools = toolsData.tools

  return (
    <section id="tools" className="tools">
      <div className="section-container">
        <div className="section-header">
          <h2 className="section-title">AI Development Tools</h2>
          <p className="section-subtitle">
            Essential tools that enhance your AI development workflow
          </p>
        </div>

        <div className="tools-grid">
          {tools.map((tool, index) => (
            <div key={index} className="tool-card">
              <div className="tool-header">
                <h3 className="tool-name">{tool.name}</h3>
                <span className="tool-category">{tool.category}</span>
              </div>
              <p className="tool-description">{tool.description}</p>
              <div className="tool-features">
                <h4>Key Features:</h4>
                <ul>
                  {tool.features.map((feature, fIndex) => (
                    <li key={fIndex}>{feature}</li>
                  ))}
                </ul>
              </div>
              <div className="tool-content-placeholder">
                <p>📝 Tutorials and examples coming soon</p>
                <ul>
                  <li>Getting started guides</li>
                  <li>Real-world use cases</li>
                  <li>Best practices</li>
                  <li>Integration examples</li>
                </ul>
              </div>
              <div className="tool-actions">
                <a 
                  href={tool.links.website} 
                  target="_blank" 
                  rel="noopener noreferrer"
                  className="tool-link"
                >
                  Visit {tool.name} →
                </a>
                {tool.links.docs && (
                  <a 
                    href={tool.links.docs} 
                    target="_blank" 
                    rel="noopener noreferrer"
                    className="tool-link-secondary"
                  >
                    Documentation →
                  </a>
                )}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default Tools
