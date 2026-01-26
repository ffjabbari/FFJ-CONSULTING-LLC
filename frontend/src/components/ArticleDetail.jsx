import { useState, useEffect } from 'react'
import { useParams, useNavigate } from 'react-router-dom'
import ReactMarkdown from 'react-markdown'
import articlesData from '../data/articles.json'
import './ArticleDetail.css'

function ArticleDetail() {
  const { articleId } = useParams()
  const navigate = useNavigate()
  const [article, setArticle] = useState(null)
  const [content, setContent] = useState('')
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    // Find the article
    let foundArticle = null
    for (const category of articlesData.categories) {
      foundArticle = category.articles.find(a => a.id === articleId)
      if (foundArticle) break
    }

    if (foundArticle) {
      setArticle(foundArticle)
      // Load markdown content
      loadContent(foundArticle.contentFile)
    } else {
      setLoading(false)
    }
  }, [articleId])

  const loadContent = async (contentFile) => {
    try {
      // Try loading from public folder first (for production)
      let response = await fetch(`/content/${contentFile}`)
      
      // If not found, try src path (for development)
      if (!response.ok) {
        response = await fetch(`/src/content/${contentFile}`)
      }
      
      // If still not found, try importing directly
      if (!response.ok) {
        try {
          const module = await import(`../content/${contentFile}?raw`)
          setContent(module.default)
          setLoading(false)
          return
        } catch (importError) {
          console.error('Import error:', importError)
        }
      }
      
      if (response.ok) {
        const text = await response.text()
        setContent(text)
      } else {
        setContent('# Article Content\n\nContent file not found. Please add the content file.')
      }
    } catch (error) {
      console.error('Error loading content:', error)
      setContent('# Article Content\n\nError loading content.')
    } finally {
      setLoading(false)
    }
  }

  if (loading) {
    return <div className="article-detail-loading">Loading...</div>
  }

  if (!article) {
    return (
      <div className="article-detail">
        <div className="article-not-found">
          <h1>Article Not Found</h1>
          <button onClick={() => navigate('/')}>Back to Home</button>
        </div>
      </div>
    )
  }

  return (
    <div className="article-detail">
      <div className="article-detail-container">
        <button className="back-button" onClick={() => navigate('/')}>
          ← Back to Articles
        </button>
        
        <article className="article-content">
          <header className="article-header">
            <h1>{article.title}</h1>
            <div className="article-meta">
              <span className="article-author">By {article.author}</span>
              <span className="article-date">{new Date(article.date).toLocaleDateString()}</span>
              <span className={`article-status ${article.status}`}>{article.status}</span>
            </div>
            <div className="article-tags">
              {article.tags.map(tag => (
                <span key={tag} className="tag">{tag}</span>
              ))}
            </div>
            {article.excerpt && (
              <p className="article-excerpt">{article.excerpt}</p>
            )}
          </header>

          <div className="article-body">
            <ReactMarkdown>{content}</ReactMarkdown>
          </div>
        </article>
      </div>
    </div>
  )
}

export default ArticleDetail
