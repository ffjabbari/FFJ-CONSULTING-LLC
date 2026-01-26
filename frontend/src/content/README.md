# Content Directory

This directory contains the markdown content files for articles.

## Structure

Each article should have a corresponding markdown file in this directory, referenced by the `contentFile` field in `articles.json`.

## Adding New Articles

1. Create a markdown file (e.g., `my-article.md`)
2. Add the article entry to `../data/articles.json`
3. Reference the markdown file in the `contentFile` field

## Markdown Format

Articles support standard markdown plus:
- Code blocks with syntax highlighting
- Images (place in `/public/images/articles/`)
- Links
- Headers, lists, etc.
