#!/bin/bash

# Verification script for FFJ Consulting LLC setup

echo "=========================================="
echo "FFJ Consulting LLC - Setup Verification"
echo "=========================================="
echo ""

# Check Node.js
echo "Checking Node.js..."
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    echo "✅ Node.js installed: $NODE_VERSION"
else
    echo "❌ Node.js is not installed"
    echo "   Install from: https://nodejs.org/"
    exit 1
fi

# Check npm
echo "Checking npm..."
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    echo "✅ npm installed: $NPM_VERSION"
else
    echo "❌ npm is not installed"
    exit 1
fi

# Check .NET SDK
echo "Checking .NET SDK..."
if command -v dotnet &> /dev/null; then
    DOTNET_VERSION=$(dotnet --version)
    echo "✅ .NET SDK installed: $DOTNET_VERSION"
else
    echo "❌ .NET SDK is not installed"
    echo "   Install from: https://dotnet.microsoft.com/download"
    exit 1
fi

echo ""
echo "Checking project structure..."

# Check frontend files
if [ -f "frontend/package.json" ]; then
    echo "✅ Frontend package.json exists"
else
    echo "❌ Frontend package.json not found"
    exit 1
fi

if [ -f "frontend/vite.config.js" ]; then
    echo "✅ Frontend vite.config.js exists"
else
    echo "❌ Frontend vite.config.js not found"
    exit 1
fi

# Check backend files
if [ -f "backend/FFJConsulting.API/FFJConsulting.API.csproj" ]; then
    echo "✅ Backend .csproj exists"
else
    echo "❌ Backend .csproj not found"
    exit 1
fi

if [ -f "backend/FFJConsulting.API/Program.cs" ]; then
    echo "✅ Backend Program.cs exists"
else
    echo "❌ Backend Program.cs not found"
    exit 1
fi

echo ""
echo "Checking dependencies..."

# Check frontend node_modules
if [ -d "frontend/node_modules" ]; then
    echo "✅ Frontend dependencies installed"
else
    echo "⚠️  Frontend dependencies not installed"
    echo "   Run: cd frontend && npm install"
fi

# Check backend packages
if [ -d "backend/FFJConsulting.API/bin" ] || [ -d "backend/FFJConsulting.API/obj" ]; then
    echo "✅ Backend has been built"
else
    echo "⚠️  Backend not built yet"
    echo "   Run: cd backend/FFJConsulting.API && dotnet restore && dotnet build"
fi

echo ""
echo "=========================================="
echo "Verification complete!"
echo "=========================================="
echo ""
echo "To start the application:"
echo "  1. Backend:  cd backend/FFJConsulting.API && dotnet run"
echo "  2. Frontend: cd frontend && npm run dev"
echo ""
