# Content Update Guide

This guide explains how to update the website content through Cursor by pointing to articles or data sources.

## Content Structure

The website content is managed through JSON data files and Markdown content files:

```
frontend/src/
├── data/
│   ├── articles.json      # Article metadata and structure
│   ├── technologies.json  # AI technology information
│   └── tools.json         # Tool information
└── content/
    └── *.md               # Markdown files for article content
```

## How to Update Content

### Method 1: Update via Cursor Chat

Simply tell Cursor what you want to update:

**Example 1: Add a new article**
```
Add a new article to the "Agentic AI" category. 
Title: "Advanced Agent Patterns"
Content: [paste your article content or point to a file]
```

**Example 2: Update technology information**
```
Update the NVIDIA section in technologies.json with information about Groq.
Add details about performance benchmarks and use cases.
```

**Example 3: Add a new tool**
```
Add a new tool to tools.json:
Name: "GitHub Copilot"
Category: "AI-Powered IDE"
Description: "AI pair programmer"
Features: [list features]
```

### Method 2: Direct File Updates

1. **Update Articles**: Edit `frontend/src/data/articles.json`
   - Add new article entries to the appropriate category
   - Create corresponding markdown file in `frontend/src/content/`
   - Reference the markdown file in `contentFile` field

2. **Update Technologies**: Edit `frontend/src/data/technologies.json`
   - Modify existing technology entries
   - Add new sections or update content

3. **Update Tools**: Edit `frontend/src/data/tools.json`
   - Add new tools or update existing ones
   - Add tutorials and examples

## Article Format

### JSON Entry (articles.json)
```json
{
  "id": "unique-article-id",
  "title": "Article Title",
  "excerpt": "Brief description",
  "status": "published" | "draft",
  "author": "Author Name",
  "date": "YYYY-MM-DD",
  "tags": ["tag1", "tag2"],
  "contentFile": "article-filename.md"
}
```

### Markdown Content File
Create a `.md` file in `frontend/src/content/` with:
- Standard markdown syntax
- Code blocks with syntax highlighting
- Images (place in `/public/images/articles/`)
- Links

## Quick Update Examples

### Add Article from External Source

**Tell Cursor:**
```
Add an article from this URL: [article URL]
Category: "Generative AI"
Title: "Understanding GPT-4"
Extract the content and create the article with proper formatting.
```

### Update from Document

**Tell Cursor:**
```
Read the content from /path/to/document.md and create a new article 
in the "AI Tools & Platforms" category titled "Getting Started with Cursor IDE".
```

### Bulk Update from Data Source

**Tell Cursor:**
```
Read this CSV/JSON file: [file path]
Create articles for each row/entry in the "Agentic AI" category.
Use the "title" column for titles and "content" column for article bodies.
```

## Technology Updates

### Update Technology Information

**Tell Cursor:**
```
Update the OpenAI section in technologies.json:
- Add new product: "GPT-4 Turbo"
- Update description with latest information
- Add a new section about "Fine-tuning capabilities"
- Update links to latest documentation
```

## Tool Updates

### Add New Tool

**Tell Cursor:**
```
Add a new tool to tools.json:
- Name: "GitHub Copilot"
- Extract information from: [URL or file]
- Include features, tutorials, and examples
```

## Content Validation

After updating content, the site will automatically:
- Display new articles in the Articles section
- Show updated technology information
- Display new tools in the Tools section

## Testing Updates

1. **Local Testing**: Run `python3 start.py` and check http://localhost:3000
2. **Verify**: Check that new content appears correctly
3. **Article Links**: Test that article detail pages load properly

## Deployment

After content updates are complete, tell Cursor:
```
Deploy the updated site to AWS
```

This will trigger the AWS deployment process.

## Tips

1. **Use Clear Instructions**: Be specific about what section to update
2. **Point to Sources**: Provide URLs, file paths, or paste content directly
3. **Specify Format**: Mention if you want technical or non-technical content
4. **Batch Updates**: You can ask Cursor to update multiple items at once

## File Locations Reference

- Articles metadata: `frontend/src/data/articles.json`
- Article content: `frontend/src/content/*.md`
- Technologies: `frontend/src/data/technologies.json`
- Tools: `frontend/src/data/tools.json`
