# 📱 HealthNest মোবাইল ইনস্টলেশন গাইড

## ✅ সম্পূর্ণ হয়েছে

### 1. ✅ AI Backend চালু হয়েছে
- **Backend URL**: `http://192.168.0.109:5000`
- **Status**: চলছে এবং কাজ করছে
- **Log File**: `/home/basar/health_nest/ai_backend_improved.log`

### 2. ✅ Notification ঠিক করা হয়েছে
- সঠিক notification channel তৈরি করা হয়েছে
- Android notification icon কনফিগার করা হয়েছে
- Push notification এবং local notification দুটোই কাজ করবে

### 3. ✅ Step Counter ঠিক করা হয়েছে
- Activity Recognition permission যোগ করা হয়েছে
- Body Sensors permission যোগ করা হয়েছে
- Pedometer service সঠিকভাবে কনফিগার করা হয়েছে
- Step counting এখন প্রপার ভাবে কাজ করবে

### 4. ✅ APK তৈরি হয়েছে
- **APK Location**: `/home/basar/HealthNest-v1.0.0.apk`
- **Size**: 77 MB
- **Version**: 1.0.0

---

## 📥 মোবাইলে ইনস্টলেশন প্রসেস

### পদ্ধতি ১: USB Cable দিয়ে (সহজ)

1. **USB Cable দিয়ে মোবাইল Connect করুন**
   ```bash
   # APK টি মোবাইলে পাঠান
   adb install ~/HealthNest-v1.0.0.apk
   ```

2. **যদি adb না থাকে, তাহলে File Transfer করুন**
   - USB দিয়ে ফোন কানেক্ট করুন
   - File Transfer mode সিলেক্ট করুন
   - `/home/basar/HealthNest-v1.0.0.apk` ফাইলটি ফোনের Download folder এ কপি করুন
   - ফোনে File Manager দিয়ে APK খুলে ইনস্টল করুন

### পদ্ধতি ২: WiFi/Bluetooth দিয়ে

1. **Bluetooth দিয়ে পাঠান**
   - Laptop এবং মোবাইল দুটোতেই Bluetooth চালু করুন
   - APK ফাইলটি Bluetooth দিয়ে পাঠান
   - মোবাইলে receive করুন এবং ইনস্টল করুন

2. **বা, শেয়ারিং সফটওয়্যার ব্যবহার করুন**
   - KDE Connect, LocalSend, বা Nearby Share ব্যবহার করুন
   - APK শেয়ার করুন এবং ইনস্টল করুন

### পদ্ধতি ৩: HTTP Server দিয়ে

1. **Local HTTP Server চালু করুন**:
   ```bash
   cd /home/basar
   python3 -m http.server 8080
   ```

2. **মোবাইল Browser থেকে Download করুন**:
   - নিশ্চিত করুন মোবাইল এবং laptop একই WiFi এ আছে
   - মোবাইল Browser এ যান: `http://192.168.0.109:8080`
   - `HealthNest-v1.0.0.apk` লিংকে ক্লিক করুন
   - Download করে ইনস্টল করুন

---

## ⚙️ ইনস্টলেশনের পরে

### 1. অ্যাপ Permissions দিন

প্রথমবার খোলার সময় নিচের permissions দিতে হবে:

- ✅ **Notifications** - ওষুধের reminder এবং health alerts এর জন্য
- ✅ **Activity Recognition** - Step counting এর জন্য  
- ✅ **Body Sensors** - Step counter sensor access এর জন্য
- ✅ **Location** (Optional) - Exercise tracking এর জন্য
- ✅ **Camera** (Optional) - Profile photo এর জন্য
- ✅ **Storage** (Optional) - Report download এর জন্য

### 2. AI Backend Connection চেক করুন

- অ্যাপ খুলুন
- AI Chatbot option এ যান
- কিছু লিখে send করুন
- যদি response আসে = সফল! ✅

**Note**: AI backend কাজ করার জন্য:
- Laptop চালু থাকতে হবে
- Laptop এবং মোবাইল একই WiFi network এ থাকতে হবে
- Backend server চলতে হবে (`http://192.168.0.109:5000`)

### 3. Step Counter Test করুন

- Dashboard এ যান
- Step Counter icon এ ট্যাপ করুন
- Permission dialog আসলে সব permissions দিন
- কিছু পদক্ষেপ হাঁটুন
- Step count update হচ্ছে কিনা দেখুন

### 4. Notification Test করুন

- Medicine Reminder তে যান
- একটি reminder সেট করুন (যেমন: 2 মিনিট পরে)
- Notification আসছে কিনা দেখুন

---

## 🔧 Troubleshooting

### সমস্যা: APK ইনস্টল হচ্ছে না

**সমাধান:**
1. Settings → Security → Unknown Sources enable করুন
2. অথবা Settings → Apps → Special app access → Install unknown apps → আপনার file manager কে permission দিন

### সমস্যা: AI Chatbot কাজ করছে না

**সমাধান:**
1. **Backend চালু আছে কিনা চেক করুন:**
   ```bash
   curl http://192.168.0.109:5000/health
   ```
   Response আসলে backend ঠিক আছে

2. **একই WiFi আছে কিনা চেক করুন:**
   ```bash
   # Laptop IP
   ip addr show
   
   # মোবাইলে Settings → WiFi → Connected network details দেখুন
   ```

3. **Backend restart করুন:**
   ```bash
   cd /home/basar/health_nest
   bash start_ai_backend_improved.sh
   ```

### সমস্যা: Step Counter কাজ করছে না

**সমাধান:**
1. **Permissions দেওয়া আছে কিনা চেক করুন:**
   - Settings → Apps → HealthNest → Permissions
   - "Physical activity" permission দিন
   - "Body sensors" permission দিন

2. **Device এ step counter sensor আছে কিনা চেক করুন:**
   - Settings → About phone → Software information
   - বেশিরভাগ আধুনিক ফোনে আছে

3. **App restart করুন:**
   - App বন্ধ করে আবার খুলুন
   - Background থেকে সম্পূর্ণ বন্ধ করে দিন

### সমস্যা: Notifications আসছে না

**সমাধান:**
1. **Notification permission দেওয়া আছে কিনা চেক করুন:**
   - Settings → Apps → HealthNest → Notifications
   - "Allow notifications" enable করুন

2. **Battery optimization disable করুন:**
   - Settings → Battery → Battery optimization
   - HealthNest খুঁজুন এবং "Don't optimize" সিলেক্ট করুন

3. **Do Not Disturb mode off আছে কিনা চেক করুন**

---

## 📊 Backend Status চেক করার Command

```bash
# Backend চালু আছে কিনা
curl http://192.168.0.109:5000/health

# Backend log দেখুন
tail -f /home/basar/health_nest/ai_backend_improved.log

# Backend restart করুন
cd /home/basar/health_nest
bash start_ai_backend_improved.sh
```

---

## 🎯 পরবর্তী Steps

1. ✅ অ্যাপ ইনস্টল করুন
2. ✅ Account তৈরি করুন বা Login করুন
3. ✅ Profile সেটআপ করুন (height, weight, age, etc.)
4. ✅ Permissions দিন
5. ✅ Features explore করুন:
   - AI Health Chatbot 🤖
   - Step Counter 👟
   - Medicine Reminder 💊
   - Water Reminder 💧
   - Exercise Tracker 🏋️
   - Pregnancy Tracker 🤰
   - Women's Health 🌸
   - Community Chat 💬

---

## 📞 সাহায্য প্রয়োজন?

যদি কোনো সমস্যা হয়:
1. Backend log চেক করুন: `tail -f /home/basar/health_nest/ai_backend_improved.log`
2. App এর error message স্ক্রিনশট নিন
3. WiFi connection verify করুন
4. App cache clear করে restart করুন

---

**Version**: 1.0.0  
**Build Date**: January 4, 2026  
**Backend**: Flask (Python) running on http://192.168.0.109:5000
