// lib/src/services/firebase_storage_service.dart
// Fallback storage service using Firebase Storage

import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class FirebaseStorageService {
  static final FirebaseStorageService _instance =
      FirebaseStorageService._internal();
  factory FirebaseStorageService() => _instance;
  FirebaseStorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  /// Upload profile image to Firebase Storage
  Future<String?> uploadProfileImage({
    required String userId,
    required XFile imageFile,
  }) async {
    try {
      // Generate unique filename
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final extension = path.extension(imageFile.path);
      final fileName = '${userId}_$timestamp$extension';
      final filePath = 'profile_images/$fileName';

      print('📤 Uploading to Firebase Storage...');
      print('   Path: $filePath');

      // Create reference
      final ref = _storage.ref().child(filePath);

      // Read file bytes
      final bytes = await imageFile.readAsBytes();
      print('📦 File size: ${bytes.length} bytes');

      // Set metadata
      final metadata = SettableMetadata(
        contentType: _getContentType(extension),
        customMetadata: {
          'userId': userId,
          'uploadedAt': DateTime.now().toIso8601String(),
        },
      );

      // Upload
      final uploadTask = ref.putData(bytes, metadata);

      // Monitor progress
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        final progress =
            (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
        print('Upload progress: ${progress.toStringAsFixed(1)}%');
      });

      // Wait for completion
      final snapshot = await uploadTask;
      print('✅ Upload complete: ${snapshot.state}');

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();
      print('🔗 Download URL: $downloadUrl');

      return downloadUrl;
    } catch (e, stackTrace) {
      print('❌ Firebase upload error: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }

  /// Delete profile image from Firebase Storage
  Future<bool> deleteProfileImage(String imageUrl) async {
    try {
      // Extract file path from URL
      final ref = _storage.refFromURL(imageUrl);
      await ref.delete();
      print('✅ Image deleted: ${ref.fullPath}');
      return true;
    } catch (e) {
      print('❌ Error deleting image: $e');
      return false;
    }
  }

  /// Update profile image (delete old + upload new)
  Future<String?> updateProfileImage({
    required String userId,
    required XFile newImageFile,
    String? oldImageUrl,
  }) async {
    try {
      // Upload new image first
      final newImageUrl = await uploadProfileImage(
        userId: userId,
        imageFile: newImageFile,
      );

      if (newImageUrl == null) {
        throw Exception('Failed to upload new image');
      }

      // Delete old image if exists
      if (oldImageUrl != null && oldImageUrl.isNotEmpty) {
        try {
          await deleteProfileImage(oldImageUrl);
        } catch (e) {
          print('⚠️ Could not delete old image: $e');
          // Continue anyway - new image is uploaded
        }
      }

      return newImageUrl;
    } catch (e) {
      print('❌ Error updating profile image: $e');
      rethrow;
    }
  }

  /// Get content type from file extension
  String _getContentType(String extension) {
    switch (extension.toLowerCase()) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.webp':
        return 'image/webp';
      default:
        return 'image/jpeg';
    }
  }

  /// Get all images for a user (for debugging)
  Future<List<String>> getUserImages(String userId) async {
    try {
      final ref = _storage.ref().child('profile_images');
      final result = await ref.listAll();

      final urls = <String>[];
      for (final item in result.items) {
        if (item.name.startsWith(userId)) {
          final url = await item.getDownloadURL();
          urls.add(url);
        }
      }

      return urls;
    } catch (e) {
      print('❌ Error getting user images: $e');
      return [];
    }
  }
}
