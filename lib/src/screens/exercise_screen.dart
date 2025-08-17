import 'package:flutter/material.dart';
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

  @override
  void initState() {
    super.initState();
    Pedometer.stepCountStream.listen((event) async {
      if (!mounted) return;
      setState(() {
        _stepCount = event.steps;
      });
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final firestoreService = FirestoreService();
      await firestoreService.addHistory(userProvider.user!.id, {
        'steps': event.steps,
        'timestamp': DateTime.now().toIso8601String(),
      });
    }).onError((error) {
      debugPrint('Pedometer error: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Step Counter')),
      body: Center(
        child: Text(
          'Steps: $_stepCount',
          style: const TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
