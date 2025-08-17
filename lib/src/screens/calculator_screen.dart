import 'package:flutter/material.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/services/firestore_service.dart';
import 'package:health_nest/src/utils/calculator_utils.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';
import '../utils/calculator_utils.dart';

class CalculatorScreen extends StatefulWidget {
  const CalculatorScreen({super.key});

  @override
  CalculatorScreenState createState() => CalculatorScreenState();
}

class CalculatorScreenState extends State<CalculatorScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String _activityLevel = 'sedentary';
  double? _bmi;
  int? _calories;
  double? _protein;
  double? _waterIntake;
  String? _errorMessage;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    if (!mounted) return;
    setState(() {
      _errorMessage = null;
    });

    try {
      final weight = double.parse(_weightController.text);
      final height = double.parse(_heightController.text);
      final age = int.parse(_ageController.text);

      final bmi = calculateBMI(weight, height);
      final calories = calculateCalories(age, weight, height, _activityLevel);
      final protein = weight * 0.8; // Rough estimate (g)
      final waterIntake = weight * 0.033; // Rough estimate (liters)

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final firestoreService = FirestoreService();

      await firestoreService.addHistory(userProvider.user!.id, {
        'bmi': bmi,
        'calories': calories,
        'protein': protein,
        'waterIntake': waterIntake,
        'weight': weight,
        'height': height,
        'age': age,
        'activityLevel': _activityLevel,
        'timestamp': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      setState(() {
        _bmi = bmi;
        _calories = calories;
        _protein = protein;
        _waterIntake = waterIntake;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Invalid input: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Calculator')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              decoration: const InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heightController,
              decoration: const InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ageController,
              decoration: const InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _activityLevel,
              items: ['sedentary', 'light', 'moderate', 'active']
                  .map((level) => DropdownMenuItem(
                        value: level,
                        child: Text(level),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _activityLevel = value!;
                });
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculate,
              child: const Text('Calculate'),
            ),
            if (_errorMessage != null)
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.red),
              ),
            if (_bmi != null) Text('BMI: ${_bmi!.toStringAsFixed(1)}'),
            if (_calories != null) Text('Daily Calories: $_calories kcal'),
            if (_protein != null)
              Text('Protein: ${_protein!.toStringAsFixed(1)} g'),
            if (_waterIntake != null)
              Text('Water Intake: ${_waterIntake!.toStringAsFixed(1)} L'),
          ],
        ),
      ),
    );
  }
}
