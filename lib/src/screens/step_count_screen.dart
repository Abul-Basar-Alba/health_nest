import 'package:flutter/material.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import '../providers/step_provider.dart'; // Make sure StepProvider is defined in this file

class StepCountScreen extends StatefulWidget {
  const StepCountScreen({super.key}); // ত্রুটি ১ সমাধান

  @override
  StepCountScreenState createState() =>
      StepCountScreenState(); // ত্রুটি ২ সমাধান
}

class StepCountScreenState extends State<StepCountScreen> {
  late Stream<StepCount> _stepCountStream;
  int _steps = 0;
  double _goalProgress = 0.0;
  final int _dailyGoal = 6000; // ব্যালেন্সড লাইফের জন্য

  @override
  void initState() {
    super.initState();
    _startListening();
  }

  void _startListening() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(
      (StepCount event) {
        if (!mounted) return;
        setState(() {
          _steps = event.steps;
          _goalProgress = _steps / _dailyGoal;
          if (_goalProgress > 1.0) _goalProgress = 1.0;
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _steps = 0;
          _goalProgress = 0.0;
        });
        print("Step count error: $error");
      },
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Steps Today: $_steps', style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            LinearProgressIndicator(value: _goalProgress),
            const SizedBox(height: 10),
            Text(
                '${(_goalProgress * 100).toStringAsFixed(0)}% of $_dailyGoal Goal'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Provider.of<StepProvider>(context, listen: false)
                    .setSteps(_steps);
              },
              child: const Text('Save Steps'),
            ),
          ],
        ),
      ),
    );
  }
}
