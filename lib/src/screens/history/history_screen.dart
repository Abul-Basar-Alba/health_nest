// lib/src/screens/history/history_screen.dart

import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/activity_history_model.dart';
import '../../models/bmi_history_model.dart';
import '../../models/nutrition_history_model.dart';
import '../../services/history_service.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen>
    with SingleTickerProviderStateMixin {
  final HistoryService _historyService = HistoryService();
  late TabController _tabController;
  DateTime? _selectedDate;

  String get _userId => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
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
              const Color(0xFF667eea),
              const Color(0xFF764ba2),
              const Color(0xFFF093FB),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildAppBar(),
              _buildTabBar(),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildAllHistoryTab(),
                    _buildBMIHistoryTab(),
                    _buildActivityHistoryTab(),
                    _buildNutritionHistoryTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'My History',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (_selectedDate != null)
                  Text(
                    '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.calendar_today, color: Colors.white),
            onPressed: () => _showDatePicker(),
          ),
          if (_selectedDate != null)
            IconButton(
              icon: const Icon(Icons.clear, color: Colors.white70),
              onPressed: () {
                setState(() {
                  _selectedDate = null;
                });
              },
            ),
          IconButton(
            icon: const Icon(Icons.analytics, color: Colors.white),
            onPressed: () {
              // TODO: Show analytics
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withOpacity(0.3),
            Colors.white.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Colors.white, Color(0xFFF5F5F5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.5),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: const Color(0xFF667eea),
        unselectedLabelColor: Colors.white.withOpacity(0.9),
        labelStyle: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 13,
          letterSpacing: 0.5,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
        dividerColor: Colors.transparent,
        tabs: const [
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.dashboard_rounded, size: 16),
                SizedBox(width: 4),
                Text('All'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.monitor_weight_rounded, size: 16),
                SizedBox(width: 4),
                Text('BMI'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.fitness_center_rounded, size: 16),
                SizedBox(width: 4),
                Text('Activity'),
              ],
            ),
          ),
          Tab(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.restaurant_menu_rounded, size: 16),
                SizedBox(width: 4),
                Text('Nutrition'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllHistoryTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          _buildWeeklyStatsCard(),
          const SizedBox(height: 16),
          _buildSectionTitle('Recent Activity'),
          const SizedBox(height: 8),
          _buildBMIHistoryList(limit: 3),
          const SizedBox(height: 16),
          _buildActivityHistoryList(limit: 3),
          const SizedBox(height: 16),
          _buildNutritionHistoryList(limit: 3),
        ],
      ),
    );
  }

  Widget _buildWeeklyStatsCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _historyService.getWeeklyAnalytics(_userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator(color: Colors.white));
        }

        if (!snapshot.hasData) {
          return const SizedBox();
        }

        final analytics = snapshot.data!;

        return FadeIn(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.insights, color: Colors.amber, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'This Week',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatColumn(
                      '${analytics['totalWorkouts']}',
                      'Workouts',
                      Icons.fitness_center,
                    ),
                    _buildStatColumn(
                      '${analytics['totalMinutes']}',
                      'Minutes',
                      Icons.timer,
                    ),
                    _buildStatColumn(
                      '${analytics['averageCalories']}',
                      'Avg Cal',
                      Icons.local_fire_department,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatColumn(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 24),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildBMIHistoryTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSectionTitle('BMI Records'),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildBMIHistoryList()),
      ],
    );
  }

  Widget _buildBMIHistoryList({int? limit}) {
    return StreamBuilder<List<BMIHistoryModel>>(
      stream: _historyService.getBMIHistory(_userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState('No BMI records yet', Icons.calculate);
        }

        // Filter by selected date if any
        var records = snapshot.data!;
        if (_selectedDate != null) {
          final startOfDay = DateTime(
              _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
          final endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month,
              _selectedDate!.day, 23, 59, 59);

          records = records.where((record) {
            return record.date
                    .isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                record.date.isBefore(endOfDay.add(const Duration(seconds: 1)));
          }).toList();
        }

        if (records.isEmpty) {
          return _buildEmptyState(
              _selectedDate != null
                  ? 'No BMI records on ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'No BMI records yet',
              Icons.calculate);
        }

        final displayRecords =
            limit != null ? records.take(limit).toList() : records;

        return ListView.builder(
          shrinkWrap: limit != null,
          physics: limit != null ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayRecords.length,
          itemBuilder: (context, index) {
            final record = displayRecords[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildBMIHistoryCard(record),
            );
          },
        );
      },
    );
  }

  Widget _buildBMIHistoryCard(BMIHistoryModel record) {
    Color categoryColor = Colors.green;
    if (record.bmi < 18.5) {
      categoryColor = Colors.blue;
    } else if (record.bmi >= 25 && record.bmi < 30) {
      categoryColor = Colors.orange;
    } else if (record.bmi >= 30) {
      categoryColor = Colors.red;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.monitor_weight, color: categoryColor, size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'BMI: ${record.bmi.toStringAsFixed(1)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.category,
                  style: TextStyle(
                    color: categoryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.weight}kg • ${record.height}cm • ${record.activityLevel}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.dateFormatted,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                record.timeFormatted,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActivityHistoryTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSectionTitle('Activity Log'),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildActivityHistoryList()),
      ],
    );
  }

  Widget _buildActivityHistoryList({int? limit}) {
    return StreamBuilder<List<ActivityHistoryModel>>(
      stream: _historyService.getActivityHistory(_userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
              'No activity records yet', Icons.fitness_center);
        }

        // Filter by selected date if any
        var records = snapshot.data!;
        if (_selectedDate != null) {
          final startOfDay = DateTime(
              _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
          final endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month,
              _selectedDate!.day, 23, 59, 59);

          records = records.where((record) {
            return record.date
                    .isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                record.date.isBefore(endOfDay.add(const Duration(seconds: 1)));
          }).toList();
        }

        if (records.isEmpty) {
          return _buildEmptyState(
              _selectedDate != null
                  ? 'No activity records on ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'No activity records yet',
              Icons.fitness_center);
        }

        final displayRecords =
            limit != null ? records.take(limit).toList() : records;

        return ListView.builder(
          shrinkWrap: limit != null,
          physics: limit != null ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayRecords.length,
          itemBuilder: (context, index) {
            final record = displayRecords[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildActivityHistoryCard(record),
            );
          },
        );
      },
    );
  }

  Widget _buildActivityHistoryCard(ActivityHistoryModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              record.activityEmoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.activityLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (record.exerciseType != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    record.exerciseType!,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ],
                if (record.durationMinutes != null ||
                    record.caloriesBurned != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${record.durationMinutes ?? 0} min • ${record.caloriesBurned ?? 0} cal',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.dateFormatted,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                record.timeFormatted,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionHistoryTab() {
    return Column(
      children: [
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: _buildSectionTitle('Nutrition Log'),
        ),
        const SizedBox(height: 8),
        Expanded(child: _buildNutritionHistoryList()),
      ],
    );
  }

  Widget _buildNutritionHistoryList({int? limit}) {
    return StreamBuilder<List<NutritionHistoryModel>>(
      stream: _historyService.getNutritionHistory(_userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildEmptyState(
              'No nutrition records yet', Icons.restaurant_menu);
        }

        // Filter by selected date if any
        var records = snapshot.data!;
        if (_selectedDate != null) {
          final startOfDay = DateTime(
              _selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
          final endOfDay = DateTime(_selectedDate!.year, _selectedDate!.month,
              _selectedDate!.day, 23, 59, 59);

          records = records.where((record) {
            return record.date
                    .isAfter(startOfDay.subtract(const Duration(seconds: 1))) &&
                record.date.isBefore(endOfDay.add(const Duration(seconds: 1)));
          }).toList();
        }

        if (records.isEmpty) {
          return _buildEmptyState(
              _selectedDate != null
                  ? 'No nutrition records on ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                  : 'No nutrition records yet',
              Icons.restaurant_menu);
        }

        final displayRecords =
            limit != null ? records.take(limit).toList() : records;

        return ListView.builder(
          shrinkWrap: limit != null,
          physics: limit != null ? const NeverScrollableScrollPhysics() : null,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: displayRecords.length,
          itemBuilder: (context, index) {
            final record = displayRecords[index];
            return FadeInUp(
              delay: Duration(milliseconds: index * 100),
              child: _buildNutritionHistoryCard(record),
            );
          },
        );
      },
    );
  }

  Widget _buildNutritionHistoryCard(NutritionHistoryModel record) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              record.mealTypeEmoji,
              style: const TextStyle(fontSize: 28),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.foodName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  record.mealType.toUpperCase(),
                  style: TextStyle(
                    color: Colors.amber.withOpacity(0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${record.calories} cal',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                if (record.protein != null ||
                    record.carbs != null ||
                    record.fats != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'P: ${record.protein?.toStringAsFixed(1) ?? 0}g • C: ${record.carbs?.toStringAsFixed(1) ?? 0}g • F: ${record.fats?.toStringAsFixed(1) ?? 0}g',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.dateFormatted,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                record.timeFormatted,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.6),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white.withOpacity(0.3)),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF667eea),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }
}
