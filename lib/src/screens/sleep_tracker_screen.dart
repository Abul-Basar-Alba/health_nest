// lib/src/screens/sleep_tracker_screen.dart

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/sleep_schedule_model.dart';
import '../providers/user_provider.dart';
import '../services/freemium_service.dart';
import '../services/sleep_tracker_service.dart';

class SleepTrackerScreen extends StatefulWidget {
  const SleepTrackerScreen({super.key});

  @override
  State<SleepTrackerScreen> createState() => _SleepTrackerScreenState();
}

class _SleepTrackerScreenState extends State<SleepTrackerScreen>
    with SingleTickerProviderStateMixin {
  final SleepTrackerService _sleepService = SleepTrackerService();

  DateTime _bedtime = DateTime(2025, 1, 1, 23, 0); // 11:00 PM
  DateTime _wakeTime = DateTime(2025, 1, 1, 7, 0); // 7:00 AM
  bool _notificationsEnabled = true;
  bool _bedtimeReminderEnabled = true;
  bool _wakeUpAlarmEnabled = true;
  int _reminderMinutesBefore = 15;
  bool _isLoading = true;
  bool _isSaving = false;
  bool _isPremium = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _loadSleepSchedule();
    _loadPremiumStatus();
    _initializeAnimation();
  }

  void _initializeAnimation() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  Future<void> _loadPremiumStatus() async {
    final isPremium = await FreemiumService.isPremiumUser();
    if (mounted) {
      setState(() {
        _isPremium = isPremium;
      });
    }
  }

  Future<void> _loadSleepSchedule() async {
    setState(() => _isLoading = true);
    final schedule = await _sleepService.getSleepSchedule();
    if (schedule != null && mounted) {
      setState(() {
        _bedtime = schedule.bedtime;
        _wakeTime = schedule.wakeTime;
        _notificationsEnabled = schedule.notificationsEnabled;
        _bedtimeReminderEnabled = schedule.bedtimeReminderEnabled;
        _wakeUpAlarmEnabled = schedule.wakeUpAlarmEnabled;
        _reminderMinutesBefore = schedule.reminderMinutesBefore;
        _isLoading = false;
      });
    } else {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSleepSchedule() async {
    setState(() => _isSaving = true);

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userId = userProvider.user?.id ?? '';

      final schedule = SleepScheduleModel(
        id: userId,
        userId: userId,
        bedtime: _bedtime,
        wakeTime: _wakeTime,
        notificationsEnabled: _notificationsEnabled,
        bedtimeReminderEnabled: _bedtimeReminderEnabled,
        wakeUpAlarmEnabled: _wakeUpAlarmEnabled,
        reminderMinutesBefore: _reminderMinutesBefore,
        activeDays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _sleepService.saveSleepSchedule(schedule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                SizedBox(width: 12),
                Text('Sleep schedule saved successfully! 🌙'),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
        Navigator.pop(context, true); // Return true to indicate success
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  double get _sleepDuration {
    int totalMinutes;
    if (_wakeTime.isAfter(_bedtime)) {
      totalMinutes = _wakeTime.difference(_bedtime).inMinutes;
    } else {
      final nextDayWake = DateTime(
        _bedtime.year,
        _bedtime.month,
        _bedtime.day + 1,
        _wakeTime.hour,
        _wakeTime.minute,
      );
      totalMinutes = nextDayWake.difference(_bedtime).inMinutes;
    }
    return totalMinutes / 60.0;
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1B2E), // Dark purple background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.deepPurple.shade300,
                    Colors.purple.shade400,
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.bedtime_rounded,
                  color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text(
              'Sleep Tracker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          if (!_isPremium)
            Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
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
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Colors.purpleAccent))
          : SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  // Sleep Duration Display
                  _buildSleepDurationCard(),
                  const SizedBox(height: 30),
                  // Circular Clock Picker
                  _buildClockPicker(),
                  const SizedBox(height: 30),
                  // Settings Section
                  _buildSettingsSection(),
                  const SizedBox(height: 30),
                  // Save and Cancel Buttons
                  _buildActionButtons(),
                  const SizedBox(height: 30),
                ],
              ),
            ),
    );
  }

  Widget _buildSleepDurationCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.deepPurple.shade700.withOpacity(0.6),
            Colors.purple.shade600.withOpacity(0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Sleep Duration',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                _sleepDuration.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'hours',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _sleepDuration >= 7 && _sleepDuration <= 9
                  ? Colors.green.withOpacity(0.3)
                  : Colors.orange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _sleepDuration >= 7 && _sleepDuration <= 9
                  ? '✅ Optimal Sleep Duration'
                  : '⚠️ ${_sleepDuration < 7 ? "Try to sleep more" : "Sleeping too much"}',
              style: TextStyle(
                color: _sleepDuration >= 7 && _sleepDuration <= 9
                    ? Colors.greenAccent
                    : Colors.orangeAccent,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClockPicker() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: const Color(0xFF252642),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          // Circular Clock
          ScaleTransition(
            scale: _pulseAnimation,
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    Colors.deepPurple.shade400.withOpacity(0.1),
                    Colors.transparent,
                  ],
                ),
                border: Border.all(
                  color: Colors.deepPurple.shade300.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: CustomPaint(
                painter: ClockPainter(
                  bedtime: _bedtime,
                  wakeTime: _wakeTime,
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.bedtime_rounded,
                          color: Colors.purpleAccent, size: 40),
                      const SizedBox(height: 8),
                      Text(
                        '${_bedtime.hour.toString().padLeft(2, '0')}:${_bedtime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Bedtime',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                      const SizedBox(height: 16),
                      const Icon(Icons.wb_sunny_rounded,
                          color: Colors.amberAccent, size: 32),
                      const SizedBox(height: 8),
                      Text(
                        '${_wakeTime.hour.toString().padLeft(2, '0')}:${_wakeTime.minute.toString().padLeft(2, '0')}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Text(
                        'Wake Time',
                        style: TextStyle(color: Colors.white60, fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Time Pickers
          Row(
            children: [
              Expanded(
                child: _buildTimePickerButton(
                  icon: Icons.bedtime_rounded,
                  label: 'Bedtime',
                  time: _bedtime,
                  color: Colors.deepPurple,
                  onTap: () => _selectTime(context, true),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTimePickerButton(
                  icon: Icons.wb_sunny_rounded,
                  label: 'Wake Time',
                  time: _wakeTime,
                  color: Colors.amber,
                  onTap: () => _selectTime(context, false),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTimePickerButton({
    required IconData icon,
    required String label,
    required DateTime time,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: color.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF252642),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Notification Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildSwitchTile(
            icon: Icons.notifications_active_rounded,
            title: 'Enable Notifications',
            subtitle: 'Receive sleep reminders',
            value: _notificationsEnabled,
            onChanged: (val) => setState(() => _notificationsEnabled = val),
          ),
          if (_notificationsEnabled) ...[
            const Divider(color: Colors.white12),
            _buildSwitchTile(
              icon: Icons.alarm_rounded,
              title: 'Bedtime Reminder',
              subtitle: '$_reminderMinutesBefore min before',
              value: _bedtimeReminderEnabled,
              onChanged: (val) => setState(() => _bedtimeReminderEnabled = val),
            ),
            if (_bedtimeReminderEnabled) ...[
              Padding(
                padding: const EdgeInsets.only(left: 56, top: 8, bottom: 8),
                child: InkWell(
                  onTap: _selectReminderTime,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.deepPurple.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.deepPurple.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Reminder Time:',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Flexible(
                                child: Text(
                                  '$_reminderMinutesBefore min before',
                                  style: const TextStyle(
                                    color: Colors.purpleAccent,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.edit,
                                color: Colors.purpleAccent,
                                size: 16,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            const Divider(color: Colors.white12),
            _buildSwitchTile(
              icon: Icons.alarm_on_rounded,
              title: 'Wake Up Alarm',
              subtitle: 'Morning notification',
              value: _wakeUpAlarmEnabled,
              onChanged: (val) => setState(() => _wakeUpAlarmEnabled = val),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.deepPurple.withOpacity(0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.purpleAccent, size: 24),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white54, fontSize: 12),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.purpleAccent,
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: const BorderSide(color: Colors.white30),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveSleepSchedule,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: Ink(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.deepPurple.shade400,
                      Colors.purple.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Container(
                  alignment: Alignment.center,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Schedule',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context, bool isBedtime) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: isBedtime ? _bedtime.hour : _wakeTime.hour,
        minute: isBedtime ? _bedtime.minute : _wakeTime.minute,
      ),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: ColorScheme.dark(
              primary: isBedtime ? Colors.deepPurple : Colors.amber,
              surface: const Color(0xFF252642),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (isBedtime) {
          _bedtime = DateTime(2025, 1, 1, picked.hour, picked.minute);
        } else {
          _wakeTime = DateTime(2025, 1, 1, picked.hour, picked.minute);
        }
      });
    }
  }

  Future<void> _selectReminderTime() async {
    final options = [5, 10, 15, 20, 30, 45, 60];

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF252642),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.deepPurple.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.timer_outlined,
                color: Colors.purpleAccent,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Reminder Time',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: options.map((minutes) {
            final isSelected = _reminderMinutesBefore == minutes;
            return InkWell(
              onTap: () {
                setState(() => _reminderMinutesBefore = minutes);
                Navigator.pop(context);
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.deepPurple.withOpacity(0.3)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected ? Colors.purpleAccent : Colors.white12,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        '$minutes min before bedtime',
                        style: TextStyle(
                          color:
                              isSelected ? Colors.purpleAccent : Colors.white70,
                          fontSize: 14,
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (isSelected)
                      const Icon(
                        Icons.check_circle,
                        color: Colors.purpleAccent,
                        size: 20,
                      ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

// Custom Clock Painter
class ClockPainter extends CustomPainter {
  final DateTime bedtime;
  final DateTime wakeTime;

  ClockPainter({required this.bedtime, required this.wakeTime});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw clock face numbers
    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    );

    for (int i = 0; i < 24; i++) {
      final angle = (i * 15 - 90) * math.pi / 180;
      final x = center.dx + (radius - 25) * math.cos(angle);
      final y = center.dy + (radius - 25) * math.sin(angle);

      if (i % 3 == 0) {
        textPainter.text = TextSpan(
          text: '${i == 0 ? 24 : i}',
          style: const TextStyle(
            color: Colors.white38,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(x - textPainter.width / 2, y - textPainter.height / 2),
        );
      }
    }

    // Draw sleep arc (from bedtime to wake time)
    final paint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.deepPurple.shade400,
          Colors.purple.shade600,
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20
      ..strokeCap = StrokeCap.round;

    final bedAngle =
        ((bedtime.hour + bedtime.minute / 60) * 15 - 90) * math.pi / 180;
    final wakeAngle =
        ((wakeTime.hour + wakeTime.minute / 60) * 15 - 90) * math.pi / 180;

    double sweepAngle = wakeAngle - bedAngle;
    if (sweepAngle < 0) sweepAngle += 2 * math.pi;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 30),
      bedAngle,
      sweepAngle,
      false,
      paint,
    );

    // Draw bedtime indicator
    final bedX = center.dx + (radius - 30) * math.cos(bedAngle);
    final bedY = center.dy + (radius - 30) * math.sin(bedAngle);
    canvas.drawCircle(
      Offset(bedX, bedY),
      8,
      Paint()..color = Colors.deepPurple.shade300,
    );

    // Draw wake time indicator
    final wakeX = center.dx + (radius - 30) * math.cos(wakeAngle);
    final wakeY = center.dy + (radius - 30) * math.sin(wakeAngle);
    canvas.drawCircle(
      Offset(wakeX, wakeY),
      8,
      Paint()..color = Colors.amberAccent,
    );
  }

  @override
  bool shouldRepaint(ClockPainter oldDelegate) =>
      bedtime != oldDelegate.bedtime || wakeTime != oldDelegate.wakeTime;
}
