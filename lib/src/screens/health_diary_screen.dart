import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/blood_pressure_log.dart';
import '../models/glucose_log.dart';
import '../models/mood_log.dart';
import '../models/weight_log.dart';
import '../providers/health_diary_provider.dart';

class HealthDiaryScreen extends StatefulWidget {
  const HealthDiaryScreen({super.key});

  @override
  State<HealthDiaryScreen> createState() => _HealthDiaryScreenState();
}

class _HealthDiaryScreenState extends State<HealthDiaryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String? _userId;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _userId = FirebaseAuth.instance.currentUser?.uid;

    if (_userId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Provider.of<HealthDiaryProvider>(context, listen: false)
            .initialize(_userId!);
      });
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
      appBar: AppBar(
        title: const Text('Health Diary'),
        backgroundColor: const Color(0xFFE91E63),
        foregroundColor: Colors.white,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(icon: Icon(Icons.favorite), text: 'Blood Pressure'),
            Tab(icon: Icon(Icons.opacity), text: 'Glucose'),
            Tab(icon: Icon(Icons.monitor_weight), text: 'Weight'),
            Tab(icon: Icon(Icons.mood), text: 'Mood'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _BloodPressureTab(userId: _userId),
          _GlucoseTab(userId: _userId),
          _WeightTab(userId: _userId),
          _MoodTab(userId: _userId),
        ],
      ),
    );
  }
}

// ============ BLOOD PRESSURE TAB ============

class _BloodPressureTab extends StatelessWidget {
  final String? userId;

  const _BloodPressureTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDiaryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Card
              _buildBPStatisticsCard(provider.bpStats),
              const SizedBox(height: 16),

              // Chart
              if (provider.bpLogs.isNotEmpty) ...[
                _buildBPChart(provider),
                const SizedBox(height: 16),
              ],

              // Recent Entries
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Readings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddBPDialog(context, userId),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (provider.bpLogs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No blood pressure readings yet'),
                  ),
                )
              else
                ...provider.bpLogs
                    .take(10)
                    .map((log) => _buildBPLogCard(context, log)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBPStatisticsCard(Map<String, dynamic> stats) {
    if (stats.isEmpty || stats['count'] == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Avg Systolic',
                    '${stats['avgSystolic']?.toStringAsFixed(0) ?? 0}',
                    'mmHg',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Diastolic',
                    '${stats['avgDiastolic']?.toStringAsFixed(0) ?? 0}',
                    'mmHg',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Pulse',
                    '${stats['avgPulse']?.toStringAsFixed(0) ?? 0}',
                    'bpm',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            Text(unit,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildBPChart(HealthDiaryProvider provider) {
    final systolicData = provider.getBPSystolicChartData();
    final diastolicData = provider.getBPDiastolicChartData();

    if (systolicData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: systolicData,
                      isCurved: true,
                      color: Colors.red,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                    LineChartBarData(
                      spots: diastolicData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 16,
                  height: 3,
                  color: Colors.red,
                ),
                const SizedBox(width: 4),
                const Text('Systolic', style: TextStyle(fontSize: 12)),
                const SizedBox(width: 16),
                Container(
                  width: 16,
                  height: 3,
                  color: Colors.blue,
                ),
                const SizedBox(width: 4),
                const Text('Diastolic', style: TextStyle(fontSize: 12)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBPLogCard(BuildContext context, BloodPressureLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(log.categoryColor),
          child: const Icon(Icons.favorite, color: Colors.white, size: 20),
        ),
        title: Text(
          '${log.systolic}/${log.diastolic} mmHg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('MMM dd, yyyy hh:mm a').format(log.timestamp)}\n'
          'Pulse: ${log.pulse} bpm • ${log.category}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteBPLog(context, log.id),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showAddBPDialog(BuildContext context, String? userId) {
    if (userId == null) return;

    final systolicController = TextEditingController();
    final diastolicController = TextEditingController();
    final pulseController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Blood Pressure Reading'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: systolicController,
                decoration: const InputDecoration(labelText: 'Systolic (mmHg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: diastolicController,
                decoration:
                    const InputDecoration(labelText: 'Diastolic (mmHg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: pulseController,
                decoration: const InputDecoration(labelText: 'Pulse (bpm)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final systolic = int.tryParse(systolicController.text);
              final diastolic = int.tryParse(diastolicController.text);
              final pulse = int.tryParse(pulseController.text);

              if (systolic == null || diastolic == null || pulse == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter valid numbers')),
                );
                return;
              }

              final log = BloodPressureLog(
                id: '',
                userId: userId,
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                timestamp: DateTime.now(),
                notes:
                    notesController.text.isEmpty ? null : notesController.text,
                createdAt: DateTime.now(),
              );

              await Provider.of<HealthDiaryProvider>(context, listen: false)
                  .addBPLog(log);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Blood pressure reading added')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteBPLog(BuildContext context, String logId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading'),
        content: const Text('Are you sure you want to delete this reading?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<HealthDiaryProvider>(context, listen: false)
                  .deleteBPLog(logId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ============ GLUCOSE TAB ============

class _GlucoseTab extends StatelessWidget {
  final String? userId;

  const _GlucoseTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDiaryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Card
              _buildGlucoseStatisticsCard(provider.glucoseStats),
              const SizedBox(height: 16),

              // Chart
              if (provider.glucoseLogs.isNotEmpty) ...[
                _buildGlucoseChart(provider),
                const SizedBox(height: 16),
              ],

              // Recent Entries
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Readings',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddGlucoseDialog(context, userId),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (provider.glucoseLogs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No glucose readings yet'),
                  ),
                )
              else
                ...provider.glucoseLogs
                    .take(10)
                    .map((log) => _buildGlucoseLogCard(context, log)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGlucoseStatisticsCard(Map<String, dynamic> stats) {
    if (stats.isEmpty || stats['count'] == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Avg Glucose',
                    '${stats['avgGlucose']?.toStringAsFixed(0) ?? 0}',
                    'mg/dL',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Fasting',
                    '${stats['avgFasting']?.toStringAsFixed(0) ?? 0}',
                    'mg/dL',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Total',
                    '${stats['count'] ?? 0}',
                    'readings',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 2),
            Text(unit,
                style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ],
    );
  }

  Widget _buildGlucoseChart(HealthDiaryProvider provider) {
    final glucoseData = provider.getGlucoseChartData();

    if (glucoseData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Glucose Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: glucoseData,
                      isCurved: true,
                      color: Colors.purple,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlucoseLogCard(BuildContext context, GlucoseLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(log.categoryColor),
          child: const Icon(Icons.opacity, color: Colors.white, size: 20),
        ),
        title: Text(
          '${log.glucose.toStringAsFixed(0)} mg/dL',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('MMM dd, yyyy hh:mm a').format(log.timestamp)}\n'
          '${log.measurementTypeDisplay} • ${log.category}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteGlucoseLog(context, log.id),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showAddGlucoseDialog(BuildContext context, String? userId) {
    if (userId == null) return;

    final glucoseController = TextEditingController();
    final notesController = TextEditingController();
    String measurementType = 'fasting';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Glucose Reading'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: glucoseController,
                  decoration:
                      const InputDecoration(labelText: 'Glucose (mg/dL)'),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: measurementType,
                  decoration:
                      const InputDecoration(labelText: 'Measurement Type'),
                  items: GlucoseLog.measurementTypes
                      .map((type) => DropdownMenuItem(
                            value: type,
                            child:
                                Text(type[0].toUpperCase() + type.substring(1)),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => measurementType = value!);
                  },
                ),
                TextField(
                  controller: notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final glucose = double.tryParse(glucoseController.text);

                if (glucose == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Please enter a valid number')),
                  );
                  return;
                }

                final log = GlucoseLog(
                  id: '',
                  userId: userId,
                  glucose: glucose,
                  measurementType: measurementType,
                  timestamp: DateTime.now(),
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                  createdAt: DateTime.now(),
                );

                await Provider.of<HealthDiaryProvider>(context, listen: false)
                    .addGlucoseLog(log);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Glucose reading added')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteGlucoseLog(BuildContext context, String logId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reading'),
        content: const Text('Are you sure you want to delete this reading?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<HealthDiaryProvider>(context, listen: false)
                  .deleteGlucoseLog(logId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ============ WEIGHT TAB ============

class _WeightTab extends StatelessWidget {
  final String? userId;

  const _WeightTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDiaryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Card
              _buildWeightStatisticsCard(provider.weightStats),
              const SizedBox(height: 16),

              // Chart
              if (provider.weightLogs.isNotEmpty) ...[
                _buildWeightChart(provider),
                const SizedBox(height: 16),
              ],

              // Recent Entries
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Entries',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddWeightDialog(context, userId),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (provider.weightLogs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No weight entries yet'),
                  ),
                )
              else
                ...provider.weightLogs
                    .take(10)
                    .map((log) => _buildWeightLogCard(context, log)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWeightStatisticsCard(Map<String, dynamic> stats) {
    if (stats.isEmpty || stats['count'] == 0) {
      return const SizedBox.shrink();
    }

    final weightChange = stats['weightChange'] as double? ?? 0.0;
    final isGain = weightChange > 0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Current',
                    '${stats['currentWeight']?.toStringAsFixed(1) ?? 0}',
                    'kg',
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const Text(
                        'Change',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            isGain ? Icons.arrow_upward : Icons.arrow_downward,
                            size: 16,
                            color: isGain ? Colors.red : Colors.green,
                          ),
                          Text(
                            '${weightChange.abs().toStringAsFixed(1)} kg',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: isGain ? Colors.red : Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'BMI',
                    stats['currentBMI'] != null
                        ? stats['currentBMI'].toStringAsFixed(1)
                        : 'N/A',
                    '',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(unit,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildWeightChart(HealthDiaryProvider provider) {
    final weightData = provider.getWeightChartData();

    if (weightData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Weight Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles:
                          SideTitles(showTitles: true, reservedSize: 40),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: weightData,
                      isCurved: true,
                      color: Colors.orange,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightLogCard(BuildContext context, WeightLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: log.calculatedBMI != null
              ? Color(log.bmiCategoryColor)
              : Colors.grey,
          child:
              const Icon(Icons.monitor_weight, color: Colors.white, size: 20),
        ),
        title: Text(
          '${log.weight.toStringAsFixed(1)} kg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('MMM dd, yyyy hh:mm a').format(log.timestamp)}\n'
          '${log.calculatedBMI != null ? 'BMI: ${log.calculatedBMI!.toStringAsFixed(1)} • ${log.bmiCategory}' : 'No BMI data'}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteWeightLog(context, log.id),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showAddWeightDialog(BuildContext context, String? userId) {
    if (userId == null) return;

    final weightController = TextEditingController();
    final heightController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Weight Entry'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: weightController,
                decoration: const InputDecoration(labelText: 'Weight (kg)'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: heightController,
                decoration:
                    const InputDecoration(labelText: 'Height (cm) - optional'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: notesController,
                decoration:
                    const InputDecoration(labelText: 'Notes (optional)'),
                maxLines: 2,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final weight = double.tryParse(weightController.text);
              final height = heightController.text.isEmpty
                  ? null
                  : double.tryParse(heightController.text);

              if (weight == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Please enter a valid weight')),
                );
                return;
              }

              final log = WeightLog.withBMI(
                id: '',
                userId: userId,
                weight: weight,
                height: height,
                timestamp: DateTime.now(),
                notes:
                    notesController.text.isEmpty ? null : notesController.text,
                createdAt: DateTime.now(),
              );

              await Provider.of<HealthDiaryProvider>(context, listen: false)
                  .addWeightLog(log);

              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Weight entry added')),
              );
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _deleteWeightLog(BuildContext context, String logId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<HealthDiaryProvider>(context, listen: false)
                  .deleteWeightLog(logId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ============ MOOD TAB ============

class _MoodTab extends StatelessWidget {
  final String? userId;

  const _MoodTab({required this.userId});

  @override
  Widget build(BuildContext context) {
    return Consumer<HealthDiaryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Statistics Card
              _buildMoodStatisticsCard(provider.moodStats),
              const SizedBox(height: 16),

              // Chart
              if (provider.moodLogs.isNotEmpty) ...[
                _buildMoodChart(provider),
                const SizedBox(height: 16),
              ],

              // Recent Entries
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Entries',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    onPressed: () => _showAddMoodDialog(context, userId),
                    icon: const Icon(Icons.add),
                    label: const Text('Add'),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              if (provider.moodLogs.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Text('No mood entries yet'),
                  ),
                )
              else
                ...provider.moodLogs
                    .take(10)
                    .map((log) => _buildMoodLogCard(context, log)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMoodStatisticsCard(Map<String, dynamic> stats) {
    if (stats.isEmpty || stats['count'] == 0) {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Statistics',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Most Common',
                    stats['mostCommonMood'] ?? 'N/A',
                    '',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Avg Energy',
                    '${stats['avgEnergyLevel']?.toStringAsFixed(1) ?? 0}/5',
                    '',
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Positive',
                    '${stats['positiveMoodCount'] ?? 0}',
                    'moods',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 2),
              Text(unit,
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildMoodChart(HealthDiaryProvider provider) {
    final energyData = provider.getEnergyLevelChartData();

    if (energyData.isEmpty) return const SizedBox.shrink();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Energy Level Trend',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        interval: 1,
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles:
                        AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  minY: 0,
                  maxY: 6,
                  lineBarsData: [
                    LineChartBarData(
                      spots: energyData,
                      isCurved: true,
                      color: Colors.teal,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodLogCard(BuildContext context, MoodLog log) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Color(log.moodColor),
          child: Text(
            log.moodEmoji,
            style: const TextStyle(fontSize: 24),
          ),
        ),
        title: Text(
          MoodLog.getMoodDisplay(log.mood),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${DateFormat('MMM dd, yyyy hh:mm a').format(log.timestamp)}\n'
          'Energy: ${log.energyLevelDescription}',
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete, color: Colors.red),
          onPressed: () => _deleteMoodLog(context, log.id),
        ),
        isThreeLine: true,
      ),
    );
  }

  void _showAddMoodDialog(BuildContext context, String? userId) {
    if (userId == null) return;

    String selectedMood = 'happy';
    int energyLevel = 3;
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Mood Entry'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: selectedMood,
                  decoration: const InputDecoration(labelText: 'Mood'),
                  items: MoodLog.moodOptions
                      .map((mood) => DropdownMenuItem(
                            value: mood,
                            child: Row(
                              children: [
                                Text(MoodLog.getMoodDisplay(mood)),
                                const SizedBox(width: 8),
                                Text(
                                  MoodLog(
                                    id: '',
                                    userId: '',
                                    mood: mood,
                                    energyLevel: 3,
                                    timestamp: DateTime.now(),
                                    createdAt: DateTime.now(),
                                  ).moodEmoji,
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ],
                            ),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedMood = value!);
                  },
                ),
                const SizedBox(height: 16),
                const Text('Energy Level'),
                Slider(
                  value: energyLevel.toDouble(),
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: '$energyLevel',
                  onChanged: (value) {
                    setState(() => energyLevel = value.toInt());
                  },
                ),
                TextField(
                  controller: notesController,
                  decoration:
                      const InputDecoration(labelText: 'Notes (optional)'),
                  maxLines: 3,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final log = MoodLog(
                  id: '',
                  userId: userId,
                  mood: selectedMood,
                  energyLevel: energyLevel,
                  timestamp: DateTime.now(),
                  notes: notesController.text.isEmpty
                      ? null
                      : notesController.text,
                  createdAt: DateTime.now(),
                );

                await Provider.of<HealthDiaryProvider>(context, listen: false)
                    .addMoodLog(log);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Mood entry added')),
                );
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteMoodLog(BuildContext context, String logId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Entry'),
        content: const Text('Are you sure you want to delete this entry?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await Provider.of<HealthDiaryProvider>(context, listen: false)
                  .deleteMoodLog(logId);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
