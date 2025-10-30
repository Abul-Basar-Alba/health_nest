import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:provider/provider.dart';

class AccountSettingsScreen extends StatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  State<AccountSettingsScreen> createState() => _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends State<AccountSettingsScreen> {
  String _language = 'English';
  String _theme = 'Auto';
  String _units = 'Metric';
  bool _autoSync = true;
  bool _offlineMode = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAccountSettings();
  }

  Future<void> _loadAccountSettings() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;

      if (userId == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userId)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _language = data['language'] ?? 'English';
          _theme = data['theme'] ?? 'Auto';
          _units = data['units'] ?? 'Metric';
          _autoSync = data['autoSync'] ?? true;
          _offlineMode = data['offlineMode'] ?? false;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;

      if (userId == null) return;

      await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userId)
          .set({
        'language': _language,
        'theme': _theme,
        'units': _units,
        'autoSync': _autoSync,
        'offlineMode': _offlineMode,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Account settings saved successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving settings: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Account Settings',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: const Color(0xFFFF9800),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              const Color(0xFFFF9800).withOpacity(0.1),
              Colors.white,
            ],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSectionCard(
              title: 'General',
              icon: Icons.settings_outlined,
              color: Colors.orange,
              children: [
                _buildDropdownTile(
                  title: 'Language',
                  subtitle: 'Select your preferred language',
                  value: _language,
                  items: ['English', 'Bangla', 'Hindi', 'Spanish'],
                  onChanged: (value) {
                    setState(() => _language = value!);
                    _saveSettings();
                  },
                ),
                const Divider(),
                _buildDropdownTile(
                  title: 'Theme',
                  subtitle: 'Choose app appearance',
                  value: _theme,
                  items: ['Auto', 'Light', 'Dark'],
                  onChanged: (value) {
                    setState(() => _theme = value!);
                    _saveSettings();
                  },
                ),
                const Divider(),
                _buildDropdownTile(
                  title: 'Units',
                  subtitle: 'Measurement system',
                  value: _units,
                  items: ['Metric', 'Imperial'],
                  onChanged: (value) {
                    setState(() => _units = value!);
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Sync & Storage',
              icon: Icons.cloud_outlined,
              color: Colors.blue,
              children: [
                _buildSwitchTile(
                  title: 'Auto Sync',
                  subtitle: 'Automatically sync data with cloud',
                  value: _autoSync,
                  onChanged: (value) {
                    setState(() => _autoSync = value);
                    _saveSettings();
                  },
                ),
                _buildSwitchTile(
                  title: 'Offline Mode',
                  subtitle: 'Work without internet connection',
                  value: _offlineMode,
                  onChanged: (value) {
                    setState(() => _offlineMode = value);
                    _saveSettings();
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildSectionCard(
              title: 'Subscription',
              icon: Icons.workspace_premium,
              color: Colors.purple,
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Manage Subscription',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    'View and manage your premium membership',
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.pushNamed(context, '/premium');
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildActionCard(
              title: 'Clear Cache',
              subtitle: 'Free up storage space',
              icon: Icons.cleaning_services_outlined,
              color: Colors.teal,
              onTap: () {
                _showClearCacheDialog();
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              title: 'Export Data',
              subtitle: 'Download all your health data',
              icon: Icons.file_download_outlined,
              color: Colors.indigo,
              onTap: () async {
                _exportUserData();
              },
            ),
            const SizedBox(height: 12),
            _buildActionCard(
              title: 'Connected Devices',
              subtitle: 'Manage fitness trackers & smartwatches',
              icon: Icons.watch_outlined,
              color: Colors.green,
              onTap: () {
                // Navigate to connected devices screen
              },
            ),
            const SizedBox(height: 24),
            _buildInfoCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items.map((item) {
          return DropdownMenuItem(
            value: item,
            child: Text(item),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      value: value,
      onChanged: onChanged,
      activeThumbColor: Colors.green,
    );
  }

  Widget _buildActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: color),
        onTap: onTap,
      ),
    );
  }

  Widget _buildInfoCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      color: Colors.blue[50],
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[700]),
                const SizedBox(width: 8),
                Text(
                  'App Information',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Version', '1.0.0'),
            _buildInfoRow('Build', '100'),
            _buildInfoRow('Last Updated', 'Oct 30, 2025'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Colors.grey[700]),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Future<void> _exportUserData() async {
    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Collecting your data...'),
            ],
          ),
          duration: Duration(seconds: 3),
        ),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;

      if (userId == null) return;

      // Collect all user data
      final userData = <String, dynamic>{};

      // User profile
      userData['profile'] = {
        'id': userProvider.user?.id,
        'name': userProvider.user?.name,
        'email': userProvider.user?.email,
        'height': userProvider.user?.height,
        'weight': userProvider.user?.weight,
        'bmi': userProvider.user?.bmi,
        'isPremium': userProvider.user?.isPremium,
      };

      // Settings
      final settingsDoc = await FirebaseFirestore.instance
          .collection('user_settings')
          .doc(userId)
          .get();
      userData['settings'] = settingsDoc.data();

      // Activity history
      final activityDocs = await FirebaseFirestore.instance
          .collection('activity_history')
          .where('userId', isEqualTo: userId)
          .get();
      userData['activity_history'] =
          activityDocs.docs.map((d) => d.data()).toList();

      // BMI history
      final bmiDocs = await FirebaseFirestore.instance
          .collection('bmi_history')
          .where('userId', isEqualTo: userId)
          .get();
      userData['bmi_history'] = bmiDocs.docs.map((d) => d.data()).toList();

      // Nutrition history
      final nutritionDocs = await FirebaseFirestore.instance
          .collection('nutrition_history')
          .where('userId', isEqualTo: userId)
          .get();
      userData['nutrition_history'] =
          nutritionDocs.docs.map((d) => d.data()).toList();

      userData['exported_at'] = DateTime.now().toIso8601String();
      userData['app_version'] = '1.0.0';

      if (mounted) {
        // Show success with data summary
        final totalRecords = (userData['activity_history'] as List).length +
            (userData['bmi_history'] as List).length +
            (userData['nutrition_history'] as List).length;

        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.green[600]),
                const SizedBox(width: 8),
                const Text('Data Ready!'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Your data has been collected:'),
                const SizedBox(height: 12),
                Text('📊 Total Records: $totalRecords'),
                Text(
                    '🏃 Activities: ${(userData['activity_history'] as List).length}'),
                Text(
                    '⚖️ BMI Entries: ${(userData['bmi_history'] as List).length}'),
                Text(
                    '🍎 Nutrition Logs: ${(userData['nutrition_history'] as List).length}'),
                const SizedBox(height: 12),
                Text(
                  'Data is ready to be shared or saved.',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  // In future, implement actual file save/share
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '💾 Data export feature coming soon! Your data is safe.'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                },
                icon: const Icon(Icons.share),
                label: const Text('Share'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error exporting data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Cache'),
        content: const Text(
          'This will clear all temporary data and free up storage space. Your personal data will not be affected.',
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              // Show loading
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Row(
                    children: [
                      SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      ),
                      SizedBox(width: 16),
                      Text('Clearing cache...'),
                    ],
                  ),
                  duration: Duration(seconds: 2),
                ),
              );

              // Actual cache clearing
              try {
                // Clear image cache
                imageCache.clear();
                imageCache.clearLiveImages();

                // Wait a bit for visual feedback
                await Future.delayed(const Duration(seconds: 1));

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          '✅ Cache cleared successfully! Free space recovered.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 3),
                    ),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Error clearing cache: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}
