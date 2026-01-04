# 🔌 USB Debugging Setup - মোবাইল Connect করার গাইড

## ❌ সমস্যা
`flutter run` বা `adb devices` command এ মোবাইল দেখাচ্ছে না।

## ✅ সমাধান - Step by Step

### 📱 Step 1: মোবাইলে Developer Options Enable করুন

1. **Settings** খুলুন
2. **About Phone** বা **About Device** এ যান
3. **Build Number** খুঁজুন (সাধারণত Software Information এর ভিতরে থাকে)
4. **Build Number** এ **7 বার** tap করুন
5. একটি message আসবে: "You are now a developer!" 🎉

### 🔓 Step 2: USB Debugging Enable করুন

1. **Settings** → **System** → **Developer Options** যান
   - কিছু ফোনে: **Settings** → **Additional Settings** → **Developer Options**
2. **Developer Options** toggle ON করুন
3. নিচে scroll করে **USB Debugging** খুঁজুন
4. **USB Debugging** toggle ON করুন
5. একটি warning dialog আসবে - **OK** press করুন

### 🔌 Step 3: USB Connection ঠিক করুন

1. **USB Cable দিয়ে মোবাইল আবার connect করুন**
2. মোবাইলে একটি popup আসবে: **"Allow USB debugging?"**
3. ✅ **"Always allow from this computer"** চেক করুন
4. **OK** বা **Allow** press করুন

### 💻 Step 4: Laptop এ Check করুন

Terminal এ এই commands চালান:

```bash
# ADB restart করুন
adb kill-server
adb start-server

# Device list দেখুন
adb devices
```

**সফল হলে দেখবেন:**
```
List of devices attached
XXXXXXXX    device
```

যদি **"unauthorized"** দেখেন:
- মোবাইলে আবার authorization popup আসবে
- "Allow" করুন

যদি এখনও device না দেখেন:
- USB cable পরিবর্তন করুন (ভাল quality cable ব্যবহার করুন)
- ভিন্ন USB port try করুন
- মোবাইল restart করুন

### 🚀 Step 5: Flutter Run করুন

```bash
cd /home/basar/health_nest
flutter devices
```

এখন আপনার মোবাইল list এ দেখাবে! 🎉

```bash
# মোবাইলে directly install এবং run করুন
flutter run
```

অথবা specific device select করুন:
```bash
flutter run -d <device-id>
```

---

## 🔧 Additional Troubleshooting

### সমস্যা: "No devices" এখনও দেখাচ্ছে

**চেক করুন:**

1. **USB Cable ঠিক আছে কিনা:**
   ```bash
   lsusb
   ```
   আপনার মোবাইল brand দেখা উচিত (যেমন: Motorola, Samsung, etc.)

2. **USB Mode পরিবর্তন করুন:**
   - মোবাইলে notification pull down করুন
   - "USB" notification tap করুন
   - **"File Transfer (MTP)"** বা **"PTP"** mode select করুন
   - কখনও কখনও **"Charging only"** থেকে switch করতে হয়

3. **Linux এ udev rules যোগ করুন:**
   ```bash
   # Android udev rules তৈরি করুন
   sudo nano /etc/udev/rules.d/51-android.rules
   ```
   
   নিচের content যোগ করুন:
   ```
   # Motorola
   SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666", GROUP="plugdev"
   
   # Samsung
   SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"
   
   # Google/Pixel
   SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"
   
   # Xiaomi
   SUBSYSTEM=="usb", ATTR{idVendor}=="2717", MODE="0666", GROUP="plugdev"
   
   # OnePlus
   SUBSYSTEM=="usb", ATTR{idVendor}=="2a70", MODE="0666", GROUP="plugdev"
   ```
   
   Save করুন এবং reload করুন:
   ```bash
   sudo chmod a+r /etc/udev/rules.d/51-android.rules
   sudo udevadm control --reload-rules
   sudo udevadm trigger
   ```

4. **User কে plugdev group এ যোগ করুন:**
   ```bash
   sudo usermod -aG plugdev $USER
   # Logout এবং login করুন
   ```

### সমস্যা: Device "unauthorized" দেখাচ্ছে

**সমাধান:**
```bash
# RSA keys reset করুন
adb kill-server
rm ~/.android/adbkey ~/.android/adbkey.pub
adb start-server

# মোবাইলে আবার authorization popup আসবে
```

### সমস্যা: Multiple devices connected, specific device select করতে চাই

```bash
# সব devices দেখুন
flutter devices

# Specific device এ run করুন
flutter run -d <device-id>

# শুধু মোবাইলে run করুন (emulator/web বাদ দিয়ে)
flutter run -d android
```

---

## 📋 Quick Command Reference

```bash
# Device status check
adb devices

# ADB restart
adb kill-server && adb start-server

# Flutter devices
flutter devices

# Run on device
flutter run

# Install APK directly
flutter install

# Build এবং install
flutter build apk --release
adb install build/app/outputs/flutter-apk/app-release.apk

# Device logs দেখুন
adb logcat

# Flutter logs
flutter logs
```

---

## 🎯 Wireless Debugging (Optional - Android 11+)

যদি cable ছাড়া debug করতে চান:

1. **মোবাইল এবং laptop একই WiFi এ connect করুন**

2. **Wireless ADB enable করুন:**
   ```bash
   # প্রথমে USB দিয়ে connect করুন
   adb tcpip 5555
   
   # মোবাইলের IP address খুঁজুন
   # Settings → About Phone → Status → IP Address
   
   # Wireless connect করুন (replace with your phone's IP)
   adb connect 192.168.0.XXX:5555
   
   # USB cable disconnect করতে পারেন
   
   # Check করুন
   adb devices
   ```

3. **Flutter run wireless mode এ:**
   ```bash
   flutter run
   ```

---

## ✅ Final Checklist

মোবাইল connect করার জন্য নিশ্চিত করুন:

- [ ] Developer Options enabled
- [ ] USB Debugging enabled  
- [ ] USB cable properly connected
- [ ] "Allow USB debugging" authorized করেছেন
- [ ] ADB server চালু আছে
- [ ] মোবাইল এবং laptop screen unlocked আছে

---

## 🆘 এখনও কাজ করছে না?

1. **মোবাইল restart করুন**
2. **Laptop restart করুন**
3. **ভিন্ন USB cable try করুন** (Data transfer support করে এমন)
4. **ভিন্ন USB port try করুন** (USB 2.0 port better)
5. **Flutter doctor চালান:**
   ```bash
   flutter doctor -v
   ```

যদি মোবাইল এখনও connect না হয়:
- মোবাইলের manufacturer website থেকে USB drivers download করুন
- অথবা APK বিল্ড করে manual install করুন (আগের guide অনুযায়ী)

---

**Help**: এই guide follow করার পরেও সমস্যা থাকলে আমাকে বলুন। আমি আরো specific help দিব! 💪
