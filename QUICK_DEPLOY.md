# 🚀 Quick Deploy Commands

## Option 1: One-Line Deploy (Fastest)

```bash
flutter build web --release && firebase deploy --only hosting
```

## Option 2: Using Deploy Script

```bash
./deploy.sh
```

## Option 3: Step-by-Step

### 1. Build Flutter Web
```bash
flutter build web --release
```

### 2. Deploy to Firebase
```bash
firebase deploy --only hosting
```

## Your Live URL
After deployment, your app will be available at:
```
https://healthnest-ae7bb.web.app
```

## Other Deployment Options

### Deploy Everything (Hosting + Functions + Firestore)
```bash
firebase deploy
```

### Deploy Only Functions
```bash
firebase deploy --only functions
```

### Deploy Only Firestore Rules
```bash
firebase deploy --only firestore:rules
```

### Deploy Only Firestore Indexes
```bash
firebase deploy --only firestore:indexes
```

## Preview Before Deploy
```bash
firebase hosting:channel:deploy preview
```

## Rollback to Previous Version
```bash
firebase hosting:rollback
```

## View Deployment History
```bash
firebase hosting:channel:list
```

## Custom Domain Setup
1. Go to Firebase Console → Hosting
2. Click "Add custom domain"
3. Follow DNS configuration steps

## CI/CD with GitHub Actions
See `.github/workflows/deploy.yml` for automatic deployment on push to main branch.

---

## Quick Start

**Right now, you can deploy with:**

```bash
# Build
flutter build web --release

# Deploy
firebase deploy --only hosting

# Done! 🎉
# Visit: https://healthnest-ae7bb.web.app
```

---

## Troubleshooting

### Error: "Firebase CLI not installed"
```bash
npm install -g firebase-tools
```

### Error: "Not logged in"
```bash
firebase login
```

### Error: "Project not found"
```bash
firebase use healthnest-ae7bb
```

### Error: "Build failed"
```bash
flutter clean
flutter pub get
flutter build web --release
```
