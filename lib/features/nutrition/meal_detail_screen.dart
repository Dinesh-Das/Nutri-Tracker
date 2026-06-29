import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/features/nutrition/add_meal_screen.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/repositories/nutrition_repository.dart';

class MealDetailScreen extends StatefulWidget {
  const MealDetailScreen({
    super.key,
    required this.meal,
    required this.date,
  });

  final MealEntry meal;
  final DateTime date;

  @override
  State<MealDetailScreen> createState() => _MealDetailScreenState();
}

class _MealDetailScreenState extends State<MealDetailScreen> {
  final _repository = NutritionRepository();
  late final TextEditingController _name;
  late final TextEditingController _quantity;
  late final TextEditingController _calories;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  late String _mealType;
  bool _saving = false;

  bool get _editable => widget.meal.id.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.meal.foodName);
    _quantity =
        TextEditingController(text: widget.meal.quantity.toStringAsFixed(0));
    _calories = TextEditingController(text: '${widget.meal.calories}');
    _protein =
        TextEditingController(text: widget.meal.protein.toStringAsFixed(1));
    _carbs = TextEditingController(text: widget.meal.carbs.toStringAsFixed(1));
    _fat = TextEditingController(text: widget.meal.fat.toStringAsFixed(1));
    _mealType = widget.meal.mealType;
  }

  @override
  void dispose() {
    _name.dispose();
    _quantity.dispose();
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
      appBar: AppBar(
        title: const Text('Meal details'),
        actions: [
          IconButton(
            tooltip: 'Favourite food',
            onPressed: () => _favourite(uid),
            icon: const Icon(Icons.star_border),
          ),
          IconButton(
            tooltip: 'Save as custom food',
            onPressed: () => _saveCustom(uid),
            icon: const Icon(Icons.bookmark_add_outlined),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!_editable)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'This is a legacy array meal. It can be viewed here, but edit/delete is available for newly logged meals.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Food'),
            enabled: _editable,
          ),
          DropdownButtonFormField<String>(
            value: _mealType,
            decoration: const InputDecoration(labelText: 'Meal type'),
            items: const [
              DropdownMenuItem(value: 'breakfast', child: Text('Breakfast')),
              DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
              DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
              DropdownMenuItem(value: 'snack', child: Text('Snack')),
            ],
            onChanged: _editable
                ? (value) => setState(() => _mealType = value ?? _mealType)
                : null,
          ),
          TextField(
            controller: _quantity,
            decoration:
                InputDecoration(labelText: 'Quantity (${widget.meal.unit})'),
            keyboardType: TextInputType.number,
            enabled: _editable,
          ),
          TextField(
            controller: _calories,
            decoration: const InputDecoration(labelText: 'Calories'),
            keyboardType: TextInputType.number,
            enabled: _editable,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _protein,
                  decoration: const InputDecoration(labelText: 'Protein g'),
                  keyboardType: TextInputType.number,
                  enabled: _editable,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _carbs,
                  decoration: const InputDecoration(labelText: 'Carbs g'),
                  keyboardType: TextInputType.number,
                  enabled: _editable,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: TextField(
                  controller: _fat,
                  decoration: const InputDecoration(labelText: 'Fat g'),
                  keyboardType: TextInputType.number,
                  enabled: _editable,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: !_editable || _saving ? null : () => _save(uid),
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save changes'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: !_editable || _saving ? null : () => _delete(uid),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Delete meal'),
          ),
        ],
      ),
    );
  }

  Future<void> _save(String uid) async {
    setState(() => _saving = true);
    try {
      await _repository.updateMealEntry(
        uid,
        widget.date,
        widget.meal.copyWith(
          mealType: _mealType,
          foodName: _name.text.trim(),
          calories: int.tryParse(_calories.text.trim()) ?? widget.meal.calories,
          protein: double.tryParse(_protein.text.trim()) ?? widget.meal.protein,
          carbs: double.tryParse(_carbs.text.trim()) ?? widget.meal.carbs,
          fat: double.tryParse(_fat.text.trim()) ?? widget.meal.fat,
          quantity:
              double.tryParse(_quantity.text.trim()) ?? widget.meal.quantity,
          servingDescription: '${_quantity.text.trim()} ${widget.meal.unit}',
        ),
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _delete(String uid) async {
    await _repository.deleteMealEntry(uid, widget.date, widget.meal);
    if (mounted) context.pop();
  }

  Future<void> _favourite(String uid) async {
    await _repository.setFavouriteFood(
      uid,
      foodItemFromMeal(widget.meal, uid),
      isFavourite: true,
    );
    _message('Added to favourites.');
  }

  Future<void> _saveCustom(String uid) async {
    await _repository.saveCustomFood(uid, foodItemFromMeal(widget.meal, uid));
    _message('Saved as custom food.');
  }

  void _message(String value) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(value)));
  }
}
