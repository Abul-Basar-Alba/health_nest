#!/bin/bash
# Start Flask AI Backend for HealthNest

cd "$(dirname "$0")/AI-Project/backend"
echo "Starting HealthNest AI Backend..."
echo "Working directory: $(pwd)"
./venv/bin/python app.py
