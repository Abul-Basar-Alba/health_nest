# Supabase Upload Test Guide

## Current Setup Status
✅ Bucket created: `profile`
✅ Bucket is Public
✅ Policies added: INSERT, SELECT, DELETE, UPDATE

## Test Checklist

### 1. Test the app and check logs:
When you click "Save Changes" after selecting an image, watch for these logs in the console:

**Expected Success Logs:**
```
🔄 Starting image upload from UI...
   Current image URL: null (or existing URL)
   User ID: your-user-id
🔄 Update profile image called
   User ID: your-user-id
   Old URL: null (or existing URL)
📤 Uploading new image...
📤 Starting upload...
   User ID: your-user-id
   File path: avatars/USER_ID_TIMESTAMP.jpg
   Extension: .jpg
📦 File size: XXXXX bytes
📄 Content type: image/jpeg
⬆️ Uploading to Supabase...
✅ Upload response: upload-response-data
🔗 Public URL generated: https://ifarrmvatyygmasvtgxk.supabase.co/storage/v1/object/public/profile/avatars/...
✅ Profile image uploaded successfully!
✅✅✅ Profile image updated successfully!
✅✅✅ Image uploaded successfully: URL
```

**Error Logs to Watch For:**
```
❌ Supabase not initialized
❌❌❌ UPLOAD ERROR ❌❌❌
Error type: StorageException
Error message: [specific error]
```

### 2. Common Errors and Solutions:

#### Error: "Row level security policy violation"
**Solution:** Run this SQL in Supabase SQL Editor:
```sql
-- Drop existing policies
DROP POLICY IF EXISTS "Profile mav895_1" ON storage.objects;
DROP POLICY IF EXISTS "Profile mav895_2" ON storage.objects;
DROP POLICY IF EXISTS "Profile mav895_3" ON storage.objects;
DROP POLICY IF EXISTS "Profile mav895_0" ON storage.objects;

-- Create new comprehensive policy
CREATE POLICY "Allow all operations on profile bucket"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'profile')
WITH CHECK (bucket_id = 'profile');
```

#### Error: "Invalid token" or "Unauthorized"
**Solution:** Verify your anon key:
1. Go to Supabase Dashboard → Settings → API
2. Copy the `anon` `public` key
3. Make sure it matches the key in `supabase_storage_service.dart`

#### Error: "Bucket not found"
**Solution:** Verify bucket exists:
1. Go to Storage → Check if `profile` bucket exists
2. Make sure it's marked as "Public"

### 3. Manual Upload Test:
1. Go to Supabase Dashboard → Storage → profile
2. Click "Upload file"
3. Try uploading a test image manually
4. If manual upload works, the issue is in the app code
5. If manual upload fails, the issue is with bucket configuration

### 4. Check Bucket Configuration:

In Supabase Dashboard → Storage → profile → Settings:
- ✅ Public bucket: ON
- ✅ File size limit: 5 MB or more
- ✅ Allowed MIME types: Leave empty (allows all) OR add:
  - `image/jpeg`
  - `image/jpg`
  - `image/png`
  - `image/webp`

### 5. Network Test:
Run this in browser console (when app is running):
```javascript
// Test if Supabase is reachable
fetch('https://ifarrmvatyygmasvtgxk.supabase.co/storage/v1/bucket/profile', {
  headers: {
    'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlmYXJybXZhdHl5Z21hc3Z0Z3hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MDg4MDcsImV4cCI6MjA4MDA4NDgwN30.IdcvqO_JDaxV-EUkFQrgqzCnN2mPglGMRxPALyff7Ls'
  }
})
.then(r => r.json())
.then(console.log)
.catch(console.error);
```

### 6. Alternative: Use Firebase Storage

If Supabase continues to fail, switch to Firebase Storage:

```dart
// In pubspec.yaml, uncomment:
firebase_storage: ^12.3.4

// Create firebase_storage_service.dart
// Similar to supabase_storage_service.dart
// Firebase Storage has easier setup and better Flutter integration
```

## Next Steps After Testing:

1. **Run the app** with the new logging
2. **Select an image** in Edit Profile
3. **Click Save Changes**
4. **Copy the error message** from the console
5. **Share the error** so we can fix the specific issue

The detailed logs will show us exactly where the upload is failing!
