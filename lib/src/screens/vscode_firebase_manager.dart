// lib/src/screens/vscode_firebase_manager.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/firebase_admin_service.dart';

class VSCodeFirebaseManager extends StatefulWidget {
  const VSCodeFirebaseManager({super.key});

  @override
  State<VSCodeFirebaseManager> createState() => _VSCodeFirebaseManagerState();
}

class _VSCodeFirebaseManagerState extends State<VSCodeFirebaseManager>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TextEditingController _rulesController;
  bool _isLoading = false;
  bool _isVSCodeAgent = false;
  String _deployStatus = '';
  Map<String, dynamic> _consoleData = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _rulesController = TextEditingController();
    _checkVSCodeAgent();
    _loadFirebaseConsoleData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _rulesController.dispose();
    super.dispose();
  }

  Future<void> _checkVSCodeAgent() async {
    final isAgent = await FirebaseAdminService.isVSCodeAgent();
    setState(() {
      _isVSCodeAgent = isAgent;
    });
  }

  Future<void> _loadFirebaseConsoleData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final data = await FirebaseAdminService.getFirebaseConsoleData();
      setState(() {
        _consoleData = data;
        _rulesController.text = data['rules'] ?? '';
      });
    } catch (e) {
      _showError('Failed to load Firebase Console data: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _syncWithVSCode() async {
    if (!_isVSCodeAgent) {
      _showError('VS Code Agent access required');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final success = await FirebaseAdminService.updateRulesFromVSCode(
        _rulesController.text,
        'vscode_sync',
      );

      if (success) {
        _showSuccess('Synced with VS Code successfully');
        _loadFirebaseConsoleData();
      } else {
        _showError('Failed to sync with VS Code');
      }
    } catch (e) {
      _showError('VS Code sync error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _deployToConsole() async {
    if (!_isVSCodeAgent) {
      _showError('VS Code Agent access required');
      return;
    }

    setState(() {
      _isLoading = true;
      _deployStatus = 'Preparing deployment...';
    });

    try {
      final result = await FirebaseAdminService.deployToFirebaseConsole(
        _rulesController.text,
      );

      if (result['success'] == true) {
        setState(() {
          _deployStatus = 'Ready for Firebase Console';
        });
        _showSuccess(result['message'] ?? 'Deployment prepared');

        // Auto-open Firebase Console
        final consoleUrl = result['consoleUrl'];
        if (consoleUrl != null) {
          _openFirebaseConsole(consoleUrl);
        }
      } else {
        setState(() {
          _deployStatus = 'Deployment failed';
        });
        _showError(result['message'] ?? 'Deployment failed');
      }
    } catch (e) {
      setState(() {
        _deployStatus = 'Deploy error';
      });
      _showError('Deployment error: $e');
    }

    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _openFirebaseConsole(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        // Copy URL to clipboard as fallback
        Clipboard.setData(ClipboardData(text: url));
        _showSuccess('Firebase Console URL copied to clipboard');
      }
    } catch (e) {
      Clipboard.setData(ClipboardData(text: url));
      _showSuccess('Firebase Console URL copied to clipboard');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.orange.shade100,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                Icons.cloud,
                color: Colors.orange.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Firebase Console Agent'),
          ],
        ),
        backgroundColor: Colors.orange.shade600,
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.security), text: 'Rules'),
            Tab(icon: Icon(Icons.link), text: 'Console'),
            Tab(icon: Icon(Icons.sync), text: 'VS Code'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _loadFirebaseConsoleData,
          ),
          if (_isVSCodeAgent)
            IconButton(
              icon: const Icon(Icons.sync),
              onPressed: _isLoading ? null : _syncWithVSCode,
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildRulesTab(),
          _buildConsoleTab(),
          _buildVSCodeTab(),
        ],
      ),
      floatingActionButton: _isVSCodeAgent
          ? FloatingActionButton.extended(
              onPressed: _isLoading ? null : _deployToConsole,
              icon: const Icon(Icons.cloud_upload),
              label: Text(
                  _deployStatus.isEmpty ? 'Deploy to Console' : _deployStatus),
              backgroundColor: Colors.orange.shade600,
            )
          : null,
    );
  }

  Widget _buildRulesTab() {
    return Column(
      children: [
        // VS Code Agent Status
        Container(
          padding: const EdgeInsets.all(16),
          color: _isVSCodeAgent ? Colors.green.shade50 : Colors.orange.shade50,
          child: Row(
            children: [
              Icon(
                _isVSCodeAgent ? Icons.check_circle : Icons.info,
                color: _isVSCodeAgent ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isVSCodeAgent
                      ? 'VS Code Agent Mode: Direct Firebase Console Access'
                      : 'Limited Access: View-only mode',
                  style: TextStyle(
                    color: _isVSCodeAgent
                        ? Colors.green.shade800
                        : Colors.orange.shade800,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
        ),

        // Firebase Console Info
        if (_consoleData.isNotEmpty)
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.info, color: Colors.blue.shade600),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Project: ${_consoleData['projectId'] ?? 'healthnest-ae7bb'}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade800,
                        ),
                      ),
                      if (_consoleData['lastSync'] != null)
                        Text(
                          'Last Sync: ${_consoleData['lastSync']}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Rules Editor
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: TextField(
              controller: _rulesController,
              readOnly: !_isVSCodeAgent,
              maxLines: null,
              expands: true,
              style: const TextStyle(
                fontFamily: 'monospace',
                fontSize: 11,
              ),
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
                hintText: _isVSCodeAgent
                    ? 'Edit Firebase Firestore rules (VS Code Agent Mode)...'
                    : 'Firebase rules (read-only)',
              ),
            ),
          ),
        ),

        // Action Buttons
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                        ClipboardData(text: _rulesController.text));
                    _showSuccess('Rules copied to clipboard');
                  },
                  icon: const Icon(Icons.copy),
                  label: const Text('Copy Rules'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              if (_isVSCodeAgent) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _syncWithVSCode,
                    icon: const Icon(Icons.sync),
                    label: const Text('Sync VS Code'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green.shade600,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConsoleTab() {
    final urls = FirebaseAdminService.getFirebaseConsoleUrls();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Firebase Console Direct Links',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ...urls.entries.map((entry) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: Icon(
                  _getIconForConsoleSection(entry.key),
                  color: Colors.orange.shade600,
                ),
                title: Text(entry.key.toUpperCase()),
                subtitle: Text(entry.value),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _openFirebaseConsole(entry.value),
              ),
            )),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => _openFirebaseConsole(urls['rules']!),
          icon: const Icon(Icons.security),
          label: const Text('Open Firestore Rules Console'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.orange.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildVSCodeTab() {
    return StreamBuilder<Map<String, dynamic>>(
      stream: FirebaseAdminService.vscodeRulesStream(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final data = snapshot.data ?? {};

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              color: Colors.green.shade50,
              child: ListTile(
                leading: const Icon(Icons.computer, color: Colors.green),
                title: const Text('VS Code Agent Status'),
                subtitle: Text(
                    _isVSCodeAgent ? 'Connected & Active' : 'Not Connected'),
                trailing: Icon(
                  _isVSCodeAgent ? Icons.check_circle : Icons.error,
                  color: _isVSCodeAgent ? Colors.green : Colors.red,
                ),
              ),
            ),
            if (data.isNotEmpty) ...[
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Real-time Sync Data',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text('Last Updated: ${data['lastUpdated'] ?? 'N/A'}'),
                      Text('Updated By: ${data['updatedBy'] ?? 'N/A'}'),
                      Text('Source: ${data['source'] ?? 'N/A'}'),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isVSCodeAgent
                  ? () {
                      // Force refresh VS Code sync
                      _syncWithVSCode();
                    }
                  : null,
              icon: const Icon(Icons.refresh),
              label: const Text('Force Sync with VS Code'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  IconData _getIconForConsoleSection(String section) {
    switch (section.toLowerCase()) {
      case 'rules':
        return Icons.security;
      case 'database':
        return Icons.storage;
      case 'auth':
        return Icons.person;
      case 'functions':
        return Icons.functions;
      case 'analytics':
        return Icons.analytics;
      case 'hosting':
        return Icons.web;
      default:
        return Icons.link;
    }
  }
}
