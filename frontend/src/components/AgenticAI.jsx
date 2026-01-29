import { useNavigate } from 'react-router-dom'
import Navigation from './Navigation'
import Footer from './Footer'
import AILinksDirectory from './AILinksDirectory'
import './AIPages.css'

function AgenticAI() {
  const navigate = useNavigate()
  const apps = [
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
  ]

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

        <AILinksDirectory
          title="Agentic AI"
          storageKey="ffj.aiLinks.agentic"
          defaultApps={apps}
        />
      </div>
      <Footer />
    </div>
  )
}

export default AgenticAI

