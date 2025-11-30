-- =====================================================
-- Supabase Storage Policies for Profile Bucket
-- Run this in: Supabase Dashboard → SQL Editor → New Query
-- =====================================================

-- Step 1: Remove all existing policies on profile bucket
DROP POLICY IF EXISTS "Profile mav895_1" ON storage.objects;
DROP POLICY IF EXISTS "Profile mav895_2" ON storage.objects;
DROP POLICY IF EXISTS "Profile mav895_3" ON storage.objects;
DROP POLICY IF EXISTS "Profile mav895_0" ON storage.objects;
DROP POLICY IF EXISTS "Allow all operations on profile bucket" ON storage.objects;
DROP POLICY IF EXISTS "Public Upload" ON storage.objects;
DROP POLICY IF EXISTS "Public Read" ON storage.objects;
DROP POLICY IF EXISTS "Public Delete" ON storage.objects;
DROP POLICY IF EXISTS "Public Update" ON storage.objects;

-- Step 2: Create ONE simple policy that allows everything
CREATE POLICY "Allow all operations on profile bucket"
ON storage.objects
FOR ALL
TO public
USING (bucket_id = 'profile')
WITH CHECK (bucket_id = 'profile');

-- Step 3: Verify the policy was created
SELECT * FROM storage.policies WHERE bucket_id = 'profile';
