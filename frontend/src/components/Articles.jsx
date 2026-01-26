import { Link } from 'react-router-dom'
import articlesData from '../data/articles.json'
import './Articles.css'

function Articles() {
  return (
    <section id="articles" className="articles">
      <div className="section-container">
        <div className="section-header">
          <h2 className="section-title">Educational Articles</h2>
          <p className="section-subtitle">
            Comprehensive guides on AI technologies, from beginner to advanced
          </p>
        </div>

        <div className="articles-grid">
          {articlesData.categories.map((category) => (
            <div key={category.id} className="article-category">
              <h3 className="category-title">{category.title}</h3>
              <p className="category-description">{category.description}</p>
              <div className="articles-list">
                {category.articles.map((article) => (
                  <Link 
                    key={article.id} 
                    to={`/article/${article.id}`}
                    className="article-item"
                  >
                    <div>
                      <h4 className="article-title">{article.title}</h4>
                      {article.excerpt && (
                        <p className="article-excerpt">{article.excerpt}</p>
                      )}
                    </div>
                    <span className={`article-status ${article.status}`}>
                      {article.status === 'published' ? 'Read →' : article.status}
                    </span>
                  </Link>
                ))}
              </div>
            </div>
          ))}
        </div>
      </div>
    </section>
  )
}

export default Articles
