import technologiesData from '../data/technologies.json'
import './AITechnologies.css'

function AITechnologies() {
  const technologies = technologiesData.technologies

  return (
    <section id="technologies" className="ai-technologies">
      <div className="section-container">
        <div className="section-header">
          <h2 className="section-title">AI Technologies</h2>
          <p className="section-subtitle">
            Explore the leading AI platforms and technologies powering the future
          </p>
        </div>

        <div className="tech-grid">
          {technologies.map((tech, index) => (
            <div key={index} className="tech-card">
              <div className="tech-header" style={{ borderTopColor: tech.color }}>
                <h3 className="tech-name">{tech.name}</h3>
                <div className="tech-products">
                  {tech.products.map((product, pIndex) => (
                    <span key={pIndex} className="tech-product-tag">{product}</span>
                  ))}
                </div>
              </div>
              <p className="tech-description">{tech.description}</p>
              <div className="tech-sections">
                {tech.sections.map((section, sIndex) => (
                  <div key={sIndex} className="tech-section">
                    <h4>{section.title}</h4>
                    <p>{section.content}</p>
                  </div>
                ))}
              </div>
              {tech.links && (
                <div className="tech-links">
                  <a href={tech.links.website} target="_blank" rel="noopener noreferrer" className="tech-link">
                    Visit Website →
                  </a>
                  {tech.links.docs && (
                    <a href={tech.links.docs} target="_blank" rel="noopener noreferrer" className="tech-link">
                      Documentation →
                    </a>
                  )}
                </div>
              )}
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default AITechnologies
