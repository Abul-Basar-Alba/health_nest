// lib/src/services/supabase_storage_service.dart

import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseStorageService {
  static final SupabaseStorageService _instance =
      SupabaseStorageService._internal();
  factory SupabaseStorageService() => _instance;
  SupabaseStorageService._internal();

  SupabaseClient? _supabase;
  static const String profileBucket = 'Profile';
  static const String bumpPhotoBucket = 'Bump_Photo';
  bool _isInitialized = false;

  // Initialize Supabase
  Future<void> initialize() async {
    if (_isInitialized) {
      print('ℹ️ Supabase already initialized');
      return;
    }

    try {
      await Supabase.initialize(
        url: 'https://ifarrmvatyygmasvtgxk.supabase.co',
        anonKey:
            'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImlmYXJybXZhdHl5Z21hc3Z0Z3hrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ1MDg4MDcsImV4cCI6MjA4MDA4NDgwN30.IdcvqO_JDaxV-EUkFQrgqzCnN2mPglGMRxPALyff7Ls',
      );
      _supabase = Supabase.instance.client;
      _isInitialized = true;
      print('✅ Supabase initialized successfully');
    } catch (e) {
      print('❌ Supabase initialization error: $e');
      _isInitialized = false;
      rethrow;
    }
  }

  // Upload profile image
  Future<String?> uploadProfileImage({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      if (_supabase == null || !_isInitialized) {
        print('❌ Supabase not initialized');
        throw Exception('Supabase not initialized');
      }

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = '${userId}_$timestamp$extension';
      final filePath = 'avatars/$fileName';

      print('📤 Starting upload...');
      print('   User ID: $userId');
      print('   File path: $filePath');
      print('   Extension: $extension');

      // Read file bytes (works on both mobile and web)
      final bytes = await imageFile.readAsBytes();
      print('📦 File size: ${bytes.length} bytes');

      // Determine content type
      String contentType = 'image/jpeg';
      if (extension.toLowerCase() == '.png') {
        contentType = 'image/png';
      } else if (extension.toLowerCase() == '.jpg' ||
          extension.toLowerCase() == '.jpeg') {
        contentType = 'image/jpeg';
      } else if (extension.toLowerCase() == '.webp') {
        contentType = 'image/webp';
      }

      print('📄 Content type: $contentType');

      // Upload to Supabase Storage with error handling
      print('⬆️ Uploading to Supabase...');
      final uploadResponse =
          await _supabase!.storage.from(profileBucket).uploadBinary(
                filePath,
                bytes,
                fileOptions: FileOptions(
                  cacheControl: '3600',
                  upsert: true,
                  contentType: contentType,
                ),
              );

      print('✅ Upload response: $uploadResponse');

      // Get public URL
      final publicUrl =
          _supabase!.storage.from(profileBucket).getPublicUrl(filePath);

      print('🔗 Public URL generated: $publicUrl');
      print('✅ Profile image uploaded successfully!');

      return publicUrl;
    } catch (e, stackTrace) {
      print('❌❌❌ UPLOAD ERROR ❌❌❌');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Throw the error so we can see it in the UI
    }
  }

  // Delete old profile image
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      if (_supabase == null || !_isInitialized) {
        print('❌ Supabase not initialized');
        return false;
      }

      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find 'profile' bucket index and get path after it
      final bucketIndex = pathSegments.indexOf(profileBucket);
      if (bucketIndex == -1) {
        print('⚠️ Invalid image URL: $imageUrl');
        return false;
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      print('🗑️ Deleting old image: $filePath');

      // Delete from Supabase Storage
      await _supabase!.storage.from(profileBucket).remove([filePath]);

      print('✅ Old profile image deleted: $filePath');
      return true;
    } catch (e, stackTrace) {
      print('❌ Error deleting profile image: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Update profile image (delete old + upload new)
  Future<String?> updateProfileImage({
    required String userId,
    required XFile newImageFile,
    String? oldImageUrl,
  }) async {
    print('🔄 Update profile image called');
    print('   User ID: $userId');
    print('   Old URL: $oldImageUrl');

    try {
      // Delete old image if exists (don't fail if delete fails)
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        print('🗑️ Attempting to delete old image...');
        try {
          await deleteProfileImage(oldImageUrl);
        } catch (deleteError) {
          print(
              '⚠️ Failed to delete old image (continuing anyway): $deleteError');
        }
      }

      // Upload new image
      print('📤 Uploading new image...');
      final newImageUrl = await uploadProfileImage(
        userId: userId,
        imageFile: newImageFile,
      );

      if (newImageUrl == null) {
        throw Exception('Upload returned null URL');
      }

      print('✅✅✅ Profile image updated successfully!');
      return newImageUrl;
    } catch (e, stackTrace) {
      print('❌❌❌ UPDATE PROFILE IMAGE ERROR ❌❌❌');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      rethrow; // Rethrow so the UI can show the error
    }
  }

  // Get profile image URL (if needed for verification)
  String? getPublicUrl(String filePath) {
    if (_supabase == null || !_isInitialized) {
      print('❌ Supabase not initialized');
      return null;
    }
    return _supabase!.storage.from(profileBucket).getPublicUrl(filePath);
  }

  // List all user's profile images (for cleanup or management)
  Future<List<FileObject>> getUserProfileImages(String userId) async {
    try {
      if (_supabase == null || !_isInitialized) {
        print('❌ Supabase not initialized');
        return [];
      }

      final files =
          await _supabase!.storage.from(profileBucket).list(path: 'avatars');

      // Filter by userId
      final userFiles =
          files.where((file) => file.name.startsWith(userId)).toList();

      return userFiles;
    } catch (e) {
      print('❌ Error listing profile images: $e');
      return [];
    }
  }

  // Cleanup old profile images (keep only latest)
  Future<void> cleanupOldProfileImages(String userId) async {
    try {
      final userImages = await getUserProfileImages(userId);

      if (userImages.length <= 1) {
        print('ℹ️ No old images to cleanup');
        return;
      }

      // Sort by timestamp (newest first)
      userImages.sort((a, b) => b.name.compareTo(a.name));

      // Delete all except the first (latest)
      final imagesToDelete = userImages.skip(1).toList();

      for (final image in imagesToDelete) {
        await _supabase!.storage
            .from(profileBucket)
            .remove(['avatars/${image.name}']);
      }

      print('✅ Cleaned up ${imagesToDelete.length} old profile images');
    } catch (e) {
      print('❌ Error cleaning up old images: $e');
    }
  }

  // ===== BUMP PHOTO UPLOADS =====

  /// Upload bump photo to Supabase Storage
  Future<String?> uploadBumpPhoto({
    required dynamic imageFile, // XFile or File
    required String userId,
    required String pregnancyId,
    required int week,
  }) async {
    try {
      if (_supabase == null || !_isInitialized) {
        print('❌ Supabase not initialized for bump photo');
        throw Exception('Supabase not initialized');
      }

      // Generate unique filename with timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      String extension = '';

      // Get extension from path
      if (imageFile is XFile) {
        extension = path.extension(imageFile.path);
      } else if (imageFile.path != null) {
        extension = path.extension(imageFile.path);
      }

      final fileName = 'bump_week_${week}_${userId}_$timestamp$extension';
      final filePath = 'pregnancies/$userId/$pregnancyId/$fileName';

      print('📤 Uploading bump photo: $filePath');

      // Read file bytes
      final bytes = await imageFile.readAsBytes();
      print('📦 Bump photo size: ${bytes.length} bytes');

      // Determine content type
      String contentType = 'image/jpeg';
      if (extension.toLowerCase() == '.png') {
        contentType = 'image/png';
      } else if (extension.toLowerCase() == '.jpg' ||
          extension.toLowerCase() == '.jpeg') {
        contentType = 'image/jpeg';
      } else if (extension.toLowerCase() == '.webp') {
        contentType = 'image/webp';
      }

      // Upload to Supabase Storage
      await _supabase!.storage.from(bumpPhotoBucket).uploadBinary(
            filePath,
            bytes,
            fileOptions: FileOptions(
              cacheControl: '3600',
              upsert: true,
              contentType: contentType,
            ),
          );

      // Get public URL
      final publicUrl =
          _supabase!.storage.from(bumpPhotoBucket).getPublicUrl(filePath);

      print('✅ Bump photo uploaded: $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      print('❌ Error uploading bump photo: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete bump photo from Supabase Storage
  Future<bool> deleteBumpPhoto(String imageUrl) async {
    try {
      if (_supabase == null || !_isInitialized) {
        print('❌ Supabase not initialized');
        return false;
      }

      // Extract file path from URL
      final uri = Uri.parse(imageUrl);
      final pathSegments = uri.pathSegments;

      // Find bucket index and get path after it
      final bucketIndex = pathSegments.indexOf(bumpPhotoBucket);
      if (bucketIndex == -1) {
        print('⚠️ Invalid bump photo URL: $imageUrl');
        return false;
      }

      final filePath = pathSegments.sublist(bucketIndex + 1).join('/');

      print('🗑️ Deleting bump photo: $filePath');

      // Delete from Supabase Storage
      await _supabase!.storage.from(bumpPhotoBucket).remove([filePath]);

      print('✅ Bump photo deleted');
      return true;
    } catch (e, stackTrace) {
      print('❌ Error deleting bump photo: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  /// Get all bump photos for a pregnancy
  Future<List<String>> getBumpPhotos(String userId, String pregnancyId) async {
    try {
      if (_supabase == null || !_isInitialized) {
        print('❌ Supabase not initialized');
        return [];
      }

      // List all files in the pregnancy folder
      final files = await _supabase!.storage
          .from(bumpPhotoBucket)
          .list(path: 'pregnancies/$userId/$pregnancyId');

      // Get public URLs for all files
      final urls = files.map((file) {
        return _supabase!.storage
            .from(bumpPhotoBucket)
            .getPublicUrl('pregnancies/$userId/$pregnancyId/${file.name}');
      }).toList();

      return urls;
    } catch (e) {
      print('❌ Error getting bump photos: $e');
      return [];
    }
  }
}
