#!/usr/bin/env python3
"""
Start script for FFJ Consulting LLC
Starts both backend (C#) and frontend (React) services
"""

import subprocess
import sys
import os
import time
import signal
from pathlib import Path

# Get the project root directory
PROJECT_ROOT = Path(__file__).parent.absolute()
BACKEND_DIR = PROJECT_ROOT / "backend" / "FFJConsulting.API"
FRONTEND_DIR = PROJECT_ROOT / "frontend"

def check_prerequisites():
    """Check if required tools are installed"""
    print("Checking prerequisites...")
    
    # Check Node.js
    try:
        result = subprocess.run(["node", "--version"], capture_output=True, text=True)
        print(f"✅ Node.js: {result.stdout.strip()}")
    except FileNotFoundError:
        print("❌ Node.js is not installed. Please install Node.js.")
        sys.exit(1)
    
    # Check npm
    try:
        result = subprocess.run(["npm", "--version"], capture_output=True, text=True)
        print(f"✅ npm: {result.stdout.strip()}")
    except FileNotFoundError:
        print("❌ npm is not installed.")
        sys.exit(1)
    
    # Check .NET SDK
    try:
        result = subprocess.run(["dotnet", "--version"], capture_output=True, text=True)
        print(f"✅ .NET SDK: {result.stdout.strip()}")
    except FileNotFoundError:
        print("❌ .NET SDK is not installed. Please install .NET 8.0 SDK.")
        sys.exit(1)
    
    print()

def start_backend():
    """Start the C# backend"""
    print("🚀 Starting C# Backend...")
    print(f"   Directory: {BACKEND_DIR}")
    
    if not BACKEND_DIR.exists():
        print(f"❌ Backend directory not found: {BACKEND_DIR}")
        return None
    
    # Change to backend directory and run
    process = subprocess.Popen(
        ["dotnet", "run"],
        cwd=str(BACKEND_DIR),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )
    
    return process

def start_frontend():
    """Start the React frontend"""
    print("🚀 Starting React Frontend...")
    print(f"   Directory: {FRONTEND_DIR}")
    
    if not FRONTEND_DIR.exists():
        print(f"❌ Frontend directory not found: {FRONTEND_DIR}")
        return None
    
    # Check if node_modules exists
    if not (FRONTEND_DIR / "node_modules").exists():
        print("⚠️  Frontend dependencies not installed. Installing...")
        subprocess.run(["npm", "install"], cwd=str(FRONTEND_DIR), check=True)
    
    # Change to frontend directory and run
    process = subprocess.Popen(
        ["npm", "run", "dev"],
        cwd=str(FRONTEND_DIR),
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        bufsize=1
    )
    
    return process

def print_output(process, name):
    """Print output from a process"""
    if process:
        for line in iter(process.stdout.readline, ''):
            if line:
                print(f"[{name}] {line.rstrip()}")

def main():
    """Main function"""
    print("=" * 60)
    print("FFJ Consulting LLC - Application Starter")
    print("=" * 60)
    print()
    
    check_prerequisites()
    
    # Start backend
    backend_process = start_backend()
    if not backend_process:
        print("❌ Failed to start backend")
        sys.exit(1)
    
    # Wait a bit for backend to start
    print("⏳ Waiting for backend to initialize...")
    time.sleep(5)
    
    # Start frontend
    frontend_process = start_frontend()
    if not frontend_process:
        print("❌ Failed to start frontend")
        backend_process.terminate()
        sys.exit(1)
    
    print()
    print("=" * 60)
    print("✅ Both services are starting!")
    print("=" * 60)
    print("📍 Frontend: http://localhost:3000")
    print("📍 Backend API: http://localhost:5000")
    print("📍 Swagger UI: http://localhost:5000/swagger")
    print()
    print("Press Ctrl+C to stop all services")
    print("=" * 60)
    print()
    
    # Handle Ctrl+C gracefully
    def signal_handler(sig, frame):
        print("\n\n🛑 Stopping services...")
        if backend_process:
            backend_process.terminate()
        if frontend_process:
            frontend_process.terminate()
        print("✅ Services stopped")
        sys.exit(0)
    
    signal.signal(signal.SIGINT, signal_handler)
    
    # Monitor processes
    try:
        # Print output from both processes
        import threading
        
        def backend_output():
            print_output(backend_process, "BACKEND")
        
        def frontend_output():
            print_output(frontend_process, "FRONTEND")
        
        backend_thread = threading.Thread(target=backend_output, daemon=True)
        frontend_thread = threading.Thread(target=frontend_output, daemon=True)
        
        backend_thread.start()
        frontend_thread.start()
        
        # Wait for processes
        backend_process.wait()
        frontend_process.wait()
        
    except KeyboardInterrupt:
        signal_handler(None, None)

if __name__ == "__main__":
    main()
