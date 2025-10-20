import 'package:flutter/material.dart';
import 'package:health_nest/src/constants/app_colors.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/routes/app_routes.dart';
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
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('My Profile'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black87,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFE8F5E9),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.green[100],
                backgroundImage: user.profileImageUrl != null
                    ? NetworkImage(user.profileImageUrl!)
                    : const AssetImage('assets/images/default_avatar.png')
                        as ImageProvider,
              ),
              const SizedBox(height: 16),
              Text(
                user.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold, color: Colors.green[800]),
              ),
              Text(
                user.isPremium ? 'Premium Member' : 'Standard Member',
                style: TextStyle(
                    color: user.isPremium ? AppColors.accent : Colors.grey,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      _buildInfoRow(
                        'Email',
                        user.email,
                        Icons.email_rounded,
                        context,
                      ),
                      _buildInfoRow(
                        'Height',
                        user.height != null ? '${user.height} cm' : 'N/A',
                        Icons.height_rounded,
                        context,
                      ),
                      _buildInfoRow(
                        'Weight',
                        user.weight != null ? '${user.weight} kg' : 'N/A',
                        Icons.monitor_weight_rounded,
                        context,
                      ),
                      _buildInfoRow(
                        'BMI',
                        user.bmi != null ? user.bmi!.toStringAsFixed(2) : 'N/A',
                        Icons.accessibility_new_rounded,
                        context,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18)),
                child: Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.lock_rounded,
                          color: AppColors.primary),
                      title: const Text('Privacy Settings'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        // Navigate to privacy settings screen
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.settings_rounded,
                          color: AppColors.primary),
                      title: const Text('Account Settings'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        // Navigate to account settings screen
                      },
                    ),
                    const Divider(height: 1, indent: 16, endIndent: 16),
                    ListTile(
                      leading: const Icon(Icons.logout_rounded,
                          color: AppColors.error),
                      title: const Text('Log Out'),
                      onTap: () async {
                        // 1. Sign out from Firebase & Google
                        await AuthService().signOut();

                        // 2. Clear UserProvider
                        userProvider.clearUser();

                        // 3. Navigate to login page and remove all previous routes
                        if (context.mounted) {
                          Navigator.pushNamedAndRemoveUntil(
                              context, AppRoutes.login, (route) => false);
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(
      String label, String value, IconData icon, BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green[600], size: 24),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const Spacer(),
          Text(value, style: Theme.of(context).textTheme.bodyLarge),
        ],
      ),
    );
  }
}
