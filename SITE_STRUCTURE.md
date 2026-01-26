# Site Structure - FFJ Consulting LLC

## Overview
Professional AI education website with landing page animation and comprehensive content sections.

## Site Flow

1. **Landing Page** (GPU/TPU Animation)
   - Animated visualization of GPU and TPU chips
   - Click anywhere to enter main site
   - Smooth transition

2. **Main Site** (After landing page)
   - Navigation bar (fixed at top)
   - Hero section
   - AI Technologies section
   - Articles section
   - Tools section
   - Footer

## Component Structure

```
frontend/src/
├── App.jsx                 # Main app with routing logic
├── App.css                 # Global styles
├── main.jsx                # Entry point
├── index.css               # Base styles
└── components/
    ├── LandingPage.jsx      # GPU/TPU animation landing
    ├── LandingPage.css
    ├── Navigation.jsx      # Top navigation bar
    ├── Navigation.css
    ├── Hero.jsx            # Hero section (Clear Digital style)
    ├── Hero.css
    ├── AITechnologies.jsx  # NVIDIA, Anthropic, OpenAI
    ├── AITechnologies.css
    ├── Articles.jsx        # Article/blog structure
    ├── Articles.css
    ├── Tools.jsx           # Cursor, Amazon Q, etc.
    ├── Tools.css
    ├── Footer.jsx          # Footer with links
    └── Footer.css
```

## Sections

### 1. Landing Page
- **Purpose**: Eye-catching entry point with GPU/TPU animation
- **Features**: 
  - Animated chip visualizations
  - Data flow animations
  - Click to enter prompt

### 2. Hero Section
- **Style**: Inspired by Clear Digital's AI Enablement page
- **Content**: Main value proposition
- **CTAs**: Explore Technologies, Read Articles

### 3. AI Technologies
- **NVIDIA**: Groq, CUDA, TensorRT
- **Anthropic**: Claude, Constitutional AI
- **OpenAI**: GPT-4, DALL-E, ChatGPT
- **Status**: Skeleton ready for content

### 4. Articles Section
- **Categories**:
  - Agentic AI
  - Generative AI
  - AI Tools & Platforms
- **Status**: Structure ready, articles marked "Coming soon"

### 5. Tools Section
- **Cursor**: AI-powered IDE
- **Amazon Q**: AWS AI assistant
- **Status**: Basic info, tutorials coming soon

### 6. Footer
- Company info
- Quick links
- Contact info
- "Powered by" indicator

## Design System

### Colors
- Primary Gradient: `#667eea` → `#764ba2`
- Dark Background: `#0a0e27`, `#1a1f3a`, `#2d1b4e`
- Light Background: `#f8f9fa`, `white`
- Text: `#0a0e27` (dark), `white` (light)

### Typography
- Headings: Bold, large (2rem - 4rem)
- Body: Regular, readable (1rem - 1.2rem)
- Font: System font stack

### Spacing
- Section padding: 6rem vertical, 2rem horizontal
- Card padding: 2.5rem
- Consistent gaps: 1rem - 3rem

## Next Steps

1. ✅ Skeleton structure complete
2. ⏳ Add real content to sections
3. ⏳ Create article detail pages
4. ⏳ Add backend API for dynamic content
5. ⏳ Implement search functionality
6. ⏳ Add contact form

## Running the Site

```bash
# Start both services
python3 start.py

# Or separately:
# Backend: cd backend/FFJConsulting.API && dotnet run
# Frontend: cd frontend && npm run dev
```

Access at: http://localhost:3000
