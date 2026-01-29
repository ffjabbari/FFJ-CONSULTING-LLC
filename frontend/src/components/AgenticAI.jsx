import { useMemo, useState } from 'react'
import { useNavigate } from 'react-router-dom'
import Navigation from './Navigation'
import Footer from './Footer'
import './AIPages.css'

function AgenticAI() {
  const navigate = useNavigate()
  const [query, setQuery] = useState('')

  const apps = useMemo(
    () => [
      {
        name: 'Amazon Bedrock Agents (Docs)',
        description: 'AWS-native agent orchestration: tool use, multi-step planning, guardrails, and integrations.',
        url: 'https://docs.aws.amazon.com/bedrock/latest/userguide/agents.html',
      },
      {
        name: 'Amazon Bedrock Knowledge Bases (Docs)',
        description: 'RAG for agents: ground responses in your documents with citations and retrieval.',
        url: 'https://docs.aws.amazon.com/bedrock/latest/userguide/knowledge-base.html',
      },
      {
        name: 'LangGraph (Docs)',
        description: 'Graph-based agent workflows with state, tools, and multi-agent patterns (LangChain ecosystem).',
        url: 'https://langchain-ai.github.io/langgraph/',
      },
      {
        name: 'LangChain Agents (Docs)',
        description: 'Agent patterns, tools, and routing for multi-step tasks.',
        url: 'https://python.langchain.com/docs/how_to/agent_executor/',
      },
      {
        name: 'Microsoft Semantic Kernel (GitHub)',
        description: 'SDK for agent-like apps with plugins/tools, planners, and memory patterns.',
        url: 'https://github.com/microsoft/semantic-kernel',
      },
      {
        name: 'AutoGen (GitHub)',
        description: 'Multi-agent conversation frameworks for tool use and task decomposition.',
        url: 'https://github.com/microsoft/autogen',
      },
      {
        name: 'CrewAI (Docs)',
        description: 'Role-based multi-agent orchestration for tasks and workflows.',
        url: 'https://docs.crewai.com/',
      },
      {
        name: 'OpenAI Assistants (Docs)',
        description: 'Tool-using assistants: function calling, retrieval, and structured workflows.',
        url: 'https://platform.openai.com/docs/assistants/overview',
      },
      {
        name: 'Anthropic Tool Use (Docs)',
        description: 'Agentic building blocks: tool use/function calling patterns for Claude-based apps.',
        url: 'https://docs.anthropic.com/claude/docs/tool-use',
      },
      {
        name: 'LlamaIndex Agents (Docs)',
        description: 'Agentic workflows + RAG: tools, query engines, and agent loops.',
        url: 'https://docs.llamaindex.ai/en/stable/understanding/agent/',
      },
    ],
    []
  )

  const filteredApps = useMemo(() => {
    const q = query.trim().toLowerCase()
    if (!q) return apps
    return apps.filter((a) => {
      const haystack = `${a.name} ${a.description}`.toLowerCase()
      return haystack.includes(q)
    })
  }, [apps, query])

  return (
    <div className="ai-page">
      <Navigation />
      <div className="ai-page-container">
        <button className="back-button" onClick={() => navigate('/')}>
          ← Back to Home
        </button>

        <header className="ai-page-header">
          <h1>Agentic AI</h1>
          <p>
            Educational links for multi-step AI workflows (agents) that can plan, call tools, and complete
            tasks. Each app opens in a new browser tab.
          </p>
        </header>

        <div className="ai-note">
          These are external educational resources (not hosted in your AWS account). We’ll later add your
          own AWS-backed demos here as separate “apps/services”.
        </div>

        <section className="ai-links" aria-label="Agentic AI links">
          <div className="ai-links-toolbar">
            <label className="ai-search">
              <span className="ai-search-label">Search</span>
              <input
                value={query}
                onChange={(e) => setQuery(e.target.value)}
                placeholder="Filter by app name or description…"
                aria-label="Search Agentic AI apps"
              />
            </label>
            <div className="ai-links-count">{filteredApps.length} results</div>
          </div>

          <div className="ai-table-wrap">
            <table className="ai-table">
              <thead>
                <tr>
                  <th style={{ width: '32%' }}>App Name</th>
                  <th>Description</th>
                </tr>
              </thead>
              <tbody>
                {filteredApps.map((app) => (
                  <tr key={app.url}>
                    <td>
                      <a href={app.url} target="_blank" rel="noopener noreferrer">
                        {app.name}
                      </a>
                    </td>
                    <td>{app.description}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      </div>
      <Footer />
    </div>
  )
}

export default AgenticAI

