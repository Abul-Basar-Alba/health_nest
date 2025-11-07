# 🤰 Pregnancy Tracker - Complete Guide | গর্ভাবস্থা ট্র্যাকার - সম্পূর্ণ গাইড

## 📱 Overview | সংক্ষিপ্ত বিবরণ

**HealthNest** এর Pregnancy Tracker হলো বাংলাদেশের প্রথম সম্পূর্ণ বাংলা ভাষা সাপোর্ট সহ গর্ভাবস্থা ট্র্যাকিং অ্যাপ্লিকেশন!

### ✨ Key Features | মূল বৈশিষ্ট্য

1. **Bilingual Support | দ্বিভাষিক সাপোর্ট**
   - English ↔ বাংলা (Real-time toggle)
   - সম্পূর্ণ UI এবং content দুই ভাষায়

2. **42 Weeks Tracking | ৪২ সপ্তাহের ট্র্যাকিং**
   - সপ্তাহভিত্তিক শিশুর বিকাশ
   - মায়ের শারীরিক পরিবর্তন
   - স্বাস্থ্য পরামর্শ

3. **Baby Kick Counter | শিশুর কিক কাউন্টার**
   - Real-time kick counting
   - Daily history tracking
   - 7-day history view

4. **Contraction Timer | সংকোচন টাইমার**
   - Labor contraction timing
   - Duration & interval calculation
   - Warning alerts

---

## 🎯 Features Details | বৈশিষ্ট্যের বিস্তারিত

### 1. Main Dashboard | মূল ড্যাশবোর্ড

**Home Screen থেকে Access:**
- Pink colored "Pregnancy Tracker" card এ click করুন
- অথবা "Pregnancy" button (🤰 icon)

**Dashboard এ দেখতে পাবেন:**
- ✅ Current week (বর্তমান সপ্তাহ)
- ✅ Baby size comparison (শিশুর আকার তুলনা)
- ✅ Due date countdown (প্রসবের তারিখ কাউন্টডাউন)
- ✅ Quick stats (ওজন, কিক, সংকোচন)
- ✅ Language toggle (ভাষা পরিবর্তন)

### 2. Week Details Screen | সপ্তাহভিত্তিক বিবরণ

**Access:** Dashboard থেকে "Week Details" button

**Content per Week:**
- 👶 **Baby's Development | শিশুর বিকাশ**
  - Size comparison (লেবু, আম, তরমুজ etc.)
  - Length & weight (দৈর্ঘ্য ও ওজন)
  - Developmental milestones
  
- 🤰 **Maternal Changes | মায়ের শারীরিক পরিবর্তন**
  - Body changes
  - Common symptoms
  - What to expect
  
- 💡 **Health Tips | স্বাস্থ্য পরামর্শ**
  - Nutrition advice
  - Exercise guidelines
  - Medical checkup reminders

**Navigation:**
- Previous Week / পূর্ববর্তী সপ্তাহ
- Next Week / পরবর্তী সপ্তাহ

### 3. Kick Counter | কিক কাউন্টার

**Access:** Dashboard থেকে "Kick Counter" button

**Features:**
- ✅ Start/Stop timer
- ✅ Tap to count each kick
- ✅ Today's total kicks display
- ✅ Last 7 days history
- ✅ Auto-save to Firestore
- ✅ Purple theme (beautiful UI)

**How to Use:**
1. Press "Start Counting"
2. Tap the big button each time you feel a kick
3. Press "Stop & Save" when done
4. View your kick history below

### 4. Contraction Timer | সংকোচন টাইমার

**Access:** Dashboard থেকে "Contraction Timer" button

**Features:**
- ⏱️ Real-time duration tracking (MM:SS)
- 📊 Interval calculation between contractions
- 📈 Average duration & interval stats
- ⚠️ Warning when interval < 5 minutes
- 🗑️ Delete individual contractions
- 💾 Auto-save to Firestore

**How to Use:**
1. When contraction starts → Press "Start Contraction"
2. When it ends → Press "End Contraction"
3. Duration and interval automatically calculated
4. Repeat for each contraction
5. Watch for warning if labor is approaching!

**⚠️ Important Warning:**
```
যদি সংকোচনের ব্যবধান ৫ মিনিটের কম হয়, অবিলম্বে ডাক্তারের সাথে যোগাযোগ করুন!
If contractions are less than 5 minutes apart, contact your doctor immediately!
```

---

## 🗄️ Data Storage | ডেটা সংরক্ষণ

**Firestore Collections:**
- `pregnancies` - Main pregnancy data
- `kick_counts` - Baby kick records
- `contraction_logs` - Contraction timing data
- `symptom_logs` - Daily symptom tracking

**Data Persistence:**
- ✅ All data saved to Firebase Firestore
- ✅ Real-time sync across devices
- ✅ Offline support
- ✅ Secure & private

---

## 🎨 UI Theme | UI থিম

**Color Scheme:**
- **Primary:** Soft Pink (#FFB6C1)
- **Secondary:** Lavender (#E6E6FA)
- **Accent:** Mint Green (#98FF98)
- **Background:** Cream (#FFF8DC)
- **Kick Counter:** Purple (#9C27B0)
- **Contraction Timer:** Red/Pink (#E91E63)

**Design Philosophy:**
- Calming and soothing colors for pregnant mothers
- Large, easy-to-tap buttons
- Clear typography
- Minimal distractions

---

## 📊 Weekly Development Data | সাপ্তাহিক বিকাশের তথ্য

**42 Weeks Complete Content:**
- Week 1-4: Early pregnancy signs
- Week 5-12: First trimester development
- Week 13-26: Second trimester growth
- Week 27-40: Third trimester preparation
- Week 41-42: Postpartum care

**Sample Week 12 Data:**
```
Baby Size: Lime 🍋 | লেবু
Length: 5.4 cm | ৫.৪ সেমি
Weight: 14 grams | ১৪ গ্রাম

Developments:
✅ Baby can open and close fingers
✅ Reflexes are developing
✅ Intestines moving into abdomen

শিশুর বিকাশ:
✅ শিশু আঙুল খুলতে এবং বন্ধ করতে পারে
✅ প্রতিবর্তী ক্রিয়া বিকশিত হচ্ছে
✅ অন্ত্র পেটের ভিতরে চলে যাচ্ছে
```

---

## 🔧 Technical Details | প্রযুক্তিগত বিবরণ

**Architecture:**
- **Models:** 5 (Pregnancy, BabyDevelopment, SymptomLog, KickCount, ContractionLog)
- **Services:** 3 (PregnancyService, PregnancyCalculator, WeeklyDevelopmentData)
- **Providers:** 1 (PregnancyProvider with ChangeNotifier)
- **Screens:** 4 (Tracker, WeekDetails, KickCounter, ContractionTimer)

**State Management:**
- Provider pattern
- Real-time Firebase streams
- Local state for counters & timers

**Calculations:**
- Due date = LMP + 280 days (40 weeks)
- Current week = (Today - LMP) / 7 days
- Days until due = Due date - Today

---

## 📱 How to Use | কীভাবে ব্যবহার করবেন

### First Time Setup | প্রথমবার সেটআপ

1. Open HealthNest app
2. Go to Home screen
3. Tap on **"Pregnancy Tracker"** card (pink color)
4. Enter your details:
   - Last Menstrual Period (LMP) date
   - Current weight
   - Any symptoms

5. Tap **"Create Pregnancy"** button
6. Your dashboard is ready! 🎉

### Daily Use | দৈনিক ব্যবহার

**Morning:**
- Check current week development
- Log your weight
- Track morning symptoms

**Throughout Day:**
- Count baby kicks (at least 10 per 2 hours recommended)
- Note any unusual symptoms

**If in Labor:**
- Use Contraction Timer
- Monitor interval duration
- Contact doctor when needed

### Language Toggle | ভাষা পরিবর্তন

- Look for the language button in top-right corner
- **EN** → Switch to বাংলা
- **বাংলা** → Switch to English
- All content updates instantly!

---

## 🎓 Educational Content | শিক্ষামূলক বিষয়বস্তু

**What Makes This Special:**
- ✅ First fully bilingual pregnancy tracker in Bangladesh
- ✅ Culturally appropriate content
- ✅ Islamic health tips included
- ✅ Local fruit/vegetable comparisons for baby size
- ✅ Bangla medical terminology

**Example Size Comparisons:**
- Week 8: Rice grain (চালের দানা)
- Week 12: Lime (লেবু)
- Week 20: Mango (আম)
- Week 36: Watermelon (তরমুজ)

---

## 🔐 Privacy & Security | গোপনীয়তা এবং নিরাপত্তা

- ✅ All data encrypted in Firebase
- ✅ Only you can access your pregnancy data
- ✅ No data shared with third parties
- ✅ Secure authentication required
- ✅ Offline mode for sensitive areas

---

## 📞 Support | সহায়তা

**If you need help:**
- Contact admin through app
- Report bugs via GitHub
- Medical emergencies → Call your doctor immediately

**Important:** This app is for tracking purposes only. Always consult your doctor for medical advice.

---

## 🚀 Future Enhancements | ভবিষ্যৎ উন্নতি

**Planned Features:**
- [ ] Photo diary for bump progression
- [ ] Partner sharing mode
- [ ] Doctor appointment reminders
- [ ] Nutrition tracker
- [ ] Exercise videos for pregnant women
- [ ] Community forum
- [ ] Export pregnancy report (PDF)
- [ ] Voice reminders in Bangla

---

## 📝 Version History | সংস্করণ ইতিহাস

**v1.0.0 - November 7, 2025**
- ✅ Initial release
- ✅ 42 weeks bilingual content
- ✅ Kick counter
- ✅ Contraction timer
- ✅ Week-by-week guide
- ✅ Language toggle
- ✅ Firebase integration

---

## 🎉 Success Metrics | সফলতার মাপকাঠি

**HealthNest is now 100% Feature Complete!**

✅ Medicine Reminder System
✅ Family Member Tracking
✅ Health Diary
✅ Drug Interaction Checker
✅ **Pregnancy Tracker (NEW!)**

**APK Size:** 67 MB
**Build Status:** ✅ Success
**Errors:** 0
**Warnings:** 50 (deprecated API, non-blocking)

---

## 🙏 Credits | কৃতজ্ঞতা

Developed with ❤️ for Bangladeshi mothers

**Tech Stack:**
- Flutter 3.x
- Firebase (Firestore, Auth)
- Provider State Management
- Material Design 3

---

## 📄 License

Copyright © 2025 HealthNest
All rights reserved.

---

**মা ও শিশুর সুস্বাস্থ্য কামনা করি! 💝**
**Wishing health and happiness to mother and baby! 💝**
