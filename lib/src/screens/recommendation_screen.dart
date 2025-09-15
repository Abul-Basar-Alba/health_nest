import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/recommendation_provider.dart';
import '../providers/user_provider.dart';
import '../providers/history_provider.dart';

class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  RecommendationScreenState createState() => RecommendationScreenState();
}

class RecommendationScreenState extends State<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    // This is not the best place to call fetchData, as it might
    // be called before the providers are fully initialized.
    // We will call the fetch method from the build method instead.
  }

  @override
  Widget build(BuildContext context) {
    // We listen to all three providers to ensure data is available
    // before attempting to generate recommendations.
    final userProvider = Provider.of<UserProvider>(context);
    final historyProvider = Provider.of<HistoryProvider>(context);
    final recProvider = Provider.of<RecommendationProvider>(context);

    // Call the generateRecommendations method only if the data is
    // available and not already loading.
    if (!recProvider.isLoading &&
        userProvider.user != null &&
        historyProvider.history.isNotEmpty &&
        recProvider.recommendationsAreEmpty) {
      recProvider.generateRecommendations(
        user: userProvider.user!,
        history: historyProvider.history,
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Health Coach'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: _buildBody(recProvider),
    );
  }

  Widget _buildBody(RecommendationProvider recProvider) {
    if (recProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (recProvider.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            recProvider.errorMessage!,
            style: const TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    if (recProvider.healthSummary == null ||
        recProvider.healthSummary!.isEmpty) {
      // This is the case where there is no user or history data
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No user or historical data available to generate recommendations.',
            style: TextStyle(color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Personalized Recommendations',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildRecommendationCard(
            context,
            title: 'Your Health Summary',
            content: recProvider.healthSummary!,
            icon: Icons.analytics_rounded,
            color: Colors.lightGreen,
          ),
          const SizedBox(height: 20),
          Text(
            'Actionable Tips',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.green[800],
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          _buildRecommendationCard(
            context,
            title: 'Nutrition Tips',
            content: recProvider.nutritionTips!,
            icon: Icons.restaurant_menu_rounded,
            color: Colors.orange,
          ),
          const SizedBox(height: 16),
          _buildRecommendationCard(
            context,
            title: 'Exercise & Activity',
            content: recProvider.exerciseTips!,
            icon: Icons.directions_run_rounded,
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context,
      {required String title,
      required String content,
      required IconData icon,
      required Color color}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 30, color: color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: color,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.black87,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
