// lib/src/services/storage_service.dart

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

import 'supabase_storage_service.dart';

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _supabaseStorage = SupabaseStorageService();

  // Upload bump photo to Supabase Storage (NEW - using Supabase)
  Future<String> uploadBumpPhoto(
    dynamic imageFile, // XFile or File
    String userId,
    String pregnancyId,
    int week,
  ) async {
    try {
      // Use Supabase for bump photos
      final url = await _supabaseStorage.uploadBumpPhoto(
        imageFile: imageFile,
        userId: userId,
        pregnancyId: pregnancyId,
        week: week,
      );

      if (url == null) {
        throw Exception('Failed to upload bump photo to Supabase');
      }

      return url;
    } catch (e) {
      print('❌ Bump photo upload failed: $e');
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Delete bump photo from Supabase Storage (NEW - using Supabase)
  Future<void> deleteBumpPhoto(String photoUrl) async {
    try {
      await _supabaseStorage.deleteBumpPhoto(photoUrl);
    } catch (e) {
      print('❌ Failed to delete bump photo: $e');
      // Silently fail if photo doesn't exist
    }
  }

  // Get all photos for a pregnancy (NEW - using Supabase)
  Future<List<String>> getBumpPhotos(String userId, String pregnancyId) async {
    try {
      return await _supabaseStorage.getBumpPhotos(userId, pregnancyId);
    } catch (e) {
      print('❌ Failed to get bump photos: $e');
      return [];
    }
  }

  // Upload profile photo (keeping Firebase for now)
  Future<String> uploadProfilePhoto(dynamic imageFile, String userId) async {
    try {
      final fileName =
          'profile_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';
      final storageRef = _storage.ref().child('users/$userId/$fileName');

      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload profile photo: $e');
    }
  }
}
