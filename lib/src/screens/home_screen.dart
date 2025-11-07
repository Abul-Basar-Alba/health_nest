import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../providers/history_provider.dart';
import '../providers/pregnancy_provider.dart';
import '../providers/user_provider.dart';
import '../routes/app_routes.dart';
import '../screens/family_profiles_screen.dart';
import '../screens/health_diary_screen.dart';
import '../screens/medicine_reminder_screen.dart';
import '../screens/sleep_tracker_screen.dart';
import '../screens/water_reminder_screen.dart';
import '../services/freemium_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
    _fetchHistoryData();
    _loadPregnancyData();
  }

  void _fetchHistoryData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);
    if (userProvider.user != null) {
      historyProvider.fetchHistory(userProvider.user!.id);
    }
  }

  void _loadPregnancyData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pregnancyProvider =
        Provider.of<PregnancyProvider>(context, listen: false);

    if (authProvider.user != null &&
        pregnancyProvider.activePregnancy == null) {
      try {
        await pregnancyProvider.loadActivePregnancy(authProvider.user!.uid);
      } catch (e) {
        debugPrint('Failed to load pregnancy data: $e');
      }
    }
  }

  void _initAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic));

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.elasticOut),
    );
  }

  void _startAnimations() {
    Future.delayed(const Duration(milliseconds: 200), () {
      _fadeController.forward();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      _slideController.forward();
    });
    Future.delayed(const Duration(milliseconds: 600), () {
      _scaleController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    final historyProvider = Provider.of<HistoryProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFE),
      body: CustomScrollView(
        slivers: [
          // Modern App Bar
          _buildSliverAppBar(user),

          // Body Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Health Status Card
                  _buildHealthStatusCard(user, historyProvider),
                  const SizedBox(height: 24),

                  // Quick Actions
                  _buildQuickActions(),
                  const SizedBox(height: 24),

                  // Today's Progress
                  _buildTodaysProgress(),
                  const SizedBox(height: 24),

                  // Health Insights
                  _buildHealthInsights(),
                  const SizedBox(height: 24),

                  // Recent Activity
                  _buildRecentActivity(historyProvider),
                  const SizedBox(height: 100), // Bottom padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(user) {
    return SliverAppBar(
      expandedHeight: 120,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false, // Remove back button from home
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF667EEA),
                Color(0xFF764BA2),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _getGreeting(),
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                user.name.split(' ').first,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: CircleAvatar(
                            radius: 28,
                            backgroundImage: user.profileImageUrl != null
                                ? NetworkImage(user.profileImageUrl!)
                                : const AssetImage(
                                        'assets/images/default_avatar.png')
                                    as ImageProvider,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHealthStatusCard(user, historyProvider) {
    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF4CAF50),
                Color(0xFF45A049),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Health Status',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Looking great today!',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _buildHealthMetric(
                    'BMI',
                    user.bmi?.toStringAsFixed(1) ?? '--',
                    _getBMIStatus(user.bmi),
                  ),
                  const SizedBox(width: 20),
                  _buildHealthMetric(
                    'Steps',
                    '${historyProvider.todaySteps}',
                    'today',
                  ),
                  const SizedBox(width: 20),
                  _buildHealthMetric(
                    'Calories',
                    '${historyProvider.todayCalories.toInt()}',
                    'kcal',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthMetric(String label, String value, String subtitle) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(
              color: Colors.white60,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Actions',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF2D3436),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 120,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: 20), // Add horizontal padding
            children: [
              _buildActionCard(
                'BMI',
                Icons.calculate,
                const Color(0xFF6C5CE7),
                () => Navigator.pushNamed(
                    context, AppRoutes.premiumBMICalculator),
              ),
              _buildActionCard(
                'AI Health',
                Icons.psychology,
                const Color(0xFF00B894),
                () => Navigator.pushNamed(context, AppRoutes.recommendations),
              ),
              _buildActionCard(
                'Track',
                Icons.restaurant,
                const Color(0xFFE17055),
                () => Navigator.pushNamed(context, AppRoutes.nutrition),
              ),
              _buildActionCard(
                'Workout',
                Icons.fitness_center,
                const Color(0xFF0984E3),
                () => Navigator.pushNamed(context, AppRoutes.exercise),
              ),
              _buildActionCard(
                'Community',
                Icons.people,
                const Color(0xFFE84393),
                () => Navigator.pushNamed(context, AppRoutes.community),
              ),
              _buildActionCard(
                'Premium',
                Icons.star,
                const Color(0xFFFFD700),
                () => Navigator.pushNamed(context, AppRoutes.premiumServices),
              ),
              _buildActionCard(
                'Step Counter',
                Icons.directions_walk,
                const Color(0xFF00CED1),
                () => Navigator.pushNamed(context, AppRoutes.stepCounter),
              ),
              _buildActionCard(
                'Sleep',
                Icons.bedtime_rounded,
                const Color(0xFF7C4DFF),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SleepTrackerScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                'Water',
                Icons.water_drop,
                const Color(0xFF2196F3),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WaterReminderScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                'Medicine',
                Icons.medication,
                const Color(0xFF009688),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MedicineReminderScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                'Family',
                Icons.people,
                const Color(0xFFFF9800),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FamilyProfilesScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                'Health Diary',
                Icons.favorite,
                const Color(0xFFE91E63),
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HealthDiaryScreen(),
                  ),
                ),
              ),
              _buildActionCard(
                'Pregnancy',
                Icons.pregnant_woman,
                const Color(0xFFFFB6C1),
                () => Navigator.pushNamed(context, AppRoutes.pregnancyTracker),
              ),
              _buildActionCard(
                'History',
                Icons.history,
                const Color(0xFF8A2BE2),
                () => Navigator.pushNamed(context, AppRoutes.history),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
      String title, IconData icon, Color color, VoidCallback onTap) {
    return Container(
      width: 90, // Reduced width to prevent overflow
      margin: const EdgeInsets.only(right: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12), // Reduced padding
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10), // Reduced padding
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22, // Slightly smaller icon
                ),
              ),
              const SizedBox(height: 6), // Reduced spacing
              Text(
                title,
                textAlign: TextAlign.center,
                maxLines: 2, // Allow 2 lines for text
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 10, // Smaller font size
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2D3436),
                  height: 1.2, // Tighter line height
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysProgress() {
    return FutureBuilder<Map<String, int>>(
      future: FreemiumService.getTodayUsage(),
      builder: (context, snapshot) {
        final usage = snapshot.data ?? {};

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    "Today's Progress",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2D3436),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Active',
                      style: TextStyle(
                        color: Colors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildProgressItem(
                'BMI Calculations',
                usage['calculator'] ?? 0,
                20,
                Icons.calculate,
                Colors.purple,
              ),
              _buildProgressItem(
                'AI Chat Messages',
                usage['aiChat'] ?? 0,
                500,
                Icons.chat,
                Colors.blue,
              ),
              _buildProgressItem(
                'Nutrition Logs',
                usage['nutrition'] ?? 0,
                10,
                Icons.restaurant,
                Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressItem(
      String title, int used, int limit, IconData icon, Color color) {
    final progress = used / limit;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2D3436),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '$used/$limit',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation(color),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHealthInsights() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF74B9FF),
            Color(0xFF0984E3),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.lightbulb,
                color: Colors.white,
                size: 24,
              ),
              SizedBox(width: 8),
              Text(
                'Health Insight',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _getDailyHealthTip(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () =>
                Navigator.pushNamed(context, AppRoutes.recommendations),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0984E3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Get AI Advice',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivity(historyProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Recent Activity',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2D3436),
              ),
            ),
            const Spacer(),
            TextButton(
              onPressed: () => Navigator.pushNamed(context, AppRoutes.history),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildActivityItem(
                'Steps Today',
                '${historyProvider.todaySteps} steps logged',
                Icons.directions_walk,
                Colors.blue,
                'Today',
              ),
              _buildActivityItem(
                'Calories Tracked',
                '${historyProvider.todayCalories.toInt()} kcal',
                Icons.local_fire_department,
                Colors.orange,
                'Today',
              ),
              _buildActivityItem(
                'Health Check',
                'BMI calculated',
                Icons.favorite,
                Colors.red,
                'Yesterday',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
      String title, String subtitle, IconData icon, Color color, String time) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2D3436),
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  String _getBMIStatus(double? bmi) {
    if (bmi == null) return 'Calculate BMI';
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  String _getDailyHealthTip() {
    final tips = [
      "Drink at least 8 glasses of water today to stay hydrated! 💧",
      "Take a 10-minute walk after meals to aid digestion. 🚶‍♀️",
      "Include 5 servings of fruits and vegetables in your diet. 🥗",
      "Get 7-9 hours of quality sleep for optimal health. 😴",
      "Practice deep breathing for 5 minutes to reduce stress. 🧘‍♂️",
      "Stand up and stretch every hour if you sit for long periods. 🤸‍♀️",
    ];
    final index = DateTime.now().day % tips.length;
    return tips[index];
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }
}
