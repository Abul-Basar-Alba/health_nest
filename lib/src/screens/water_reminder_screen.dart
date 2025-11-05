// lib/src/screens/water_reminder_screen.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/user_provider.dart';
import '../providers/water_reminder_provider.dart';

class WaterReminderScreen extends StatefulWidget {
  const WaterReminderScreen({super.key});

  @override
  State<WaterReminderScreen> createState() => _WaterReminderScreenState();
}

class _WaterReminderScreenState extends State<WaterReminderScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _waveController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();

    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final waterProvider =
        Provider.of<WaterReminderProvider>(context, listen: false);

    if (userProvider.user?.id != null && !_isInitialized) {
      await waterProvider.initialize(userProvider.user!.id);
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade50,
              Colors.cyan.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<WaterReminderProvider>(
            builder: (context, provider, _) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF2196F3),
                  ),
                );
              }

              return CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 80,
                    floating: false,
                    pinned: true,
                    backgroundColor: Colors.white,
                    elevation: 2,
                    shadowColor: Colors.grey.shade300,
                    leading: IconButton(
                      icon: const Icon(Icons.arrow_back,
                          color: Color(0xFF2196F3)),
                      onPressed: () => Navigator.pop(context),
                    ),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF03A9F4)],
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.water_drop,
                                color: Colors.white, size: 18),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Water Reminder',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF2196F3),
                            ),
                          ),
                        ],
                      ),
                      centerTitle: true,
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.settings,
                            color: Color(0xFF2196F3)),
                        onPressed: () => _showSettingsDialog(context, provider),
                      ),
                    ],
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          // Water Wave Progress Circle
                          _buildWaveProgress(provider),

                          const SizedBox(height: 15),

                          // Reset Button
                          if (provider.todayIntake > 0)
                            TextButton.icon(
                              onPressed: () =>
                                  _showResetDialog(context, provider),
                              icon: const Icon(Icons.refresh, size: 20),
                              label: const Text('Reset Today'),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.orange.shade700,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10),
                              ),
                            ),

                          const SizedBox(height: 30),

                          // Stats Cards
                          _buildStatsCards(provider),

                          const SizedBox(height: 25),

                          // Quick Action Buttons
                          _buildQuickActions(provider),

                          const SizedBox(height: 25),

                          // Reminder Times Card
                          _buildReminderTimesCard(provider),

                          const SizedBox(height: 25),

                          // History Chart (placeholder for now)
                          _buildHistoryCard(provider),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // Water Wave Progress Circle
  Widget _buildWaveProgress(WaterReminderProvider provider) {
    return Container(
      height: 280,
      width: 280,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 30,
            spreadRadius: 10,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Animated Water Wave
          AnimatedBuilder(
            animation: _waveController,
            builder: (context, child) {
              return CustomPaint(
                size: const Size(280, 280),
                painter: WaterWavePainter(
                  animationValue: _waveController.value,
                  fillPercentage: provider.percentageCompleted,
                ),
              );
            },
          ),

          // Center Text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${provider.todayIntake}',
                style: TextStyle(
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  color: provider.percentageCompleted >= 1.0
                      ? Colors.green.shade700
                      : const Color(0xFF2196F3),
                  shadows: [
                    Shadow(
                      color: Colors.white.withOpacity(0.8),
                      blurRadius: 4,
                    ),
                  ],
                ),
              ),
              Text(
                'of ${provider.targetGlasses} glasses',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                '${provider.totalMlToday} / ${provider.targetMl} ml',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),

          // Completion Badge
          if (provider.percentageCompleted >= 1.0)
            Positioned(
              top: 20,
              right: 20,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.shade200,
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Stats Cards
  Widget _buildStatsCards(WaterReminderProvider provider) {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.local_drink,
            label: 'Glass Size',
            value: '${provider.glassSize} ml',
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: _buildStatCard(
            icon: Icons.emoji_events,
            label: 'Progress',
            value: '${(provider.percentageCompleted * 100).toInt()}%',
            color: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // Quick Action Buttons
  Widget _buildQuickActions(WaterReminderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildDrinkButton(
                glasses: 1,
                icon: Icons.water_drop_outlined,
                provider: provider,
              ),
              _buildDrinkButton(
                glasses: 2,
                icon: Icons.local_drink,
                provider: provider,
              ),
              _buildDrinkButton(
                glasses: 3,
                icon: Icons.sports_bar,
                provider: provider,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDrinkButton({
    required int glasses,
    required IconData icon,
    required WaterReminderProvider provider,
  }) {
    return InkWell(
      onTap: () async {
        await provider.drinkWater(glasses);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content:
                  Text('Added $glasses glass${glasses > 1 ? 'es' : ''}! 💧'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 2),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      },
      child: Container(
        width: 90,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF2196F3), Color(0xFF03A9F4)],
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.shade200,
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              '+$glasses',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'glass${glasses > 1 ? 'es' : ''}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Reminder Times Card
  Widget _buildReminderTimesCard(WaterReminderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
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
              Row(
                children: [
                  Text(
                    'Reminder Times',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Switch(
                    value: provider.isEnabled,
                    onChanged: (value) => provider.toggleReminders(value),
                    activeThumbColor: const Color(0xFF2196F3),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.add_circle, color: Color(0xFF2196F3)),
                onPressed: () => _showAddTimeDialog(context, provider),
              ),
            ],
          ),
          const SizedBox(height: 15),
          LayoutBuilder(
            builder: (context, constraints) {
              final times = provider.reminderTimes;
              final itemsPerRow = 2;
              final rows = (times.length / itemsPerRow).ceil();

              return Column(
                children: List.generate(rows, (rowIndex) {
                  final startIndex = rowIndex * itemsPerRow;
                  final endIndex =
                      (startIndex + itemsPerRow).clamp(0, times.length);
                  final rowItems = times.sublist(startIndex, endIndex);

                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: rowIndex < rows - 1 ? 10.0 : 0,
                    ),
                    child: Row(
                      children: [
                        for (int i = 0; i < rowItems.length; i++) ...[
                          Expanded(
                            child: _buildTimeChip(rowItems[i], provider),
                          ),
                          if (i < rowItems.length - 1)
                            const SizedBox(width: 10),
                        ],
                        // Fill remaining space if odd number
                        if (rowItems.length < itemsPerRow)
                          Expanded(child: Container()),
                      ],
                    ),
                  );
                }),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTimeChip(String time, WaterReminderProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: provider.isEnabled
            ? const Color(0xFF2196F3).withOpacity(0.1)
            : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: provider.isEnabled
              ? const Color(0xFF2196F3)
              : Colors.grey.shade400,
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.alarm,
            size: 16,
            color: provider.isEnabled
                ? const Color(0xFF2196F3)
                : Colors.grey.shade600,
          ),
          const SizedBox(width: 6),
          Text(
            _formatTime(time),
            style: TextStyle(
              color: provider.isEnabled
                  ? const Color(0xFF2196F3)
                  : Colors.grey.shade600,
              fontWeight: FontWeight.w600,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          GestureDetector(
            onTap: () => provider.removeReminderTime(time),
            child: Icon(
              Icons.close,
              size: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(String time24) {
    final parts = time24.split(':');
    final hour = int.parse(parts[0]);
    final minute = parts[1];

    if (hour == 0) return '12:$minute AM';
    if (hour < 12) return '$hour:$minute AM';
    if (hour == 12) return '12:$minute PM';
    return '${hour - 12}:$minute PM';
  }

  // History Card
  Widget _buildHistoryCard(WaterReminderProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'This Week',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 15),
          const Center(
            child: Text(
              '📊 Weekly chart coming soon!',
              style: TextStyle(color: Colors.grey),
            ),
          ),
        ],
      ),
    );
  }

  // Settings Dialog
  void _showSettingsDialog(
      BuildContext context, WaterReminderProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.flag, color: Color(0xFF2196F3)),
              title: const Text('Daily Target'),
              subtitle: Text('${provider.targetGlasses} glasses'),
              onTap: () => _showTargetDialog(context, provider),
            ),
            ListTile(
              leading: const Icon(Icons.local_drink, color: Color(0xFF2196F3)),
              title: const Text('Glass Size'),
              subtitle: Text('${provider.glassSize} ml'),
              onTap: () => _showGlassSizeDialog(context, provider),
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

  // Target Dialog
  void _showTargetDialog(BuildContext context, WaterReminderProvider provider) {
    Navigator.pop(context); // Close settings
    showDialog(
      context: context,
      builder: (context) {
        int tempTarget = provider.targetGlasses;
        return AlertDialog(
          title: const Text('Set Daily Target'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempTarget glasses',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  Slider(
                    value: tempTarget.toDouble(),
                    min: 4,
                    max: 15,
                    divisions: 11,
                    activeColor: const Color(0xFF2196F3),
                    onChanged: (value) {
                      setState(() => tempTarget = value.toInt());
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.updateTarget(tempTarget);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Glass Size Dialog
  void _showGlassSizeDialog(
      BuildContext context, WaterReminderProvider provider) {
    Navigator.pop(context); // Close settings
    showDialog(
      context: context,
      builder: (context) {
        int tempSize = provider.glassSize;
        return AlertDialog(
          title: const Text('Set Glass Size'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$tempSize ml',
                    style: const TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                  Slider(
                    value: tempSize.toDouble(),
                    min: 150,
                    max: 500,
                    divisions: 7,
                    activeColor: const Color(0xFF2196F3),
                    onChanged: (value) {
                      setState(() => tempSize = (value ~/ 50) * 50);
                    },
                  ),
                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                provider.updateGlassSize(tempSize);
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  // Add Time Dialog
  void _showAddTimeDialog(
      BuildContext context, WaterReminderProvider provider) {
    TimeOfDay selectedTime = TimeOfDay.now();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Reminder Time'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime: selectedTime,
                );
                if (time != null) {
                  selectedTime = time;
                }
              },
              icon: const Icon(Icons.access_time),
              label: const Text('Pick Time'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final timeStr =
                  '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}';
              provider.addReminderTime(timeStr);
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  // Reset Dialog
  void _showResetDialog(BuildContext context, WaterReminderProvider provider) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
        title: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.refresh, color: Colors.orange, size: 22),
            SizedBox(width: 8),
            Flexible(
              child: Text(
                'Reset Progress?',
                style: TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Text(
            'Reset water intake to 0 glasses for today?',
            style: TextStyle(fontSize: 14),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final userProvider =
                  Provider.of<UserProvider>(context, listen: false);
              if (userProvider.user?.id != null) {
                await provider.resetDaily(userProvider.user!.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Progress reset successfully! 🔄'),
                      backgroundColor: Colors.orange,
                      duration: Duration(seconds: 2),
                    ),
                  );
                }
              }
            },
            child: const Text(
              'Reset',
              style: TextStyle(color: Colors.orange),
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Water Wave Animation
class WaterWavePainter extends CustomPainter {
  final double animationValue;
  final double fillPercentage;

  WaterWavePainter({
    required this.animationValue,
    required this.fillPercentage,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final radius = size.width / 2;
    final center = Offset(size.width / 2, size.height / 2);

    // Background circle
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, bgPaint);

    // Calculate water level
    final waterLevel = size.height - (size.height * fillPercentage);

    // Clip to circle
    canvas.save();
    canvas.clipPath(
        Path()..addOval(Rect.fromCircle(center: center, radius: radius)));

    // Draw wave
    final wavePaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF2196F3).withOpacity(0.5),
          const Color(0xFF03A9F4),
        ],
      ).createShader(Rect.fromLTWH(0, waterLevel, size.width, size.height));

    final wavePath = Path();
    wavePath.moveTo(0, size.height);

    for (double i = 0; i <= size.width; i++) {
      final waveHeight = 10;
      final y = waterLevel +
          math.sin(((i / size.width) * 2 * math.pi) +
                  (animationValue * 2 * math.pi)) *
              waveHeight;
      wavePath.lineTo(i, y);
    }

    wavePath.lineTo(size.width, size.height);
    wavePath.close();

    canvas.drawPath(wavePath, wavePaint);
    canvas.restore();

    // Border circle
    final borderPaint = Paint()
      ..color = const Color(0xFF2196F3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;
    canvas.drawCircle(center, radius, borderPaint);
  }

  @override
  bool shouldRepaint(WaterWavePainter oldDelegate) {
    return animationValue != oldDelegate.animationValue ||
        fillPercentage != oldDelegate.fillPercentage;
  }
}
