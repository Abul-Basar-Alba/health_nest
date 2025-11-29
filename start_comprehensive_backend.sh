#!/bin/bash
# HealthNest AI Comprehensive Chatbot Startup Script

echo "=================================================="
echo "🏥 HealthNest AI Comprehensive Chatbot"
echo "=================================================="

cd /home/basar/health_nest/AI-Project/backend

# Stop old backends
echo "🛑 Stopping old backends..."
pkill -f "python.*app" 2>/dev/null
sleep 2

# Start comprehensive backend
echo "🚀 Starting comprehensive chatbot backend..."
nohup ./venv/bin/python app_comprehensive.py > ai_comprehensive.log 2>&1 &
BACKEND_PID=$!

sleep 3

# Check if running
if ps -p $BACKEND_PID > /dev/null; then
    echo "✅ Backend started successfully!"
    echo "   PID: $BACKEND_PID"
    echo "   URL: http://192.168.0.108:5000"
    
    # Test health
    echo ""
    echo "🔍 Testing backend health..."
    HEALTH=$(curl -s http://192.168.0.108:5000/health)
    
    if [ $? -eq 0 ]; then
        echo "✅ Health check passed!"
        echo "$HEALTH" | python3 -m json.tool 2>/dev/null || echo "$HEALTH"
    else
        echo "❌ Health check failed!"
    fi
    
    echo ""
    echo "=================================================="
    echo "📊 Features Available:"
    echo "   • App Information & Usage"
    echo "   • BMI Calculator & Analysis"
    echo "   • Weight Loss Planning"
    echo "   • Nutrition & Diet Guidance"
    echo "   • Water Intake Calculation"
    echo "   • Sleep Tracking Info"
    echo "   • Fitness & Exercise Plans"
    echo "   • Pregnancy Tracker"
    echo "   • Women's Health Support"
    echo "   • Medicine Reminders"
    echo "   • Blood Pressure Management"
    echo "   • Diabetes Prevention"
    echo "   • Mental Health Support"
    echo "   • Health Diary Guidance"
    echo "   • Family Health Management"
    echo "=================================================="
    echo ""
    echo "🎯 Ready to answer ALL health questions!"
    echo "   Log: ai_comprehensive.log"
    echo "=================================================="
else
    echo "❌ Failed to start backend!"
    echo "   Check ai_comprehensive.log for errors"
fi
