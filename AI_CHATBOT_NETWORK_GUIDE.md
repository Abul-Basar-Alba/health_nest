# AI Chatbot Network Setup Guide

## সমস্যা:
Mobile app থেকে AI chatbot access করতে পারছো না কারণ:
- Mobile আর laptop **একই WiFi network** এ থাকতে হয়
- WiFi বন্ধ থাকলে বা আলাদা network এ থাকলে কাজ করবে না

## ✅ Solution 1: Same WiFi Network (বর্তমান setup)

### Requirements:
1. Laptop আর phone **একই WiFi** এ connect থাকতে হবে
2. Flask backend running থাকতে হবে

### Steps:
```bash
# 1. Backend চালু করো
cd /home/basar/health_nest
./start_ai_backend.sh

# 2. Check IP address
ip addr show | grep "inet " | grep -v "127.0.0.1"
# Output: 192.168.0.108

# 3. Phone থেকে test করো (same WiFi থেকে)
```

### যদি কাজ না করে:
```bash
# Phone আর laptop same network এ আছে কিনা check করো
# Phone settings → WiFi → Check network name
# Laptop: Check WiFi name

# Backend accessible কিনা test করো
curl http://192.168.0.108:5000/health
```

---

## ✅ Solution 2: ngrok Tunnel (Anywhere থেকে access)

এটা use করলে:
- Phone আর laptop আলাদা network এও কাজ করবে
- Internet থাকলেই হবে
- Free tier: 2GB/month bandwidth

### Installation:

```bash
# 1. Download ngrok
cd ~
wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz
tar xvzf ngrok-v3-stable-linux-amd64.tgz
sudo mv ngrok /usr/local/bin/

# 2. Sign up at https://ngrok.com/ (free)
# 3. Get your authtoken from dashboard
# 4. Setup authtoken
ngrok config add-authtoken YOUR_AUTHTOKEN_HERE
```

### Usage:

```bash
# Terminal 1: Start Flask backend
cd /home/basar/health_nest
./start_ai_backend.sh

# Terminal 2: Start ngrok tunnel
ngrok http 5000
```

**Output:**
```
Forwarding https://abc123.ngrok.io -> http://localhost:5000
```

### Update Flutter app:

Edit `/lib/src/services/ai_chatbot_service.dart`:

```dart
static String get _baseUrl {
  // Use ngrok URL for mobile
  if (Platform.isAndroid || Platform.isIOS) {
    return 'https://YOUR-NGROK-URL.ngrok.io'; // Replace with your ngrok URL
  }
  // Use localhost for web/desktop
  return 'http://localhost:5000';
}
```

---

## ✅ Solution 3: Cloud Deployment (Production)

### Free Options:

#### A. Railway.app (Recommended)
```bash
# 1. Install Railway CLI
npm install -g @railway/cli

# 2. Login
railway login

# 3. Deploy
cd /home/basar/health_nest/AI-Project
railway init
railway up
```

#### B. Render.com
1. Go to https://render.com
2. Create new Web Service
3. Connect GitHub repo
4. Set:
   - Build Command: `cd backend && pip install -r requirements.txt`
   - Start Command: `cd backend && python app.py`

#### C. Google Cloud Run
```bash
# Create Dockerfile in AI-Project/backend/
# Deploy to Cloud Run
gcloud run deploy healthnest-ai --source .
```

### Update Flutter app:
```dart
static const String _baseUrl = 'https://your-app.railway.app';
// or
static const String _baseUrl = 'https://your-app.onrender.com';
```

---

## 🎯 Recommended Approach

### For Development (এখন):
**Use Solution 1** - Same WiFi
- সবচেয়ে সহজ
- Setup লাগে না
- শুধু same WiFi তে থাকো

### For Testing from Anywhere:
**Use Solution 2** - ngrok
- কোথাও থেকে test করতে পারবে
- Free tier যথেষ্ট
- 2 মিনিটে setup হয়ে যায়

### For Production:
**Use Solution 3** - Cloud Deploy
- Permanent URL
- সবসময় available
- Professional

---

## Current Setup Status:

✅ Backend: Running on `http://192.168.0.108:5000`
✅ Chrome/Desktop: Working perfectly
⚠️ Mobile: Only works on same WiFi network

---

## Quick Fix for Mobile (Right Now):

### Make sure:

1. **Same WiFi Network:**
   ```
   Laptop WiFi: [Check your WiFi name]
   Phone WiFi: [Must be same name]
   ```

2. **Backend Running:**
   ```bash
   # Check if running
   ps aux | grep "python.*app.py"
   
   # If not running, start it
   ./start_ai_backend.sh
   ```

3. **Test from Phone Browser:**
   - Open phone browser
   - Go to: `http://192.168.0.108:5000/health`
   - Should show: `{"status": "healthy"}`
   - If this works, app will also work

4. **Rebuild App:**
   ```bash
   flutter clean
   flutter build apk --release
   ```

---

## Troubleshooting:

### Error: "No route to host"
**Reason:** Phone not on same WiFi or laptop IP changed

**Fix:**
```bash
# Get current IP
ip addr show | grep "inet " | grep -v "127.0.0.1" | awk '{print $2}'

# If IP changed, update ai_chatbot_service.dart line 15
# Then rebuild app
```

### Error: "Connection refused"
**Reason:** Backend not running

**Fix:**
```bash
./start_ai_backend.sh
# Wait 5 seconds
curl http://192.168.0.108:5000/health
```

### Error: "Timeout"
**Reason:** Firewall blocking or different network

**Fix:**
```bash
# Check firewall
sudo ufw status
# If active, allow port 5000
sudo ufw allow 5000

# Or temporarily disable
sudo ufw disable
```

---

## Next Steps:

### Option A: Continue with Same WiFi (Quick)
1. Connect phone to same WiFi as laptop
2. Restart backend: `./start_ai_backend.sh`
3. Test from phone browser: `http://192.168.0.108:5000/health`
4. Use app normally

### Option B: Setup ngrok (30 minutes)
1. Install ngrok (see above)
2. Get free account
3. Start tunnel: `ngrok http 5000`
4. Update `ai_chatbot_service.dart` with ngrok URL
5. Rebuild app
6. Works from anywhere with internet!

### Option C: Deploy to Cloud (1-2 hours)
1. Choose platform (Railway recommended)
2. Deploy backend
3. Get permanent URL
4. Update app
5. Production ready!

---

## Contact:
For production deployment help or ngrok setup, let me know which solution you want to implement.
