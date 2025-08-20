import 'package:flutter/material.dart';
import 'package:health_nest/src/constants/app_colors.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: user.profileImageUrl != null
                  ? NetworkImage(user.profileImageUrl!)
                  : const AssetImage('assets/images/default_avatar.png')
                      as ImageProvider,
            ),
            const SizedBox(height: 16),
            Text(
              user.name,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            Text(
              user.isPremium ? 'Premium Member' : 'Standard Member',
              style: TextStyle(
                  color: user.isPremium ? AppColors.accent : Colors.grey),
            ),
            const SizedBox(height: 32),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildInfoRow(
                      'Email',
                      user.email,
                      Icons.email_rounded,
                    ),
                    _buildInfoRow(
                      'Height',
                      user.height != null ? '${user.height} cm' : 'N/A',
                      Icons.height_rounded,
                    ),
                    _buildInfoRow(
                      'Weight',
                      user.weight != null ? '${user.weight} kg' : 'N/A',
                      Icons.monitor_weight_rounded,
                    ),
                    _buildInfoRow(
                      'BMI',
                      user.bmi != null ? user.bmi!.toStringAsFixed(2) : 'N/A',
                      Icons.accessibility_new_rounded,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.lock_rounded, color: AppColors.primary),
              title: const Text('Privacy Settings'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // Navigate to privacy settings screen
              },
            ),
            const Divider(),
            ListTile(
              leading:
                  const Icon(Icons.settings_rounded, color: AppColors.primary),
              title: const Text('Account Settings'),
              trailing: const Icon(Icons.arrow_forward_ios_rounded),
              onTap: () {
                // Navigate to account settings screen
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout_rounded, color: AppColors.error),
              title: const Text('Log Out'),
              onTap: () async {
                await AuthService().signOut();
                if (context.mounted) {
                  userProvider.clearUser();
                  Navigator.pushNamedAndRemoveUntil(
                      context, '/', (route) => false);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary, size: 20),
          const SizedBox(width: 12),
          Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(value),
        ],
      ),
    );
  }
}
