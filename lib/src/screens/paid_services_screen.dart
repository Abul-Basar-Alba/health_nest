import 'package:flutter/material.dart';

class PaidServicesScreen extends StatelessWidget {
  const PaidServicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Premium Services'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero section with an image
            Container(
              height: 250,
              width: double.infinity,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/premium_hero.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                color: Colors.black.withOpacity(0.4),
                child: const Center(
                  child: Text(
                    'Unlock Your Full Potential',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Go Pro with Our Exclusive Plans',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureList(context),
                  const SizedBox(height: 32),
                  _buildPlanCard(
                    context,
                    title: 'Monthly Plan',
                    price: '\$9.99 / month',
                    buttonText: 'Start 7-Day Free Trial',
                  ),
                  const SizedBox(height: 16),
                  _buildPlanCard(
                    context,
                    title: 'Yearly Plan (Best Value)',
                    price: '\$79.99 / year',
                    buttonText: 'Go Pro Now',
                    isBestValue: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureList(BuildContext context) {
    return Column(
      children: [
        _buildFeatureItem(
            context, 'Advanced AI Recommendations', Icons.psychology_rounded),
        _buildFeatureItem(
            context, 'Personalized Meal Plans', Icons.fastfood_rounded),
        _buildFeatureItem(
            context, 'Custom Workout Routines', Icons.fitness_center_rounded),
        _buildFeatureItem(
            context, 'Detailed Progress Reports', Icons.bar_chart_rounded),
        _buildFeatureItem(
            context, 'Access to Expert Coaches', Icons.school_rounded),
      ],
    );
  }

  Widget _buildFeatureItem(BuildContext context, String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.green, size: 30),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(BuildContext context,
      {required String title,
      required String price,
      required String buttonText,
      bool isBestValue = false}) {
    return Card(
      elevation: isBestValue ? 8 : 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: isBestValue
            ? const BorderSide(color: Colors.amber, width: 3)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isBestValue)
              Align(
                alignment: Alignment.topRight,
                child: Chip(
                  label: const Text('BEST VALUE'),
                  backgroundColor: Colors.amber,
                  labelStyle: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              price,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.green[700],
                  ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Starting subscription: $title')),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isBestValue ? Colors.green[800] : Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(buttonText),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
