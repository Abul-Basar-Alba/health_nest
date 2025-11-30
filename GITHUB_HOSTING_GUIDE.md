# 🚀 GitHub Hosting Setup Guide

## Option 1: GitHub Pages (FREE - সবচেয়ে সহজ)

### Automatic Deployment (Already Configured! ✅)

GitHub Actions workflow তৈরি করা হয়েছে যা automatically deploy করবে প্রতি push-এ।

### Enable GitHub Pages:

1. **GitHub repository-তে যান:**
   ```
   https://github.com/Abul-Basar-Alba/health_nest/settings/pages
   ```

2. **Source সিলেক্ট করুন:**
   - Source: GitHub Actions
   - ✅ Save করুন

3. **Automatic Deployment:**
   - প্রতিবার `main` branch-এ push করলে automatically build ও deploy হবে
   - 2-3 মিনিট পর app live হবে

4. **Your Live URL:**
   ```
   https://abul-basar-alba.github.io/health_nest/
   ```

---

## Option 2: Firebase Hosting (RECOMMENDED - Better Performance)

### Manual Deployment:

```bash
# Build
flutter build web --release

# Deploy
firebase deploy --only hosting
```

### Your Live URL:
```
https://healthnest-ae7bb.web.app
```

### GitHub Actions Automatic Deployment:

1. **Generate Firebase Service Account:**
   
   ```bash
   firebase init hosting:github
   ```
   
   অথবা manually:
   
   a. Firebase Console-এ যান:
      ```
      https://console.firebase.google.com/project/healthnest-ae7bb/settings/serviceaccounts/adminsdk
      ```
   
   b. "Generate new private key" click করুন
   
   c. JSON file download হবে

2. **Add GitHub Secret:**
   
   a. GitHub repository-তে যান:
      ```
      https://github.com/Abul-Basar-Alba/health_nest/settings/secrets/actions
      ```
   
   b. "New repository secret" click করুন
   
   c. Name: `FIREBASE_SERVICE_ACCOUNT_HEALTHNEST_AE7BB`
   
   d. Value: পুরো JSON file-এর content paste করুন
   
   e. "Add secret" click করুন

3. **Push to GitHub:**
   ```bash
   git push origin main
   ```

4. **Automatic Deployment:**
   - GitHub Actions automatically build ও deploy করবে
   - Firebase Hosting-এ live হবে

---

## Option 3: Vercel (Alternative - Very Fast)

### Steps:

1. **Vercel-এ যান:**
   ```
   https://vercel.com
   ```

2. **GitHub দিয়ে login করুন**

3. **Import Project:**
   - Repository select করুন: `health_nest`
   - Framework Preset: Other
   - Build Command: `flutter build web --release`
   - Output Directory: `build/web`

4. **Deploy:**
   - "Deploy" button click করুন
   - 2-3 মিনিটে live হবে

5. **Your Live URL:**
   ```
   https://health-nest.vercel.app
   ```

---

## Option 4: Netlify (Alternative - Easy)

### Steps:

1. **Netlify-এ যান:**
   ```
   https://app.netlify.com
   ```

2. **GitHub দিয়ে login করুন**

3. **Import Project:**
   - "New site from Git" click করুন
   - Repository select করুন: `health_nest`
   - Build command: `flutter build web --release`
   - Publish directory: `build/web`

4. **Deploy:**
   - "Deploy site" button click করুন

5. **Your Live URL:**
   ```
   https://health-nest.netlify.app
   ```

---

## Quick Comparison

| Platform | URL | Setup Time | Auto Deploy | Cost |
|----------|-----|------------|-------------|------|
| **GitHub Pages** | github.io/health_nest | 2 min | ✅ Yes | FREE |
| **Firebase Hosting** | .web.app | 5 min | ✅ Yes* | FREE |
| **Vercel** | .vercel.app | 3 min | ✅ Yes | FREE |
| **Netlify** | .netlify.app | 3 min | ✅ Yes | FREE |

\* Requires service account setup

---

## Right Now - Choose One:

### 🎯 Easiest (2 minutes):

**GitHub Pages** - Already configured!

1. Go to: https://github.com/Abul-Basar-Alba/health_nest/settings/pages
2. Source: GitHub Actions
3. Save
4. Push code: `git push`
5. Wait 2-3 minutes
6. Visit: https://abul-basar-alba.github.io/health_nest/

### 🚀 Best Performance (5 minutes):

**Firebase Hosting** - Better features

```bash
flutter build web --release
firebase deploy --only hosting
```

Live URL: https://healthnest-ae7bb.web.app

---

## Current Status

✅ GitHub Actions workflows created:
- `.github/workflows/github-pages.yml` - GitHub Pages deployment
- `.github/workflows/firebase-hosting-merge.yml` - Firebase auto deploy
- `.github/workflows/firebase-hosting-pull-request.yml` - Preview deployments

✅ Firebase hosting configured in `firebase.json`

✅ Ready to deploy!

---

## Next Steps

1. **Commit changes:**
   ```bash
   git add .
   git commit -m "Add GitHub hosting workflows"
   git push origin main
   ```

2. **Enable GitHub Pages** (for Option 1)
   OR
   **Add Firebase Secret** (for Option 2)

3. **Wait 2-3 minutes**

4. **Visit your live site! 🎉**

---

## Monitoring

### GitHub Pages:
- Actions: https://github.com/Abul-Basar-Alba/health_nest/actions
- Deployments: https://github.com/Abul-Basar-Alba/health_nest/deployments

### Firebase Hosting:
- Console: https://console.firebase.google.com/project/healthnest-ae7bb/hosting
- Analytics: https://console.firebase.google.com/project/healthnest-ae7bb/analytics

---

## Custom Domain (Optional)

### GitHub Pages:
1. Go to Settings → Pages
2. Custom domain: `yourdomain.com`
3. Add CNAME record in your DNS

### Firebase Hosting:
1. Go to Hosting → Add custom domain
2. Follow verification steps
3. Auto SSL certificate

---

## Troubleshooting

### Build failing?
```bash
flutter clean
flutter pub get
flutter build web --release
```

### GitHub Actions not running?
- Check: https://github.com/Abul-Basar-Alba/health_nest/actions
- Enable Actions in repository settings

### Firebase deploy failing?
```bash
firebase login
firebase use healthnest-ae7bb
firebase deploy --only hosting
```

---

**Choose GitHub Pages for quickest setup, or Firebase Hosting for best performance!**
