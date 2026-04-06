╭─fjabbari@Freds-MacBook-Pro ~/REPO_CURSOR/FFJ-CONSULTING-LLC ‹master●› 
╰─$ ./run-resume-and-deploy.sh
==========================================
1. Sync resume (website .md → Word .docx)
==========================================
============================================================
Sync website resume (resume.md) → local Word (.docx)
============================================================
✅ Resume synced successfully (in place).
📄 Saved: /Users/fjabbari/@@@PUBLIC/@@@RESUME_2026/Fred_Jabbari_Resume_Optimized_2026_with_Bedrock_BDAGood001_with_links.docx

==========================================
2. Build & deploy to AWS
==========================================
==========================================
FFJ Consulting LLC - AWS Deployment
Profile: my-sso
==========================================

Checking prerequisites...
✅ Prerequisites check passed

Step 1: Building frontend...

> ffj-consulting-frontend@1.0.0 build
> vite build

vite v5.4.21 building for production...
✓ 283 modules transformed.
dist/index.html                                       0.55 kB │ gzip:   0.34 kB
dist/assets/index-D3mKnDfe.css                       35.75 kB │ gzip:   6.78 kB
dist/assets/README-NJSkXsw0.js                        0.64 kB │ gzip:   0.38 kB
dist/assets/introduction-to-agentic-ai-Du1seDrV.js    0.96 kB │ gzip:   0.55 kB
dist/assets/ai-revolution-demo-ceI2qEOE.js            3.13 kB │ gzip:   1.48 kB
dist/assets/resume-D1EXG9mr.js                       11.21 kB │ gzip:   4.04 kB
dist/assets/index-CYH4fW0G.js                       335.91 kB │ gzip: 104.77 kB
✓ built in 798ms
✅ Frontend built successfully

Step 2: Setting up S3 bucket...
⚠️  S3 bucket already exists
Step 3: Uploading frontend to S3...
delete: s3://ffj-consulting-website/assets/index-CE9d1n-5.js
upload: frontend/dist/content/introduction-to-agentic-ai.md to s3://ffj-consulting-website/content/introduction-to-agentic-ai.md
upload: frontend/dist/assets/ai-revolution-demo-ceI2qEOE.js to s3://ffj-consulting-website/assets/ai-revolution-demo-ceI2qEOE.js
upload: frontend/dist/content/resume.md to s3://ffj-consulting-website/content/resume.md
upload: frontend/dist/docs/aws-deployment.html to s3://ffj-consulting-website/docs/aws-deployment.html
upload: frontend/dist/docs/architecture.html to s3://ffj-consulting-website/docs/architecture.html
upload: frontend/dist/docs/deployment.html to s3://ffj-consulting-website/docs/deployment.html
upload: frontend/dist/docs/design.html to s3://ffj-consulting-website/docs/design.html
delete: s3://ffj-consulting-website/assets/resume-CVdK_c3-.js     
upload: frontend/dist/assets/introduction-to-agentic-ai-Du1seDrV.js to s3://ffj-consulting-website/assets/introduction-to-agentic-ai-Du1seDrV.js
upload: frontend/dist/assets/README-NJSkXsw0.js to s3://ffj-consulting-website/assets/README-NJSkXsw0.js
upload: frontend/dist/content/ai-revolution-demo.md to s3://ffj-consulting-website/content/ai-revolution-demo.md
upload: frontend/dist/assets/resume-D1EXG9mr.js to s3://ffj-consulting-website/assets/resume-D1EXG9mr.js
upload: frontend/dist/content/README.md to s3://ffj-consulting-website/content/README.md
upload: frontend/dist/docs/financial-planning.html to s3://ffj-consulting-website/docs/financial-planning.html
upload: frontend/dist/assets/index-D3mKnDfe.css to s3://ffj-consulting-website/assets/index-D3mKnDfe.css
upload: frontend/dist/docs/index.html to s3://ffj-consulting-website/docs/index.html
upload: frontend/dist/docs/job-search.html to s3://ffj-consulting-website/docs/job-search.html
upload: frontend/dist/docs/styles.css to s3://ffj-consulting-website/docs/styles.css
upload: frontend/dist/docs/maintenance.html to s3://ffj-consulting-website/docs/maintenance.html
upload: frontend/dist/index.html to s3://ffj-consulting-website/index.html
upload: frontend/dist/docs/implementation.html to s3://ffj-consulting-website/docs/implementation.html
upload: frontend/dist/docs/how-to-make-changes.html to s3://ffj-consulting-website/docs/how-to-make-changes.html
upload: frontend/dist/assets/index-CYH4fW0G.js to s3://ffj-consulting-website/assets/index-CYH4fW0G.js
upload: frontend/dist/images/fred-picture.png to s3://ffj-consulting-website/images/fred-picture.png
✅ Frontend uploaded to S3

Invalidating CloudFront cache...
✅ CloudFront invalidation created (allow 1–5 min)

Step 4: Building backend...
Restore complete (0.3s)

Build succeeded in 0.5s
Restore complete (0.2s)
  FFJConsulting.API succeeded (0.3s) → publish/

Build succeeded in 0.7s
✅ Backend built successfully

Step 5: Deploying backend to Elastic Beanstalk...
Note: This requires EB CLI. Install with: pip install awsebcli

⚠️  EB CLI not found. Skipping backend deployment.
To deploy backend manually:
  1. Install EB CLI: pip install awsebcli
  2. Run: cd backend/FFJConsulting.API && eb init && eb create && eb deploy

==========================================
Deployment Complete!
==========================================

Frontend: https://ffjconsultingllc.com
  (S3 website: http://ffj-consulting-website.s3-website-us-east-1.amazonaws.com)

If the site is blank: wait 1–5 min for CloudFront invalidation, then hard refresh (Cmd+Shift+R).


Done.
╭─fjabbari@Freds-MacBook-Pro ~/REPO_CURSOR/FFJ-CONSULTING-LLC ‹master●› 