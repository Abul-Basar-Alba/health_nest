// lib/src/services/firebase_admin_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FirebaseAdminService {
  static const String _projectId = 'healthnest-ae7bb';
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  
  // VS Code Agent Detection
  static Future<bool> isVSCodeAgent() async {
    if (!kIsWeb) return false;
    
    try {
      // Check for localhost development server (VS Code extension)
      final response = await http.get(
        Uri.parse('http://localhost:4000/health'),
      ).timeout(const Duration(seconds: 2));
      
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
  
  // Get Firebase Console Data
  static Future<Map<String, dynamic>> getFirebaseConsoleData() async {
    try {
      final rulesSnapshot = await _firestore
          .collection('_admin')
          .doc('firestore_rules')
          .get();
      
      final rules = rulesSnapshot.exists 
          ? (rulesSnapshot.data()?['rules'] ?? _getDefaultRules()) as String
          : _getDefaultRules();
      
      return {
        'projectId': _projectId,
        'rules': rules,
        'lastSync': DateTime.now().toIso8601String(),
        'consoleUrls': getFirebaseConsoleUrls(),
      };
    } catch (e) {
      // Fallback to default rules
      return {
        'projectId': _projectId,
        'rules': _getDefaultRules(),
        'lastSync': 'Error: $e',
        'consoleUrls': getFirebaseConsoleUrls(),
      };
    }
  }
  
  // Update Rules from VS Code
  static Future<bool> updateRulesFromVSCode(String rules, String source) async {
    if (!await isVSCodeAgent()) return false;
    
    try {
      // Update local admin collection
      await _firestore.collection('_admin').doc('firestore_rules').set({
        'rules': rules,
        'updatedAt': FieldValue.serverTimestamp(),
        'updatedBy': _auth.currentUser?.email ?? 'vscode_agent',
        'source': source,
      });
      
      // Send to VS Code extension if available
      await _syncWithVSCodeExtension(rules);
      
      return true;
    } catch (e) {
      if (kDebugMode) {
        print('Failed to update rules from VS Code: $e');
      }
      return false;
    }
  }
  
  // Deploy to Firebase Console
  static Future<Map<String, dynamic>> deployToFirebaseConsole(String rules) async {
    if (!await isVSCodeAgent()) {
      return {
        'success': false,
        'message': 'VS Code Agent access required',
      };
    }
    
    try {
      // Update rules in admin collection
      await _firestore.collection('_admin').doc('firestore_rules').set({
        'rules': rules,
        'deployedAt': FieldValue.serverTimestamp(),
        'deployedBy': _auth.currentUser?.email ?? 'vscode_agent',
        'status': 'ready_for_deploy',
      });
      
      // Try to deploy via VS Code extension
      final deployResult = await _deployViaVSCode(rules);
      
      if (deployResult['success'] == true) {
        return {
          'success': true,
          'message': 'Rules deployed successfully via VS Code',
          'consoleUrl': getFirebaseConsoleUrls()['rules'],
        };
      } else {
        // Fallback: prepare for manual deployment
        return {
          'success': true,
          'message': 'Rules prepared for deployment. Please check Firebase Console.',
          'consoleUrl': getFirebaseConsoleUrls()['rules'],
          'instructions': 'Copy rules to Firebase Console manually or use Firebase CLI',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Deployment failed: $e',
      };
    }
  }
  
  // Firebase Console URLs
  static Map<String, String> getFirebaseConsoleUrls() {
    return {
      'project': 'https://console.firebase.google.com/project/$_projectId',
      'rules': 'https://console.firebase.google.com/project/$_projectId/firestore/rules',
      'database': 'https://console.firebase.google.com/project/$_projectId/firestore/data',
      'auth': 'https://console.firebase.google.com/project/$_projectId/authentication/users',
      'functions': 'https://console.firebase.google.com/project/$_projectId/functions/list',
      'analytics': 'https://console.firebase.google.com/project/$_projectId/analytics/app/android:com.example.health_nest',
      'hosting': 'https://console.firebase.google.com/project/$_projectId/hosting/main',
    };
  }
  
  // VS Code Rules Stream
  static Stream<Map<String, dynamic>> vscodeRulesStream() {
    return _firestore
        .collection('_admin')
        .doc('firestore_rules')
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists) return {};
      
      final data = snapshot.data()!;
      return {
        'lastUpdated': data['updatedAt']?.toDate()?.toIso8601String() ?? 'Never',
        'updatedBy': data['updatedBy'] ?? 'Unknown',
        'source': data['source'] ?? 'Unknown',
        'status': data['status'] ?? 'Active',
      };
    });
  }
  
  // Private: Sync with VS Code Extension
  static Future<void> _syncWithVSCodeExtension(String rules) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/firebase/sync'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': 'rules_update',
          'rules': rules,
          'timestamp': DateTime.now().toIso8601String(),
          'projectId': _projectId,
        }),
      ).timeout(const Duration(seconds: 5));
      
      if (kDebugMode) {
        print('VS Code sync response: ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('VS Code sync failed: $e');
      }
    }
  }
  
  // Private: Deploy via VS Code
  static Future<Map<String, dynamic>> _deployViaVSCode(String rules) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost:4000/firebase/deploy'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'type': 'deploy_rules',
          'rules': rules,
          'projectId': _projectId,
        }),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final result = json.decode(response.body);
        return {
          'success': true,
          'result': result,
        };
      } else {
        return {
          'success': false,
          'error': 'HTTP ${response.statusCode}',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
  
  // Default Firestore Rules
  static String _getDefaultRules() {
    return '''rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Allow admin access for authenticated users
    function isAdmin() {
      return request.auth != null && 
             get(/databases/\$(database)/documents/admins/\$(request.auth.uid)).data.isAdmin == true;
    }
    
    // Allow read/write for authenticated users on their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Community posts - authenticated users can read, owners can write
    match /community_posts/{postId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.auth.uid == resource.data.userId;
      allow update, delete: if request.auth != null && 
                            (request.auth.uid == resource.data.userId || isAdmin());
    }
    
    // Chat messages - authenticated users
    match /chat_messages/{messageId} {
      allow read, create: if request.auth != null;
      allow update, delete: if request.auth != null && 
                            (request.auth.uid == resource.data.userId || isAdmin());
    }
    
    // Admin collection - admins only
    match /_admin/{document} {
      allow read, write: if isAdmin();
    }
    
    // Allow read for all other collections (for authenticated users)
    match /{document=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && isAdmin();
    }
  }
}''';
  }
}
