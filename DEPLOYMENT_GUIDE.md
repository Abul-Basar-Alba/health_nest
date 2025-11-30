# 🚀 Cloud Deployment Guide - HealthNest

## Option 1: Firebase Hosting (FREE - RECOMMENDED for Flutter Web)

### Prerequisites:
✅ Firebase already configured in your project
✅ Firebase CLI installed

### Steps:

#### 1. Build Flutter Web App
```bash
flutter build web --release
```

#### 2. Initialize Firebase Hosting (if not done)
```bash
firebase init hosting
```

Configuration:
- Public directory: `build/web`
- Configure as single-page app: Yes
- Set up automatic builds with GitHub: No (optional)
- Overwrite index.html: No

#### 3. Deploy to Firebase Hosting
```bash
firebase deploy --only hosting
```

#### 4. Your app will be live at:
```
https://healthnest-ae7bb.web.app
```

### Custom Domain (Optional):
```bash
firebase hosting:channel:deploy production
```

---

## Option 2: Google Cloud Platform (GCP)

### A. Cloud Run (Recommended for Flutter Web + Backend)

#### 1. Create Dockerfile
```dockerfile
# Use official nginx image
FROM nginx:alpine

# Copy built web app
COPY build/web /usr/share/nginx/html

# Copy nginx config (optional)
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

#### 2. Create nginx.conf
```nginx
events {
    worker_connections 1024;
}

http {
    include /etc/nginx/mime.types;
    default_type application/octet-stream;

    server {
        listen 80;
        server_name _;
        root /usr/share/nginx/html;
        index index.html;

        location / {
            try_files $uri $uri/ /index.html;
        }
    }
}
```

#### 3. Build and Deploy
```bash
# Build Flutter web
flutter build web --release

# Build Docker image
gcloud builds submit --tag gcr.io/healthnest-ae7bb/healthnest-web

# Deploy to Cloud Run
gcloud run deploy healthnest-web \
  --image gcr.io/healthnest-ae7bb/healthnest-web \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

### B. App Engine
```bash
# Create app.yaml
cat > app.yaml << EOF
runtime: python39
service: default

handlers:
- url: /
  static_files: build/web/index.html
  upload: build/web/index.html

- url: /(.*)
  static_files: build/web/\1
  upload: build/web/(.*)
EOF

# Deploy
gcloud app deploy
```

---

## Option 3: Vercel (FREE - Easiest for Web Apps)

### Steps:

#### 1. Install Vercel CLI
```bash
npm i -g vercel
```

#### 2. Build Flutter Web
```bash
flutter build web --release
```

#### 3. Create vercel.json
```json
{
  "version": 2,
  "builds": [
    {
      "src": "build/web/**",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/build/web/$1"
    }
  ]
}
```

#### 4. Deploy
```bash
vercel --prod
```

Your app will be live at: `https://your-project.vercel.app`

---

## Option 4: Netlify (FREE - Great for Static Sites)

### Steps:

#### 1. Install Netlify CLI
```bash
npm install -g netlify-cli
```

#### 2. Build Flutter Web
```bash
flutter build web --release
```

#### 3. Create netlify.toml
```toml
[build]
  publish = "build/web"
  command = "flutter build web --release"

[[redirects]]
  from = "/*"
  to = "/index.html"
  status = 200
```

#### 4. Deploy
```bash
netlify deploy --prod --dir=build/web
```

---

## Option 5: AWS (Amazon Web Services)

### A. AWS Amplify (Easiest)
```bash
# Install Amplify CLI
npm install -g @aws-amplify/cli

# Initialize
amplify init

# Add hosting
amplify add hosting

# Build and deploy
flutter build web --release
amplify publish
```

### B. AWS S3 + CloudFront
```bash
# Build
flutter build web --release

# Create S3 bucket
aws s3 mb s3://healthnest-web

# Enable static website hosting
aws s3 website s3://healthnest-web --index-document index.html

# Upload files
aws s3 sync build/web s3://healthnest-web --acl public-read

# Set up CloudFront (optional for CDN)
aws cloudfront create-distribution \
  --origin-domain-name healthnest-web.s3.amazonaws.com
```

---

## Option 6: Heroku (Good for Full-Stack Apps)

### Steps:

#### 1. Create Procfile
```
web: python -m http.server $PORT --directory build/web
```

#### 2. Create requirements.txt (if needed)
```
# Empty or add dependencies
```

#### 3. Deploy
```bash
# Build
flutter build web --release

# Login to Heroku
heroku login

# Create app
heroku create healthnest-app

# Deploy
git push heroku main
```

---

## Option 7: DigitalOcean App Platform

### Steps:

#### 1. Build Flutter Web
```bash
flutter build web --release
```

#### 2. Create Dockerfile
```dockerfile
FROM nginx:alpine
COPY build/web /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]
```

#### 3. Deploy via GitHub
- Connect your GitHub repo
- Select branch
- Auto-deploy on push

---

## Comparison Table

| Platform | Cost | Ease | Performance | Best For |
|----------|------|------|-------------|----------|
| **Firebase Hosting** | FREE (up to 10GB) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Flutter Web |
| **Vercel** | FREE | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Static Sites |
| **Netlify** | FREE | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Static Sites |
| **Google Cloud Run** | Pay-as-you-go | ⭐⭐⭐ | ⭐⭐⭐⭐⭐ | Containerized Apps |
| **AWS Amplify** | FREE tier | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | Full-Stack |
| **Heroku** | FREE tier ending | ⭐⭐⭐ | ⭐⭐⭐ | Full-Stack |
| **DigitalOcean** | $5/month | ⭐⭐⭐ | ⭐⭐⭐⭐ | Containers |

---

## 🎯 RECOMMENDED: Firebase Hosting (For HealthNest)

### Why Firebase?
✅ Already configured in your project
✅ FREE hosting up to 10GB storage, 360MB/day bandwidth
✅ Automatic SSL certificate
✅ Global CDN
✅ Easy rollback
✅ Works perfectly with Firebase services (Auth, Firestore, Storage)

### Quick Deploy Commands:
```bash
# 1. Build
flutter build web --release

# 2. Deploy
firebase deploy --only hosting

# Done! Your app is live at:
# https://healthnest-ae7bb.web.app
```

---

## Backend Deployment (Firebase Functions - Already Setup)

Your Node.js backend in `/functions` can be deployed:

```bash
# Deploy Firebase Functions
firebase deploy --only functions

# Your functions will be live at:
# https://us-central1-healthnest-ae7bb.cloudfunctions.net/functionName
```

---

## Environment Variables (for Production)

Create `.env.production`:
```env
# Firebase
FIREBASE_API_KEY=your_production_key
FIREBASE_PROJECT_ID=healthnest-ae7bb

# Supabase
SUPABASE_URL=https://ifarrmvatyygmasvtgxk.supabase.co
SUPABASE_ANON_KEY=your_supabase_key

# Other APIs
GOOGLE_MAPS_API_KEY=your_maps_key
```

---

## CI/CD Setup (GitHub Actions)

Create `.github/workflows/deploy.yml`:
```yaml
name: Deploy to Firebase Hosting

on:
  push:
    branches:
      - main

jobs:
  build_and_deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      
      - name: Setup Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Build web
        run: flutter build web --release
      
      - name: Deploy to Firebase
        uses: FirebaseExtended/action-hosting-deploy@v0
        with:
          repoToken: '${{ secrets.GITHUB_TOKEN }}'
          firebaseServiceAccount: '${{ secrets.FIREBASE_SERVICE_ACCOUNT }}'
          channelId: live
          projectId: healthnest-ae7bb
```

---

## Mobile App Deployment

### Android (Google Play Store)
```bash
# Build release APK
flutter build apk --release

# Or build App Bundle (recommended)
flutter build appbundle --release

# Upload to Google Play Console
# https://play.google.com/console
```

### iOS (Apple App Store)
```bash
# Build iOS release
flutter build ios --release

# Open Xcode
open ios/Runner.xcworkspace

# Archive and upload via Xcode
```

---

## Monitoring & Analytics

### Firebase Performance Monitoring
```bash
firebase deploy --only performance
```

### Google Analytics
```bash
firebase deploy --only analytics
```

### Error Tracking (Sentry)
```bash
# Add to pubspec.yaml
dependencies:
  sentry_flutter: ^7.0.0

# Configure in main.dart
await SentryFlutter.init(
  (options) {
    options.dsn = 'your-sentry-dsn';
  },
  appRunner: () => runApp(MyApp()),
);
```

---

## Cost Estimation (Monthly)

### FREE Tier (Recommended for Start):
- **Firebase Hosting**: 10GB storage, 360MB/day → FREE
- **Firestore**: 1GB storage, 50K reads/day → FREE
- **Firebase Auth**: Unlimited → FREE
- **Cloud Functions**: 2M invocations/month → FREE
- **Supabase**: 500MB storage, 2GB bandwidth → FREE

### Paid (If Scaling):
- **Firebase Blaze Plan**: Pay as you go
- **Google Cloud Run**: ~$5-20/month
- **Custom Domain**: $12/year

---

## Next Steps

1. **Choose a platform** (Recommended: Firebase Hosting)
2. **Build your web app**: `flutter build web --release`
3. **Deploy**: `firebase deploy --only hosting`
4. **Test**: Visit your live URL
5. **Set up CI/CD** (optional)
6. **Monitor**: Use Firebase Console

---

## Support & Resources

- Firebase Console: https://console.firebase.google.com/project/healthnest-ae7bb
- Firebase Docs: https://firebase.google.com/docs/hosting
- Flutter Web Deployment: https://docs.flutter.dev/deployment/web
- Supabase Dashboard: https://app.supabase.com

---

## Quick Start Script

Create and run this deployment script:

```bash
#!/bin/bash
# deploy.sh

echo "🚀 Deploying HealthNest to Firebase Hosting..."

# Clean previous builds
echo "🧹 Cleaning previous builds..."
flutter clean

# Get dependencies
echo "📦 Getting dependencies..."
flutter pub get

# Build web app
echo "🔨 Building web app..."
flutter build web --release

# Deploy to Firebase
echo "☁️ Deploying to Firebase..."
firebase deploy --only hosting

echo "✅ Deployment complete!"
echo "🌐 Your app is live at: https://healthnest-ae7bb.web.app"
```

Make it executable:
```bash
chmod +x deploy.sh
./deploy.sh
```

---

**Choose Firebase Hosting for the easiest and most cost-effective deployment! 🚀**
