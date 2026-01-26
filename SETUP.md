# Setup Instructions

## Prerequisites

Before running the application, ensure you have:

1. **Node.js** (v18 or higher)
   - Check: `node --version`
   - Install: https://nodejs.org/

2. **.NET 8.0 SDK** (or higher)
   - Check: `dotnet --version`
   - Install: https://dotnet.microsoft.com/download

3. **Internet connection** (for initial package installation)

## Step-by-Step Setup

### 1. Install Frontend Dependencies

```bash
cd frontend
npm install
```

This will install:
- React and React DOM
- Vite (build tool)
- Axios (HTTP client)
- All development dependencies

### 2. Install Backend Dependencies

```bash
cd backend/FFJConsulting.API
dotnet restore
```

This will download:
- ASP.NET Core packages
- Entity Framework Core
- SQLite provider
- Swagger/OpenAPI

### 3. Build the Backend

```bash
cd backend/FFJConsulting.API
dotnet build
```

### 4. Run the Application

#### Option A: Run Both Services Manually

**Terminal 1 - Start Backend:**
```bash
cd backend/FFJConsulting.API
dotnet run
```

The backend will start at `http://localhost:5000`

**Terminal 2 - Start Frontend:**
```bash
cd frontend
npm run dev
```

The frontend will start at `http://localhost:3000`

#### Option B: Use the Helper Script

```bash
./run-local.sh
```

Note: You may need to make the script executable first:
```bash
chmod +x run-local.sh
```

## Verification

### Check Backend is Running

1. Open browser to: http://localhost:5000/swagger
2. You should see the Swagger UI with the API endpoints
3. Test the endpoint: `GET /api/backend-info`
4. Should return: `{"backend":"C#","version":"8.0","message":"Hello from C# backend!","timestamp":"..."}`

### Check Frontend is Running

1. Open browser to: http://localhost:3000
2. You should see the FFJ Consulting LLC homepage
3. The page should display "Powered by: C#"
4. Check browser console (F12) for any errors

### Test the Connection

1. With both services running, the frontend should automatically fetch backend info
2. The "Powered by" indicator should show "C#"
3. The status message should show "Hello from C# backend!"

## Troubleshooting

### Port Already in Use

If port 5000 or 3000 is already in use:

**Backend:** Edit `backend/FFJConsulting.API/Properties/launchSettings.json` and change the port.

**Frontend:** Edit `frontend/vite.config.js` and change the port in the server section.

### CORS Errors

If you see CORS errors, ensure:
- Backend is running on port 5000
- Frontend proxy is configured correctly in `vite.config.js`
- CORS policy in `Program.cs` allows `http://localhost:3000`

### Database Issues

The SQLite database (`ffjconsulting.db`) will be created automatically on first run in the `backend/FFJConsulting.API` directory.

If you need to recreate it:
```bash
cd backend/FFJConsulting.API
rm ffjconsulting.db
dotnet run
```

### Network/Proxy Issues

If you're behind a corporate proxy or firewall:
- Configure npm proxy: `npm config set proxy http://proxy:port`
- Configure .NET NuGet proxy in `nuget.config`

## Next Steps

Once everything is running locally:

1. ✅ Verify both services start without errors
2. ✅ Test the API endpoints via Swagger
3. ✅ Verify frontend displays backend information
4. ✅ Ready for AWS deployment configuration

## Project Structure

```
FFJ-CONSULTING-LLC/
├── frontend/              # React application
│   ├── src/
│   │   ├── App.jsx       # Main React component
│   │   ├── App.css       # Styles
│   │   └── main.jsx      # Entry point
│   ├── package.json      # Frontend dependencies
│   └── vite.config.js    # Vite configuration
├── backend/
│   └── FFJConsulting.API/
│       ├── Controllers/  # API controllers
│       ├── Data/         # Database context
│       ├── Program.cs    # Application entry
│       └── appsettings.json  # Configuration
└── Docs/                 # Documentation
```
