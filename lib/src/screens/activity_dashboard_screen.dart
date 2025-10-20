// lib/src/screens/activity_dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/step_provider.dart';

class ActivityDashboardScreen extends StatefulWidget {
  const ActivityDashboardScreen({super.key});

  @override
  ActivityDashboardScreenState createState() => ActivityDashboardScreenState();
}

class ActivityDashboardScreenState extends State<ActivityDashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _congratsController;
  late Animation<double> _congratsAnimation;
  bool _hasShownCongrats = false;

  // Public methods to be called from wrapper
  void showResetDialog() {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);
    _showResetDialog(stepProvider);
  }

  void showGoalDialog() {
    final stepProvider = Provider.of<StepProvider>(context, listen: false);
    _showGoalDialog(stepProvider);
  }

  void showPremiumDialog() {
    _showPremiumDialog();
  }

  @override
  void initState() {
    super.initState();
    _congratsController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _congratsAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _congratsController,
      curve: Curves.elasticOut,
    ));
  }

  @override
  void dispose() {
    _congratsController.dispose();
    super.dispose();
  }

  void _checkGoalAchievement(int steps, int goal) {
    if (steps >= goal && !_hasShownCongrats) {
      _hasShownCongrats = true;
      _congratsController.forward();
      _showCongratsDialog();
    } else if (steps < goal) {
      _hasShownCongrats = false;
      _congratsController.reset();
    }
  }

  void _showCongratsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.celebration, color: Colors.amber, size: 30),
              const SizedBox(width: 10),
              const Text('🎉 Congratulations!'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green.shade100, Colors.blue.shade100],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Column(
                  children: [
                    Icon(Icons.emoji_events, color: Colors.amber, size: 50),
                    const SizedBox(height: 10),
                    const Text(
                      'Well Done!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Consumer<StepProvider>(
                      builder: (context, provider, child) {
                        return Text(
                          'You\'ve reached your daily goal of ${provider.dailyGoal} steps! Keep up the excellent work!',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[700],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Thank You!'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StepProvider>(
      builder: (context, stepProvider, child) {
        final int steps = stepProvider.steps;
        final int goal = stepProvider.dailyGoal;
        final double progress = steps / goal;

        // Check for goal achievement
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkGoalAchievement(steps, goal);
        });

        return Scaffold(
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section with Goal Achievement Status
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: progress >= 1.0
                          ? [Colors.green.shade400, Colors.blue.shade400]
                          : [Colors.blue.shade400, Colors.purple.shade400],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Today\'s Progress',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                progress >= 1.0
                                    ? '🎉 Goal Achieved! Amazing!'
                                    : 'Keep pushing towards your goal!',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: Colors.white70,
                                    ),
                              ),
                            ],
                          ),
                          if (progress >= 1.0)
                            ScaleTransition(
                              scale: _congratsAnimation,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.emoji_events,
                                    color: Colors.white, size: 30),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                // Steps Counter Section
                Center(
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background circle
                        Container(
                          width: 280,
                          height: 280,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                                color: Colors.grey.shade200, width: 2),
                          ),
                        ),
                        // Progress indicator
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(begin: 0.0, end: progress),
                            duration: const Duration(seconds: 2),
                            builder: (context, value, child) {
                              return CircularProgressIndicator(
                                value: value.clamp(0.0, 1.0),
                                strokeWidth: 15,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  progress >= 1.0
                                      ? Colors.green
                                      : Colors.blue.shade700,
                                ),
                              );
                            },
                          ),
                        ),
                        // Center content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              progress >= 1.0
                                  ? Icons.emoji_events
                                  : Icons.directions_walk,
                              size: 50,
                              color: progress >= 1.0
                                  ? Colors.amber
                                  : Colors.blue.shade700,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              '$steps',
                              style: Theme.of(context)
                                  .textTheme
                                  .displayLarge
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: progress >= 1.0
                                        ? Colors.green
                                        : Colors.blue.shade700,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Steps',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // Status Message below the circle
                const SizedBox(height: 15),
                Center(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: stepProvider.statusMessage.contains('active') ||
                              stepProvider.statusMessage.contains('Ready')
                          ? Colors.green.shade100
                          : Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      stepProvider.statusMessage,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: stepProvider.statusMessage
                                        .contains('active') ||
                                    stepProvider.statusMessage.contains('Ready')
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                            fontWeight: FontWeight.w600,
                          ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Step Counter Status Card
                if (!stepProvider.isAvailable)
                  Card(
                    elevation: 4,
                    color: Colors.orange.shade50,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.sensors,
                                  color: Colors.orange, size: 30),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Activate Step Counter',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleLarge
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.orange.shade700,
                                      ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Text(
                            'Enable step tracking to monitor your daily activity and reach your fitness goals automatically.',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: Colors.grey[700],
                                ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: () => stepProvider.requestPermissions(),
                            icon: const Icon(Icons.play_arrow),
                            label: const Text('Enable Step Tracking'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 30, vertical: 15),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25)),
                              elevation: 3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Daily Step Recommendations
                const SizedBox(height: 25),
                _buildStepRecommendations(),

                // Health Metrics
                const SizedBox(height: 30),
                Text(
                  'Health Insights',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  childAspectRatio: 1.1,
                  children: [
                    _buildMetricCard(
                      context,
                      'Daily Goal',
                      stepProvider.dailyGoal.toString(),
                      Icons.flag,
                      Colors.green,
                      subtitle: stepProvider.dailyGoal == 10000
                          ? 'WHO Recommended'
                          : 'Custom Goal',
                    ),
                    _buildMetricCard(
                      context,
                      'Calories Burned',
                      (steps * 0.04).toStringAsFixed(0),
                      Icons.local_fire_department,
                      Colors.red,
                      subtitle: 'Estimated',
                    ),
                    _buildMetricCard(
                      context,
                      'Distance',
                      '${(steps * 0.0008).toStringAsFixed(2)} km',
                      Icons.straighten,
                      Colors.teal,
                      subtitle: 'Approximate',
                    ),
                    _buildMetricCard(
                      context,
                      'Goal Progress',
                      '${((steps / goal) * 100).clamp(0, 100).toStringAsFixed(0)}%',
                      Icons.track_changes,
                      Colors.indigo,
                      subtitle:
                          progress >= 1.0 ? 'Completed! 🎉' : 'In Progress',
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Motivational Tips
                _buildMotivationalTips(steps, progress, goal),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStepRecommendations() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.lightbulb, color: Colors.amber.shade700, size: 25),
                const SizedBox(width: 10),
                Text(
                  'Daily Step Standards',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            _buildRecommendationItem('10,000 Steps',
                'WHO Global Recommendation', Colors.green, Icons.public),
            _buildRecommendationItem('7,000-8,000 Steps',
                'Minimum for Health Benefits', Colors.blue, Icons.favorite),
            _buildRecommendationItem('12,000+ Steps', 'Optimal for Weight Loss',
                Colors.orange, Icons.trending_up),
            _buildRecommendationItem('15,000+ Steps',
                'Athletic/Very Active Level', Colors.purple, Icons.sports),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(
      String steps, String description, Color color, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
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
                  steps,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: color,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMotivationalTips(int steps, double progress, int goal) {
    String message;
    Color color;
    IconData icon;

    if (progress >= 1.0) {
      message =
          'Outstanding! You\'ve exceeded your daily goal. You\'re a fitness champion!';
      color = Colors.green;
      icon = Icons.emoji_events;
    } else if (progress >= 0.8) {
      message =
          'Almost there! Just ${goal - steps} more steps to reach your goal!';
      color = Colors.orange;
      icon = Icons.trending_up;
    } else if (progress >= 0.5) {
      message = 'Great progress! You\'re halfway to your goal. Keep it up!';
      color = Colors.blue;
      icon = Icons.thumb_up;
    } else if (progress >= 0.25) {
      message = 'Good start! Every step counts towards better health.';
      color = Colors.teal;
      icon = Icons.directions_walk;
    } else {
      message = 'Ready to start your fitness journey? Take the first step!';
      color = Colors.purple;
      icon = Icons.play_arrow;
    }

    return Card(
      elevation: 3,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: () {
          if (progress < 0.25) {
            // Show workout start dialog
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                title: Row(
                  children: [
                    Icon(Icons.fitness_center, color: Colors.purple, size: 28),
                    const SizedBox(width: 10),
                    const Text('Start Workout?'),
                  ],
                ),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.directions_run,
                      size: 60,
                      color: Colors.purple.shade300,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Ready to begin your fitness journey? Let\'s get moving!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Later',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); // Close dialog
                      Navigator.pop(context, 2); // Go to workout tab
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.purple,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Start Now'),
                  ),
                ],
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 30),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Text(
                  message,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ),
              if (progress < 0.25)
                Icon(
                  Icons.arrow_forward_ios,
                  color: color,
                  size: 18,
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPremiumDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.workspace_premium,
                  color: Colors.amber.shade700, size: 30),
              const SizedBox(width: 10),
              const Text('Premium Features'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPremiumFeature('📊', 'Advanced Analytics & Reports'),
              _buildPremiumFeature('🎯', 'Custom Goals & Challenges'),
              _buildPremiumFeature('🏆', 'Achievement Badges & Rewards'),
              _buildPremiumFeature('📱', 'Heart Rate Monitoring'),
              _buildPremiumFeature('🌙', 'Sleep Tracking Integration'),
              _buildPremiumFeature('👥', 'Social Competitions'),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.amber.shade100, Colors.orange.shade100],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  '🎉 Special Launch Offer: 50% OFF\n₹199/month → ₹99/month',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Maybe Later'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to premium services screen
                Navigator.pushNamed(context, '/premium-services');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Upgrade Now'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPremiumFeature(String emoji, String feature) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 10),
          Expanded(child: Text(feature)),
        ],
      ),
    );
  }

  Widget _buildMetricCard(BuildContext context, String title, String value,
      IconData icon, Color color,
      {String? subtitle}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 30),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.w500,
                  ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                      fontSize: 10,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Goal Setting Dialog
  void _showGoalDialog(StepProvider stepProvider) {
    final TextEditingController goalController = TextEditingController();
    goalController.text = stepProvider.dailyGoal.toString();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.flag, color: Colors.green.shade600, size: 30),
              const SizedBox(width: 10),
              const Text('Set Daily Goal'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Set your daily step goal. Standard recommendations:',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 15),
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Text('• 7,000-8,000: Minimum for health',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                    Text('• 10,000: WHO recommendation',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                    Text('• 12,000+: Optimal for weight loss',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                    Text('• 15,000+: Athletic level',
                        style:
                            TextStyle(fontSize: 12, color: Colors.grey[700])),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: goalController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Daily Step Goal',
                  prefixIcon: Icon(Icons.flag, color: Colors.green.shade600),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  suffixText: 'steps',
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickGoalButton('7K', 7000, goalController),
                  _buildQuickGoalButton('10K', 10000, goalController),
                  _buildQuickGoalButton('12K', 12000, goalController),
                  _buildQuickGoalButton('15K', 15000, goalController),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final newGoal = int.tryParse(goalController.text) ?? 10000;
                if (newGoal > 0 && newGoal <= 50000) {
                  stepProvider.setDailyGoal(newGoal);
                  Navigator.of(context).pop();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Daily goal set to ${newGoal.toString()} steps!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content:
                          Text('Please enter a valid goal (1-50,000 steps)'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Set Goal'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildQuickGoalButton(
      String label, int goal, TextEditingController controller) {
    return ElevatedButton(
      onPressed: () => controller.text = goal.toString(),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue.shade100,
        foregroundColor: Colors.blue.shade700,
        minimumSize: const Size(50, 30),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      ),
      child: Text(label, style: const TextStyle(fontSize: 12)),
    );
  }

  // Reset Steps Dialog
  void _showResetDialog(StepProvider stepProvider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.refresh, color: Colors.red.shade600, size: 30),
              const SizedBox(width: 10),
              const Text('Reset Daily Steps'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(Icons.warning, color: Colors.red.shade600, size: 40),
                    const SizedBox(height: 10),
                    Text(
                      'Are you sure you want to reset today\'s step count?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Current Steps: ${stepProvider.steps}',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Text(
                'This action cannot be undone. Your step count will return to 0.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                stepProvider.resetDailySteps();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Daily steps reset successfully!'),
                    backgroundColor: Colors.green,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Reset Steps'),
            ),
          ],
        );
      },
    );
  }
}
