import { useNavigate } from 'react-router-dom'
import Navigation from './Navigation'
import Footer from './Footer'
import AILinksDirectory from './AILinksDirectory'
import './AIPages.css'

function GenerativeAI() {
  const navigate = useNavigate()
  const apps = [
    {
      name: 'Amazon Bedrock (User Guide)',
      description: 'Learn how to invoke foundation models on AWS (text, embeddings, images) and build GenAI apps.',
      url: 'https://docs.aws.amazon.com/bedrock/latest/userguide/what-is-bedrock.html',
    },
    {
      name: 'Amazon Bedrock Playground (Console)',
      description: 'Try prompts interactively in the AWS console (requires AWS login).',
      url: 'https://console.aws.amazon.com/bedrock/home',
    },
    {
      name: 'Hugging Face Spaces',
      description: 'Explore thousands of live GenAI demos (text, vision, audio) hosted by the community.',
      url: 'https://huggingface.co/spaces',
    },
    {
      name: 'Chatbot Arena (LMSYS)',
      description: 'Compare LLMs head-to-head in a live chat UI and see which answers you prefer.',
      url: 'https://chat.lmsys.org/',
    },
    {
      name: 'OpenAI Playground',
      description: 'Experiment with prompts, sampling params, and model behaviors (requires account).',
      url: 'https://platform.openai.com/playground',
    },
    {
      name: 'Anthropic Console',
      description: 'Prompt and iterate with Claude models (requires account).',
      url: 'https://console.anthropic.com/',
    },
    {
      name: 'Prompting Guide',
      description: 'Practical prompt engineering techniques and examples across common tasks.',
      url: 'https://www.promptingguide.ai/',
    },
    {
      name: 'LangChain Prompt Templates (Docs)',
      description: 'How to structure reusable prompts and chains for summarization, extraction, and more.',
      url: 'https://python.langchain.com/docs/concepts/prompt_templates/',
    },
    {
      name: 'LlamaIndex RAG (Docs)',
      description: 'Learn retrieval-augmented generation patterns and how to ground responses in data.',
      url: 'https://docs.llamaindex.ai/en/stable/understanding/rag/',
    },
    {
      name: 'Stable Diffusion Web Demo (Hugging Face)',
      description: 'Text-to-image demo you can try in the browser (model + UI hosted on Hugging Face).',
      url: 'https://huggingface.co/spaces/stabilityai/stable-diffusion',
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
          <h1>Generative AI</h1>
          <p>
            Educational links for content generation, transformation, and summarization. Each app opens in
            a new browser tab.
          </p>
        </header>

        <div className="ai-note">
          These are external educational resources (not hosted in your AWS account). We’ll later add your
          own AWS-backed demos here as separate “apps/services”.
        </div>

        <AILinksDirectory
          title="Generative AI"
          storageKey="ffj.aiLinks.generative"
          defaultApps={apps}
        />
      </div>
      <Footer />
    </div>
  )
}

export default GenerativeAI

