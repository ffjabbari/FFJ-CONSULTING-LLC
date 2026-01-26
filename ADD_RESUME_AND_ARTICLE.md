# Adding Resume and AI Article Content

I've created the structure for your resume and AI article. Now we need to extract the content from the .docx files.

## What's Been Set Up

1. ✅ **Resume Page** - Created at `/resume` route
2. ✅ **AI Article** - Added to articles list in "AI Tools & Platforms" category
3. ✅ **Navigation** - Added "Resume" link to navigation menu
4. ✅ **Placeholder files** - Created markdown files ready for content

## Next Steps - Extract Content

Since we can't install python-docx due to network issues, you have two options:

### Option 1: Tell Cursor to Extract Content

Simply tell Cursor:

```
Extract the content from this resume file and update resume.md:
/Users/fjabbari/@@@PUBLIC/@@@RESUME_2026/Fred_Jabbari_Resume_Optimized_2026_with_Bedrock_BDAGood001.docx

Convert it to markdown format and preserve formatting.
```

And for the article:

```
Extract the content from this article file and update ai-revolution-demo.md:
/Users/fjabbari/@@@PUBLIC/@@@RESUME_2026/AI_Revolution_Demo.docx

Convert it to markdown format with proper headings and structure.
```

### Option 2: Manual Extraction

1. Open the .docx files in Word or Google Docs
2. Copy the content
3. Paste into:
   - `frontend/src/content/resume.md`
   - `frontend/src/content/ai-revolution-demo.md`
4. Format as markdown (headings with #, lists with -, etc.)

## File Locations

- Resume content: `frontend/src/content/resume.md`
- AI Article content: `frontend/src/content/ai-revolution-demo.md`
- Resume page component: `frontend/src/components/Resume.jsx`

## Testing

After adding content:
1. Run `python3 start.py` or `npm run dev`
2. Visit http://localhost:3000/resume to see your resume
3. Visit http://localhost:3000/article/ai-revolution-demo to see the article

## Deployment

Once content is added, you can deploy with:
```
Deploy the site to AWS
```
