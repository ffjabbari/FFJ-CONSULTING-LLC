# FFJ Consulting LLC - Website

A modern web application built with React frontend and multiple backend options (C#, Java, Python).

## Architecture

- **Frontend**: React with Vite
- **Backend**: ASP.NET Core Web API (C#) - Default
- **Database**: SQLite3
- **Future Backends**: Java, Python

## Project Structure

```
FFJ-CONSULTING-LLC/
├── frontend/          # React application
├── backend/           # Backend services
│   └── FFJConsulting.API/  # C# ASP.NET Core API
├── Docs/              # Documentation
└── README.md
```

## Local Development Setup

### Prerequisites

- Node.js (v18 or higher)
- .NET 8.0 SDK
- npm or yarn

### Running the Application

#### 1. Start the Backend (C#)

```bash
cd backend/FFJConsulting.API
dotnet restore
dotnet run
```

The API will be available at `http://localhost:5000`

#### 2. Start the Frontend (React)

```bash
cd frontend
npm install
npm run dev
```

The frontend will be available at `http://localhost:3000`

### Accessing the Application

- Frontend: http://localhost:3000
- Backend API: http://localhost:5000
- Swagger UI: http://localhost:5000/swagger

## Backend Switching

The application supports multiple backends. The current backend is configured in:
- C#: `backend/FFJConsulting.API/appsettings.json` (Backend:Name)

The frontend displays "Powered by [Backend Name]" based on the backend configuration.

## Database

SQLite database file (`ffjconsulting.db`) will be created automatically in the backend directory when the application first runs.

## Deployment

Deployment to AWS will be configured in a future update.

## License

Copyright © 2025 FFJ Consulting LLC. All rights reserved.
