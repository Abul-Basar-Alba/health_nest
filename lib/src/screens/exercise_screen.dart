import 'package:flutter/material.dart';
import 'package:health_nest/src/providers/user_provider.dart';
import 'package:health_nest/src/services/firestore_service.dart';
import 'package:pedometer/pedometer.dart';
import 'package:provider/provider.dart';
import '../providers/user_provider.dart';
import '../services/firestore_service.dart';

class ExerciseScreen extends StatefulWidget {
  const ExerciseScreen({super.key});

  @override
  ExerciseScreenState createState() => ExerciseScreenState();
}

class ExerciseScreenState extends State<ExerciseScreen> {
  int _stepCount = 0;
  String _status = 'Not initialized';

  @override
  void initState() {
    super.initState();
    Pedometer.stepCountStream.listen(
      (event) async {
        if (!mounted) return;
        setState(() {
          _stepCount = event.steps;
          _status = 'Tracking...';
        });
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        final firestoreService = FirestoreService();
        await firestoreService.addHistory(userProvider.user!.id, {
          'steps': event.steps,
          'timestamp': DateTime.now().toIso8601String(),
        });
      },
      onError: (error) {
        if (!mounted) return;
        setState(() {
          _status = 'Error: $error';
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step Counter')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Steps: $_stepCount',
              style: const TextStyle(fontSize: 24),
            ),
            const SizedBox(height: 10),
            Text(_status),
          ],
        ),
      ),
    );
  }
}
