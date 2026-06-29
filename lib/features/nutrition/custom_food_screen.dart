import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/models/food_item.dart';
import 'package:nutri_tracker/repositories/nutrition_repository.dart';

class CustomFoodScreen extends StatefulWidget {
  const CustomFoodScreen({super.key});

  @override
  State<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends State<CustomFoodScreen> {
  final _repository = NutritionRepository();
  final _name = TextEditingController();
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  FoodItem? _editing;

  @override
  void dispose() {
    _name.dispose();
    _calories.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Custom foods')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _editing == null ? 'Add custom food' : 'Edit custom food',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  TextField(
                    controller: _name,
                    decoration: const InputDecoration(labelText: 'Name'),
                  ),
                  TextField(
                    controller: _calories,
                    decoration:
                        const InputDecoration(labelText: 'Calories / 100g'),
                    keyboardType: TextInputType.number,
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _protein,
                          decoration:
                              const InputDecoration(labelText: 'Protein'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _carbs,
                          decoration: const InputDecoration(labelText: 'Carbs'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _fat,
                          decoration: const InputDecoration(labelText: 'Fat'),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => _save(uid),
                    icon: const Icon(Icons.save_outlined),
                    label: Text(_editing == null ? 'Save food' : 'Update food'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<FoodItem>>(
            stream: _repository.watchCustomFoods(uid),
            builder: (context, snapshot) {
              final foods = snapshot.data ?? const <FoodItem>[];
              if (foods.isEmpty) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text('No custom foods yet.'),
                  ),
                );
              }
              return Card(
                child: Column(
                  children: [
                    for (final food in foods)
                      ListTile(
                        title: Text(food.name),
                        subtitle:
                            Text('${food.caloriesPer100g.round()} kcal / 100g'),
                        onTap: () => _edit(food),
                        trailing: IconButton(
                          tooltip: 'Delete custom food',
                          icon: const Icon(Icons.delete_outline),
                          onPressed: () =>
                              _repository.deleteCustomFood(uid, food.id),
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _save(String uid) async {
    final name = _name.text.trim();
    final calories = double.tryParse(_calories.text.trim());
    if (name.isEmpty || calories == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add a food name and calories.')),
      );
      return;
    }
    await _repository.saveCustomFood(
      uid,
      FoodItem(
        id: _editing?.id ?? '',
        uid: uid,
        name: name,
        caloriesPer100g: calories,
        proteinPer100g: double.tryParse(_protein.text.trim()) ?? 0,
        carbsPer100g: double.tryParse(_carbs.text.trim()) ?? 0,
        fatPer100g: double.tryParse(_fat.text.trim()) ?? 0,
        isCustom: true,
      ),
    );
    _clear();
  }

  void _edit(FoodItem food) {
    setState(() {
      _editing = food;
      _name.text = food.name;
      _calories.text = food.caloriesPer100g.toStringAsFixed(0);
      _protein.text = food.proteinPer100g.toStringAsFixed(1);
      _carbs.text = food.carbsPer100g.toStringAsFixed(1);
      _fat.text = food.fatPer100g.toStringAsFixed(1);
    });
  }

  void _clear() {
    setState(() => _editing = null);
    _name.clear();
    _calories.clear();
    _protein.clear();
    _carbs.clear();
    _fat.clear();
  }
}
