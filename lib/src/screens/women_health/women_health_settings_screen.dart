// lib/src/screens/women_health/women_health_settings_screen.dart

import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../providers/women_health_provider.dart';
import 'women_health_colors.dart';

class WomenHealthSettingsScreen extends StatefulWidget {
  const WomenHealthSettingsScreen({super.key});

  @override
  State<WomenHealthSettingsScreen> createState() =>
      _WomenHealthSettingsScreenState();
}

class _WomenHealthSettingsScreenState extends State<WomenHealthSettingsScreen> {
  final _cycleLengthController = TextEditingController();
  final _periodLengthController = TextEditingController();
  DateTime? _lastPeriodDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<WomenHealthProvider>(context, listen: false);
      _cycleLengthController.text =
          provider.settings?.averageCycleLength.toString() ?? '28';
      _periodLengthController.text =
          provider.settings?.averagePeriodLength.toString() ?? '5';
      _lastPeriodDate = provider.settings?.lastPeriodStart;
    });
  }

  @override
  void dispose() {
    _cycleLengthController.dispose();
    _periodLengthController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WomenHealthColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: WomenHealthColors.primaryPink,
          ),
        ),
        title: const Text(
          'Settings',
          style: TextStyle(
            color: WomenHealthColors.darkText,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer2<WomenHealthProvider, AuthProvider>(
        builder: (context, womenHealthProvider, authProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCycleSettingsCard(womenHealthProvider, authProvider),
                const SizedBox(height: 16),
                _buildPillTrackingCard(womenHealthProvider, authProvider),
                const SizedBox(height: 16),
                _buildReminderSettingsCard(),
                const SizedBox(height: 16),
                _buildDataManagementCard(womenHealthProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCycleSettingsCard(
      WomenHealthProvider provider, AuthProvider authProvider) {
    return FadeInUp(
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
                  Icons.calendar_today,
                  color: WomenHealthColors.primaryPink,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Cycle Settings',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WomenHealthColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _cycleLengthController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Average Cycle Length (days)',
                hintText: '28',
                prefixIcon: const Icon(Icons.event,
                    color: WomenHealthColors.primaryPink),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: WomenHealthColors.primaryPink,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _periodLengthController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Average Period Length (days)',
                hintText: '5',
                prefixIcon: const Icon(Icons.water_drop,
                    color: WomenHealthColors.periodRed),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(
                    color: WomenHealthColors.primaryPink,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_note,
                  color: WomenHealthColors.primaryPurple),
              title: const Text('Last Period Start Date'),
              subtitle: Text(
                _lastPeriodDate != null
                    ? '${_lastPeriodDate!.day}/${_lastPeriodDate!.month}/${_lastPeriodDate!.year}'
                    : 'Not set',
              ),
              trailing:
                  const Icon(Icons.edit, color: WomenHealthColors.primaryPink),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: _lastPeriodDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: const ColorScheme.light(
                          primary: WomenHealthColors.primaryPink,
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (date != null) {
                  setState(() {
                    _lastPeriodDate = date;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (authProvider.user != null) {
                    final cycleLength =
                        int.tryParse(_cycleLengthController.text) ?? 28;
                    final periodLength =
                        int.tryParse(_periodLengthController.text) ?? 5;

                    final updates = <String, dynamic>{
                      'averageCycleLength': cycleLength,
                      'averagePeriodLength': periodLength,
                    };

                    if (_lastPeriodDate != null) {
                      updates['lastPeriodStart'] = _lastPeriodDate;
                    }

                    await provider.updateSettings(
                      authProvider.user!.uid,
                      updates,
                    );

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Settings saved successfully!'),
                          backgroundColor: WomenHealthColors.primaryPink,
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: WomenHealthColors.primaryPink,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Save Changes',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillTrackingCard(
      WomenHealthProvider provider, AuthProvider authProvider) {
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
            const Row(
              children: [
                Icon(
                  Icons.medication,
                  color: WomenHealthColors.pillYellow,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Pill Tracking',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WomenHealthColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Enable pill tracking to get daily reminders and track adherence',
              style: TextStyle(
                fontSize: 14,
                color: WomenHealthColors.mediumText,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Enable Pill Tracking'),
              subtitle: const Text('Track daily pill intake'),
              value: provider.isPillTrackingEnabled,
              activeThumbColor: WomenHealthColors.primaryPink,
              onChanged: (value) async {
                if (authProvider.user != null) {
                  await provider.togglePillTracking(
                      authProvider.user!.uid, value);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReminderSettingsCard() {
    return FadeInUp(
      delay: const Duration(milliseconds: 200),
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
                  Icons.notifications_active,
                  color: WomenHealthColors.primaryPurple,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Reminders',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WomenHealthColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Period Reminders'),
              subtitle: const Text('Get notified 3 days before period'),
              value: true,
              activeThumbColor: WomenHealthColors.primaryPink,
              onChanged: (value) {
                // TODO: Implement reminder settings
              },
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Pill Reminders'),
              subtitle: const Text('Daily pill reminder'),
              value: true,
              activeThumbColor: WomenHealthColors.primaryPink,
              onChanged: (value) {
                // TODO: Implement reminder settings
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataManagementCard(WomenHealthProvider provider) {
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
                  Icons.storage,
                  color: WomenHealthColors.mintGreen,
                  size: 24,
                ),
                SizedBox(width: 12),
                Text(
                  'Data Management',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: WomenHealthColors.darkText,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.download,
                  color: WomenHealthColors.primaryPurple),
              title: const Text('Export Data'),
              subtitle: const Text('Download your health data as text'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                _showExportDialog(provider);
              },
            ),
            const Divider(),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.delete_forever, color: Colors.red),
              title: const Text('Clear All Data'),
              subtitle: const Text('Permanently delete all records'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Clear All Data?'),
                    content: const Text(
                      'This will permanently delete all your cycle, pill, and symptom records. This action cannot be undone.',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () {
                          // TODO: Implement data clearing
                          Navigator.pop(context);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Feature coming soon!'),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Delete All'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showExportDialog(WomenHealthProvider provider) {
    final exportData = _generateExportText(provider);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.download, color: WomenHealthColors.primaryPurple),
            SizedBox(width: 8),
            Text('Export Data'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Your Women\'s Health Data:',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: WomenHealthColors.palePink,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: WomenHealthColors.primaryPink.withOpacity(0.3),
                  ),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    exportData,
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: 'monospace',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: WomenHealthColors.mediumText,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'You can copy this data or download it to your device.',
                      style: TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: WomenHealthColors.mediumText,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await _downloadExportData(exportData);
            },
            icon: const Icon(Icons.download),
            label: const Text('Download'),
            style: ElevatedButton.styleFrom(
              backgroundColor: WomenHealthColors.primaryPurple,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _downloadExportData(String data) async {
    try {
      // Show loading
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(width: 16),
              Text('Preparing file...'),
            ],
          ),
          duration: Duration(seconds: 2),
        ),
      );

      // Get app directory (works without special permissions)
      Directory directory;
      if (Platform.isAndroid) {
        // Use app-specific external directory (no permission needed)
        final appDir = await getExternalStorageDirectory();
        if (appDir == null) {
          throw Exception('Could not access storage');
        }
        // Navigate up to create a more accessible location
        directory = Directory('${appDir.path}/../../Documents/HealthNest');
      } else {
        // For iOS and other platforms
        directory = await getApplicationDocumentsDirectory();
      }

      // Create directory if it doesn't exist
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // Create filename with timestamp
      final timestamp = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final filename = 'women_health_data_$timestamp.txt';
      final filePath = '${directory.path}/$filename';

      // Write file
      final file = File(filePath);
      await file.writeAsString(data);

      // Show success message
      if (!mounted) return;
      Navigator.pop(context); // Close dialog
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      '✅ File saved successfully!',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Location: Internal Storage/Android/data/HealthNest/$filename',
                      style: const TextStyle(fontSize: 11),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 6),
          action: SnackBarAction(
            label: 'OK',
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    } catch (e) {
      print('Error saving file: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 16),
              Expanded(
                child: Text('❌ Failed to save: ${e.toString()}'),
              ),
            ],
          ),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  String _generateExportText(WomenHealthProvider provider) {
    final buffer = StringBuffer();
    buffer.writeln('=== WOMEN\'S HEALTH DATA EXPORT ===');
    buffer.writeln('Export Date: ${DateTime.now()}');
    buffer.writeln('');

    // Settings
    buffer.writeln('--- SETTINGS ---');
    if (provider.settings != null) {
      buffer.writeln(
          'Pill Tracking: ${provider.isPillTrackingEnabled ? "Enabled" : "Disabled"}');
      buffer.writeln(
          'Average Cycle Length: ${provider.settings!.averageCycleLength} days');
      buffer.writeln(
          'Average Period Length: ${provider.settings!.averagePeriodLength} days');
      if (provider.settings!.lastPeriodStart != null) {
        buffer.writeln(
            'Last Period Start: ${provider.settings!.lastPeriodStart}');
      }
    }
    buffer.writeln('');

    // Cycle Entries
    buffer.writeln('--- CYCLE HISTORY (${provider.cycles.length} entries) ---');
    for (var cycle in provider.cycles) {
      buffer.writeln('Start: ${cycle.startDate}');
      if (cycle.endDate != null) {
        buffer.writeln('End: ${cycle.endDate}');
        buffer.writeln('Length: ${cycle.cycleLength} days');
      }
      buffer.writeln('Flow Level: ${cycle.flowLevel}/5');
      if (cycle.symptoms.isNotEmpty) {
        buffer.writeln('Symptoms: ${cycle.symptoms.join(", ")}');
      }
      if (cycle.notes != null) {
        buffer.writeln('Notes: ${cycle.notes}');
      }
      buffer.writeln('---');
    }
    buffer.writeln('');

    // Symptom Logs
    buffer.writeln(
        '--- SYMPTOM LOGS (${provider.symptomLogs.length} entries) ---');
    for (var log in provider.symptomLogs) {
      buffer.writeln('Date: ${log.date}');
      buffer.writeln('Mood: ${log.mood}');
      if (log.symptoms.isNotEmpty) {
        buffer.writeln('Symptoms: ${log.symptoms.join(", ")}');
      }
      buffer.writeln('Pain Level: ${log.painLevel}/10');
      buffer.writeln('Energy Level: ${log.energyLevel}/10');
      if (log.notes != null) {
        buffer.writeln('Notes: ${log.notes}');
      }
      buffer.writeln('---');
    }
    buffer.writeln('');

    // Pill Logs
    if (provider.isPillTrackingEnabled) {
      buffer.writeln('--- PILL LOGS (${provider.pillLogs.length} entries) ---');
      for (var log in provider.pillLogs) {
        buffer.writeln('Date: ${log.scheduledTime}');
        buffer.writeln('Pill: ${log.pillName}');
        buffer.writeln(
            'Status: ${log.isTaken ? "Taken" : (log.isMissed ? "Missed" : "Pending")}');
        if (log.takenTime != null) {
          buffer.writeln('Taken At: ${log.takenTime}');
        }
        buffer.writeln('---');
      }
      buffer.writeln('');
    }

    // Statistics
    buffer.writeln('--- STATISTICS ---');
    if (provider.statistics != null) {
      provider.statistics!.forEach((key, value) {
        buffer.writeln('$key: $value');
      });
    }
    buffer.writeln('');

    buffer.writeln('=== END OF EXPORT ===');

    return buffer.toString();
  }
}
