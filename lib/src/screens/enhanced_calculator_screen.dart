// lib/src/screens/enhanced_calculator_screen.dart

import 'package:flutter/material.dart';

import '../services/freemium_service.dart';
import '../widgets/premium_showcase_widget.dart';

class EnhancedCalculatorScreen extends StatefulWidget {
  const EnhancedCalculatorScreen({super.key});

  @override
  State<EnhancedCalculatorScreen> createState() =>
      _EnhancedCalculatorScreenState();
}

class _EnhancedCalculatorScreenState extends State<EnhancedCalculatorScreen> {
  final int _selectedIndex = 0;
  Map<String, dynamic>? _usageStatus;
  bool _isLoading = true;

  final List<CalculatorType> calculators = [
    CalculatorType(
      title: 'BMI Calculator',
      subtitle: 'Body Mass Index',
      icon: Icons.person,
      color: Colors.blue,
      isFree: true,
    ),
    CalculatorType(
      title: 'Calorie Calculator',
      subtitle: 'Daily calorie needs',
      icon: Icons.local_fire_department,
      color: Colors.orange,
      isFree: true,
    ),
    CalculatorType(
      title: 'Macro Calculator',
      subtitle: 'Protein, carbs, fats',
      icon: Icons.pie_chart,
      color: Colors.green,
      isFree: true,
    ),
    CalculatorType(
      title: 'Body Fat Calculator',
      subtitle: 'Body fat percentage',
      icon: Icons.fitness_center,
      color: Colors.purple,
      isFree: true,
    ),
    CalculatorType(
      title: 'Water Intake Calculator',
      subtitle: 'Daily water needs',
      icon: Icons.water_drop,
      color: Colors.cyan,
      isFree: true,
    ),
    CalculatorType(
      title: 'Ideal Weight Calculator',
      subtitle: 'Target weight range',
      icon: Icons.scale,
      color: Colors.teal,
      isFree: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadUsageStatus();
  }

  Future<void> _loadUsageStatus() async {
    final status = await FreemiumService.canUseFeature('calculator_uses');
    setState(() {
      _usageStatus = status;
      _isLoading = false;
    });
  }

  Future<void> _useCalculator(int index) async {
    if (_usageStatus == null) return;

    // Check if user can use calculator
    if (!_usageStatus!['canUse']) {
      _showPremiumUpgradeDialog();
      return;
    }

    // Increment usage
    final success = await FreemiumService.incrementUsage('calculator_uses');
    if (!success) {
      _showPremiumUpgradeDialog();
      return;
    }

    // Navigate to actual calculator
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => CalculatorDetailScreen(
          calculator: calculators[index],
        ),
      ),
    );

    // Reload usage status
    _loadUsageStatus();
  }

  void _showPremiumUpgradeDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: PremiumShowcaseWidget(
          feature: 'calculator_uses',
          onUpgradePressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).pushNamed('/subscription');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Calculators'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        actions: [
          if (!_isLoading &&
              _usageStatus != null &&
              !_usageStatus!['isPremium'])
            Container(
              margin: const EdgeInsets.all(8),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calculate, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    '${_usageStatus!['remaining']}/${_usageStatus!['limit']}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Usage status card
                if (_usageStatus != null && !_usageStatus!['isPremium'])
                  UsageLimitWarning(
                    feature: 'calculator_uses',
                    remaining: _usageStatus!['remaining'],
                    total: _usageStatus!['limit'],
                  ),

                // Premium status card
                if (_usageStatus != null && _usageStatus!['isPremium'])
                  Container(
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.amber.shade300, Colors.amber.shade500],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, color: Colors.white),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Premium Active - Unlimited Calculator Usage',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Calculator grid
                Expanded(
                  child: GridView.builder(
                    padding: const EdgeInsets.all(16),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.1,
                    ),
                    itemCount: calculators.length,
                    itemBuilder: (context, index) {
                      final calculator = calculators[index];
                      final canUse = _usageStatus?['canUse'] ?? false;

                      return InkWell(
                        onTap: () => _useCalculator(index),
                        child: Container(
                          decoration: BoxDecoration(
                            color: calculator.color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: calculator.color.withOpacity(0.3),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: calculator.color.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              // Main content
                              Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      calculator.icon,
                                      color: calculator.color,
                                      size: 32,
                                    ),
                                    const Spacer(),
                                    Text(
                                      calculator.title,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: calculator.color,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      calculator.subtitle,
                                      style: TextStyle(
                                        fontSize: 12,
                                        color:
                                            calculator.color.withOpacity(0.7),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Free/Premium badge
                              if (calculator.isFree)
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Text(
                                      'FREE',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),

                              // Disabled overlay
                              if (!canUse &&
                                  !(_usageStatus?['isPremium'] ?? false))
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: const Center(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            Icons.lock,
                                            color: Colors.white,
                                            size: 24,
                                          ),
                                          SizedBox(height: 4),
                                          Text(
                                            'Limit Reached',
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
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Upgrade button for free users
                if (_usageStatus != null && !_usageStatus!['isPremium'])
                  Container(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () =>
                            Navigator.of(context).pushNamed('/subscription'),
                        icon: const Icon(Icons.star),
                        label: const Text(
                            'Upgrade to Premium - Unlimited Calculators'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange.shade600,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

class CalculatorType {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isFree;

  CalculatorType({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isFree,
  });
}

class CalculatorDetailScreen extends StatelessWidget {
  final CalculatorType calculator;

  const CalculatorDetailScreen({
    super.key,
    required this.calculator,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(calculator.title),
        backgroundColor: calculator.color,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              calculator.icon,
              size: 64,
              color: calculator.color,
            ),
            const SizedBox(height: 16),
            Text(
              calculator.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              calculator.subtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            const Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'This is where the actual calculator interface would be implemented. Each calculator would have its own specific UI and logic.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
