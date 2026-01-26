#!/bin/bash

# Script to run both frontend and backend locally

echo "Starting FFJ Consulting LLC Application..."
echo ""

# Check if .NET SDK is installed
if ! command -v dotnet &> /dev/null; then
    echo "Error: .NET SDK is not installed. Please install .NET 8.0 SDK."
    exit 1
fi

# Check if Node.js is installed
if ! command -v node &> /dev/null; then
    echo "Error: Node.js is not installed. Please install Node.js."
    exit 1
fi

# Start backend in background
echo "Starting C# Backend..."
cd backend/FFJConsulting.API
dotnet restore
dotnet run &
BACKEND_PID=$!
cd ../..

# Wait a moment for backend to start
sleep 3

# Start frontend
echo "Starting React Frontend..."
cd frontend

# Check if node_modules exists, if not install
if [ ! -d "node_modules" ]; then
    echo "Installing frontend dependencies..."
    npm install
fi

echo ""
echo "=========================================="
echo "Application is starting!"
echo "Frontend: http://localhost:3000"
echo "Backend API: http://localhost:5000"
echo "Swagger UI: http://localhost:5000/swagger"
echo "=========================================="
echo ""
echo "Press Ctrl+C to stop all services"

npm run dev

# Cleanup on exit
trap "kill $BACKEND_PID 2>/dev/null" EXIT
