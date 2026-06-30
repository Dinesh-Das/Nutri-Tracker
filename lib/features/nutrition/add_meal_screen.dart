import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/food_item.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/models/meal_template.dart';
import 'package:nutri_tracker/repositories/nutrition_repository.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/barcode_service.dart';
import 'package:nutri_tracker/services/calorie_service.dart';
import 'package:nutri_tracker/services/daily_summary_service.dart';

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
      length: 5,
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
              Tab(text: 'Templates'),
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
                  _TemplatesTab(
                    uid: uid,
                    date: _date,
                    mealType: lateMealType,
                    repository: _repository,
                    onLogTemplate: _logTemplate,
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
      await _syncSummary(uid);
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
    await _syncSummary(uid);
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
      await _syncSummary(uid);
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
    final options = _servingOptionsFor(food);
    var selectedOption = options.first;
    var quantity = selectedOption.quantity;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final factor = _servingFactor(food, selectedOption, quantity);
            final calories = (food.caloriesPer100g * factor).round();
            final unit = selectedOption.unit;
            final slider = _sliderBoundsFor(selectedOption);
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
                  DropdownButtonFormField<ServingOption>(
                    value: selectedOption,
                    decoration: const InputDecoration(labelText: 'Serving'),
                    items: [
                      for (final option in options)
                        DropdownMenuItem(
                          value: option,
                          child: Text(option.label),
                        ),
                    ],
                    onChanged: (value) {
                      if (value == null) return;
                      setModalState(() {
                        selectedOption = value;
                        quantity = value.quantity;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  Text('Quantity: ${_formatQuantity(quantity)} $unit'),
                  Slider(
                    value: quantity.clamp(slider.$1, slider.$2).toDouble(),
                    min: slider.$1,
                    max: slider.$2,
                    divisions: slider.$3,
                    label: '${_formatQuantity(quantity)} $unit',
                    onChanged: (value) => setModalState(() => quantity = value),
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
                          servingDescription:
                              '${_formatQuantity(quantity)} $unit',
                        ),
                      );
                      await _syncSummary(uid);
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

  Future<void> _logTemplate(MealTemplate template) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _saving = true);
    try {
      await _repository.logMealTemplate(
        uid: uid,
        date: _date,
        template: template,
        mealType: lateMealType,
      );
      await _syncSummary(uid);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _syncSummary(String uid) {
    return DailySummaryService().rebuildSummary(uid, _date);
  }
}

List<ServingOption> _servingOptionsFor(FoodItem food) {
  final existing = food.servingOptions;
  final unit = food.defaultServingUnit.toLowerCase();
  final options = <ServingOption>[
    ...existing,
    ServingOption(
      label:
          '${_formatQuantity(food.defaultServingQuantity)} ${food.defaultServingUnit}',
      quantity: food.defaultServingQuantity,
      unit: food.defaultServingUnit,
      gramEquivalent: _isMassUnit(unit) ? food.defaultServingQuantity : null,
    ),
    const ServingOption(
      label: 'Grams',
      quantity: 100,
      unit: 'grams',
      gramEquivalent: 100,
    ),
    const ServingOption(
      label: '1 roti',
      quantity: 1,
      unit: 'roti',
      gramEquivalent: 40,
    ),
    const ServingOption(
      label: '1 bowl',
      quantity: 1,
      unit: 'bowl',
      gramEquivalent: 200,
    ),
    const ServingOption(
      label: '1 katori',
      quantity: 1,
      unit: 'katori',
      gramEquivalent: 150,
    ),
    const ServingOption(
      label: '1 cup',
      quantity: 1,
      unit: 'cup',
      gramEquivalent: 240,
    ),
    const ServingOption(
      label: '1 idli',
      quantity: 1,
      unit: 'idli',
      gramEquivalent: 50,
    ),
    const ServingOption(
      label: '1 dosa',
      quantity: 1,
      unit: 'dosa',
      gramEquivalent: 120,
    ),
    const ServingOption(
      label: '1 serving',
      quantity: 1,
      unit: 'serving',
    ),
  ];
  final seen = <String>{};
  return [
    for (final option in options)
      if (seen.add('${option.label}-${option.unit}')) option,
  ];
}

double _servingFactor(
  FoodItem food,
  ServingOption option,
  double quantity,
) {
  final unit = option.unit.toLowerCase();
  if (_isMassUnit(unit)) return quantity / 100;
  final grams = option.gramEquivalent;
  if (grams != null && grams > 0) {
    final servings = quantity / (option.quantity <= 0 ? 1 : option.quantity);
    return (grams * servings) / 100;
  }
  if (!_isMassUnit(food.defaultServingUnit.toLowerCase())) {
    return quantity /
        (food.defaultServingQuantity <= 0 ? 1 : food.defaultServingQuantity);
  }
  return 1;
}

bool _isMassUnit(String unit) {
  return unit == 'grams' || unit == 'gram' || unit == 'g' || unit == 'ml';
}

(double, double, int) _sliderBoundsFor(ServingOption option) {
  if (_isMassUnit(option.unit.toLowerCase())) return (25, 600, 23);
  return (1, 10, 9);
}

String _formatQuantity(double value) {
  return value % 1 == 0 ? value.round().toString() : value.toStringAsFixed(1);
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

class _TemplatesTab extends StatelessWidget {
  const _TemplatesTab({
    required this.uid,
    required this.date,
    required this.mealType,
    required this.repository,
    required this.onLogTemplate,
  });

  final String uid;
  final DateTime date;
  final String mealType;
  final NutritionRepository repository;
  final ValueChanged<MealTemplate> onLogTemplate;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<MealTemplate>>(
      stream: repository.watchMealTemplates(uid),
      builder: (context, snapshot) {
        final templates = snapshot.data ?? const <MealTemplate>[];
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            FilledButton.icon(
              onPressed: () => _saveCurrentMealGroup(context),
              icon: const Icon(Icons.bookmark_add_outlined),
              label: const Text('Save current meal as template'),
            ),
            const SizedBox(height: 12),
            if (templates.isEmpty)
              const Card(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Text('Saved meal templates appear here.'),
                ),
              ),
            for (final template in templates)
              Card(
                child: ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.bookmarks)),
                  title: Text(template.name),
                  subtitle: Text(
                    '${template.mealType} - ${template.foods.length} foods - ${template.totalCalories} kcal',
                  ),
                  trailing: PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'log') onLogTemplate(template);
                      if (value == 'edit') _editTemplate(context, template);
                      if (value == 'delete') {
                        repository.deleteMealTemplate(uid, template.id);
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'log', child: Text('Log')),
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                  onTap: () => onLogTemplate(template),
                ),
              ),
          ],
        );
      },
    );
  }

  Future<void> _saveCurrentMealGroup(BuildContext context) async {
    final log = await repository.getDailyLog(uid, date);
    final meals = log.meals.where((meal) => meal.mealType == mealType).toList();
    if (!context.mounted) return;
    if (meals.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Log foods in this meal first.')),
      );
      return;
    }
    final name = await _templateNameDialog(
      context,
      initialName: '${mealType[0].toUpperCase()}${mealType.substring(1)} combo',
    );
    if (name == null || name.trim().isEmpty) return;
    await repository.saveMealsAsTemplate(
      uid: uid,
      name: name.trim(),
      mealType: mealType,
      meals: meals,
    );
  }

  Future<void> _editTemplate(
    BuildContext context,
    MealTemplate template,
  ) async {
    final name = await _templateNameDialog(
      context,
      initialName: template.name,
    );
    if (name == null || name.trim().isEmpty) return;
    await repository.saveMealTemplate(
      uid,
      template.copyWith(name: name.trim()),
    );
  }

  Future<String?> _templateNameDialog(
    BuildContext context, {
    required String initialName,
  }) {
    final controller = TextEditingController(text: initialName);
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Meal template'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Template name'),
          textCapitalization: TextCapitalization.words,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: const Text('Save'),
          ),
        ],
      ),
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
