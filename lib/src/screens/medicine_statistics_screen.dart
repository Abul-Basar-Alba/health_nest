// lib/src/screens/medicine_statistics_screen.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../services/medicine_reminder_service.dart';

class MedicineStatisticsScreen extends StatefulWidget {
  const MedicineStatisticsScreen({super.key});

  @override
  State<MedicineStatisticsScreen> createState() =>
      _MedicineStatisticsScreenState();
}

class _MedicineStatisticsScreenState extends State<MedicineStatisticsScreen> {
  int _selectedDays = 30;
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => _isLoading = true);
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final service = MedicineReminderService();
        final stats =
            await service.getDetailedStatistics(userId, _selectedDays).timeout(
          const Duration(seconds: 10),
          onTimeout: () {
            // Return empty stats on timeout
            return {
              'totalDoses': 0,
              'takenDoses': 0,
              'missedDoses': 0,
              'activeMedicines': 0,
              'medicineStats': [],
              'recentLogs': [],
            };
          },
        );
        if (mounted) {
          setState(() {
            _stats = stats;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      print('Error loading statistics: $e');
      if (mounted) {
        setState(() {
          _stats = {
            'totalDoses': 0,
            'takenDoses': 0,
            'missedDoses': 0,
            'activeMedicines': 0,
            'medicineStats': [],
            'recentLogs': [],
          };
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Medicine Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTimeRangeSelector(),
                  const SizedBox(height: 20),
                  _buildAdherenceCard(_calculateAdherenceRate()),
                  const SizedBox(height: 16),
                  _buildStatsGrid(),
                  const SizedBox(height: 16),
                  _buildMedicineWiseStats(),
                  const SizedBox(height: 16),
                  _buildRecentHistory(),
                ],
              ),
            ),
    );
  }

  // Calculate real-time adherence from actual statistics data
  double _calculateAdherenceRate() {
    if (_stats == null) return 0.0;

    final totalDoses = _stats!['totalDoses'] as int;
    final takenDoses = _stats!['takenDoses'] as int;

    if (totalDoses == 0) return 0.0;

    return (takenDoses / totalDoses * 100);
  }

  Widget _buildTimeRangeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTimeRangeButton('7 Days', 7),
          _buildTimeRangeButton('30 Days', 30),
          _buildTimeRangeButton('90 Days', 90),
        ],
      ),
    );
  }

  Widget _buildTimeRangeButton(String label, int days) {
    final isSelected = _selectedDays == days;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedDays = days);
          _loadStatistics();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF009688) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdherenceCard(double adherence) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF009688), Color(0xFF00BFA5)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF009688).withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Overall Adherence',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            '${adherence.toStringAsFixed(1)}%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 48,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: adherence / 100,
            backgroundColor: Colors.white24,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
          ),
          const SizedBox(height: 12),
          Text(
            _getAdherenceMessage(adherence),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _getAdherenceMessage(double adherence) {
    if (adherence >= 90) return 'Excellent! Keep it up! 🎉';
    if (adherence >= 75) return 'Great job! Stay consistent! 👍';
    if (adherence >= 60) return 'Good progress! Try to improve! 💪';
    return 'Need improvement. Set reminders! ⏰';
  }

  Widget _buildStatsGrid() {
    if (_stats == null) return const SizedBox();

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          'Total Doses',
          _stats!['totalDoses'].toString(),
          Icons.medication,
          Colors.blue,
        ),
        _buildStatCard(
          'Taken',
          _stats!['takenDoses'].toString(),
          Icons.check_circle,
          Colors.green,
        ),
        _buildStatCard(
          'Missed',
          _stats!['missedDoses'].toString(),
          Icons.cancel,
          Colors.red,
        ),
        _buildStatCard(
          'Active Medicines',
          _stats!['activeMedicines'].toString(),
          Icons.medical_services,
          const Color(0xFF009688),
        ),
      ],
    );
  }

  Widget _buildStatCard(
      String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 6),
          Flexible(
            child: Text(
              value,
              style: TextStyle(
                color: color,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineWiseStats() {
    if (_stats == null || (_stats!['medicineStats'] as List).isEmpty) {
      return const SizedBox();
    }

    final medicineStats = _stats!['medicineStats'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Medicine-wise Adherence',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: medicineStats.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final stat = medicineStats[index];
              final adherence =
                  (stat['taken'] / stat['total'] * 100).toStringAsFixed(1);

              return ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF009688).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Color(0xFF009688),
                  ),
                ),
                title: Text(
                  stat['medicineName'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text('${stat['taken']}/${stat['total']} doses taken'),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getAdherenceColor(double.parse(adherence)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '$adherence%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getAdherenceColor(double adherence) {
    if (adherence >= 90) return Colors.green;
    if (adherence >= 75) return const Color(0xFF009688);
    if (adherence >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildRecentHistory() {
    if (_stats == null || (_stats!['recentLogs'] as List).isEmpty) {
      return const SizedBox();
    }

    final recentLogs = _stats!['recentLogs'] as List;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent History',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: recentLogs.length > 10 ? 10 : recentLogs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final log = recentLogs[index];
              final status = log['status'] as String;

              Color statusColor;
              IconData statusIcon;

              switch (status) {
                case 'taken':
                  statusColor = Colors.green;
                  statusIcon = Icons.check_circle;
                  break;
                case 'missed':
                  statusColor = Colors.red;
                  statusIcon = Icons.cancel;
                  break;
                default:
                  statusColor = Colors.grey;
                  statusIcon = Icons.help;
              }

              final scheduledTime =
                  (log['scheduledTime'] as Timestamp).toDate();
              final takenTime = log['takenTime'] != null
                  ? (log['takenTime'] as Timestamp).toDate()
                  : null;

              return ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Icon(statusIcon, color: statusColor, size: 32),
                title: Text(
                  log['medicineName'],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        'Scheduled: ${DateFormat('MMM d, h:mm a').format(scheduledTime)}'),
                    if (takenTime != null)
                      Text(
                          'Taken: ${DateFormat('MMM d, h:mm a').format(takenTime)}'),
                  ],
                ),
                trailing: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    status.toUpperCase(),
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
