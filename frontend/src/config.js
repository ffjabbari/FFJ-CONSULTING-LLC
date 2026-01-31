// Configuration for the website
// Production URL: https://ffjconsultingllc.com

// Vite exposes env vars via import.meta.env (process.env is not available in the browser)
export const SITE_URL = import.meta.env.VITE_SITE_URL || 'https://ffjconsultingllc.com'
export const GITHUB_REPO = 'https://github.com/ffjabbari/FFJ-CONSULTING-LLC'

// Helper function to get full URL
export const getFullUrl = (path) => {
  return `${SITE_URL}${path}`
}
