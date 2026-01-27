// Configuration for the website
// Production URL: https://ffjconsultingllc.com

export const SITE_URL = process.env.VITE_SITE_URL || 'https://ffjconsultingllc.com'
export const GITHUB_REPO = 'https://github.com/ffjabbari/FFJ-CONSULTING-LLC'

// Helper function to get full URL
export const getFullUrl = (path) => {
  return `${SITE_URL}${path}`
}
