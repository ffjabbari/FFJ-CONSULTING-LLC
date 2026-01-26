// Configuration for the website
// Production URL: http://ffj-consulting-website.s3-website-us-east-1.amazonaws.com

export const SITE_URL = process.env.VITE_SITE_URL || 'http://ffj-consulting-website.s3-website-us-east-1.amazonaws.com'
export const GITHUB_REPO = 'https://github.com/fjabbari/FFJ-CONSULTING-LLC'

// Helper function to get full URL
export const getFullUrl = (path) => {
  return `${SITE_URL}${path}`
}
