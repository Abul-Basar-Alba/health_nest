// lib/src/screens/women_health/women_health_dashboard.dart

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/women_health_provider.dart';
import 'widgets/insights_widget.dart';
import 'widgets/period_calendar_widget.dart';
import 'women_health_colors.dart';
import 'women_health_settings_screen.dart';

class WomenHealthDashboard extends StatefulWidget {
  const WomenHealthDashboard({super.key});

  @override
  State<WomenHealthDashboard> createState() => _WomenHealthDashboardState();
}

class _WomenHealthDashboardState extends State<WomenHealthDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeData();
  }

  Future<void> _initializeData() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final womenHealthProvider =
        Provider.of<WomenHealthProvider>(context, listen: false);

    if (authProvider.user != null && !_isInitialized) {
      await womenHealthProvider.initializeUserData(authProvider.user!.uid);
      setState(() => _isInitialized = true);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WomenHealthColors.background,
      body: Container(
        decoration: const BoxDecoration(
          gradient: WomenHealthColors.pinkGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildDashboardTab(),
                    _buildCalendarTab(),
                    _buildInsightsTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: WomenHealthColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back_ios_new,
                  color: WomenHealthColors.primaryPink,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Women\'s Health',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: WomenHealthColors.darkText,
                    ),
                  ),
                  Text(
                    'Track your cycle & wellness',
                    style: TextStyle(
                      fontSize: 14,
                      color: WomenHealthColors.lightText,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const WomenHealthSettingsScreen(),
                  ),
                );
              },
              icon: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: WomenHealthColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.settings_outlined,
                  color: WomenHealthColors.primaryPink,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return FadeInDown(
      delay: const Duration(milliseconds: 100),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: WomenHealthColors.shadowColor,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TabBar(
          controller: _tabController,
          indicator: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                WomenHealthColors.primaryPink,
                WomenHealthColors.primaryPurple,
              ],
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          labelColor: Colors.white,
          unselectedLabelColor: WomenHealthColors.mediumText,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Dashboard'),
            Tab(text: 'Calendar'),
            Tab(text: 'Insights'),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCycleStatusCard(),
          const SizedBox(height: 16),
          _buildPillTrackerCard(),
          const SizedBox(height: 16),
          _buildQuickActionsGrid(),
          const SizedBox(height: 16),
          _buildTodaySymptoms(),
        ],
      ),
    );
  }

  Widget _buildCycleStatusCard() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final womenHealthProvider = Provider.of<WomenHealthProvider>(context);
    final daysUntilPeriod = womenHealthProvider.daysUntilNextPeriod ?? 0;
    final avgCycleLength =
        womenHealthProvider.settings?.averageCycleLength ?? 28;

    return FadeInUp(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFFF85B3),
              Color(0xFFB565D8),
            ],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WomenHealthColors.primaryPink.withOpacity(0.3),
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
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Cycle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Cycle Length: $avgCycleLength days',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildCycleStat(
                    'Next Period',
                    daysUntilPeriod > 0
                        ? '$daysUntilPeriod days'
                        : 'Update cycle',
                    Icons.calendar_today,
                  ),
                  Container(
                    width: 1,
                    height: 40,
                    color: Colors.white30,
                  ),
                  _buildCycleStat(
                    'Fertile Window',
                    daysUntilPeriod > 14
                        ? '${daysUntilPeriod - 14} days'
                        : 'Soon',
                    Icons.spa_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (authProvider.user != null) {
                    await womenHealthProvider.startNewCycle(
                      authProvider.user!.uid,
                      DateTime.now(),
                    );
                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Period started!'),
                          backgroundColor: WomenHealthColors.primaryPink,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: WomenHealthColors.primaryPink,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Log Period Start',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleStat(String label, String value, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white70, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white70,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPillTrackerCard() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final womenHealthProvider = Provider.of<WomenHealthProvider>(context);
    final isPillEnabled = womenHealthProvider.isPillTrackingEnabled;

    return FadeInUp(
      delay: const Duration(milliseconds: 100),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WomenHealthColors.shadowColor,
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
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: WomenHealthColors.lightPink,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: WomenHealthColors.primaryPink,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Pill Tracking',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: WomenHealthColors.darkText,
                    ),
                  ),
                ),
                Switch(
                  value: isPillEnabled,
                  onChanged: (value) async {
                    if (authProvider.user != null) {
                      await womenHealthProvider.togglePillTracking(
                        authProvider.user!.uid,
                        value,
                      );
                    }
                  },
                  activeThumbColor: WomenHealthColors.primaryPink,
                ),
              ],
            ),
            if (isPillEnabled) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: WomenHealthColors.palePink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            WomenHealthColors.pillYellow,
                            WomenHealthColors.accentPeach,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.medication_outlined,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Today\'s Pill',
                            style: TextStyle(
                              fontSize: 14,
                              color: WomenHealthColors.mediumText,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('h:mm a').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: WomenHealthColors.darkText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (authProvider.user != null) {
                          // Create today's pill log
                          await womenHealthProvider.logPillTaken(
                            authProvider.user!.uid,
                            DateTime.now(),
                          );

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('✅ Pill marked as taken!'),
                                backgroundColor: Colors.green,
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: WomenHealthColors.primaryPink,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text('Take'),
                    ),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              Text(
                'Enable pill tracking to monitor your daily medication',
                style: TextStyle(
                  fontSize: 14,
                  color: WomenHealthColors.lightText,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActionsGrid() {
    final actions = [
      {
        'icon': Icons.edit_calendar,
        'label': 'Log Symptoms',
        'color': WomenHealthColors.symptomOrange,
      },
      {
        'icon': Icons.mood,
        'label': 'Track Mood',
        'color': WomenHealthColors.primaryPurple,
      },
      {
        'icon': Icons.water_drop,
        'label': 'Flow Level',
        'color': WomenHealthColors.periodRed,
      },
      {
        'icon': Icons.local_hospital,
        'label': 'Health Tips',
        'color': WomenHealthColors.mintGreen,
      },
    ];

    return FadeInUp(
      delay: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: WomenHealthColors.darkText,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
            ),
            itemCount: actions.length,
            itemBuilder: (context, index) {
              final action = actions[index];
              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: WomenHealthColors.shadowColor,
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      _handleQuickAction(action['label'] as String);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            action['icon'] as IconData,
                            color: action['color'] as Color,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            action['label'] as String,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: WomenHealthColors.darkText,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTodaySymptoms() {
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: WomenHealthColors.shadowColor,
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.favorite_border,
                  color: WomenHealthColors.primaryPink,
                  size: 20,
                ),
                SizedBox(width: 8),
                Text(
                  'How are you feeling today?',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: WomenHealthColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildSymptomChip('😊', 'Good'),
                _buildSymptomChip('😰', 'Anxious'),
                _buildSymptomChip('😴', 'Tired'),
                _buildSymptomChip('💪', 'Energetic'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomChip(String emoji, String label) {
    return InkWell(
      onTap: () => _handleMoodSelection(label),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: WomenHealthColors.palePink,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: WomenHealthColors.lightPink,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: WomenHealthColors.mediumText,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleQuickAction(String action) {
    switch (action) {
      case 'Log Symptoms':
        _showSymptomLogDialog();
        break;
      case 'Track Mood':
        _showMoodTrackingDialog();
        break;
      case 'Flow Level':
        _showFlowLevelDialog();
        break;
      case 'Health Tips':
        _showHealthTipsDialog();
        break;
    }
  }

  void _handleMoodSelection(String mood) async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final womenHealthProvider =
        Provider.of<WomenHealthProvider>(context, listen: false);

    if (authProvider.user != null) {
      await womenHealthProvider.saveSymptomLog(
        authProvider.user!.uid,
        DateTime.now(),
        mood: mood,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mood logged: $mood'),
            backgroundColor: WomenHealthColors.primaryPink,
          ),
        );
      }
    }
  }

  void _showSymptomLogDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Symptoms'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Common symptoms:'),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  'Cramps',
                  'Headache',
                  'Fatigue',
                  'Bloating',
                  'Mood Swings',
                  'Nausea',
                  'Backache',
                  'Acne',
                ]
                    .map((symptom) => ActionChip(
                          label: Text(symptom),
                          onPressed: () async {
                            final authProvider = Provider.of<AuthProvider>(
                                context,
                                listen: false);
                            final womenHealthProvider =
                                Provider.of<WomenHealthProvider>(context,
                                    listen: false);

                            if (authProvider.user != null) {
                              await womenHealthProvider.saveSymptomLog(
                                authProvider.user!.uid,
                                DateTime.now(),
                                symptoms: [symptom],
                              );

                              if (mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Symptom logged: $symptom'),
                                    backgroundColor:
                                        WomenHealthColors.primaryPink,
                                  ),
                                );
                              }
                            }
                          },
                          backgroundColor: WomenHealthColors.palePink,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showMoodTrackingDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Track Your Mood'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('How are you feeling today?'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                {'emoji': '😊', 'label': 'Happy'},
                {'emoji': '😰', 'label': 'Anxious'},
                {'emoji': '😴', 'label': 'Tired'},
                {'emoji': '💪', 'label': 'Energetic'},
                {'emoji': '😢', 'label': 'Sad'},
                {'emoji': '😠', 'label': 'Irritated'},
              ]
                  .map((mood) => InkWell(
                        onTap: () async {
                          final authProvider =
                              Provider.of<AuthProvider>(context, listen: false);
                          final womenHealthProvider =
                              Provider.of<WomenHealthProvider>(context,
                                  listen: false);

                          if (authProvider.user != null) {
                            await womenHealthProvider.saveSymptomLog(
                              authProvider.user!.uid,
                              DateTime.now(),
                              mood: mood['label']!,
                            );

                            if (mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content:
                                      Text('Mood logged: ${mood['label']}'),
                                  backgroundColor:
                                      WomenHealthColors.primaryPink,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: WomenHealthColors.palePink,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              Text(
                                mood['emoji']!,
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(height: 4),
                              Text(mood['label']!),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showFlowLevelDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Flow Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Select your flow level:'),
            const SizedBox(height: 16),
            ...List.generate(5, (index) {
              final level = index + 1;
              final labels = [
                'Spotting',
                'Light',
                'Medium',
                'Heavy',
                'Very Heavy'
              ];
              return ListTile(
                leading: Icon(
                  Icons.water_drop,
                  color: WomenHealthColors.periodRed.withOpacity(level / 5),
                ),
                title: Text('$level - ${labels[index]}'),
                onTap: () async {
                  final authProvider =
                      Provider.of<AuthProvider>(context, listen: false);
                  final womenHealthProvider =
                      Provider.of<WomenHealthProvider>(context, listen: false);

                  if (authProvider.user != null) {
                    await womenHealthProvider.saveSymptomLog(
                      authProvider.user!.uid,
                      DateTime.now(),
                      notes: 'Flow level: $level - ${labels[index]}',
                    );

                    if (mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Flow level logged: ${labels[index]}'),
                          backgroundColor: WomenHealthColors.primaryPink,
                        ),
                      );
                    }
                  }
                },
              );
            }),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showHealthTipsDialog() {
    final tips = [
      '💧 Stay hydrated - Drink 8-10 glasses of water daily',
      '🏃‍♀️ Light exercise can help reduce cramps',
      '😴 Get 7-8 hours of sleep for hormonal balance',
      '🥗 Eat iron-rich foods during period',
      '🧘‍♀️ Practice yoga or meditation for stress relief',
      '☕ Reduce caffeine to minimize bloating',
      '🌡️ Use heating pad for cramps relief',
      '📝 Track symptoms to understand your patterns',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Health Tips'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: tips
                .map((tip) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: WomenHealthColors.mintGreen,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              tip,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarTab() {
    final womenHealthProvider = Provider.of<WomenHealthProvider>(context);

    // Extract period dates from cycle entries
    List<DateTime> periodDays = [];
    for (var entry in womenHealthProvider.cycles) {
      // Add all days in the period
      final endDate =
          entry.endDate ?? entry.startDate.add(const Duration(days: 5));
      for (var i = 0; i <= endDate.difference(entry.startDate).inDays; i++) {
        periodDays.add(entry.startDate.add(Duration(days: i)));
      }
    }

    // Get fertile days from settings
    List<DateTime> fertileDays = [];
    DateTime? ovulationDay;
    if (womenHealthProvider.settings?.lastPeriodStart != null) {
      final lastPeriod = womenHealthProvider.settings!.lastPeriodStart!;
      // Ovulation typically 14 days before next period
      ovulationDay = lastPeriod.add(Duration(
        days: (womenHealthProvider.settings!.averageCycleLength - 14),
      ));
      // Fertile window: 5 days before and 1 day after ovulation
      for (var i = -5; i <= 1; i++) {
        fertileDays.add(ovulationDay.add(Duration(days: i)));
      }
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: PeriodCalendarWidget(
        periodDays: periodDays,
        fertileDays: fertileDays,
        ovulationDay: ovulationDay,
      ),
    );
  }

  Widget _buildInsightsTab() {
    final womenHealthProvider = Provider.of<WomenHealthProvider>(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: InsightsWidget(
        statistics: womenHealthProvider.statistics ?? {},
        symptomFrequency: womenHealthProvider.symptomFrequency ?? {},
        pillAdherenceData: womenHealthProvider.pillAdherence,
      ),
    );
  }
}
