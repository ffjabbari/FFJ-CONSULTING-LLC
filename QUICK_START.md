# Quick Start Guide

## 🚀 Get Running in 5 Minutes

### Step 1: Install Dependencies

**Frontend:**
```bash
cd frontend
npm install
```

**Backend:**
```bash
cd backend/FFJConsulting.API
dotnet restore
```

### Step 2: Start Services

**Terminal 1 - Backend:**
```bash
cd backend/FFJConsulting.API
dotnet run
```
✅ Backend running at: http://localhost:5000

**Terminal 2 - Frontend:**
```bash
cd frontend
npm run dev
```
✅ Frontend running at: http://localhost:3000

### Step 3: Open in Browser

1. Go to: **http://localhost:3000**
2. You should see the FFJ Consulting LLC homepage
3. It should display "Powered by: C#"

### Step 4: Test API

1. Go to: **http://localhost:5000/swagger**
2. Click on `GET /api/backend-info`
3. Click "Try it out" → "Execute"
4. Should return backend information

## ✅ Success Indicators

- ✅ Backend shows: "Now listening on: http://localhost:5000"
- ✅ Frontend shows: "Local: http://localhost:3000"
- ✅ Browser shows homepage with "Powered by: C#"
- ✅ No errors in browser console (F12)

## 🐛 Common Issues

**Port in use?**
- Change ports in `vite.config.js` (frontend) or `launchSettings.json` (backend)

**Dependencies not installing?**
- Check internet connection
- Try: `npm cache clean --force` (frontend)
- Try: `dotnet nuget locals all --clear` (backend)

**CORS errors?**
- Ensure backend is running first
- Check CORS settings in `Program.cs`

## 📚 More Details

See `SETUP.md` for detailed setup instructions.
