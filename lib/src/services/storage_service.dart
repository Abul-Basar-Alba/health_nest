// lib/src/services/storage_service.dart

import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;

class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload bump photo to Firebase Storage
  Future<String> uploadBumpPhoto(
    File imageFile,
    String userId,
    String pregnancyId,
    int week,
  ) async {
    try {
      // Create unique filename
      final fileName =
          'bump_week_${week}_${DateTime.now().millisecondsSinceEpoch}${path.extension(imageFile.path)}';

      // Create storage path
      final storageRef = _storage.ref().child(
            'pregnancies/$userId/$pregnancyId/bump_photos/$fileName',
          );

      // Upload file
      final uploadTask = storageRef.putFile(imageFile);

      // Wait for upload to complete
      final snapshot = await uploadTask.whenComplete(() {});

      // Get download URL
      final downloadUrl = await snapshot.ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload photo: $e');
    }
  }

  // Delete bump photo from Firebase Storage
  Future<void> deleteBumpPhoto(String photoUrl) async {
    try {
      final ref = _storage.refFromURL(photoUrl);
      await ref.delete();
    } catch (e) {
      // Silently fail if photo doesn't exist
    }
  }

  // Upload profile photo
  Future<String> uploadProfilePhoto(File imageFile, String userId) async {
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

  // Get all photos for a pregnancy
  Future<List<String>> getBumpPhotos(String userId, String pregnancyId) async {
    try {
      final storageRef = _storage.ref().child(
            'pregnancies/$userId/$pregnancyId/bump_photos',
          );

      final result = await storageRef.listAll();

      final urls = await Future.wait(
        result.items.map((item) => item.getDownloadURL()),
      );

      return urls;
    } catch (e) {
      return [];
    }
  }
}
