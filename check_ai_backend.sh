#!/bin/bash
# AI Chatbot Diagnostic Tool

echo "=================================="
echo "HealthNest AI Chatbot Diagnostics"
echo "=================================="
echo ""

# 1. Check Backend Status
echo "1. Backend Status:"
if ps aux | grep "python.*app.py" | grep -v grep > /dev/null; then
    echo "   ✅ Flask backend is running"
else
    echo "   ❌ Flask backend is NOT running"
    echo "   → Run: ./start_ai_backend.sh"
    exit 1
fi
echo ""

# 2. Check IP Address
echo "2. Network Configuration:"
IP=$(ip addr show | grep 'inet ' | grep -v '127.0.0.1' | awk '{print $2}' | cut -d/ -f1 | head -1)
echo "   Laptop IP: $IP"
echo "   Backend URL: http://$IP:5000"
echo ""

# 3. Test Health Endpoint
echo "3. Testing Backend:"
if curl -s http://$IP:5000/health | grep -q "healthy"; then
    echo "   ✅ Backend is healthy and accessible"
else
    echo "   ❌ Backend health check failed"
    exit 1
fi
echo ""

# 4. Test Chat Endpoint
echo "4. Testing AI Chat:"
RESPONSE=$(curl -s -X POST http://$IP:5000/chat \
    -H "Content-Type: application/json" \
    -d '{"message": "test"}' | python3 -c "import sys, json; print(json.load(sys.stdin).get('response', 'error')[:50])" 2>/dev/null)
if [ ! -z "$RESPONSE" ] && [ "$RESPONSE" != "error" ]; then
    echo "   ✅ AI Chat is working"
    echo "   Response: $RESPONSE..."
else
    echo "   ❌ AI Chat failed"
    exit 1
fi
echo ""

# 5. Network Info
echo "5. WiFi Network:"
WIFI=$(nmcli -t -f active,ssid dev wifi | grep '^yes' | cut -d: -f2)
if [ ! -z "$WIFI" ]; then
    echo "   Connected to: $WIFI"
    echo "   📱 Connect your phone to the SAME WiFi: $WIFI"
else
    echo "   WiFi info not available"
fi
echo ""

# 6. Instructions
echo "=================================="
echo "📱 Mobile App Setup Instructions:"
echo "=================================="
echo ""
echo "1. Make sure your phone is connected to WiFi: $WIFI"
echo ""
echo "2. Test from phone browser first:"
echo "   Open: http://$IP:5000/health"
echo "   Should show: {\"status\": \"healthy\"}"
echo ""
echo "3. If browser test works, rebuild your app:"
echo "   flutter clean"
echo "   flutter build apk --release"
echo ""
echo "4. Install and test the app"
echo ""
echo "=================================="
echo "✅ All checks passed!"
echo "=================================="
echo ""
echo "Backend is ready at: http://$IP:5000"
echo "Mobile app should work when on same WiFi"
echo ""
