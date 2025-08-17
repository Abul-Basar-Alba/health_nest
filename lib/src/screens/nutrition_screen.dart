import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../models/food_model.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  NutritionScreenState createState() => NutritionScreenState();
}

class NutritionScreenState extends State<NutritionScreen> {
  final _searchController = TextEditingController();
  List<FoodModel> _foods = [];
  List<FoodModel> _filteredFoods = [];

  @override
  void initState() {
    super.initState();
    Provider.of<FirestoreService>(context, listen: false)
        .getFoods()
        .listen((foods) {
      if (!mounted) return;
      setState(() {
        _foods = foods;
        _filteredFoods = foods;
      });
    });
    _searchController.addListener(_filterFoods);
  }

  void _filterFoods() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      _filteredFoods = _foods
          .where((food) => food.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nutrition')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Food',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _filteredFoods.length,
              itemBuilder: (context, index) {
                final food = _filteredFoods[index];
                return ListTile(
                  title: Text(food.name),
                  subtitle: Text('Calories: ${food.calories} kcal'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
