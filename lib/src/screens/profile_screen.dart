import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/routes/app_routes.dart';
import 'package:health_nest/src/services/enhanced_auth_service.dart';
import 'package:provider/provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _weeklySteps = 0;
  int _weeklyWorkouts = 0;
  int _caloriesBurned = 0;
  bool _isLoading = true;
  double targetWeight = 65.0; // Default target weight
  int dailyStepsGoal = 10000; // Default daily steps goal
  int weeklyWorkoutsGoal = 5; // Default weekly workouts goal

  @override
  void initState() {
    super.initState();
    _loadWeeklyStats();
    _loadHealthGoals();
  }

  Future<void> _loadHealthGoals() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;

      if (userId == null) return;

      final goalsDoc = await FirebaseFirestore.instance
          .collection('health_goals')
          .doc(userId)
          .get();

      if (goalsDoc.exists && mounted) {
        setState(() {
          targetWeight = (goalsDoc.data()?['targetWeight'] ?? 65.0).toDouble();
          dailyStepsGoal = (goalsDoc.data()?['dailySteps'] ?? 10000);
          weeklyWorkoutsGoal = (goalsDoc.data()?['weeklyWorkouts'] ?? 5);
        });
      }
    } catch (e) {
      debugPrint('Error loading health goals: $e');
    }
  }

  Future<void> _loadWeeklyStats() async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id;

      if (userId == null) return;

      // Get stats from last 7 days
      final weekAgo = DateTime.now().subtract(const Duration(days: 7));

      // Load activity history
      final activityDocs = await FirebaseFirestore.instance
          .collection('activity_history')
          .where('userId', isEqualTo: userId)
          .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(weekAgo))
          .get();

      int steps = 0;
      int workouts = activityDocs.docs.length;
      int calories = 0;

      for (var doc in activityDocs.docs) {
        final data = doc.data();
        calories += (data['caloriesBurned'] as num?)?.toInt() ?? 0;
      }

      setState(() {
        _weeklySteps = steps;
        _weeklyWorkouts = workouts;
        _caloriesBurned = calories;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;

    if (user == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF1F8F4), // Soft mint
              Color(0xFFE8F5E9), // Light green
              Color(0xFFF3E5F5), // Light lavender
            ],
          ),
        ),
        child: RefreshIndicator(
          onRefresh: _loadWeeklyStats,
          color: const Color(0xFF43A047),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(isMobile ? 16.0 : 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Profile Header with Avatar
                _buildProfileHeader(user, context),
                const SizedBox(height: 24),

                // Weekly Stats Card (MyFitnessPal inspired)
                if (!_isLoading) _buildWeeklyStatsCard(isMobile),
                if (!_isLoading) const SizedBox(height: 16),

                // User Info Card with Flexible Email
                _buildUserInfoCard(user, context, isMobile),
                const SizedBox(height: 16),

                // Health Goals Card (HealthifyMe inspired)
                _buildHealthGoalsCard(user, isMobile),
                const SizedBox(height: 16),

                // Settings & Actions Card
                _buildSettingsCard(context, userProvider),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader(dynamic user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: Colors.green[100],
                  backgroundImage: user.profileImageUrl != null
                      ? NetworkImage(
                          '${user.profileImageUrl!}?t=${DateTime.now().millisecondsSinceEpoch}',
                        )
                      : const AssetImage('assets/images/default_avatar.png')
                          as ImageProvider,
                ),
              ),
              if (user.isPremium)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFD700),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.workspace_premium,
                        size: 16, color: Colors.white),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            user.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: user.isPremium
                  ? const Color(0xFFFFD700)
                  : Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              user.isPremium ? '👑 Premium Member' : 'Standard Member',
              style: TextStyle(
                color: user.isPremium ? Colors.black87 : Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsCard(bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.blue[50]!, Colors.purple[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.trending_up, color: Colors.blue[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'This Week\'s Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatItem(
                  icon: Icons.directions_walk,
                  label: 'Steps',
                  value: _weeklySteps.toString(),
                  color: Colors.orange,
                ),
                _buildStatItem(
                  icon: Icons.fitness_center,
                  label: 'Workouts',
                  value: _weeklyWorkouts.toString(),
                  color: Colors.green,
                ),
                _buildStatItem(
                  icon: Icons.local_fire_department,
                  label: 'Calories',
                  value: _caloriesBurned.toString(),
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 28),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildUserInfoCard(dynamic user, BuildContext context, bool isMobile) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.person, color: Colors.green[700], size: 24),
                const SizedBox(width: 8),
                const Text(
                  'Personal Information',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E7D32),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFlexibleInfoRow(
              'Email',
              user.email,
              Icons.email_rounded,
              context,
            ),
            const Divider(height: 24),
            _buildFlexibleInfoRow(
              'Height',
              user.height != null ? '${user.height} cm' : 'Not set',
              Icons.height_rounded,
              context,
            ),
            const Divider(height: 24),
            _buildFlexibleInfoRow(
              'Weight',
              user.weight != null ? '${user.weight} kg' : 'Not set',
              Icons.monitor_weight_rounded,
              context,
            ),
            const Divider(height: 24),
            _buildFlexibleInfoRow(
              'BMI',
              user.bmi != null ? user.bmi!.toStringAsFixed(2) : 'Calculate',
              Icons.accessibility_new_rounded,
              context,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlexibleInfoRow(
      String label, String value, IconData icon, BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.green[700], size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHealthGoalsCard(dynamic user, bool isMobile) {
    // Use saved goal state variables so updating goals updates UI immediately
    final goalWeight = targetWeight; // state variable (goal)
    final currentWeight = user.weight;
    // Compute a simple progress ratio: how close current weight is to goal.
    // If no current weight, show 0.0. If currentWeight >= goalWeight treat as complete.
    final progress = (currentWeight != null && goalWeight > 0)
        ? (currentWeight / goalWeight).clamp(0.0, 1.0)
        : 0.0;
    // Daily steps progress uses available weekly steps as an approximation
    final dailyProgress = (dailyStepsGoal > 0)
        ? (_weeklySteps / dailyStepsGoal.toDouble()).clamp(0.0, 1.0)
        : 0.0;
    final weeklyProgress = (weeklyWorkoutsGoal > 0)
        ? (_weeklyWorkouts / weeklyWorkoutsGoal.toDouble()).clamp(0.0, 1.0)
        : 0.0;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.all(isMobile ? 16 : 20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [Colors.green[50]!, Colors.teal[50]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(Icons.flag, color: Colors.green[700], size: 24),
                    const SizedBox(width: 8),
                    const Text(
                      'Health Goals',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                  ],
                ),
                TextButton.icon(
                  onPressed: () {
                    _showEditHealthGoalsDialog();
                  },
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text('Edit'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.green[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildGoalProgress(
              'Target Weight',
              '${goalWeight.toStringAsFixed(1)} kg',
              progress,
              Colors.blue,
            ),
            const SizedBox(height: 12),
            _buildGoalProgress(
              'Daily Steps',
              '${dailyStepsGoal.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} steps',
              dailyProgress,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildGoalProgress(
              'Weekly Workouts',
              '$weeklyWorkoutsGoal sessions',
              weeklyProgress,
              Colors.purple,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalProgress(
      String label, String target, double progress, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              target,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 8,
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsCard(BuildContext context, UserProvider userProvider) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          _buildSettingsTile(
            icon: Icons.edit_rounded,
            title: 'Edit Profile',
            subtitle: 'Update your personal information',
            color: Colors.blue,
            onTap: () {
              Navigator.pushNamed(context, '/edit-profile');
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.lock_outline,
            title: 'Privacy Settings',
            subtitle: 'Control your data and visibility',
            color: Colors.purple,
            onTap: () {
              Navigator.pushNamed(context, '/privacy-settings');
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.settings_outlined,
            title: 'Account Settings',
            subtitle: 'Manage your account preferences',
            color: Colors.orange,
            onTap: () {
              Navigator.pushNamed(context, '/account-settings');
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.lock_reset_rounded,
            title: 'Change Password',
            subtitle: 'Update your security credentials',
            color: Colors.teal,
            onTap: () {
              Navigator.pushNamed(context, '/change-password');
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.help_outline,
            title: 'Help & Support',
            subtitle: 'Get assistance and FAQs',
            color: Colors.indigo,
            onTap: () {
              Navigator.pushNamed(context, '/help-support');
            },
          ),
          _buildDivider(),
          _buildSettingsTile(
            icon: Icons.logout_rounded,
            title: 'Log Out',
            subtitle: 'Sign out from your account',
            color: Colors.red,
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Confirm Logout'),
                  content: const Text('Are you sure you want to log out?'),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Log Out'),
                    ),
                  ],
                ),
              );

              if (confirm == true && context.mounted) {
                await EnhancedAuthService().signOut();
                userProvider.clearUser();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                      context, AppRoutes.login, (route) => false);
                }
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      leading: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: color, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey[600],
        ),
      ),
      trailing:
          Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
      onTap: onTap,
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 20,
      endIndent: 20,
      color: Colors.grey[200],
    );
  }

  // Health Goals Edit Dialog
  Future<void> _showEditHealthGoalsDialog() async {
    final targetWeightController = TextEditingController(
      text: targetWeight.toStringAsFixed(1),
    );
    final dailyStepsController =
        TextEditingController(text: dailyStepsGoal.toString());
    final weeklyWorkoutsController =
        TextEditingController(text: weeklyWorkoutsGoal.toString());

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.flag, color: Colors.green[700]),
            const SizedBox(width: 8),
            const Text(
              'Edit Health Goals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: targetWeightController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Weight (kg)',
                  prefixIcon:
                      Icon(Icons.monitor_weight, color: Colors.blue[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.blue[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: dailyStepsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Daily Steps Goal',
                  prefixIcon:
                      Icon(Icons.directions_walk, color: Colors.orange[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.orange[50],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: weeklyWorkoutsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Weekly Workouts Goal',
                  prefixIcon:
                      Icon(Icons.fitness_center, color: Colors.purple[700]),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.purple[50],
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey[600])),
          ),
          ElevatedButton(
            onPressed: () async {
              // Save to Firestore
              final user =
                  Provider.of<UserProvider>(context, listen: false).user;
              if (user != null) {
                final newTargetWeight =
                    double.tryParse(targetWeightController.text) ??
                        targetWeight;
                final dailySteps =
                    int.tryParse(dailyStepsController.text) ?? 10000;
                final weeklyWorkouts =
                    int.tryParse(weeklyWorkoutsController.text) ?? 5;

                await FirebaseFirestore.instance
                    .collection('health_goals')
                    .doc(user.id)
                    .set({
                  'userId': user.id,
                  'targetWeight': newTargetWeight,
                  'dailySteps': dailySteps,
                  'weeklyWorkouts': weeklyWorkouts,
                  'updatedAt': FieldValue.serverTimestamp(),
                }, SetOptions(merge: true));

                if (mounted) {
                  setState(() {
                    targetWeight = newTargetWeight;
                    dailyStepsGoal = dailySteps;
                    weeklyWorkoutsGoal = weeklyWorkouts;
                  });
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Health goals updated successfully!'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green[700],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save Goals'),
          ),
        ],
      ),
    );
  }
}
