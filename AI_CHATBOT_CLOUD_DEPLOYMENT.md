# 🚀 AI Chatbot Cloud Deployment Guide

**Project:** HealthNest AI Chatbot  
**Backend:** Flask (Python 3.13)  
**Current:** Local (192.168.0.108:5000)  
**Target:** Cloud Deployment (Railway/Heroku)

---

## 📋 DEPLOYMENT OPTIONS

### Option 1: Railway (RECOMMENDED) ⭐

**Pros:**
- ✅ Free tier (no credit card for first 500 hours)
- ✅ Automatic HTTPS
- ✅ Easy deployment (one command)
- ✅ Auto-scaling
- ✅ Fast deployment (< 5 mins)
- ✅ GitHub integration
- ✅ Environment variables support

**Cons:**
- ⚠️ 500 hours/month limit on free tier
- ⚠️ Cold starts after inactivity

**Cost:** $0 (free tier) or $5/month (pro)

---

### Option 2: Heroku

**Pros:**
- ✅ Well-documented
- ✅ Mature platform
- ✅ Free tier available
- ✅ Add-ons ecosystem

**Cons:**
- ⚠️ Requires credit card even for free tier
- ⚠️ Apps sleep after 30 mins inactivity
- ⚠️ Slower deployment
- ⚠️ More complex setup

**Cost:** $0 (free tier) or $7/month (basic)

---

### Option 3: Google Cloud Run

**Pros:**
- ✅ Auto-scaling
- ✅ Pay-per-use
- ✅ Very reliable
- ✅ No sleep/cold starts

**Cons:**
- ⚠️ Complex setup
- ⚠️ Requires billing account
- ⚠️ Steeper learning curve

**Cost:** ~$2-5/month (based on usage)

---

## 🎯 STEP-BY-STEP: Railway Deployment

### Prerequisites:
- Python 3.13 installed
- Git installed
- Railway account (free signup)

---

### Step 1: Prepare Your Code

```bash
cd /home/basar/health_nest/AI-Project/backend
```

---

### Step 2: Create `requirements.txt`

```bash
pip freeze > requirements.txt
```

Or manually create with these dependencies:

```txt
Flask==3.0.0
Flask-CORS==4.0.0
gunicorn==21.2.0
Werkzeug==3.0.0
```

---

### Step 3: Create `Procfile`

```bash
echo "web: gunicorn app_bilingual:app" > Procfile
```

This tells Railway how to run your app.

---

### Step 4: Create `railway.json` (Optional)

```json
{
  "$schema": "https://railway.app/railway.schema.json",
  "build": {
    "builder": "NIXPACKS"
  },
  "deploy": {
    "startCommand": "gunicorn app_bilingual:app",
    "restartPolicyType": "ON_FAILURE",
    "restartPolicyMaxRetries": 10
  }
}
```

---

### Step 5: Create `.railwayignore` (Optional)

```
__pycache__/
*.pyc
*.pyo
*.pyd
.Python
venv/
env/
.env
*.log
.DS_Store
```

---

### Step 6: Install Railway CLI

```bash
# Using npm (if Node.js installed)
npm i -g @railway/cli

# Or using curl
curl -fsSL https://railway.app/install.sh | sh
```

---

### Step 7: Login to Railway

```bash
railway login
```

This will open browser for authentication.

---

### Step 8: Initialize Railway Project

```bash
railway init
```

Choose:
- Create new project
- Name: `healthnest-ai-chatbot`
- Template: Empty project

---

### Step 9: Link to Project

```bash
railway link
```

Select the project you just created.

---

### Step 10: Deploy!

```bash
railway up
```

Wait 2-3 minutes for deployment to complete.

---

### Step 11: Get Your URL

```bash
railway domain
```

This will give you a URL like: `https://healthnest-ai-chatbot-production.up.railway.app`

Or manually:
1. Go to railway.app
2. Select your project
3. Click "Settings"
4. Under "Networking" → "Generate Domain"

---

### Step 12: Set Environment Variables (if needed)

```bash
railway variables set FLASK_ENV=production
railway variables set PORT=5000
```

Or via Railway Dashboard:
1. Project → Variables
2. Add variables

---

### Step 13: Test Deployment

```bash
curl https://your-app-url.railway.app/health
```

Should return:
```json
{
  "status": "healthy",
  "service": "HealthNest AI Chatbot API (Bilingual)"
}
```

---

### Step 14: Update Flutter App

Open `/lib/src/providers/ai_chatbot_provider.dart`:

**Find:**
```dart
final String baseUrl = 'http://192.168.0.108:5000';
```

**Replace with:**
```dart
final String baseUrl = 'https://healthnest-ai-chatbot-production.up.railway.app';
```

---

### Step 15: Test from Flutter App

1. Run Flutter app
2. Open AI Chatbot
3. Send test message: "What is BMI?"
4. Should get response from cloud server

---

## 🔄 ALTERNATIVE: Heroku Deployment

### Step 1: Install Heroku CLI

```bash
curl https://cli-assets.heroku.com/install.sh | sh
```

---

### Step 2: Login

```bash
heroku login
```

---

### Step 3: Create App

```bash
cd /home/basar/health_nest/AI-Project/backend
heroku create healthnest-ai-chatbot
```

---

### Step 4: Add Python Buildpack

```bash
heroku buildpacks:set heroku/python
```

---

### Step 5: Create Procfile

```bash
echo "web: gunicorn app_bilingual:app" > Procfile
```

---

### Step 6: Create requirements.txt

```bash
pip freeze > requirements.txt
```

---

### Step 7: Create runtime.txt

```bash
echo "python-3.13.0" > runtime.txt
```

---

### Step 8: Initialize Git (if not already)

```bash
git init
git add .
git commit -m "Initial commit for Heroku deployment"
```

---

### Step 9: Deploy to Heroku

```bash
git push heroku main
```

Or if you're on a branch:
```bash
git push heroku your-branch:main
```

---

### Step 10: Scale Dynos

```bash
heroku ps:scale web=1
```

---

### Step 11: Open App

```bash
heroku open
```

---

### Step 12: View Logs

```bash
heroku logs --tail
```

---

### Step 13: Get App URL

Your app will be at: `https://healthnest-ai-chatbot.herokuapp.com`

---

## 🐛 TROUBLESHOOTING

### Railway Issues:

**Problem: Deployment failed**
```bash
railway logs
```
Check error messages.

**Problem: App crashes on startup**
- Check `requirements.txt` has all dependencies
- Verify `Procfile` is correct
- Check Python version compatibility

**Problem: Port binding error**
```python
# In app_bilingual.py, change:
if __name__ == '__main__':
    port = int(os.environ.get('PORT', 5000))
    app.run(host='0.0.0.0', port=port)
```

---

### Heroku Issues:

**Problem: Application error**
```bash
heroku logs --tail
```

**Problem: H10 error (app crashed)**
- Check `Procfile` syntax
- Verify `gunicorn` in requirements.txt
- Check app runs locally first

**Problem: H14 error (no web processes)**
```bash
heroku ps:scale web=1
```

---

## 📊 MONITORING

### Railway:

1. Go to Railway Dashboard
2. Select project
3. View:
   - Deployment logs
   - Resource usage
   - Request metrics
   - Error rates

### Heroku:

```bash
# View app status
heroku ps

# View logs
heroku logs --tail

# View metrics (requires addon)
heroku addons:create newrelic:wayne
```

---

## 💰 COST ESTIMATION

### Railway Free Tier:
- 500 hours/month
- $5 credit included
- No credit card required initially
- **Cost: $0**

### Railway Pro:
- Unlimited hours
- Better resources
- **Cost: $5/month**

### Heroku Free Tier:
- 550 hours/month
- Apps sleep after 30 mins
- **Cost: $0**

### Heroku Basic:
- No sleeping
- Better performance
- **Cost: $7/month**

---

## 🔐 SECURITY BEST PRACTICES

1. **Use Environment Variables:**
```bash
railway variables set API_KEY=your_secret_key
railway variables set DB_PASSWORD=secure_password
```

2. **Enable CORS Properly:**
```python
CORS(app, resources={
    r"/chat": {"origins": ["https://your-flutter-app.com"]},
    r"/health": {"origins": "*"}
})
```

3. **Use HTTPS Only:**
Railway and Heroku provide automatic HTTPS.

4. **Rate Limiting:**
```python
from flask_limiter import Limiter

limiter = Limiter(
    app,
    key_func=lambda: request.remote_addr,
    default_limits=["100 per hour"]
)
```

---

## 📝 POST-DEPLOYMENT CHECKLIST

- [ ] AI Chatbot deployed to Railway/Heroku
- [ ] Custom domain added (optional)
- [ ] HTTPS working
- [ ] `/health` endpoint returns 200
- [ ] `/chat` endpoint works
- [ ] Flutter app updated with new URL
- [ ] Tested from mobile device
- [ ] Logs show no errors
- [ ] Environment variables set
- [ ] Monitoring enabled

---

## 🎯 RECOMMENDED DEPLOYMENT: RAILWAY

**Why Railway?**
1. Free tier doesn't require credit card
2. Fastest deployment (< 5 mins)
3. Automatic HTTPS
4. Better free tier limits
5. Easier to use
6. Great for indie developers

**Command Summary:**
```bash
npm i -g @railway/cli
railway login
cd /home/basar/health_nest/AI-Project/backend
echo "web: gunicorn app_bilingual:app" > Procfile
pip freeze > requirements.txt
railway init
railway up
railway domain
```

**Update Flutter:**
```dart
// In ai_chatbot_provider.dart
final String baseUrl = 'https://your-app.railway.app';
```

**DONE!** ✅

---

## 📞 SUPPORT

**Railway:**
- Docs: https://docs.railway.app
- Discord: https://discord.gg/railway

**Heroku:**
- Docs: https://devcenter.heroku.com
- Support: https://help.heroku.com

---

**Next Steps:**
1. Deploy using Railway (5 mins)
2. Update Flutter app URL (1 min)
3. Test on device (2 mins)
4. **TOTAL: < 10 minutes to cloud deployment!**

---

**Prepared by:** GitHub Copilot  
**Date:** November 30, 2025  
**Status:** Ready for deployment 🚀
