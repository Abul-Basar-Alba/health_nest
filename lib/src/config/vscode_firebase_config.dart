// lib/src/config/vscode_firebase_config.dart

import 'package:flutter/foundation.dart';

class VSCodeFirebaseConfig {
  static const String projectId = 'healthnest-ae7bb';
  static const String region = 'us-central1';
  static const String firestoreDatabase = '(default)';

  // VS Code Firebase Extension Endpoints
  static const Map<String, String> vscodeEndpoints = {
    'rules': 'http://localhost:4000/firebase/rules',
    'emulator': 'http://localhost:4000/firebase/emulator',
    'console': 'http://localhost:4000/firebase/console',
    'deploy': 'http://localhost:4000/firebase/deploy',
    'sync': 'http://localhost:4000/firebase/sync',
  };

  // Firebase Console URLs
  static const Map<String, String> consoleUrls = {
    'project': 'https://console.firebase.google.com/project/$projectId',
    'rules':
        'https://console.firebase.google.com/project/$projectId/firestore/rules',
    'database':
        'https://console.firebase.google.com/project/$projectId/firestore/data',
    'auth':
        'https://console.firebase.google.com/project/$projectId/authentication/users',
    'functions':
        'https://console.firebase.google.com/project/$projectId/functions/list',
    'analytics':
        'https://console.firebase.google.com/project/$projectId/analytics/app/android:com.example.health_nest',
    'hosting':
        'https://console.firebase.google.com/project/$projectId/hosting/main',
  };

  // Firebase Emulator Ports
  static const Map<String, int> emulatorPorts = {
    'firestore': 8080,
    'auth': 9099,
    'functions': 5001,
    'hosting': 5000,
    'storage': 9199,
  };

  // VS Code Agent Detection
  static bool get isVSCodeEnvironment {
    return kIsWeb && _isVSCodeWebview();
  }

  static bool _isVSCodeWebview() {
    try {
      // Check for VS Code webview context
      return Uri.base.host.contains('vscode-webview') ||
          Uri.base.host == 'localhost' && Uri.base.port == 4000;
    } catch (e) {
      return false;
    }
  }

  // Firebase CLI Commands for VS Code
  static const Map<String, String> firebaseCLICommands = {
    'login': 'firebase login',
    'init': 'firebase init',
    'deploy_rules': 'firebase deploy --only firestore:rules',
    'deploy_functions': 'firebase deploy --only functions',
    'emulators_start': 'firebase emulators:start',
    'emulators_export': 'firebase emulators:export',
    'use_project': 'firebase use $projectId',
  };

  // VS Code Extension Settings
  static const Map<String, dynamic> vscodeExtensionConfig = {
    'firebase.projects': [projectId],
    'firebase.useEmulatorSuite': true,
    'firebase.emulatorAutoStart': false,
    'firebase.defaultProject': projectId,
    'firebase.deployRulesOnSave': false,
  };

  // Local Development URLs
  static Map<String, String> get localUrls {
    if (!kIsWeb) return {};

    final host = Uri.base.host;
    final port = Uri.base.port;

    return {
      'app': 'http://$host:$port',
      'firebase_ui': 'http://$host:4000',
      'firestore_emulator': 'http://$host:${emulatorPorts['firestore']}',
      'auth_emulator': 'http://$host:${emulatorPorts['auth']}',
    };
  }

  // Agent Commands for Firebase Console Access
  static const Map<String, String> agentCommands = {
    'open_console': 'code --command firebase.openConsole',
    'deploy_rules': 'code --command firebase.deployRules',
    'start_emulators': 'code --command firebase.startEmulators',
    'view_logs': 'code --command firebase.viewLogs',
  };

  // Firebase Admin SDK Configuration
  static const Map<String, dynamic> adminSDKConfig = {
    'credential_path': 'functions/serviceAccountKey.json',
    'database_url': 'https://$projectId-default-rtdb.firebaseio.com',
    'storage_bucket': '$projectId.appspot.com',
  };
}

// VS Code Firebase Extension Bridge
class VSCodeFirebaseBridge {
  static const String _extensionId = 'firebase.vscode-firebase-explorer';

  // Check if Firebase extension is installed in VS Code
  static Future<bool> isExtensionInstalled() async {
    if (!VSCodeFirebaseConfig.isVSCodeEnvironment) return false;

    try {
      // This would typically use JS interop in a real VS Code webview
      // For now, return true if in VS Code environment
      return VSCodeFirebaseConfig.isVSCodeEnvironment;
    } catch (e) {
      return false;
    }
  }

  // Execute VS Code command
  static Future<Map<String, dynamic>> executeCommand(
    String command, [
    List<dynamic>? args,
  ]) async {
    if (!VSCodeFirebaseConfig.isVSCodeEnvironment) {
      return {'success': false, 'error': 'Not in VS Code environment'};
    }

    try {
      // In a real implementation, this would use postMessage to VS Code
      if (kDebugMode) {
        print('Executing VS Code command: $command with args: $args');
      }

      return {
        'success': true,
        'command': command,
        'args': args,
        'timestamp': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      return {'success': false, 'error': e.toString()};
    }
  }

  // Send message to VS Code extension
  static Future<void> sendMessage(Map<String, dynamic> message) async {
    if (!VSCodeFirebaseConfig.isVSCodeEnvironment) return;

    try {
      // In a real implementation, this would use postMessage
      if (kDebugMode) {
        print('Sending message to VS Code: $message');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to send message to VS Code: $e');
      }
    }
  }
}
