# Supabase Profile Image Upload Troubleshooting Guide

## Error: "Failed to upload image"

### Issue
When clicking "Save Changes" after selecting a profile image, the upload fails with an orange snackbar message.

### Root Causes & Solutions

#### 1. **Bucket Permissions** (Most Common)
The 'profile' bucket needs public access for uploads and reads.

**Fix in Supabase Dashboard:**
1. Go to https://supabase.com/dashboard/project/ifarrmvatyygmasvtgxk
2. Navigate to **Storage** → **profile** bucket
3. Click **Policies** tab
4. Create the following policies:

**Policy 1: Public Upload**
```sql
CREATE POLICY "Public Upload"
ON storage.objects FOR INSERT
TO public
WITH CHECK (bucket_id = 'profile');
```

**Policy 2: Public Read**
```sql
CREATE POLICY "Public Read"
ON storage.objects FOR SELECT
TO public
USING (bucket_id = 'profile');
```

**Policy 3: Public Delete (for old image cleanup)**
```sql
CREATE POLICY "Public Delete"
ON storage.objects FOR DELETE
TO public
USING (bucket_id = 'profile');
```

**Policy 4: Public Update**
```sql
CREATE POLICY "Public Update"
ON storage.objects FOR UPDATE
TO public
USING (bucket_id = 'profile');
```

#### 2. **Bucket Configuration**
Make sure the bucket is public:
- In Supabase Dashboard → Storage → profile
- Check "Public bucket" option
- File size limit: Set to at least 5MB
- Allowed MIME types: `image/jpeg`, `image/png`, `image/jpg`, `image/webp`

#### 3. **CORS Settings**
If testing on web, add CORS settings:
- Go to Settings → API
- Add your domain to allowed origins
- For development: `http://localhost:*`

#### 4. **Anon Key Verification**
Current key in code:
```
eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlmYXJybXZhdHl5Z21hc3Z0Z3hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MDg4MDcsImV4cCI6MjA4MDA4NDgwN30.IdcvqO_JDaxV-EUkFQrgqzCnN2mPglGMRxPALyff7Ls
```

Verify this matches your project's anon key in:
Supabase Dashboard → Settings → API → Project API keys → `anon` `public`

### Quick Test Commands

**Test 1: Check Supabase Connection**
```bash
# Look for this log in terminal when app starts
✅ Supabase initialized successfully
```

**Test 2: Test Image Upload**
1. Open app
2. Go to Profile → Edit Profile
3. Tap camera icon
4. Select an image
5. Check terminal logs:

Expected logs:
```
📤 Uploading image: avatars/USER_ID_TIMESTAMP.jpg
📦 File size: XXXXX bytes
✅ Profile image uploaded successfully: https://...
```

Error logs to watch for:
```
❌ Supabase not initialized
❌ Image file does not exist
❌ Error uploading profile image: [specific error]
```

### Testing Image Upload Manually

Run this test in your Supabase SQL editor:
```sql
-- Check if bucket exists
SELECT * FROM storage.buckets WHERE name = 'profile';

-- Check existing policies
SELECT * FROM storage.policies WHERE bucket_id = 'profile';

-- Check uploaded files
SELECT * FROM storage.objects WHERE bucket_id = 'profile';
```

### Common Error Messages & Fixes

| Error Message | Cause | Solution |
|--------------|-------|----------|
| "new row violates row-level security policy" | Missing upload policy | Add Policy 1 above |
| "Failed to upload image" | Network/permissions | Check bucket public + policies |
| "Supabase not initialized" | Init failed in main.dart | Check logs, verify API key |
| "Image file does not exist" | Image picker issue | Check file permissions |

### Debugging Steps

1. **Check Console Logs:**
```bash
flutter run
# Watch for Supabase initialization and upload logs
```

2. **Verify Bucket in Supabase:**
- Go to Storage → profile
- Should show "Public" badge
- Click "Upload file" manually to test
- If manual upload works, issue is in app code

3. **Test with Simple Image:**
- Use a small PNG (< 100KB)
- Try camera vs gallery
- Check if one works but not the other

4. **Network Inspector (Web):**
- Open browser DevTools → Network tab
- Look for failed POST requests to `supabase.co`
- Check response status code and error message

### Alternative: Use Firebase Storage

If Supabase continues to have issues, switch to Firebase Storage:

1. Uncomment Firebase Storage in `pubspec.yaml`
2. Create `firebase_storage_service.dart` similar to Supabase service
3. Update `edit_profile_screen.dart` to use Firebase service

### Quick Fix: Temporary Workaround

If you need a quick solution, disable image upload and use default avatars:
```dart
// In edit_profile_screen.dart _saveProfile()
// Comment out the image upload section
// String? newImageUrl = _currentImageUrl; // Keep existing image
```

### Contact Support

If none of these work:
1. Check Supabase Status: https://status.supabase.com
2. Supabase Discord: https://discord.supabase.com
3. GitHub Issues: https://github.com/supabase/supabase/issues

---

**Last Updated:** November 30, 2025
**Supabase Project:** ifarrmvatyygmasvtgxk
**Bucket:** profile
