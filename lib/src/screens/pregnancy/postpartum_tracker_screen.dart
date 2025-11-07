// lib/src/screens/pregnancy/postpartum_tracker_screen.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/postpartum_log_model.dart';
import '../../providers/pregnancy_provider.dart';

class PostpartumTrackerScreen extends StatefulWidget {
  const PostpartumTrackerScreen({super.key});

  @override
  State<PostpartumTrackerScreen> createState() =>
      _PostpartumTrackerScreenState();
}

class _PostpartumTrackerScreenState extends State<PostpartumTrackerScreen> {
  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);
    if (provider.activePregnancy != null) {
      await provider.loadPostpartumLogs(
        provider.activePregnancy!.userId,
        provider.activePregnancy!.id,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyProvider>(
      builder: (context, provider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFFFFF0F5), // Lavender blush
          appBar: AppBar(
            title: Text(
              provider.isBangla ? 'প্রসবোত্তর ট্র্যাকার' : 'Postpartum Tracker',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: const Color(0xFFE91E63), // Pink
            elevation: 0,
          ),
          body: provider.isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _loadLogs,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Today's Statistics Card
                      _buildStatisticsCard(provider),

                      const SizedBox(height: 24),

                      // Quick Actions
                      _buildQuickActions(provider),

                      const SizedBox(height: 24),

                      // Today's Logs
                      Text(
                        provider.isBangla ? 'আজকের লগ' : "Today's Logs",
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Logs List
                      ...provider.getTodayPostpartumLogs().map(
                            (log) => _buildLogCard(log, provider),
                          ),

                      if (provider.getTodayPostpartumLogs().isEmpty)
                        _buildEmptyState(provider),
                    ],
                  ),
                ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddLogDialog(context),
            backgroundColor: const Color(0xFFE91E63),
            icon: const Icon(Icons.add),
            label: Text(
              provider.isBangla ? 'লগ যোগ করুন' : 'Add Log',
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatisticsCard(PregnancyProvider provider) {
    final stats = provider.getTodayFeedingStats();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.bar_chart, color: Color(0xFFE91E63)),
                const SizedBox(width: 8),
                Text(
                  provider.isBangla ? 'আজকের পরিসংখ্যান' : "Today's Statistics",
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Breastfeeding stats
            Row(
              children: [
                const Text('🤱 ', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.isBangla ? 'স্তন্যপান' : 'Breastfeeding',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${stats['breastfeedingCount']} ${provider.isBangla ? 'বার' : 'times'} • ${stats['breastfeedingDuration']} ${provider.isBangla ? 'মিনিট' : 'min'}',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Bottle feeding stats
            Row(
              children: [
                const Text('🍼 ', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        provider.isBangla ? 'বোতল খাওয়ানো' : 'Bottle Feeding',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${stats['bottleFeedingCount']} ${provider.isBangla ? 'বার' : 'times'} • ${stats['bottleAmount'].toStringAsFixed(0)} ml',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickActions(PregnancyProvider provider) {
    final actions = [
      {
        'type': PostpartumLogType.breastfeeding,
        'icon': '🤱',
        'nameEN': 'Breastfeed',
        'nameBN': 'স্তন্যপান',
        'color': const Color(0xFFE91E63),
      },
      {
        'type': PostpartumLogType.bottleFeeding,
        'icon': '🍼',
        'nameEN': 'Bottle',
        'nameBN': 'বোতল',
        'color': const Color(0xFF2196F3),
      },
      {
        'type': PostpartumLogType.diaper,
        'icon': '👶',
        'nameEN': 'Diaper',
        'nameBN': 'ডায়াপার',
        'color': const Color(0xFFFFB74D),
      },
      {
        'type': PostpartumLogType.sleep,
        'icon': '😴',
        'nameEN': 'Sleep',
        'nameBN': 'ঘুম',
        'color': const Color(0xFF9C27B0),
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          provider.isBangla ? 'দ্রুত অ্যাকশন' : 'Quick Actions',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: actions.map((action) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: _buildQuickActionButton(
                  icon: action['icon'] as String,
                  label: provider.isBangla
                      ? action['nameBN'] as String
                      : action['nameEN'] as String,
                  color: action['color'] as Color,
                  onTap: () => _showAddLogDialog(
                    context,
                    type: action['type'] as PostpartumLogType,
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionButton({
    required String icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogCard(PostpartumLogModel log, PregnancyProvider provider) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getLogColor(log.type).withOpacity(0.2),
          child: Text(
            log.icon,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          log.getTypeName(provider.isBangla),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(log.formattedTime),
            if (_getLogDetails(log, provider).isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                _getLogDetails(log, provider),
                style: TextStyle(color: Colors.grey[600], fontSize: 12),
              ),
            ],
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            PopupMenuItem(
              child: Row(
                children: [
                  const Icon(Icons.delete, size: 20, color: Colors.red),
                  const SizedBox(width: 8),
                  Text(provider.isBangla ? 'মুছুন' : 'Delete'),
                ],
              ),
              onTap: () {
                Future.delayed(
                  const Duration(milliseconds: 100),
                  () => _confirmDelete(log, provider),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String _getLogDetails(PostpartumLogModel log, PregnancyProvider provider) {
    switch (log.type) {
      case PostpartumLogType.breastfeeding:
        if (log.feedingDuration != null && log.feedingSide != null) {
          final side = provider.isBangla
              ? (log.feedingSide == 'left'
                  ? 'বাম'
                  : log.feedingSide == 'right'
                      ? 'ডান'
                      : 'উভয়')
              : log.feedingSide;
          return '$side • ${log.feedingDuration} ${provider.isBangla ? 'মিনিট' : 'min'}';
        }
        return '';
      case PostpartumLogType.bottleFeeding:
        if (log.bottleAmount != null) {
          return '${log.bottleAmount!.toStringAsFixed(0)} ml';
        }
        return '';
      case PostpartumLogType.diaper:
        if (log.diaperType != null) {
          final type = provider.isBangla
              ? (log.diaperType == 'wet'
                  ? 'ভেজা'
                  : log.diaperType == 'dirty'
                      ? 'নোংরা'
                      : 'উভয়')
              : log.diaperType;
          return type!;
        }
        return '';
      case PostpartumLogType.sleep:
        if (log.formattedSleepDuration != null) {
          return log.formattedSleepDuration!;
        }
        return '';
      case PostpartumLogType.mood:
        if (log.moodRating != null) {
          return '⭐' * log.moodRating!;
        }
        return '';
      case PostpartumLogType.pain:
        if (log.painLevel != null && log.painLocation != null) {
          return '${log.painLocation} • ${log.painLevel}/10';
        }
        return '';
      default:
        return log.notes ?? '';
    }
  }

  Color _getLogColor(PostpartumLogType type) {
    switch (type) {
      case PostpartumLogType.breastfeeding:
        return const Color(0xFFE91E63);
      case PostpartumLogType.bottleFeeding:
        return const Color(0xFF2196F3);
      case PostpartumLogType.pumping:
        return const Color(0xFF00BCD4);
      case PostpartumLogType.diaper:
        return const Color(0xFFFFB74D);
      case PostpartumLogType.sleep:
        return const Color(0xFF9C27B0);
      case PostpartumLogType.mood:
        return const Color(0xFFFFEB3B);
      case PostpartumLogType.pain:
        return const Color(0xFFF44336);
      case PostpartumLogType.bleeding:
        return const Color(0xFFE57373);
      case PostpartumLogType.medication:
        return const Color(0xFF26A69A);
      case PostpartumLogType.exercise:
        return const Color(0xFF66BB6A);
      case PostpartumLogType.note:
        return const Color(0xFF9E9E9E);
    }
  }

  Widget _buildEmptyState(PregnancyProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.event_note,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              provider.isBangla ? 'আজ এখনও কোনো লগ নেই' : 'No logs yet today',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              provider.isBangla
                  ? 'লগ যোগ করতে + বাটনে ট্যাপ করুন'
                  : 'Tap the + button to add a log',
              style: TextStyle(
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAddLogDialog(BuildContext context, {PostpartumLogType? type}) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            provider.isBangla ? 'লগ টাইপ নির্বাচন করুন' : 'Select Log Type',
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: PostpartumLogType.values.map((logType) {
                return ListTile(
                  leading: Text(
                    PostpartumLogModel.typeIcons[logType] ?? '📝',
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    provider.isBangla
                        ? (PostpartumLogModel.typeNamesBN[logType] ??
                            logType.name)
                        : (PostpartumLogModel.typeNamesEN[logType] ??
                            logType.name),
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _showLogFormDialog(context, logType);
                  },
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(provider.isBangla ? 'বাতিল' : 'Cancel'),
            ),
          ],
        );
      },
    );

    if (type != null) {
      Navigator.pop(context);
      _showLogFormDialog(context, type);
    }
  }

  void _showLogFormDialog(BuildContext context, PostpartumLogType type) {
    final provider = Provider.of<PregnancyProvider>(context, listen: false);

    // Controllers
    final notesController = TextEditingController();
    final durationController = TextEditingController();
    final amountController = TextEditingController();

    // State variables
    String? selectedSide = 'left';
    String? selectedDiaperType = 'wet';
    int moodRating = 3;
    String? selectedPainLocation = 'incision';
    int painLevel = 5;
    String? selectedBleedingLevel = 'moderate';
    DateTime selectedDateTime = DateTime.now();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(
                provider.isBangla
                    ? (PostpartumLogModel.typeNamesBN[type] ?? type.name)
                    : (PostpartumLogModel.typeNamesEN[type] ?? type.name),
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Date & Time picker
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: Text(
                        DateFormat('MMM dd, yyyy - HH:mm')
                            .format(selectedDateTime),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () async {
                          final date = await showDatePicker(
                            context: context,
                            initialDate: selectedDateTime,
                            firstDate: DateTime.now()
                                .subtract(const Duration(days: 90)),
                            lastDate: DateTime.now(),
                          );
                          if (date != null) {
                            final time = await showTimePicker(
                              context: context,
                              initialTime:
                                  TimeOfDay.fromDateTime(selectedDateTime),
                            );
                            if (time != null) {
                              setState(() {
                                selectedDateTime = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                  time.hour,
                                  time.minute,
                                );
                              });
                            }
                          }
                        },
                      ),
                    ),

                    const Divider(),

                    // Type-specific fields
                    if (type == PostpartumLogType.breastfeeding) ...[
                      Text(
                        provider.isBangla ? 'পার্শ্ব' : 'Side',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(provider.isBangla ? 'বাম' : 'Left'),
                              value: 'left',
                              groupValue: selectedSide,
                              onChanged: (value) {
                                setState(() => selectedSide = value);
                              },
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: Text(provider.isBangla ? 'ডান' : 'Right'),
                              value: 'right',
                              groupValue: selectedSide,
                              onChanged: (value) {
                                setState(() => selectedSide = value);
                              },
                            ),
                          ),
                        ],
                      ),
                      RadioListTile<String>(
                        title: Text(provider.isBangla ? 'উভয়' : 'Both'),
                        value: 'both',
                        groupValue: selectedSide,
                        onChanged: (value) {
                          setState(() => selectedSide = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: durationController,
                        decoration: InputDecoration(
                          labelText: provider.isBangla
                              ? 'সময়কাল (মিনিট)'
                              : 'Duration (minutes)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    if (type == PostpartumLogType.bottleFeeding) ...[
                      TextField(
                        controller: amountController,
                        decoration: InputDecoration(
                          labelText:
                              provider.isBangla ? 'পরিমাণ (ml)' : 'Amount (ml)',
                          border: const OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ],

                    if (type == PostpartumLogType.diaper) ...[
                      Text(
                        provider.isBangla ? 'টাইপ' : 'Type',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioListTile<String>(
                        title: Text(provider.isBangla ? 'ভেজা' : 'Wet'),
                        value: 'wet',
                        groupValue: selectedDiaperType,
                        onChanged: (value) {
                          setState(() => selectedDiaperType = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(provider.isBangla ? 'নোংরা' : 'Dirty'),
                        value: 'dirty',
                        groupValue: selectedDiaperType,
                        onChanged: (value) {
                          setState(() => selectedDiaperType = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(provider.isBangla ? 'উভয়' : 'Both'),
                        value: 'both',
                        groupValue: selectedDiaperType,
                        onChanged: (value) {
                          setState(() => selectedDiaperType = value);
                        },
                      ),
                    ],

                    if (type == PostpartumLogType.mood) ...[
                      Text(
                        provider.isBangla ? 'মেজাজ রেটিং' : 'Mood Rating',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: moodRating.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: '⭐' * moodRating,
                        onChanged: (value) {
                          setState(() => moodRating = value.toInt());
                        },
                      ),
                      Center(
                          child: Text('⭐' * moodRating,
                              style: const TextStyle(fontSize: 32))),
                    ],

                    if (type == PostpartumLogType.pain) ...[
                      Text(
                        provider.isBangla ? 'ব্যথার স্থান' : 'Pain Location',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      DropdownButtonFormField<String>(
                        initialValue: selectedPainLocation,
                        decoration: const InputDecoration(
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          'incision',
                          'perineum',
                          'breast',
                          'back',
                          'other'
                        ].map((loc) {
                          final locNames = {
                            'incision': provider.isBangla ? 'ছেদ' : 'Incision',
                            'perineum':
                                provider.isBangla ? 'পেরিনিয়াম' : 'Perineum',
                            'breast': provider.isBangla ? 'স্তন' : 'Breast',
                            'back': provider.isBangla ? 'পিঠ' : 'Back',
                            'other': provider.isBangla ? 'অন্যান্য' : 'Other',
                          };
                          return DropdownMenuItem(
                            value: loc,
                            child: Text(locNames[loc] ?? loc),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() => selectedPainLocation = value);
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        provider.isBangla
                            ? 'ব্যথার মাত্রা: $painLevel/10'
                            : 'Pain Level: $painLevel/10',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Slider(
                        value: painLevel.toDouble(),
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: '$painLevel',
                        onChanged: (value) {
                          setState(() => painLevel = value.toInt());
                        },
                      ),
                    ],

                    if (type == PostpartumLogType.bleeding) ...[
                      Text(
                        provider.isBangla
                            ? 'রক্তপাতের মাত্রা'
                            : 'Bleeding Level',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      RadioListTile<String>(
                        title: Text(provider.isBangla ? 'হালকা' : 'Light'),
                        value: 'light',
                        groupValue: selectedBleedingLevel,
                        onChanged: (value) {
                          setState(() => selectedBleedingLevel = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(provider.isBangla ? 'মাঝারি' : 'Moderate'),
                        value: 'moderate',
                        groupValue: selectedBleedingLevel,
                        onChanged: (value) {
                          setState(() => selectedBleedingLevel = value);
                        },
                      ),
                      RadioListTile<String>(
                        title: Text(provider.isBangla ? 'ভারী' : 'Heavy'),
                        value: 'heavy',
                        groupValue: selectedBleedingLevel,
                        onChanged: (value) {
                          setState(() => selectedBleedingLevel = value);
                        },
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Notes (for all types)
                    TextField(
                      controller: notesController,
                      decoration: InputDecoration(
                        labelText: provider.isBangla
                            ? 'নোট (ঐচ্ছিক)'
                            : 'Notes (optional)',
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(provider.isBangla ? 'বাতিল' : 'Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    // Create log
                    final log = PostpartumLogModel(
                      id: '',
                      userId: provider.activePregnancy!.userId,
                      pregnancyId: provider.activePregnancy!.id,
                      type: type,
                      logDate: selectedDateTime,
                      notes: notesController.text.trim().isEmpty
                          ? null
                          : notesController.text.trim(),
                      feedingSide: type == PostpartumLogType.breastfeeding
                          ? selectedSide
                          : null,
                      feedingDuration: type == PostpartumLogType.breastfeeding
                          ? int.tryParse(durationController.text)
                          : null,
                      bottleAmount: type == PostpartumLogType.bottleFeeding
                          ? double.tryParse(amountController.text)
                          : null,
                      diaperType: type == PostpartumLogType.diaper
                          ? selectedDiaperType
                          : null,
                      moodRating:
                          type == PostpartumLogType.mood ? moodRating : null,
                      painLocation: type == PostpartumLogType.pain
                          ? selectedPainLocation
                          : null,
                      painLevel:
                          type == PostpartumLogType.pain ? painLevel : null,
                      bleedingLevel: type == PostpartumLogType.bleeding
                          ? selectedBleedingLevel
                          : null,
                    );

                    Navigator.pop(context);

                    await provider.addPostpartumLog(log);

                    if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.isBangla
                                ? 'লগ সফলভাবে যোগ করা হয়েছে!'
                                : 'Log added successfully!',
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  },
                  child: Text(provider.isBangla ? 'যোগ করুন' : 'Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(PostpartumLogModel log, PregnancyProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(provider.isBangla ? 'লগ মুছুন?' : 'Delete Log?'),
          content: Text(
            provider.isBangla
                ? 'আপনি কি নিশ্চিত যে আপনি এই লগটি মুছতে চান?'
                : 'Are you sure you want to delete this log?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(provider.isBangla ? 'বাতিল' : 'Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await provider.deletePostpartumLog(log.id);

                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.isBangla
                            ? 'লগ মুছে ফেলা হয়েছে'
                            : 'Log deleted',
                      ),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text(provider.isBangla ? 'মুছুন' : 'Delete'),
            ),
          ],
        );
      },
    );
  }
}
