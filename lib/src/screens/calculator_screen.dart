import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../utils/calculator_utils.dart';
import '../providers/user_provider2.dart';

class CalculatorScreen extends StatefulWidget {
  @override
  _CalculatorScreenState createState() => _CalculatorScreenState();
}

class _CalculatorScreenState extends State<CalculatorScreen> {
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String _activityLevel = 'moderate';
  String? _bmiResult;
  int? _calorieResult;
  bool _isLoading = false;

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _calculate() async {
    setState(() => _isLoading = true);
    try {
      double weight = double.parse(_weightController.text);
      double height = double.parse(_heightController.text) / 100; // cm to meters
      int age = int.parse(_ageController.text);

      // Calculate BMI and Calories
      double bmi = calculateBMI(weight, height);
      int calories = calculateCalories(age, weight, height, _activityLevel);

      // Save to Firestore
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final firestoreService = FirestoreService();
      await firestoreService.addHistory(
        userProvider.user!.id,
        {
          'bmi': bmi,
          'calories': calories,
          'weight': weight,
          'height': height,
          'age': age,
          'activityLevel': _activityLevel,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      setState(() {
        _bmiResult = 'BMI: ${bmi.toStringAsFixed(1)}';
        _calorieResult = calories;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Health Calculator')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _weightController,
              decoration: InputDecoration(labelText: 'Weight (kg)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _heightController,
              decoration: InputDecoration(labelText: 'Height (cm)'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: _ageController,
              decoration: InputDecoration(labelText: 'Age'),
              keyboardType: TextInputType.number,
            ),
            DropdownButton<String>(
              value: _activityLevel,
              items: [
                DropdownMenuItem(value: 'sedentary', child: Text('Sedentary')),
                DropdownMenuItem(value: 'moderate', child: Text('Moderate')),
                DropdownMenuItem(value: 'active', child: Text('Active')),
              ],
              onChanged: (value) => setState(() => _activityLevel = value!),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _calculate,
                    child: Text('Calculate'),
                  ),
            if (_bmiResult != null) ...[
              SizedBox(height: 20),
              Text(_bmiResult!, style: TextStyle(fontSize: 20)),
              Text('Daily Calories: $_calorieResult kcal', style: TextStyle(fontSize: 20)),
            ],
          ],
        ),
      ),
    );
  }
}