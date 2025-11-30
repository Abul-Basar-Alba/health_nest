# Firestore Index Setup Guide

## Issue
The app shows **"No photos yet"** even though images are successfully uploaded to Supabase. This is because Firestore queries require composite indexes that haven't been created yet.

## Root Cause
The bump photos list query uses:
```dart
.where('userId', isEqualTo: userId)
.where('pregnancyId', isEqualTo: pregnancyId)
.orderBy('week', descending: false)
```

This requires a **composite index** on the `bump_photos` collection.

## Solution

### Option 1: Create Index via Firebase Console (RECOMMENDED - FASTEST)

1. **Open the app and trigger the error:**
   - Navigate to: Pregnancy Tracker → Bump Photos
   - Try to view the photos list
   - Look at the error message in the console/logs

2. **The error will contain a clickable URL like:**
   ```
   FAILED_PRECONDITION: The query requires an index. You can create it here:
   https://console.firebase.google.com/v1/r/project/healthnest-ae7bb/firestore/indexes?create_composite=...
   ```

3. **Click the URL** - It will:
   - Open Firebase Console
   - Pre-fill the index configuration
   - Show you exactly what will be created

4. **Click "Create Index"** button

5. **Wait 1-2 minutes** for the index to build

6. **Refresh the app** - Photos will now appear!

### Option 2: Manual Index Creation via Firebase Console

1. Go to: https://console.firebase.google.com/project/healthnest-ae7bb/firestore/indexes

2. Click **"Create Index"**

3. Configure the index:
   - **Collection ID:** `bump_photos`
   - **Fields to index:**
     1. Field: `userId` | Order: Ascending
     2. Field: `pregnancyId` | Order: Ascending  
     3. Field: `week` | Order: Ascending
   - **Query scope:** Collection

4. Click **"Create"**

5. Wait for the index to build (1-2 minutes)

### Option 3: Deploy via Firebase CLI (ALREADY ATTEMPTED - HAS CONFLICTS)

The `firestore.indexes.json` file has been updated with all required indexes, but deployment fails because some indexes already exist in Firebase. This is a known Firebase CLI issue.

**Why it fails:**
```
Error: HTTP Error: 409, index already exists
```

**Current firestore.indexes.json includes:**
- ✅ `bump_photos` - userId, pregnancyId, week
- ✅ `symptom_logs` - pregnancyId, logDate DESC
- ✅ `kick_counts` - pregnancyId, startTime DESC
- ✅ `contractions` - pregnancyId, startTime DESC

## Additional Indexes Needed

You may also see these warnings (non-critical for bump photos):

### 1. Symptom Logs
```
Collection: symptom_logs
Fields: pregnancyId (ASC), logDate (DESC)
```

### 2. Kick Counts
```
Collection: kick_counts
Fields: pregnancyId (ASC), startTime (DESC)
```

### 3. Contractions
```
Collection: contractions
Fields: pregnancyId (ASC), startTime (DESC)
```

**To create these:** Follow the same process as bump_photos above. Firebase will provide clickable URLs in the error messages.

## Verification

After creating the index:

1. **Wait 1-2 minutes** for the index to build (you'll see "Building" status in Firebase Console)

2. **Test the app:**
   ```bash
   flutter run
   ```

3. **Navigate to:** Pregnancy Tracker → Bump Photos

4. **Verify:**
   - Previously uploaded photos now appear
   - Upload a new photo - it appears immediately
   - Delete a photo - it disappears from the list
   - Photos are sorted by week number

## Troubleshooting

### "Index already exists" error
This is normal - it means Firebase CLI tried to create an index that's already there. Use Option 1 or 2 instead.

### Photos still not showing after 5+ minutes
1. Check Firebase Console → Firestore → Indexes
2. Verify index status is "Enabled" (not "Building" or "Error")
3. Restart the app
4. Clear app cache (Settings → Storage → Clear Cache)

### How to check if index is created
```bash
firebase firestore:indexes
```

Or visit: https://console.firebase.google.com/project/healthnest-ae7bb/firestore/indexes

## Current Status

### ✅ Working:
- Image upload to Supabase storage
- Image compression (1024x1024, 85% quality)
- Cross-platform support (Web + Mobile)
- Metadata storage to Firestore

### ⚠️ Blocked by Missing Index:
- Displaying photos in list
- Photo comparison view
- Timeline/gallery features

### 📋 Next Steps:
1. **IMMEDIATE:** Create bump_photos index via Firebase Console (2 minutes)
2. Test photo display functionality
3. **OPTIONAL:** Create other pregnancy indexes (symptom_logs, kick_counts, contractions)
4. Monitor for any additional index requirements

## Summary

**The bump photo upload feature is 100% functional** - images are successfully stored in Supabase and metadata is saved to Firestore. The only issue is the **Firestore query can't run without the composite index**. Creating the index via the Firebase Console (Option 1) is the fastest solution and takes just 1-2 minutes.

After the index is created, all previously uploaded photos will immediately appear in the app.
