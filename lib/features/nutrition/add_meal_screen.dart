import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/food_item.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/repositories/nutrition_repository.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/barcode_service.dart';
import 'package:nutri_tracker/services/calorie_service.dart';

class AddMealScreen extends StatefulWidget {
  const AddMealScreen({
    super.key,
    this.date,
    this.initialMealType = 'snack',
  });

  final DateTime? date;
  final String initialMealType;

  @override
  State<AddMealScreen> createState() => _AddMealScreenState();
}

class _AddMealScreenState extends State<AddMealScreen> {
  final _searchController = TextEditingController();
  final _manualName = TextEditingController();
  final _manualCalories = TextEditingController();
  final _manualProtein = TextEditingController();
  final _manualCarbs = TextEditingController();
  final _manualFat = TextEditingController();
  final _repository = NutritionRepository();
  final _calorieService = CalorieService();
  String lateMealType = 'snack';
  bool _saving = false;

  DateTime get _date => widget.date ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    lateMealType = widget.initialMealType;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _manualName.dispose();
    _manualCalories.dispose();
    _manualProtein.dispose();
    _manualCarbs.dispose();
    _manualFat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add meal'),
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Search'),
              Tab(text: 'Manual'),
              Tab(text: 'Recent'),
              Tab(text: 'Saved'),
            ],
          ),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: lateMealType,
                      decoration: const InputDecoration(labelText: 'Meal'),
                      items: const [
                        DropdownMenuItem(
                            value: 'breakfast', child: Text('Breakfast')),
                        DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                        DropdownMenuItem(
                            value: 'dinner', child: Text('Dinner')),
                        DropdownMenuItem(value: 'snack', child: Text('Snack')),
                      ],
                      onChanged: (value) =>
                          setState(() => lateMealType = value ?? lateMealType),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ActionChip(
                    avatar: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Barcode'),
                    onPressed: _saving ? null : () => _scanBarcode(uid),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.document_scanner, size: 18),
                    label: const Text('Label'),
                    onPressed: _saving ? null : () => _scanLabel(uid),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.camera_alt_outlined, size: 18),
                    label: const Text('Photo'),
                    onPressed: () => context.push(
                      AppRoutes.photoMeal,
                      extra: {'date': _date, 'mealType': lateMealType},
                    ),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.auto_awesome, size: 18),
                    label: const Text('AI estimate'),
                    onPressed: () => context.push(AppRoutes.nutritionEstimator),
                  ),
                  ActionChip(
                    avatar: const Icon(Icons.add_box_outlined, size: 18),
                    label: const Text('Custom food'),
                    onPressed: () => context.push(AppRoutes.customFood),
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _SearchFoodsTab(
                    controller: _searchController,
                    calorieService: _calorieService,
                    onFoodSelected: (food) => _showQuantitySheet(
                      uid,
                      food,
                      source: 'search',
                    ),
                  ),
                  _ManualEntryTab(
                    name: _manualName,
                    calories: _manualCalories,
                    protein: _manualProtein,
                    carbs: _manualCarbs,
                    fat: _manualFat,
                    saving: _saving,
                    onSave: () => _saveManual(uid),
                  ),
                  _FoodStreamTab(
                    stream: _repository.watchRecentFoods(uid),
                    emptyText: 'Recent foods appear after you log meals.',
                    onFoodSelected: (food) => _showQuantitySheet(
                      uid,
                      food,
                      source: 'recent',
                    ),
                  ),
                  ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      _FoodStreamSection(
                        title: 'Favourites',
                        stream: _repository.watchFavouriteFoods(uid),
                        emptyText: 'Mark foods as favourite from meal details.',
                        onFoodSelected: (food) => _showQuantitySheet(
                          uid,
                          food,
                          source: 'favourite',
                        ),
                      ),
                      const SizedBox(height: 12),
                      _FoodStreamSection(
                        title: 'Custom foods',
                        stream: _repository.watchCustomFoods(uid),
                        emptyText: 'Create custom foods for homemade meals.',
                        onFoodSelected: (food) => _showQuantitySheet(
                          uid,
                          food,
                          source: 'custom',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _scanBarcode(String uid) async {
    final code = await context.push<String>(AppRoutes.barcodeScanner);
    if (code == null || code.trim().isEmpty || !mounted) return;
    setState(() => _saving = true);
    try {
      final entry = await BarcodeService().lookupBarcode(
        code,
        mealType: lateMealType,
      );
      if (!mounted) return;
      if (entry == null) {
        _showMessage('Barcode not found. Try search or manual entry.');
        return;
      }
      await _repository.addMealEntry(
        uid,
        _date,
        entry.copyWith(source: 'barcode', mealType: lateMealType),
      );
      if (mounted) context.pop();
    } catch (error) {
      _showMessage('Unable to scan barcode: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _scanLabel(String uid) async {
    final entry = await context.push<MealEntry>(
      AppRoutes.nutritionLabelScanner,
      extra: lateMealType,
    );
    if (entry == null || !mounted) return;
    await _repository.addMealEntry(
      uid,
      _date,
      entry.copyWith(source: 'label', mealType: lateMealType),
    );
    if (mounted) context.pop();
  }

  Future<void> _saveManual(String uid) async {
    final name = _manualName.text.trim();
    final calories = int.tryParse(_manualCalories.text.trim());
    if (name.isEmpty || calories == null || calories <= 0) {
      _showMessage('Add a food name and calories.');
      return;
    }
    setState(() => _saving = true);
    try {
      await _repository.addMealEntry(
        uid,
        _date,
        MealEntry(
          source: 'manual',
          mealType: lateMealType,
          foodName: name,
          calories: calories,
          protein: double.tryParse(_manualProtein.text.trim()) ?? 0,
          carbs: double.tryParse(_manualCarbs.text.trim()) ?? 0,
          fat: double.tryParse(_manualFat.text.trim()) ?? 0,
          quantity: 1,
          unit: 'serving',
          servingDescription: '1 serving',
        ),
      );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showQuantitySheet(
    String uid,
    FoodItem food, {
    required String source,
  }) {
    var quantity = food.defaultServingQuantity;
    var unit =
        {'grams', 'pieces', 'ml', 'serving'}.contains(food.defaultServingUnit)
            ? food.defaultServingUnit
            : 'grams';
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final factor = quantity / 100;
            final calories = (food.caloriesPer100g * factor).round();
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food.name,
                      style: Theme.of(context).textTheme.titleLarge),
                  if (food.brand.isNotEmpty) Text(food.brand),
                  const SizedBox(height: 12),
                  Text('Serving: ${quantity.round()} $unit'),
                  Slider(
                    value: quantity.clamp(25, 600).toDouble(),
                    min: 25,
                    max: 600,
                    divisions: 23,
                    label: '${quantity.round()} $unit',
                    onChanged: (value) => setModalState(() => quantity = value),
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'grams', label: Text('g')),
                      ButtonSegment(value: 'pieces', label: Text('pc')),
                      ButtonSegment(value: 'ml', label: Text('ml')),
                      ButtonSegment(value: 'serving', label: Text('serv')),
                    ],
                    selected: {unit},
                    onSelectionChanged: (value) =>
                        setModalState(() => unit = value.first),
                  ),
                  const SizedBox(height: 12),
                  Text('Estimated: $calories kcal'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final navigator = Navigator.of(context);
                      final rootContext = this.context;
                      await _repository.addMealEntry(
                        uid,
                        _date,
                        MealEntry(
                          source: source,
                          mealType: lateMealType,
                          foodName: food.name,
                          calories: calories,
                          protein: food.proteinPer100g * factor,
                          carbs: food.carbsPer100g * factor,
                          fat: food.fatPer100g * factor,
                          fiber: food.fiberPer100g * factor,
                          sugar: food.sugarPer100g * factor,
                          sodium: food.sodiumPer100g * factor,
                          quantity: quantity,
                          unit: unit,
                          servingDescription: '${quantity.round()} $unit',
                        ),
                      );
                      if (!mounted) return;
                      navigator.pop();
                      if (rootContext.mounted) rootContext.pop();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Log food'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}

class _SearchFoodsTab extends StatelessWidget {
  const _SearchFoodsTab({
    required this.controller,
    required this.calorieService,
    required this.onFoodSelected,
  });

  final TextEditingController controller;
  final CalorieService calorieService;
  final ValueChanged<FoodItem> onFoodSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: 'Search Indian foods',
            ),
            onChanged: (_) => (context as Element).markNeedsBuild(),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: calorieService.searchIndianFoods(controller.text),
            builder: (context, snapshot) {
              final docs = snapshot.data?.docs ?? [];
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (docs.isEmpty) {
                return const Center(child: Text('No foods found.'));
              }
              return ListView.builder(
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final food = FoodItem.fromMap(
                    docs[index].id,
                    docs[index].data(),
                  );
                  return _FoodTile(food: food, onTap: onFoodSelected);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ManualEntryTab extends StatelessWidget {
  const _ManualEntryTab({
    required this.name,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.saving,
    required this.onSave,
  });

  final TextEditingController name;
  final TextEditingController calories;
  final TextEditingController protein;
  final TextEditingController carbs;
  final TextEditingController fat;
  final bool saving;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        TextField(
          controller: name,
          decoration: const InputDecoration(labelText: 'Food name'),
          textCapitalization: TextCapitalization.words,
        ),
        TextField(
          controller: calories,
          decoration: const InputDecoration(labelText: 'Calories'),
          keyboardType: TextInputType.number,
        ),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: protein,
                decoration: const InputDecoration(labelText: 'Protein g'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: carbs,
                decoration: const InputDecoration(labelText: 'Carbs g'),
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: fat,
                decoration: const InputDecoration(labelText: 'Fat g'),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: saving ? null : onSave,
          icon: saving
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: const Text('Log manual meal'),
        ),
      ],
    );
  }
}

class _FoodStreamTab extends StatelessWidget {
  const _FoodStreamTab({
    required this.stream,
    required this.emptyText,
    required this.onFoodSelected,
  });

  final Stream<List<FoodItem>> stream;
  final String emptyText;
  final ValueChanged<FoodItem> onFoodSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _FoodStreamSection(
          title: 'Foods',
          stream: stream,
          emptyText: emptyText,
          onFoodSelected: onFoodSelected,
        ),
      ],
    );
  }
}

class _FoodStreamSection extends StatelessWidget {
  const _FoodStreamSection({
    required this.title,
    required this.stream,
    required this.emptyText,
    required this.onFoodSelected,
  });

  final String title;
  final Stream<List<FoodItem>> stream;
  final String emptyText;
  final ValueChanged<FoodItem> onFoodSelected;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<FoodItem>>(
      stream: stream,
      builder: (context, snapshot) {
        final foods = snapshot.data ?? const <FoodItem>[];
        return Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child:
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
              ),
              if (foods.isEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  child: Text(emptyText),
                ),
              for (final food in foods)
                _FoodTile(food: food, onTap: onFoodSelected),
            ],
          ),
        );
      },
    );
  }
}

class _FoodTile extends StatelessWidget {
  const _FoodTile({required this.food, required this.onTap});

  final FoodItem food;
  final ValueChanged<FoodItem> onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const CircleAvatar(child: Icon(Icons.restaurant_menu)),
      title: Text(food.name),
      subtitle: Text(
        '${food.caloriesPer100g.round()} kcal / 100g - ${food.dietType}',
      ),
      trailing: Icon(food.isFavourite ? Icons.star : Icons.chevron_right),
      onTap: () => onTap(food),
    );
  }
}

FoodItem foodItemFromMeal(MealEntry meal, String uid) {
  final factor = max(meal.quantity, 1) / 100;
  return FoodItem(
    id: '',
    uid: uid,
    name: meal.foodName,
    caloriesPer100g: meal.calories / factor,
    proteinPer100g: meal.protein / factor,
    carbsPer100g: meal.carbs / factor,
    fatPer100g: meal.fat / factor,
    fiberPer100g: meal.fiber / factor,
    sugarPer100g: meal.sugar / factor,
    sodiumPer100g: meal.sodium / factor,
    defaultServingQuantity: meal.quantity,
    defaultServingUnit: meal.unit,
  );
}
