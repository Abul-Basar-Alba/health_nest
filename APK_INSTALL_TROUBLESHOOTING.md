# 🔧 APK Install/Load না হওয়ার সমস্যা ও সমাধান

## ✅ বর্তমান APK Information:
- **Package Name:** com.example.health_nest
- **Version:** 1.0.0 (versionCode: 1)
- **Min SDK:** 24 (Android 7.0)
- **Target SDK:** 36 (Android 14+)
- **APK Size:** 73.2 MB
- **Location:** `build/app/outputs/flutter-apk/app-release.apk`

---

## 🚨 সম্ভাব্য সমস্যা এবং সমাধান:

### 1️⃣ **"App not installed" Error**

#### কারণ:
- APK corrupt হয়ে গেছে
- Device এ পর্যাপ্ত storage নেই
- Previous version conflict
- Debug signature দিয়ে signed (release এর জন্য ঠিক না)

#### সমাধান:
```bash
# 1. Settings → Apps → HealthNest → Uninstall (যদি আগে install থাকে)
# 2. Storage check করুন (কমপক্ষে 200MB free থাকতে হবে)
# 3. APK টা fresh download করুন
# 4. "Install from Unknown Sources" enable করুন
```

---

### 2️⃣ **App Install হয় কিন্তু Open হলে Crash/White Screen**

#### কারণ:
- Firebase configuration missing
- Internet permission নেই (আমরা fix করেছি ✅)
- Minimum SDK version এর চেয়ে কম Android version

#### সমাধান:
✅ **আমরা যা fix করেছি:**
- Internet permission added
- Network state permission added
- All required permissions added

**আপনার device check করুন:**
- Android version must be **7.0 (API 24) or higher**
- যদি Android 6.0 বা কম হয়, APK run হবে না

---

### 3️⃣ **"Parse Error" / "There was a problem parsing the package"**

#### কারণ:
- APK টা incompatible architecture এর জন্য built
- APK download করার সময় corrupt হয়েছে
- Device এর Android version খুব পুরানো

#### সমাধান:
```bash
# Fresh APK build করুন:
flutter clean
flutter build apk --release

# অথবা specific architecture এর জন্য:
flutter build apk --split-per-abi --release
```

---

### 4️⃣ **App Opens কিন্তু Features কাজ করে না**

#### কারণ:
- Runtime permissions না দেওয়া
- Internet connection নেই
- Firebase not connected

#### সমাধান:
1. **Settings → Apps → HealthNest → Permissions**
   - ✅ Location (Allow)
   - ✅ Storage (Allow)
   - ✅ Body Sensors (Allow)
   - ✅ Physical Activity (Allow)
   - ✅ Notifications (Allow)

2. **Internet Connection Check:**
   - WiFi বা Mobile Data on করুন
   - Airplane mode off করুন

3. **Firebase Connection:**
   - App open করার পর কিছু সময় wait করুন
   - Data sync হতে 5-10 seconds লাগতে পারে

---

## 📋 Installation Steps (বিস্তারিত):

### Step 1: Device Preparation
```
1. Settings → Security → Unknown Sources → Enable
   (অথবা Settings → Apps → Special Access → Install Unknown Apps → File Manager → Allow)

2. Settings → Storage → Check Free Space
   (কমপক্ষে 200 MB free থাকতে হবে)

3. যদি আগে HealthNest install থাকে:
   Settings → Apps → HealthNest → Uninstall
```

### Step 2: APK Transfer
```
Option A: USB Cable দিয়ে
1. Phone কে computer এ USB দিয়ে connect করুন
2. File Transfer mode select করুন
3. app-release.apk টা Downloads folder এ copy করুন

Option B: WhatsApp/Telegram দিয়ে
1. APK টা নিজেকে send করুন
2. Phone এ download করুন

Option C: Google Drive দিয়ে
1. APK upload করুন Drive এ
2. Phone থেকে download করুন
```

### Step 3: Installation
```
1. File Manager open করুন
2. Downloads folder এ যান
3. app-release.apk তে tap করুন
4. "Install" button এ click করুন
5. Installation complete হওয়ার পর "Open" করুন
```

### Step 4: First Launch Setup
```
1. App open হলে Login/Sign Up করুন
2. Permissions দিন (যখন চাইবে):
   - Location ✅
   - Storage ✅
   - Body Sensors ✅
   - Activity Recognition ✅
   - Notifications ✅

3. Internet connection check করুন
4. কিছু সময় wait করুন (Firebase sync এর জন্য)
5. এখন সব features কাজ করবে! 🎉
```

---

## 🔍 Debugging Steps (যদি এখনো কাজ না করে):

### Method 1: Logcat দেখুন (Advanced)
```bash
# USB debugging enable করুন phone এ
# Computer এ এই command run করুন:
adb logcat | grep -i "healthnest\|flutter\|crash"
```

### Method 2: Split APK Build করুন
```bash
# আপনার phone এর architecture এর জন্য specific APK:
flutter build apk --split-per-abi --release

# এতে 3টা APK তৈরি হবে:
# - app-armeabi-v7a-release.apk (32-bit ARM)
# - app-arm64-v8a-release.apk (64-bit ARM) ← Most common
# - app-x86_64-release.apk (Intel)

# আপনার phone এ যেটা কাজ করবে সেটা install করুন
```

### Method 3: Debug APK Test করুন
```bash
# যদি release APK কাজ না করে, debug APK try করুন:
flutter build apk --debug

# এটা install করুন এবং দেখুন কোনো error message আসে কিনা
```

---

## ✅ Final Checklist:

### Before Installation:
- [ ] Android version 7.0+ (Check: Settings → About Phone)
- [ ] 200+ MB free storage
- [ ] Unknown Sources enabled
- [ ] Previous HealthNest app uninstalled

### During Installation:
- [ ] APK file খোলা যাচ্ছে
- [ ] "Install" button visible
- [ ] Installation progress সম্পূর্ণ হচ্ছে
- [ ] "App installed" message দেখাচ্ছে

### After Installation:
- [ ] App icon home screen এ visible
- [ ] App open হচ্ছে (crash করছে না)
- [ ] Login/Sign Up screen দেখাচ্ছে
- [ ] Internet connection আছে
- [ ] All permissions granted

---

## 🆘 এখনো সমস্যা হলে:

### Check করুন:
1. **Device Info:**
   - Settings → About Phone → Android version
   - Must be 7.0 or higher

2. **APK Info:**
   - File size should be ~73 MB
   - If less, re-download

3. **Installation Log:**
   - যদি error message আসে, screenshot নিন
   - Error message কি বলছে?

### Common Error Messages:

| Error | কারণ | সমাধান |
|-------|------|--------|
| "App not installed" | Signature mismatch | Previous app uninstall করুন |
| "Parse error" | Corrupt APK | Fresh download করুন |
| "Installation blocked" | Security settings | Unknown Sources enable করুন |
| "Insufficient storage" | Low space | Space clear করুন |
| "Version downgrade" | Lower version | Higher versionCode দিয়ে build করুন |

---

## 📞 Contact for Help:

যদি এই সব try করেও কাজ না করে, এই information পাঠান:
1. Phone model & Android version
2. Exact error message (screenshot)
3. Installation step যেখানে আটকে যাচ্ছে
4. APK file size (corrupted কিনা check করার জন্য)

---

**Last Updated:** November 18, 2025  
**APK Version:** 1.0.0  
**Min Android:** 7.0 (API 24)
