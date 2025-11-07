import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/weekly_development_data.dart';
import '../../providers/pregnancy_provider.dart';
import '../../services/pregnancy_calculator.dart';

class WeekDetailsScreen extends StatelessWidget {
  const WeekDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8DC), // Cream background
      body: Consumer<PregnancyProvider>(
        builder: (context, provider, _) {
          if (!provider.hasActivePregnancy) {
            return const Center(child: Text('No active pregnancy'));
          }

          final pregnancy = provider.activePregnancy!;
          final currentWeek = pregnancy.getCurrentWeek();
          final weekData = WeeklyDevelopmentData.getWeekData(currentWeek);

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFFFFB6C1),
                flexibleSpace: FlexibleSpaceBar(
                  title: Text(
                    provider.isBangla
                        ? 'সপ্তাহ $currentWeek'
                        : 'Week $currentWeek',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          blurRadius: 2,
                          color: Colors.black26,
                        ),
                      ],
                    ),
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          const Color(0xFFFFB6C1),
                          const Color(0xFFE6E6FA).withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.child_care,
                        size: 80,
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Column(
                  children: <Widget>[
                    const SizedBox(height: 16),

                    // Size comparison card
                    _buildSizeCard(provider, weekData),

                    const SizedBox(height: 16),

                    // Measurements card
                    _buildMeasurementsCard(provider, weekData),

                    const SizedBox(height: 16),

                    // Developments card
                    _buildDevelopmentsCard(provider, weekData),

                    const SizedBox(height: 16),

                    // Symptoms card
                    _buildSymptomsCard(provider, weekData),

                    const SizedBox(height: 16),

                    // Tips card
                    _buildTipsCard(provider, weekData),

                    const SizedBox(height: 16),

                    // Milestone card
                    _buildMilestoneCard(provider, currentWeek),

                    const SizedBox(height: 16),

                    // Week selector
                    _buildWeekSelector(context, provider, currentWeek),

                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSizeCard(PregnancyProvider provider, weekData) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
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
        children: <Widget>[
          Text(
            provider.isBangla ? 'শিশুর আকার' : 'Baby\'s Size',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFE6E6FA).withOpacity(0.3),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: <Widget>[
                const Icon(
                  Icons.spa,
                  size: 48,
                  color: Color(0xFFFFB6C1),
                ),
                const SizedBox(height: 12),
                Text(
                  provider.isBangla
                      ? weekData.sizeComparisonBN
                      : weekData.sizeComparisonEN,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFFB6C1),
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementsCard(PregnancyProvider provider, weekData) {
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
            provider.isBangla ? 'পরিমাপ' : 'Measurements',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: <Widget>[
              Expanded(
                child: _buildMeasurementItem(
                  Icons.straighten,
                  provider.isBangla ? 'দৈর্ঘ্য' : 'Length',
                  weekData.lengthCm,
                  const Color(0xFFFFB6C1),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildMeasurementItem(
                  Icons.monitor_weight,
                  provider.isBangla ? 'ওজন' : 'Weight',
                  weekData.weightGrams,
                  const Color(0xFF98FF98),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMeasurementItem(
      IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDevelopmentsCard(PregnancyProvider provider, weekData) {
    final developments =
        provider.isBangla ? weekData.developmentsBN : weekData.developmentsEN;

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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB6C1).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.science,
                  color: Color(0xFFFFB6C1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                provider.isBangla ? 'শিশুর বিকাশ' : 'Baby\'s Development',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...developments.map<Widget>((dev) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFFB6C1),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        dev,
                        style: const TextStyle(
                          fontSize: 15,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildSymptomsCard(PregnancyProvider provider, weekData) {
    final symptoms =
        provider.isBangla ? weekData.symptomsBN : weekData.symptomsEN;

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
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDAB9).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.health_and_safety,
                  color: Color(0xFFFFDAB9),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                provider.isBangla ? 'সাধারণ লক্ষণ' : 'Common Symptoms',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: symptoms
                .map<Widget>((symptom) => Chip(
                      label: Text(symptom),
                      backgroundColor: const Color(0xFFFFDAB9).withOpacity(0.2),
                      side: BorderSide.none,
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsCard(PregnancyProvider provider, weekData) {
    final tips = provider.isBangla ? weekData.tipsBN : weekData.tipsEN;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF98FF98).withOpacity(0.2),
            const Color(0xFFE6E6FA).withOpacity(0.2),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF98FF98).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.lightbulb,
                  color: Color(0xFF98FF98),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                provider.isBangla ? 'পরামর্শ' : 'Tips for You',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...tips
              .map<Widget>((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: Color(0xFF98FF98),
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            tip,
                            style: const TextStyle(
                              fontSize: 15,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(PregnancyProvider provider, int week) {
    final milestone = provider.isBangla
        ? PregnancyCalculator.getMilestoneBN(week)
        : PregnancyCalculator.getMilestoneEN(week);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFB6C1), Color(0xFFE6E6FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFFB6C1).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.emoji_events,
            color: Colors.white,
            size: 40,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.isBangla ? 'মাইলস্টোন' : 'Milestone',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  milestone,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekSelector(
      BuildContext context, PregnancyProvider provider, int currentWeek) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            provider.isBangla ? 'অন্য সপ্তাহ দেখুন' : 'View Other Weeks',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: 42,
              itemBuilder: (context, index) {
                final week = index + 1;
                final isCurrentWeek = week == currentWeek;

                return GestureDetector(
                  onTap: () {
                    // Navigate to different week details (can be enhanced)
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.isBangla
                              ? 'সপ্তাহ $week এর বিবরণ দেখান'
                              : 'Show week $week details',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 80,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isCurrentWeek
                          ? const Color(0xFFFFB6C1)
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isCurrentWeek
                            ? const Color(0xFFFFB6C1)
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          provider.isBangla ? 'সপ্তাহ' : 'Week',
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                isCurrentWeek ? Colors.white : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$week',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color:
                                isCurrentWeek ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (isCurrentWeek)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              provider.isBangla ? 'বর্তমান' : 'Current',
                              style: const TextStyle(
                                fontSize: 10,
                                color: Color(0xFFFFB6C1),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
