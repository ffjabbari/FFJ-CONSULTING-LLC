#!/usr/bin/env python3
"""
Update the .docx resume file with AWS website links
"""

import sys
from pathlib import Path

try:
    from docx import Document
    from docx.shared import Pt
    from docx.enum.text import WD_PARAGRAPH_ALIGNMENT
except ImportError:
    print("Installing python-docx...")
    import subprocess
    subprocess.check_call([sys.executable, "-m", "pip", "install", "python-docx", "--user", "--quiet"])
    from docx import Document
    from docx.shared import Pt
    from docx.enum.text import WD_PARAGRAPH_ALIGNMENT

RESUME_PATH = "/Users/fjabbari/@@@PUBLIC/@@@RESUME_2026/Fred_Jabbari_Resume_Optimized_2026_with_Bedrock_BDAGood001.docx"
WEBSITE_URL = "http://ffj-consulting-website.s3-website-us-east-1.amazonaws.com"
GITHUB_URL = "https://github.com/fjabbari/FFJ-CONSULTING-LLC"

def update_resume():
    """Add links section to the resume"""
    print(f"Opening resume: {RESUME_PATH}")
    
    if not Path(RESUME_PATH).exists():
        print(f"❌ Resume file not found: {RESUME_PATH}")
        return False
    
    try:
        doc = Document(RESUME_PATH)
        
        # Add a new section at the end
        doc.add_paragraph()  # Empty line
        doc.add_paragraph()  # Empty line
        
        # Add heading
        heading = doc.add_paragraph("Additional Resources")
        heading.style = 'Heading 2'
        
        # Add website link
        p1 = doc.add_paragraph()
        p1.add_run("FFJ Consulting Cloud and AI Hands on Architecture: ").bold = True
        website_run = p1.add_run(WEBSITE_URL)
        website_run.font.color.rgb = None  # Default color
        website_run.hyperlink.address = WEBSITE_URL
        
        # Add article link
        p2 = doc.add_paragraph()
        p2.add_run("AI History, Past and Present: ").bold = True
        article_url = f"{WEBSITE_URL}/article/ai-revolution-demo"
        article_run = p2.add_run(article_url)
        article_run.hyperlink.address = article_url
        
        # Add GitHub link
        p3 = doc.add_paragraph()
        p3.add_run("GitHub Source Code: ").bold = True
        github_run = p3.add_run(GITHUB_URL)
        github_run.hyperlink.address = GITHUB_URL
        
        # Save the updated document
        output_path = RESUME_PATH.replace('.docx', '_with_links.docx')
        doc.save(output_path)
        
        print(f"✅ Resume updated successfully!")
        print(f"📄 Saved as: {output_path}")
        print(f"\nThe original file was preserved.")
        print(f"Review the new file and replace the original if you're happy with it.")
        return True
        
    except Exception as e:
        print(f"❌ Error updating resume: {str(e)}")
        return False

if __name__ == "__main__":
    print("="*60)
    print("Updating Resume with AWS Links")
    print("="*60)
    print()
    
    if update_resume():
        print("\n✅ Done!")
    else:
        print("\n❌ Failed to update resume")
        sys.exit(1)
