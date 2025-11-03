// lib/src/screens/step_counter_dashboard_screen.dart

import 'dart:ui' show ImageFilter;

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/step_provider.dart';
import '../services/history_service.dart';

class StepCounterDashboardScreen extends StatefulWidget {
  const StepCounterDashboardScreen({super.key});

  @override
  State<StepCounterDashboardScreen> createState() =>
      _StepCounterDashboardScreenState();
}

class _StepCounterDashboardScreenState extends State<StepCounterDashboardScreen>
    with TickerProviderStateMixin {
  final HistoryService _historyService = HistoryService();
  bool _isSaving = false;
  List<DailySteps> _weeklySteps = [];
  int _dailyGoal = 10000;
  int _selectedDayIndex = 6; // Today by default
  // Step Counter is now FREE for all users - no premium required
  final bool _isPremium = true; // Always true - Step Counter is free
  late AnimationController _progressController;
  late AnimationController _pulseController;
  late Animation<double> _progressAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadWeeklySteps();
    _loadDailyGoal();
    // Step Counter is FREE - no need to check premium status
    _initializeAnimations();
    _requestStepPermission();
  }

  void _initializeAnimations() {
    _progressController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _progressAnimation = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _progressController.forward();
  }

  Future<void> _requestStepPermission() async {
    if (kIsWeb) return;

    try {
      final stepProvider = Provider.of<StepProvider>(context, listen: false);
      await stepProvider.requestPermissions();
    } catch (e) {
      print('Permission error: $e');
    }
  }

  Future<void> _loadDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = prefs.getInt('daily_step_goal') ?? 10000;
    });
  }

  Future<void> _saveDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('daily_step_goal', goal);
    setState(() {
      _dailyGoal = goal;
    });
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _loadWeeklySteps() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    try {
      final now = DateTime.now();
      final List<DailySteps> steps = [];

      for (int i = 6; i >= 0; i--) {
        final date = now.subtract(Duration(days: i));
        final startOfDay = DateTime(date.year, date.month, date.day);
        final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

        final activities = await _historyService.getActivityHistoryByDateRange(
          userId,
          startOfDay,
          endOfDay,
        );

        int totalSteps = 0;
        for (var activity in activities) {
          if (activity.steps != null) {
            totalSteps += activity.steps!;
          }
        }

        steps.add(DailySteps(
          date: date,
          steps: totalSteps,
          dayName: DateFormat('E').format(date), // Mon, Tue, etc.
        ));
      }

      setState(() {
        _weeklySteps = steps;
      });
    } catch (e) {
      print('Error loading weekly steps: $e');
    }
  }

  Future<void> _saveStepsToHistory() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Step counter only works on mobile devices!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first!')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final stepProvider = Provider.of<StepProvider>(context, listen: false);
      final stepsToSave = stepProvider.steps;

      await _historyService.saveActivityHistory(
        userId: userId,
        activityLevel: 'Moderate',
        exerciseType: 'Daily Steps',
        durationMinutes: 0,
        caloriesBurned: (stepsToSave * 0.04).toInt(),
        steps: stepsToSave,
        notes:
            'Daily step count for ${DateFormat('MMM dd, yyyy').format(DateTime.now())}',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('✅ $stepsToSave steps saved successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }

      await _loadWeeklySteps();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving steps: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  void _showGoalSettingDialog() {
    int tempGoal = _dailyGoal;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.flag, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              const Text('Set Daily Goal'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose your daily step target',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade50, Colors.purple.shade50],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    Text(
                      NumberFormat('#,###').format(tempGoal),
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    const Text('steps per day'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildGoalPreset('5K', 5000, tempGoal, setDialogState,
                      (goal) => tempGoal = goal),
                  _buildGoalPreset('8K', 8000, tempGoal, setDialogState,
                      (goal) => tempGoal = goal),
                  _buildGoalPreset('10K', 10000, tempGoal, setDialogState,
                      (goal) => tempGoal = goal),
                  _buildGoalPreset('15K', 15000, tempGoal, setDialogState,
                      (goal) => tempGoal = goal),
                ],
              ),
              const SizedBox(height: 16),
              Slider(
                value: tempGoal.toDouble(),
                min: 1000,
                max: 20000,
                divisions: 19,
                activeColor: Colors.blue,
                label: '${NumberFormat('#,###').format(tempGoal)} steps',
                onChanged: (value) {
                  setDialogState(() {
                    tempGoal = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _saveDailyGoal(tempGoal);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'Goal set to ${NumberFormat('#,###').format(tempGoal)} steps!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Save Goal'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoalPreset(String label, int goal, int currentGoal,
      StateSetter setDialogState, Function(int) onTap) {
    final isSelected = currentGoal == goal;
    return GestureDetector(
      onTap: () {
        setDialogState(() {
          onTap(goal);
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.transparent,
            width: 2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.blue.shade400, Colors.purple.shade300],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: FadeInUp(
                child: Card(
                  margin: const EdgeInsets.all(32),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(40),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.orange.shade100,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(Icons.smartphone,
                              size: 64, color: Colors.orange.shade700),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          '📱 Mobile Device Required',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Step Counter uses your device\'s built-in pedometer sensor.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Please open this app on your Android or iOS device.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                        const SizedBox(height: 32),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back),
                          label: const Text('Go Back'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 16),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade600,
              Colors.purple.shade400,
              Colors.pink.shade300,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildPremiumAppBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildTodayCard(),
                      const SizedBox(height: 20),
                      _buildActionButtons(),
                      const SizedBox(height: 24),
                      _buildWeeklyGraph(),
                      const SizedBox(height: 24),
                      _buildStatsCards(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPremiumAppBar() {
    return FadeInDown(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius:
              const BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
        child: Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Step Counter',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Track your daily progress',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () => Navigator.pushNamed(context, '/history'),
            ),
            IconButton(
              icon: const Icon(Icons.flag_outlined, color: Colors.white),
              onPressed: _showGoalSettingDialog,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTodayCard() {
    final steps = context.watch<StepProvider>().steps;
    final progress = (steps / _dailyGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();
    final isGoalAchieved = steps >= _dailyGoal;

    return FadeInUp(
      duration: const Duration(milliseconds: 600),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white,
              Colors.blue.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Today\'s Progress',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      DateFormat('EEEE, MMM d').format(DateTime.now()),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
                if (isGoalAchieved)
                  Pulse(
                    infinite: true,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Colors.amber,
                        size: 32,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 32),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 220,
                  height: 220,
                  child: AnimatedBuilder(
                    animation: _progressAnimation,
                    builder: (context, child) {
                      return CircularProgressIndicator(
                        value: progress * _progressAnimation.value,
                        strokeWidth: 16,
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isGoalAchieved ? Colors.green : Colors.blue,
                        ),
                      );
                    },
                  ),
                ),
                if (isGoalAchieved)
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: child,
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.directions_walk,
                          size: 56,
                          color: Colors.green,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          NumberFormat('#,###').format(steps),
                          style: const TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        const Text(
                          'Steps',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.green,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.directions_walk,
                        size: 56,
                        color: Colors.blue,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        NumberFormat('#,###').format(steps),
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Text(
                        'Steps',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isGoalAchieved
                      ? [Colors.green, Colors.green.shade700]
                      : [Colors.orange, Colors.orange.shade700],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: (isGoalAchieved ? Colors.green : Colors.orange)
                        .withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGoalAchieved ? Icons.verified : Icons.trending_up,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isGoalAchieved
                        ? '🎉 Goal Achieved!'
                        : '$percentage% to goal',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Goal: ${NumberFormat('#,###').format(_dailyGoal)} steps',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return FadeInUp(
      duration: const Duration(milliseconds: 800),
      child: Row(
        children: [
          Expanded(
            child: _buildActionButton(
              icon: Icons.save,
              label: 'Save',
              gradient: [Colors.green, Colors.green.shade700],
              onTap: _saveStepsToHistory,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.flag,
              label: 'Goal',
              gradient: [Colors.blue, Colors.blue.shade700],
              onTap: _showGoalSettingDialog,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildActionButton(
              icon: Icons.history,
              label: 'History',
              gradient: [Colors.purple, Colors.purple.shade700],
              onTap: () => Navigator.pushNamed(context, '/history'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required List<Color> gradient,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: gradient),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient[0].withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeeklyGraph() {
    if (_weeklySteps.isEmpty) {
      return FadeInUp(
        duration: const Duration(milliseconds: 1000),
        child: Container(
          padding: const EdgeInsets.all(40),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }

    return FadeInUp(
      duration: const Duration(milliseconds: 1000),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bar_chart, color: Colors.blue, size: 24),
                    SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Weekly Progress',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Tap bars to view details',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                if (!_isPremium)
                  GestureDetector(
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: const Row(
                            children: [
                              Icon(Icons.lock, color: Colors.white),
                              SizedBox(width: 12),
                              Text(
                                  'Upgrade to Premium for advanced analytics!'),
                            ],
                          ),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.amber, Colors.orange],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.lock, color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'PRO',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 220,
              child: Stack(
                children: [
                  BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: (_dailyGoal * 1.2).toDouble(),
                      barTouchData: BarTouchData(
                        enabled: true,
                        touchCallback: (FlTouchEvent event, barTouchResponse) {
                          if (event is FlTapUpEvent &&
                              barTouchResponse != null) {
                            final spot = barTouchResponse.spot;
                            if (spot != null) {
                              setState(() {
                                _selectedDayIndex = spot.touchedBarGroupIndex;
                              });
                              _showDayDetails(
                                  _weeklySteps[spot.touchedBarGroupIndex]);
                            }
                          }
                        },
                        touchTooltipData: BarTouchTooltipData(
                          getTooltipColor: (group) => Colors.blue.shade700,
                          getTooltipItem: (group, groupIndex, rod, rodIndex) {
                            return BarTooltipItem(
                              '${NumberFormat('#,###').format(rod.toY.toInt())}\nsteps',
                              const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            );
                          },
                        ),
                      ),
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              if (value.toInt() >= 0 &&
                                  value.toInt() < _weeklySteps.length) {
                                final isSelected =
                                    value.toInt() == _selectedDayIndex;
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    _weeklySteps[value.toInt()].dayName,
                                    style: TextStyle(
                                      fontSize: isSelected ? 14 : 12,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w600,
                                      color: isSelected
                                          ? Colors.blue
                                          : Colors.black87,
                                    ),
                                  ),
                                );
                              }
                              return const Text('');
                            },
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 45,
                            getTitlesWidget: (value, meta) {
                              return Text(
                                '${(value / 1000).toStringAsFixed(0)}k',
                                style: const TextStyle(
                                    fontSize: 11, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles: SideTitles(showTitles: false)),
                      ),
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: _dailyGoal / 4,
                        getDrawingHorizontalLine: (value) {
                          return FlLine(
                            color: Colors.grey.shade200,
                            strokeWidth: 1,
                          );
                        },
                      ),
                      borderData: FlBorderData(show: false),
                      barGroups: _weeklySteps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final data = entry.value;
                        final isGoalAchieved = data.steps >= _dailyGoal;
                        final isSelected = index == _selectedDayIndex;

                        return BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: data.steps.toDouble(),
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: isGoalAchieved
                                    ? [
                                        Colors.green.shade400,
                                        Colors.green.shade600
                                      ]
                                    : [
                                        Colors.blue.shade300,
                                        Colors.blue.shade600
                                      ],
                              ),
                              width: isSelected ? 24 : 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(8),
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                      extraLinesData: ExtraLinesData(
                        horizontalLines: [
                          HorizontalLine(
                            y: _dailyGoal.toDouble(),
                            color: Colors.orange,
                            strokeWidth: 2,
                            dashArray: [8, 4],
                            label: HorizontalLineLabel(
                              show: true,
                              labelResolver: (line) => 'Goal',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontWeight: FontWeight.bold,
                                fontSize: 11,
                              ),
                              alignment: Alignment.topRight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (!_isPremium)
                    Positioned.fill(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
                          child: Container(
                            color: Colors.white.withOpacity(0.3),
                            child: Center(
                              child: Pulse(
                                infinite: true,
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [Colors.amber, Colors.orange],
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.orange.withOpacity(0.5),
                                        blurRadius: 20,
                                      ),
                                    ],
                                  ),
                                  child: const Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.lock,
                                          color: Colors.white, size: 40),
                                      SizedBox(height: 8),
                                      Text(
                                        'Premium Feature',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      Text(
                                        'Unlock detailed analytics',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem(Colors.green, 'Goal Achieved'),
                const SizedBox(width: 20),
                _buildLegendItem(Colors.blue, 'In Progress'),
                const SizedBox(width: 20),
                _buildLegendItem(Colors.orange, 'Target'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showDayDetails(DailySteps day) {
    final isGoalAchieved = day.steps >= _dailyGoal;
    final percentage = ((day.steps / _dailyGoal) * 100).toInt();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isGoalAchieved ? Icons.emoji_events : Icons.directions_walk,
                  color: isGoalAchieved ? Colors.amber : Colors.blue,
                  size: 40,
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.dayName,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      DateFormat('MMM d, yyyy').format(day.date),
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isGoalAchieved
                      ? [Colors.green.shade50, Colors.green.shade100]
                      : [Colors.blue.shade50, Colors.blue.shade100],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Text(
                    NumberFormat('#,###').format(day.steps),
                    style: TextStyle(
                      fontSize: 56,
                      fontWeight: FontWeight.bold,
                      color: isGoalAchieved ? Colors.green : Colors.blue,
                    ),
                  ),
                  const Text(
                    'Steps',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        isGoalAchieved ? Icons.check_circle : Icons.trending_up,
                        color: isGoalAchieved ? Colors.green : Colors.orange,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        isGoalAchieved
                            ? 'Goal Achieved! 🎉'
                            : '$percentage% of goal',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isGoalAchieved ? Colors.green : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.local_fire_department,
                    label: 'Calories',
                    value: '${(day.steps * 0.04).toInt()}',
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.straighten,
                    label: 'Distance',
                    value: '${(day.steps * 0.0008).toStringAsFixed(1)} km',
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    final totalSteps = _weeklySteps.fold<int>(0, (sum, day) => sum + day.steps);
    final avgSteps =
        _weeklySteps.isEmpty ? 0 : (totalSteps / _weeklySteps.length).toInt();
    final goalsAchieved =
        _weeklySteps.where((day) => day.steps >= _dailyGoal).length;
    final bestDay = _weeklySteps.isEmpty
        ? null
        : _weeklySteps.reduce((a, b) => a.steps > b.steps ? a : b);

    return FadeInUp(
      duration: const Duration(milliseconds: 1200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Weekly Summary',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.directions_walk,
                  label: 'Total',
                  value: NumberFormat.compact().format(totalSteps),
                  color: Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.trending_up,
                  label: 'Average',
                  value: NumberFormat.compact().format(avgSteps),
                  color: Colors.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.emoji_events,
                  label: 'Goals Hit',
                  value: '$goalsAchieved/7',
                  color: Colors.amber,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniStatCard(
                  icon: Icons.star,
                  label: 'Best Day',
                  value: bestDay?.dayName ?? 'N/A',
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [color, color.withOpacity(0.7)],
            ),
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class DailySteps {
  final DateTime date;
  final int steps;
  final String dayName;

  DailySteps({
    required this.date,
    required this.steps,
    required this.dayName,
  });
}
