#!/bin/bash
# Start Improved AI Backend

cd "$(dirname "$0")/AI-Project/backend"
echo "Starting HealthNest AI Backend (Improved Version)..."
echo "Working directory: $(pwd)"

# Kill old backend if running
pkill -f "python.*app.py" 2>/dev/null
pkill -f "python.*app_improved.py" 2>/dev/null
sleep 1

# Start new backend
./venv/bin/python app_improved.py
