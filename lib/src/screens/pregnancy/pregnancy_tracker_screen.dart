import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/symptom_log_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/pregnancy_provider.dart';
import '../../routes/app_routes.dart';
import '../../services/pregnancy_calculator.dart';
import 'contraction_timer_screen.dart';
import 'kick_counter_screen.dart';
import 'week_details_screen.dart';

class PregnancyTrackerScreen extends StatefulWidget {
  const PregnancyTrackerScreen({super.key});

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPregnancy();
    });
  }

  Future<void> _loadPregnancy() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final pregnancyProvider =
        Provider.of<PregnancyProvider>(context, listen: false);

    if (authProvider.user != null) {
      await pregnancyProvider.loadActivePregnancy(authProvider.user!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC), // Cream background
      appBar: AppBar(
        title: Consumer<PregnancyProvider>(
          builder: (context, provider, _) => Text(
            provider.isBangla ? 'গর্ভাবস্থা ট্র্যাকার' : 'Pregnancy Tracker',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color(0xFFFFB6C1), // Soft pink
        elevation: 0,
        actions: [
          Consumer<PregnancyProvider>(
            builder: (context, provider, _) => IconButton(
              icon: const Icon(Icons.language),
              tooltip: provider.isBangla ? 'English' : 'বাংলা',
              onPressed: () => provider.toggleLanguage(),
            ),
          ),
          Consumer<PregnancyProvider>(
            builder: (context, provider, _) {
              if (!provider.hasActivePregnancy) return const SizedBox.shrink();

              return PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (value) {
                  if (value == 'reset') {
                    _showResetConfirmation(context, provider);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'reset',
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.refresh, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          provider.isBangla ? 'রিসেট করুন' : 'Reset Pregnancy',
                          style: const TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: Consumer<PregnancyProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!provider.hasActivePregnancy) {
            return _buildNoPregnancyView(provider);
          }

          return _buildPregnancyView(provider);
        },
      ),
    );
  }

  Widget _buildNoPregnancyView(PregnancyProvider provider) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.pregnant_woman,
              size: 120,
              color: const Color(0xFFFFB6C1).withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              provider.isBangla
                  ? 'আপনার গর্ভাবস্থা ট্র্যাক করা শুরু করুন'
                  : 'Start tracking your pregnancy',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              provider.isBangla
                  ? 'আপনার শিশুর বিকাশ পর্যবেক্ষণ করুন, লক্ষণ লগ করুন এবং আরও অনেক কিছু'
                  : 'Monitor baby development, log symptoms and more',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => _showCreatePregnancyDialog(provider),
              icon: const Icon(Icons.add),
              label: Text(
                provider.isBangla ? 'গর্ভাবস্থা যুক্ত করুন' : 'Add Pregnancy',
                style: const TextStyle(fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB6C1),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyView(PregnancyProvider provider) {
    final pregnancy = provider.activePregnancy!;
    final week = pregnancy.getCurrentWeek();
    final weekData = provider.getCurrentWeekData();
    final daysRemaining = pregnancy.getDaysRemaining();
    final progress = pregnancy.getProgressPercentage();

    return RefreshIndicator(
      onRefresh: _loadPregnancy,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          children: <Widget>[
            // Header card with week info
            _buildHeaderCard(
                provider, pregnancy, week, daysRemaining, progress),

            const SizedBox(height: 16),

            // Current week development
            if (weekData != null) _buildWeekDevelopmentCard(provider, weekData),

            const SizedBox(height: 16),

            // Features grid
            _buildFeaturesGrid(provider),

            const SizedBox(height: 16),

            // Recent activities
            _buildRecentActivities(provider),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard(
    PregnancyProvider provider,
    pregnancy,
    int week,
    int daysRemaining,
    double progress,
  ) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFF8BA7),
            Color(0xFFC8A4E0)
          ], // Darker pink to purple
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      provider.isBangla
                          ? pregnancy.getTrimesterNameBN()
                          : pregnancy.getTrimesterNameEN(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.isBangla ? 'সপ্তাহ $week' : 'Week $week',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 3,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      provider.isBangla
                          ? PregnancyCalculator.formatWeeksAndDaysBN(
                              pregnancy.lastPeriodDate)
                          : PregnancyCalculator.formatWeeksAndDaysEN(
                              pregnancy.lastPeriodDate),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black26,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.pregnant_woman,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${progress.toInt()}%',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: Colors.white.withOpacity(0.3),
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
              minHeight: 8,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Text(
                provider.isBangla
                    ? '$daysRemaining দিন বাকি'
                    : '$daysRemaining days to go',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
              Text(
                pregnancy.babyName ??
                    (provider.isBangla ? 'আমার শিশু' : 'My Baby'),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeekDevelopmentCard(PregnancyProvider provider, weekData) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const WeekDetailsScreen(),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF8BA7).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.child_care,
                    color: Color(0xFFFF1493),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        provider.isBangla
                            ? 'এই সপ্তাহে আপনার শিশু'
                            : 'Your Baby This Week',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF333333),
                        ),
                      ),
                      Text(
                        provider.isBangla
                            ? weekData.sizeComparisonBN
                            : weekData.sizeComparisonEN,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF666666),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios,
                    size: 16, color: Color(0xFF999999)),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              provider.isBangla
                  ? '${weekData.lengthCm} দৈর্ঘ্য • ${weekData.weightGrams} ওজন'
                  : '${weekData.lengthCm} length • ${weekData.weightGrams} weight',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFFFF1493),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturesGrid(PregnancyProvider provider) {
    final features = [
      {
        'icon': Icons.info_outline,
        'titleEN': 'Week Details',
        'titleBN': 'সাপ্তাহিক বিবরণ',
        'color': const Color(0xFFFF69B4), // Darker pink
        'screen': const WeekDetailsScreen(),
      },
      {
        'icon': Icons.child_friendly,
        'titleEN': 'Kick Counter',
        'titleBN': 'কিক কাউন্টার',
        'color': const Color(0xFF66BB6A), // Darker green
        'screen': const KickCounterScreen(),
      },
      {
        'icon': Icons.timer,
        'titleEN': 'Contractions',
        'titleBN': 'সংকোচন',
        'color': const Color(0xFF9B7DCD), // Darker lavender/purple
        'screen': const ContractionTimerScreen(),
      },
      {
        'icon': Icons.local_hospital,
        'titleEN': 'Doctor Visits',
        'titleBN': 'ডাক্তার পরিদর্শন',
        'color': const Color(0xFF42A5F5), // Darker blue
        'route': AppRoutes.doctorVisits,
      },
      {
        'icon': Icons.family_restroom,
        'titleEN': 'Family Support',
        'titleBN': 'পরিবার সাপোর্ট',
        'color': const Color(0xFFFF9800), // Keep orange
        'route': AppRoutes.familySupport,
      },
      {
        'icon': Icons.photo_camera,
        'titleEN': 'Bump Photos',
        'titleBN': 'বাম্প ফটো',
        'color': const Color(0xFFAB47BC), // Darker purple
        'route': AppRoutes.bumpPhotos,
      },
      {
        'icon': Icons.baby_changing_station,
        'titleEN': 'Postpartum',
        'titleBN': 'প্রসবোত্তর',
        'color': const Color(0xFFE91E63), // Keep deep pink
        'route': AppRoutes.postpartumTracker,
      },
      {
        'icon': Icons.volume_up,
        'titleEN': 'Voice Settings',
        'titleBN': 'ভয়েস সেটিংস',
        'color': const Color(0xFF009688), // Keep teal
        'route': AppRoutes.voiceSettings,
      },
      {
        'icon': Icons.picture_as_pdf,
        'titleEN': 'PDF Report',
        'titleBN': 'পিডিএফ রিপোর্ট',
        'color': const Color(0xFFF44336), // Keep red
        'route': AppRoutes.pregnancyReport,
      },
      {
        'icon': Icons.people,
        'titleEN': 'Community',
        'titleBN': 'কমিউনিটি',
        'color': const Color(0xFF4CAF50), // Keep green
        'route': AppRoutes.community,
      },
      {
        'icon': Icons.health_and_safety,
        'titleEN': 'Symptoms',
        'titleBN': 'লক্ষণ',
        'color': const Color(0xFFFFDAB9),
        'onTap': () => _showSymptomLogDialog(provider),
      },
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1.3,
        ),
        itemCount: features.length,
        itemBuilder: (context, index) {
          final feature = features[index];
          return InkWell(
            onTap: () {
              if (feature['route'] != null) {
                Navigator.pushNamed(context, feature['route'] as String);
              } else if (feature['screen'] != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => feature['screen'] as Widget,
                  ),
                );
              } else if (feature['onTap'] != null) {
                (feature['onTap'] as Function)();
              }
            },
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: (feature['color'] as Color).withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: (feature['color'] as Color).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    feature['icon'] as IconData,
                    size: 44,
                    color: feature['color'] as Color,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    provider.isBangla
                        ? (feature['titleBN'] as String)
                        : (feature['titleEN'] as String),
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF333333),
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRecentActivities(PregnancyProvider provider) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            provider.isBangla ? 'সাম্প্রতিক কার্যকলাপ' : 'Recent Activities',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          if (provider.kickCounts.isNotEmpty)
            _buildActivityTile(
              provider,
              Icons.child_friendly,
              provider.isBangla ? 'লাস্ট কিক কাউন্ট' : 'Last Kick Count',
              provider.isBangla
                  ? '${provider.kickCounts.first.kickCount} লাথি'
                  : '${provider.kickCounts.first.kickCount} kicks',
              const Color(0xFF98FF98),
            ),
          if (provider.contractions.isNotEmpty)
            _buildActivityTile(
              provider,
              Icons.timer,
              provider.isBangla ? 'সর্বশেষ সংকোচন' : 'Last Contraction',
              provider.isBangla
                  ? provider.contractions.first.getDurationTextBN()
                  : provider.contractions.first.getDurationText(),
              const Color(0xFFE6E6FA),
            ),
          if (provider.symptomLogs.isNotEmpty)
            _buildActivityTile(
              provider,
              Icons.health_and_safety,
              provider.isBangla ? 'সর্বশেষ লক্ষণ' : 'Last Symptom',
              provider.symptomLogs.first.symptoms.first,
              const Color(0xFFFFDAB9),
            ),
          if (provider.kickCounts.isEmpty &&
              provider.contractions.isEmpty &&
              provider.symptomLogs.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  provider.isBangla
                      ? 'কোন কার্যকলাপ নেই'
                      : 'No recent activities',
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityTile(
    PregnancyProvider provider,
    IconData icon,
    String title,
    String subtitle,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: <Widget>[
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showCreatePregnancyDialog(PregnancyProvider provider) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    DateTime selectedDate = DateTime.now();
    final babyNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(
              provider.isBangla ? 'গর্ভাবস্থা যুক্ত করুন' : 'Add Pregnancy'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                InkWell(
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate:
                          DateTime.now().subtract(const Duration(days: 280)),
                      lastDate: DateTime.now(),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.calendar_today, color: Colors.pink),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                provider.isBangla
                                    ? 'শেষ মাসিকের তারিখ'
                                    : 'Last Period Date',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: babyNameController,
                  decoration: InputDecoration(
                    labelText: provider.isBangla
                        ? 'শিশুর নাম (ঐচ্ছিক)'
                        : 'Baby Name (Optional)',
                    border: const OutlineInputBorder(),
                    prefixIcon: const Icon(Icons.child_care),
                  ),
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
                final success = await provider.createPregnancy(
                  userId: authProvider.user!.uid,
                  lastPeriodDate: selectedDate,
                  babyName: babyNameController.text.isEmpty
                      ? null
                      : babyNameController.text,
                );

                if (!mounted) return;
                Navigator.pop(context);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        provider.isBangla
                            ? 'গর্ভাবস্থা সফলভাবে যুক্ত হয়েছে'
                            : 'Pregnancy added successfully',
                      ),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFB6C1),
              ),
              child: Text(provider.isBangla ? 'যুক্ত করুন' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSymptomLogDialog(PregnancyProvider provider) {
    final selectedSymptoms = <String>[];
    String severity = 'medium';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(provider.isBangla ? 'লক্ষণ লগ করুন' : 'Log Symptoms'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  provider.isBangla
                      ? 'লক্ষণ নির্বাচন করুন:'
                      : 'Select symptoms:',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                ...List.generate(
                  provider.isBangla
                      ? SymptomLogModel.commonSymptomsBN.length
                      : SymptomLogModel.commonSymptomsEN.length,
                  (index) {
                    final symptom = provider.isBangla
                        ? SymptomLogModel.commonSymptomsBN[index]
                        : SymptomLogModel.commonSymptomsEN[index];
                    return CheckboxListTile(
                      title: Text(symptom),
                      value: selectedSymptoms.contains(symptom),
                      onChanged: (value) {
                        setState(() {
                          if (value!) {
                            selectedSymptoms.add(symptom);
                          } else {
                            selectedSymptoms.remove(symptom);
                          }
                        });
                      },
                    );
                  },
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
              onPressed: selectedSymptoms.isEmpty
                  ? null
                  : () async {
                      await provider.addSymptomLog(
                        symptoms: selectedSymptoms,
                        severity: severity,
                      );
                      if (!mounted) return;
                      Navigator.pop(context);
                    },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFFFDAB9),
              ),
              child: Text(provider.isBangla ? 'লগ করুন' : 'Log'),
            ),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmation(
      BuildContext context, PregnancyProvider provider) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            provider.isBangla ? 'গর্ভাবস্থা রিসেট করুন?' : 'Reset Pregnancy?',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                provider.isBangla
                    ? 'এই কাজটি সব গর্ভাবস্থার ডেটা মুছে ফেলবে:'
                    : 'This will delete all pregnancy data:',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 12),
              ...[
                provider.isBangla
                    ? '• গর্ভাবস্থার তথ্য'
                    : '• Pregnancy information',
                provider.isBangla ? '• লক্ষণ লগ' : '• Symptom logs',
                provider.isBangla ? '• কিক কাউন্ট' : '• Kick counts',
                provider.isBangla ? '• সংকোচন রেকর্ড' : '• Contraction records',
                provider.isBangla ? '• ডাক্তার পরিদর্শন' : '• Doctor visits',
                provider.isBangla ? '• পরিবারের সদস্য' : '• Family members',
                provider.isBangla ? '• বাম্প ফটো' : '• Bump photos',
              ].map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(item, style: const TextStyle(fontSize: 14)),
                  )),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[200]!),
                ),
                child: Row(
                  children: <Widget>[
                    const Icon(Icons.warning, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        provider.isBangla
                            ? 'এই কাজটি পূর্বাবস্থায় ফেরানো যাবে না!'
                            : 'This action cannot be undone!',
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                provider.isBangla ? 'বাতিল' : 'Cancel',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _resetPregnancy(provider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: Text(
                provider.isBangla ? 'রিসেট করুন' : 'Reset',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetPregnancy(PregnancyProvider provider) async {
    try {
      // Show loading
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    provider.isBangla ? 'রিসেট করা হচ্ছে...' : 'Resetting...',
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Delete all pregnancy data
      if (provider.activePregnancy != null) {
        await provider.deletePregnancy(provider.activePregnancy!.id);
      }

      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.isBangla
                  ? 'গর্ভাবস্থা সফলভাবে রিসেট হয়েছে'
                  : 'Pregnancy reset successfully',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) {
        Navigator.pop(context);

        // Show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              provider.isBangla
                  ? 'রিসেট করতে ব্যর্থ: $e'
                  : 'Failed to reset: $e',
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
