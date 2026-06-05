import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/services/ai_service.dart';
import 'package:nutri_tracker/services/calorie_service.dart';

class PhotoMealScreen extends StatefulWidget {
  const PhotoMealScreen({
    super.key,
    this.date,
    this.mealType = 'snack',
  });

  final DateTime? date;
  final String mealType;

  @override
  State<PhotoMealScreen> createState() => _PhotoMealScreenState();
}

class _PhotoMealScreenState extends State<PhotoMealScreen> {
  final _picker = ImagePicker();
  final _ai = AIService();
  final _calorieService = CalorieService();
  final _nameController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  final _servingController = TextEditingController();
  XFile? _image;
  bool _loading = false;
  String _confidence = 'low';
  late String _mealType;

  @override
  void initState() {
    super.initState();
    _mealType = widget.mealType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    _servingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Photo Meal')),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (_image == null)
                _PhotoEmptyState(
                  onCamera: () => _pick(ImageSource.camera),
                  onGallery: () => _pick(ImageSource.gallery),
                )
              else ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    File(_image!.path),
                    height: 260,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pick(ImageSource.camera),
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Retake'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _pick(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library),
                        label: const Text('Gallery'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: _loading ? null : _analyse,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Analyse with AI'),
                ),
              ],
              if (_nameController.text.isNotEmpty) ...[
                const SizedBox(height: 16),
                _ConfidenceBadge(confidence: _confidence),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _mealType,
                  decoration: const InputDecoration(labelText: 'Meal type'),
                  items: const [
                    DropdownMenuItem(
                        value: 'breakfast', child: Text('Breakfast')),
                    DropdownMenuItem(value: 'lunch', child: Text('Lunch')),
                    DropdownMenuItem(value: 'dinner', child: Text('Dinner')),
                    DropdownMenuItem(value: 'snack', child: Text('Snack')),
                  ],
                  onChanged: (value) =>
                      setState(() => _mealType = value ?? _mealType),
                ),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Meal name'),
                ),
                TextField(
                  controller: _servingController,
                  decoration: const InputDecoration(labelText: 'Serving size'),
                ),
                TextField(
                  controller: _caloriesController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Calories'),
                ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _proteinController,
                        keyboardType: TextInputType.number,
                        decoration:
                            const InputDecoration(labelText: 'Protein g'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _carbsController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Carbs g'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _fatController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Fat g'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () => _log(uid),
                  icon: const Icon(Icons.check),
                  label: const Text('Log this meal'),
                ),
              ],
            ],
          ),
          if (_loading)
            Positioned.fill(
              child: ColoredBox(
                color: Colors.black54,
                child: Center(
                  child: Container(
                    width: 220,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Scanning meal photo...'),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 85);
    if (image == null || !mounted) return;
    setState(() => _image = image);
  }

  Future<void> _analyse() async {
    final image = _image;
    if (image == null) return;
    setState(() => _loading = true);
    try {
      final result = await _ai.estimateNutritionFromPhoto(File(image.path));
      if (!mounted) return;
      setState(() {
        _nameController.text = result['mealName']?.toString() ?? 'Meal photo';
        _caloriesController.text =
            '${(result['calories'] as num?)?.round() ?? 0}';
        _proteinController.text =
            (result['protein'] as num?)?.toStringAsFixed(1) ?? '0';
        _carbsController.text =
            (result['carbs'] as num?)?.toStringAsFixed(1) ?? '0';
        _fatController.text =
            (result['fat'] as num?)?.toStringAsFixed(1) ?? '0';
        _servingController.text =
            result['servingSize']?.toString() ?? '1 serving';
        _confidence = result['confidence']?.toString() ?? 'low';
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to analyse photo: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _log(String uid) async {
    final entry = MealEntry(
      mealType: _mealType,
      foodName: _nameController.text.trim().isEmpty
          ? 'Meal photo'
          : _nameController.text.trim(),
      calories: int.tryParse(_caloriesController.text.trim()) ?? 0,
      protein: double.tryParse(_proteinController.text.trim()) ?? 0,
      carbs: double.tryParse(_carbsController.text.trim()) ?? 0,
      fat: double.tryParse(_fatController.text.trim()) ?? 0,
      quantity: 1,
      unit: _servingController.text.trim().isEmpty
          ? 'serving'
          : _servingController.text.trim(),
    );
    await _calorieService.addMealEntry(
      uid,
      widget.date ?? DateTime.now(),
      entry,
    );
    if (mounted) context.pop();
  }
}

class _PhotoEmptyState extends StatelessWidget {
  const _PhotoEmptyState({
    required this.onCamera,
    required this.onGallery,
  });

  final VoidCallback onCamera;
  final VoidCallback onGallery;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Icon(Icons.camera_alt, size: 56),
            const SizedBox(height: 12),
            Text('Add a meal photo',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onCamera,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Take Photo'),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Choose from Gallery'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence});

  final String confidence;

  @override
  Widget build(BuildContext context) {
    final normalized = confidence.toLowerCase();
    final color = switch (normalized) {
      'high' => Colors.green,
      'medium' => Colors.orange,
      _ => Colors.red,
    };
    return Align(
      alignment: Alignment.centerLeft,
      child: Chip(
        avatar: Icon(Icons.verified, color: color),
        label: Text('Confidence: $normalized'),
      ),
    );
  }
}
