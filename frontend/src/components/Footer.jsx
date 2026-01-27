import { getFullUrl, GITHUB_REPO } from '../config'
import './Footer.css'

function Footer() {
  return (
    <footer id="about" className="footer">
      <div className="footer-container">
        <div className="footer-content">
          <div className="footer-section">
            <div className="footer-logo-section">
              <img 
                src="/images/fred-picture.png" 
                alt="Fred" 
                className="footer-owner-image"
              />
              <h3>FFJ Consulting LLC</h3>
            </div>
            <p>Empowering businesses with AI technologies and expert consulting services.</p>
          </div>
          
          <div className="footer-section">
            <h4>Quick Links</h4>
            <ul>
              <li><a href="#home">Home</a></li>
              <li><a href="#technologies">AI Technologies</a></li>
              <li><a href="#articles">Articles</a></li>
              <li><a href="#tools">Tools</a></li>
            </ul>
          </div>
          
          <div className="footer-section">
            <h4>Resources</h4>
            <ul>
              <li><a href="#articles">Learning Resources</a></li>
              <li><a href="#tools">Development Tools</a></li>
              <li><a href="#technologies">Technology Guides</a></li>
              <li><a href="/docs" target="_blank" rel="noopener noreferrer">Documentation</a></li>
              <li><a href="/docs/index.html" target="_blank" rel="noopener noreferrer">Full Documentation Portal</a></li>
            </ul>
          </div>
          
          <div className="footer-section">
            <h4>Contact & Resources</h4>
            <p>Get in touch for consulting services</p>
            <div className="footer-links">
              <a href={getFullUrl('/resume')}>View Resume</a>
              <a href={getFullUrl('/article/ai-revolution-demo')}>AI History Article</a>
              <a href={getFullUrl('/docs')} target="_blank" rel="noopener noreferrer">
                Documentation
              </a>
              <a href={GITHUB_REPO} target="_blank" rel="noopener noreferrer">
                GitHub Source Code
              </a>
            </div>
            <p className="powered-by">
              Powered by: <strong>C#</strong>
            </p>
          </div>
        </div>
        
        <div className="footer-bottom">
          <p>&copy; 2025 FFJ Consulting LLC. All rights reserved.</p>
        </div>
      </div>
    </footer>
  )
}

export default Footer
