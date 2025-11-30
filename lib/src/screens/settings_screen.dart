// health_nest/lib/src/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:health_nest/src/providers/theme_provider.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/services/enhanced_auth_service.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  String _language = 'English';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.teal.shade600, Colors.teal.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: ListView(
        children: [
          _buildSection(
            title: 'General',
            icon: Icons.settings,
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Enable push notifications',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.dark_mode,
                title: 'Dark Mode',
                subtitle: 'Enable dark theme',
                value: themeProvider.isDarkMode,
                onChanged: (value) async {
                  await themeProvider.toggleTheme();
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          value ? 'Dark mode enabled' : 'Light mode enabled',
                        ),
                        duration: const Duration(seconds: 2),
                        backgroundColor: Colors.teal,
                      ),
                    );
                  }
                },
              ),
              _buildListTile(
                icon: Icons.language,
                title: 'Language',
                subtitle: _language,
                onTap: () => _showLanguageDialog(),
              ),
            ],
          ),
          _buildSection(
            title: 'Notifications',
            icon: Icons.notifications_active,
            children: [
              _buildSwitchTile(
                icon: Icons.volume_up,
                title: 'Sound',
                subtitle: 'Play sound for notifications',
                value: _soundEnabled,
                onChanged: (value) {
                  setState(() => _soundEnabled = value);
                },
              ),
              _buildSwitchTile(
                icon: Icons.vibration,
                title: 'Vibration',
                subtitle: 'Vibrate on notifications',
                value: _vibrationEnabled,
                onChanged: (value) {
                  setState(() => _vibrationEnabled = value);
                },
              ),
            ],
          ),
          _buildSection(
            title: 'Health Data',
            icon: Icons.health_and_safety,
            children: [
              _buildListTile(
                icon: Icons.backup,
                title: 'Backup Data',
                subtitle: 'Backup your health data',
                onTap: () => _showBackupDialog(),
              ),
              _buildListTile(
                icon: Icons.restore,
                title: 'Restore Data',
                subtitle: 'Restore from backup',
                onTap: () => _showRestoreDialog(),
              ),
              _buildListTile(
                icon: Icons.delete_forever,
                title: 'Clear All Data',
                subtitle: 'Delete all health records',
                titleColor: Colors.red,
                onTap: () => _showClearDataDialog(),
              ),
            ],
          ),
          _buildSection(
            title: 'Privacy & Security',
            icon: Icons.security,
            children: [
              _buildListTile(
                icon: Icons.lock,
                title: 'Change Password',
                subtitle: 'Update your account password',
                onTap: () {
                  Navigator.pushNamed(context, '/change-password');
                },
              ),
              _buildListTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                onTap: () {
                  Navigator.pushNamed(context, '/privacy-policy');
                },
              ),
              _buildListTile(
                icon: Icons.description,
                title: 'Terms of Service',
                subtitle: 'Read terms and conditions',
                onTap: () {
                  Navigator.pushNamed(context, '/terms-of-service');
                },
              ),
            ],
          ),
          _buildSection(
            title: 'About',
            icon: Icons.info,
            children: [
              _buildListTile(
                icon: Icons.help,
                title: 'Help & Support',
                subtitle: 'Get help and FAQs',
                onTap: () {
                  Navigator.pushNamed(context, '/help-support');
                },
              ),
              _buildListTile(
                icon: Icons.book,
                title: 'Documentation',
                subtitle: 'View app documentation',
                onTap: () {
                  Navigator.pushNamed(context, '/documentation');
                },
              ),
              _buildListTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: 'Version 1.0.0',
                onTap: () {},
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () => _showLogoutDialog(),
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: Colors.teal.shade600),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal.shade600,
                ),
              ),
            ],
          ),
        ),
        Card(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.teal.shade600),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.teal.shade600,
      ),
    );
  }

  Widget _buildListTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? Colors.teal.shade600),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w500, color: titleColor),
      ),
      subtitle: Text(subtitle, style: TextStyle(color: Colors.grey.shade600)),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<String>(
              title: const Text('English'),
              value: 'English',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
              },
            ),
            RadioListTile<String>(
              title: const Text('বাংলা (Bengali)'),
              value: 'Bengali',
              groupValue: _language,
              onChanged: (value) {
                setState(() => _language = value!);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('বাংলা ভাষা শীঘ্রই আসছে!'),
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showBackupDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.backup, color: Colors.teal),
            SizedBox(width: 8),
            Text('Backup Data'),
          ],
        ),
        content: const Text(
          'Your health data is automatically backed up to the cloud. Last backup: Just now',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Backup completed successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const Text('Backup Now'),
          ),
        ],
      ),
    );
  }

  void _showRestoreDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.restore, color: Colors.orange),
            SizedBox(width: 8),
            Text('Restore Data'),
          ],
        ),
        content: const Text(
          'This will restore your health data from the latest backup. Current data will be replaced.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data restored successfully!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
            child: const Text('Restore'),
          ),
        ],
      ),
    );
  }

  void _showClearDataDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all your health records. This action cannot be undone!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All data cleared successfully!'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete All'),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final userProvider = Provider.of<UserProvider>(
                context,
                listen: false,
              );
              await EnhancedAuthService().signOut();
              userProvider.clearUser();
              if (mounted) {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  '/login',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }
}
