import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/barcode_service.dart';
import 'package:nutri_tracker/services/calorie_service.dart';

class AddMealBottomSheet extends StatefulWidget {
  const AddMealBottomSheet({
    super.key,
    required this.uid,
    required this.date,
    required this.mealType,
  });

  final String uid;
  final DateTime date;
  final String mealType;

  @override
  State<AddMealBottomSheet> createState() => _AddMealBottomSheetState();
}

class _AddMealBottomSheetState extends State<AddMealBottomSheet> {
  final _searchController = TextEditingController();
  final _service = CalorieService();
  final _barcodeService = BarcodeService();
  double _quantity = 100;
  String _unit = 'grams';
  bool _lookingUpBarcode = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.82,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        prefixIcon: Icon(Icons.search),
                        labelText: 'Search Indian foods',
                      ),
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Scan barcode',
                    onPressed: _lookingUpBarcode ? null : _scanBarcode,
                    icon: _lookingUpBarcode
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.qr_code_scanner),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    tooltip: 'Scan nutrition label',
                    onPressed: _lookingUpBarcode ? null : _scanLabel,
                    icon: const Icon(Icons.document_scanner),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: _service.searchIndianFoods(_searchController.text),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final docs = snapshot.data?.docs ?? [];
                    if (docs.isEmpty) {
                      return const Center(child: Text('No foods found yet.'));
                    }
                    return ListView.builder(
                      controller: scrollController,
                      itemCount: docs.length,
                      itemBuilder: (context, index) {
                        final doc = docs[index];
                        final food = doc.data();
                        return ListTile(
                          leading: const CircleAvatar(
                            child: Icon(Icons.restaurant_menu),
                          ),
                          title: Text(food['name'] ?? 'Food'),
                          subtitle: Text(
                            '${food['caloriesPer100g'] ?? 0} kcal / 100g • ${food['dietType'] ?? ''}',
                          ),
                          onTap: () => _showQuantityPicker(food),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _scanBarcode() async {
    final code = await context.push<String>(AppRoutes.barcodeScanner);
    if (code == null || code.trim().isEmpty || !mounted) return;

    setState(() => _lookingUpBarcode = true);
    try {
      final entry = await _barcodeService.lookupBarcode(
        code,
        mealType: widget.mealType,
      );
      if (!mounted) return;
      if (entry == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Barcode not found. Try text search.')),
        );
        return;
      }
      _quantity = 100;
      _unit = 'grams';
      _showQuantityPicker({
        'name': entry.foodName,
        'caloriesPer100g': entry.calories,
        'proteinPer100g': entry.protein,
        'carbsPer100g': entry.carbs,
        'fatPer100g': entry.fat,
        'dietType': 'packaged',
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to lookup barcode: $error')),
      );
    } finally {
      if (mounted) setState(() => _lookingUpBarcode = false);
    }
  }

  Future<void> _scanLabel() async {
    final entry = await context.push<MealEntry>(
      AppRoutes.nutritionLabelScanner,
      extra: widget.mealType,
    );
    if (entry == null || !mounted) return;
    _quantity = 100;
    _unit = 'grams';
    _showQuantityPicker({
      'name': entry.foodName,
      'caloriesPer100g': entry.calories,
      'proteinPer100g': entry.protein,
      'carbsPer100g': entry.carbs,
      'fatPer100g': entry.fat,
      'dietType': 'label scan',
    });
  }

  void _showQuantityPicker(Map<String, dynamic> food) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final factor = _quantity / 100;
            final calories =
                ((food['caloriesPer100g'] as num? ?? 0) * factor).round();
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(food['name'] ?? 'Food',
                      style: Theme.of(context).textTheme.titleLarge),
                  Slider(
                    value: _quantity,
                    min: 25,
                    max: 600,
                    divisions: 23,
                    label: '${_quantity.round()} $_unit',
                    onChanged: (value) => setModalState(() {
                      _quantity = value;
                    }),
                  ),
                  SegmentedButton<String>(
                    segments: const [
                      ButtonSegment(value: 'grams', label: Text('g')),
                      ButtonSegment(value: 'pieces', label: Text('pc')),
                      ButtonSegment(value: 'ml', label: Text('ml')),
                    ],
                    selected: {_unit},
                    onSelectionChanged: (value) => setModalState(() {
                      _unit = value.first;
                    }),
                  ),
                  const SizedBox(height: 12),
                  Text('Estimated calories: $calories kcal'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () async {
                      final entry = MealEntry(
                        mealType: widget.mealType,
                        foodName: food['name'] ?? 'Food',
                        calories: calories,
                        protein:
                            ((food['proteinPer100g'] as num? ?? 0) * factor)
                                .toDouble(),
                        carbs: ((food['carbsPer100g'] as num? ?? 0) * factor)
                            .toDouble(),
                        fat: ((food['fatPer100g'] as num? ?? 0) * factor)
                            .toDouble(),
                        quantity: _quantity,
                        unit: _unit,
                      );
                      final navigator = Navigator.of(context);
                      await _service.addMealEntry(
                          widget.uid, widget.date, entry);
                      if (!mounted) return;
                      navigator.pop();
                      navigator.pop();
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Log this meal'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
