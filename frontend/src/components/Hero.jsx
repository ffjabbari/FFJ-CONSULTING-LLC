import './Hero.css'

function Hero() {
  return (
    <section id="home" className="hero">
      <div className="hero-content">
        <h1 className="hero-title">
          We embed AI into digital experiences, workflows, and systems to drive measurable business impact.
        </h1>
        <p className="hero-subtitle">
          Learn how to leverage Agentic and Generative AI technologies to transform your business
        </p>
        <div className="hero-cta">
          <button className="btn-primary" onClick={() => {
            document.getElementById('technologies')?.scrollIntoView({ behavior: 'smooth' })
          }}>
            Explore AI Technologies
          </button>
          <button className="btn-secondary" onClick={() => {
            document.getElementById('articles')?.scrollIntoView({ behavior: 'smooth' })
          }}>
            Read Articles
          </button>
        </div>
      </div>
    </section>
  )
}

export default Hero
