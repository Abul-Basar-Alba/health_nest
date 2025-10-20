// lib/src/screens/calculator_screen.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/calculator_utils.dart';
import '../utils/validators.dart';
import '../providers/history_provider.dart';
import '../providers/user_provider.dart';
import '../models/history_model.dart';
import '../routes/app_routes.dart'; // Add this import
import '../widgets/premium_lock_widget.dart';
import '../services/freemium_service.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  String? _selectedActivityLevel;
  bool _isMale = true;
  double _bmiResult = 0.0;
  double _dailyCalories = 0.0;
  Map<String, double> _macros = {};
  double _waterNeeds = 0.0;
  String _vitaminRecs = '';
  bool _showResult = false;

  final Map<String, double> _activityLevels = {
    'Sedentary': 1.2,
    'Lightly Active': 1.375,
    'Moderately Active': 1.55,
    'Very Active': 1.725,
    'Extremely Active': 1.9,
  };

  @override
  void dispose() {
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _calculateHealthMetrics() async {
    if (_formKey.currentState!.validate()) {
      // Check freemium usage limits
      final canUse = await FreemiumService.canUseFeature('calculator_uses');

      if (!canUse['canUse']) {
        // Show usage limit dialog
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: Row(
              children: [
                Icon(Icons.lock, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Text('Daily Limit Reached'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.calculate, size: 64, color: Colors.orange[600]),
                const SizedBox(height: 16),
                Text(
                  'You\'ve used all ${canUse['limit']} calculator uses for today!',
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Upgrade to Premium for unlimited calculations.',
                  style: TextStyle(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                // Usage summary
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Today\'s Usage:',
                          style: TextStyle(fontWeight: FontWeight.w600)),
                      UsageLimitBadge(
                        feature: 'calculator',
                        used: canUse['usage'],
                        limit: canUse['limit'],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Maybe Later'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(context, '/premium-services');
                },
                icon: const Icon(Icons.diamond),
                label: const Text('Upgrade Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber[600],
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
        return;
      }

      final age = int.parse(_ageController.text);
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);
      final activityMultiplier = _activityLevels[_selectedActivityLevel]!;

      setState(() {
        _bmiResult =
            CalculatorUtils.calculateBMI(weight: weight, height: height);
        _dailyCalories = CalculatorUtils.calculateDailyCalories(
          age: age,
          weight: weight,
          height: height,
          activityMultiplier: activityMultiplier,
          isMale: _isMale,
        );
        _macros = CalculatorUtils.calculateMacronutrients(_dailyCalories);
        _waterNeeds = CalculatorUtils.calculateWaterNeeds(weight);
        _vitaminRecs = CalculatorUtils.getVitaminRecommendations(age, _isMale);
        _showResult = true;
      });

      // Increment usage after successful calculation
      await FreemiumService.incrementUsage('calculator_uses');

      _saveCalculationToHistory();
    }
  }

  void _saveCalculationToHistory() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final historyProvider =
        Provider.of<HistoryProvider>(context, listen: false);

    if (userProvider.user != null) {
      final newEntry = HistoryModel(
        id: '', // Firestore will generate a unique ID
        timestamp: Timestamp.now(),
        type: 'calculation', // Set the type of history
        data: {
          'bmi': _bmiResult,
          'daily_calories': _dailyCalories,
          'protein': _macros['protein'],
          'fat': _macros['fat'],
          'carbohydrates': _macros['carbohydrates'],
          'water_needs': _waterNeeds,
        },
      );
      historyProvider.addHistoryEntry(userProvider.user!.id, newEntry);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Health Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your Health Data',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _ageController,
                          decoration: const InputDecoration(
                            labelText: 'Age (years)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              Validators.validateNumber(value, 'Age'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          decoration: const InputDecoration(
                            labelText: 'Weight (kg)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              Validators.validateNumber(value, 'Weight'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          decoration: const InputDecoration(
                            labelText: 'Height (cm)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) =>
                              Validators.validateNumber(value, 'Height'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Activity Level',
                      border: OutlineInputBorder(),
                    ),
                    initialValue: _selectedActivityLevel,
                    items: _activityLevels.keys.map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedActivityLevel = newValue;
                      });
                    },
                    validator: (value) => value == null
                        ? 'Please select an activity level.'
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildGenderToggle(
                          label: 'Male',
                          isSelected: _isMale,
                          onTap: () => setState(() => _isMale = true)),
                      const SizedBox(width: 16),
                      _buildGenderToggle(
                          label: 'Female',
                          isSelected: !_isMale,
                          onTap: () => setState(() => _isMale = false)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _calculateHealthMetrics,
                child: const Text('Calculate'),
              ),
            ),

            // Usage indicator for free users
            const SizedBox(height: 8),
            FutureBuilder<Map<String, dynamic>>(
              future: FreemiumService.canUseFeature('calculator_uses'),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const SizedBox.shrink();

                final data = snapshot.data!;
                final isPremium = data['isPremium'] as bool;

                if (isPremium) {
                  return Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.amber[100],
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.amber[300]!),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const PremiumBadge(showText: false, size: 14),
                        const SizedBox(width: 6),
                        Text(
                          'Unlimited calculations',
                          style: TextStyle(
                            color: Colors.amber[800],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.info_outline,
                          size: 14, color: Colors.blue[600]),
                      const SizedBox(width: 6),
                      Text(
                        'Daily uses: ${data['usage']}/${data['limit']}',
                        style: TextStyle(
                          color: Colors.blue[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (data['usage'] >= data['limit'] - 3) ...[
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () =>
                              Navigator.pushNamed(context, '/premium-services'),
                          child: Text(
                            'Upgrade',
                            style: TextStyle(
                              color: Colors.green[600],
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
            if (_showResult) ...[
              const SizedBox(height: 32),
              _buildResultCard(
                context,
                title: 'Your BMI & Daily Calories',
                children: [
                  _buildResultRow(
                    label: 'BMI',
                    value: _bmiResult.toStringAsFixed(2),
                    unit: _getBmiCategory(_bmiResult),
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  _buildResultRow(
                    label: 'Daily Calories',
                    value: _dailyCalories.toStringAsFixed(0),
                    unit: 'kcal',
                    color: Colors.orange,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                context,
                title: 'Nutritional Breakdown',
                children: [
                  _buildResultRow(
                    label: 'Protein',
                    value: _macros['protein']!.toStringAsFixed(0),
                    unit: 'grams',
                    color: Colors.green,
                  ),
                  _buildResultRow(
                    label: 'Fat',
                    value: _macros['fat']!.toStringAsFixed(0),
                    unit: 'grams',
                    color: Colors.redAccent,
                  ),
                  _buildResultRow(
                    label: 'Carbohydrates',
                    value: _macros['carbohydrates']!.toStringAsFixed(0),
                    unit: 'grams',
                    color: Colors.amber,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildResultCard(
                context,
                title: 'Hydration & Vitamins',
                children: [
                  _buildResultRow(
                    label: 'Water',
                    value: _waterNeeds.toStringAsFixed(2),
                    unit: 'liters',
                    color: Colors.blue,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Vitamin Recommendations:',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _vitaminRecs,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),

              // Add a section with action buttons after the results
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.recommendations);
                      },
                      icon: const Icon(Icons.analytics_rounded),
                      label: const Text('Recommendations'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(context, AppRoutes.nutrition);
                      },
                      icon: const Icon(Icons.restaurant_menu_rounded),
                      label: const Text('Nutrition Tips'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildGenderToggle(
      {required String label,
      required bool isSelected,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.grey.shade400,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) return 'Underweight';
    if (bmi >= 18.5 && bmi <= 24.9) return 'Normal weight';
    if (bmi >= 25 && bmi <= 29.9) return 'Overweight';
    if (bmi >= 30) return 'Obesity';
    return '';
  }

  Widget _buildResultCard(BuildContext context,
      {required String title, required List<Widget> children}) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const Divider(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildResultRow({
    required String label,
    required String value,
    required String unit,
    required Color color,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
          ),
          Text(
            '$value $unit',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}
