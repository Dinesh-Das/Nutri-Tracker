import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
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
  double _quantity = 100;
  String _unit = 'grams';

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
              TextField(
                controller: _searchController,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  labelText: 'Search Indian foods',
                ),
                onChanged: (_) => setState(() {}),
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

  void _showQuantityPicker(Map<String, dynamic> food) {
    showModalBottomSheet<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final factor = _quantity / 100;
            final calories = ((food['caloriesPer100g'] as num? ?? 0) * factor)
                .round();
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
                      await _service.addMealEntry(widget.uid, widget.date, entry);
                      if (mounted) Navigator.pop(context);
                      if (mounted) Navigator.pop(context);
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
