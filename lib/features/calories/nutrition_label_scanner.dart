import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:nutri_tracker/models/meal_entry.dart';
import 'package:nutri_tracker/services/ai_service.dart';

class NutritionLabelScanner extends StatefulWidget {
  const NutritionLabelScanner({
    super.key,
    this.mealType = 'snack',
  });

  final String mealType;

  @override
  State<NutritionLabelScanner> createState() => _NutritionLabelScannerState();
}

class _NutritionLabelScannerState extends State<NutritionLabelScanner> {
  final _picker = ImagePicker();
  final _nameController = TextEditingController(text: 'Packaged food');
  final _caloriesController = TextEditingController();
  final _proteinController = TextEditingController();
  final _carbsController = TextEditingController();
  final _fatController = TextEditingController();
  XFile? _image;
  Uint8List? _imageBytes;
  bool _loading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _caloriesController.dispose();
    _proteinController.dispose();
    _carbsController.dispose();
    _fatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Nutrition Label')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (_image == null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    const Icon(Icons.document_scanner, size: 56),
                    const SizedBox(height: 12),
                    Text('Capture the nutrition facts panel',
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 16),
                    FilledButton.icon(
                      onPressed: () => _pick(ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Scan Label'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _pick(ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Choose Photo'),
                    ),
                  ],
                ),
              ),
            )
          else ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.memory(
                _imageBytes!,
                height: 240,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _loading ? null : _scan,
              icon: _loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.text_snippet),
              label: const Text('Read Label'),
            ),
          ],
          if (_caloriesController.text.isNotEmpty) ...[
            const SizedBox(height: 16),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Food name'),
            ),
            TextField(
              controller: _caloriesController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Calories per 100g'),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _proteinController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Protein g'),
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
              onPressed: _returnEntry,
              icon: const Icon(Icons.check),
              label: const Text('Use this food'),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _pick(ImageSource source) async {
    final image = await _picker.pickImage(source: source, imageQuality: 90);
    if (image == null || !mounted) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _image = image;
      _imageBytes = bytes;
    });
  }

  Future<void> _scan() async {
    final image = _image;
    final bytes = _imageBytes;
    if (image == null || bytes == null) return;
    setState(() => _loading = true);
    final recognizer =
        kIsWeb ? null : TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final parsed = <String, double>{};
      if (recognizer != null) {
        final text = await recognizer.processImage(
          InputImage.fromFilePath(image.path),
        );
        parsed.addAll(_parseNutrition(text.text));
      }
      if (parsed.values.where((value) => value > 0).length < 2) {
        final ai = await AIService().estimateNutritionFromPhoto(
          bytes,
          mediaType: _mediaType(image),
        );
        parsed
          ..['calories'] = (ai['calories'] as num?)?.toDouble() ?? 0
          ..['protein'] = (ai['protein'] as num?)?.toDouble() ?? 0
          ..['carbs'] = (ai['carbs'] as num?)?.toDouble() ?? 0
          ..['fat'] = (ai['fat'] as num?)?.toDouble() ?? 0;
        _nameController.text =
            ai['mealName']?.toString() ?? _nameController.text;
      }
      if (!mounted) return;
      setState(() {
        _caloriesController.text =
            parsed['calories']?.toStringAsFixed(0) ?? '0';
        _proteinController.text = parsed['protein']?.toStringAsFixed(1) ?? '0';
        _carbsController.text = parsed['carbs']?.toStringAsFixed(1) ?? '0';
        _fatController.text = parsed['fat']?.toStringAsFixed(1) ?? '0';
      });
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to scan label: $error')),
      );
    } finally {
      await recognizer?.close();
      if (mounted) setState(() => _loading = false);
    }
  }

  String _mediaType(XFile image) {
    final explicitType = image.mimeType;
    if (explicitType != null && explicitType.startsWith('image/')) {
      return explicitType;
    }
    return image.name.toLowerCase().endsWith('.png')
        ? 'image/png'
        : 'image/jpeg';
  }

  Map<String, double> _parseNutrition(String text) {
    final normalized = text.replaceAll('\n', ' ').toLowerCase();
    return {
      'calories': _firstMatch(normalized, [
        RegExp(r'(?:energy|calories)\s*:?\s*(\d+(?:\.\d+)?)\s*k?cal'),
        RegExp(r'(\d+(?:\.\d+)?)\s*kcal'),
      ]),
      'protein': _firstMatch(normalized, [
        RegExp(r'protein\s*:?\s*(\d+(?:\.\d+)?)\s*g'),
      ]),
      'carbs': _firstMatch(normalized, [
        RegExp(r'(?:carbohydrate|carbs)\s*:?\s*(\d+(?:\.\d+)?)\s*g'),
      ]),
      'fat': _firstMatch(normalized, [
        RegExp(r'(?:total\s+fat|fat)\s*:?\s*(\d+(?:\.\d+)?)\s*g'),
      ]),
    };
  }

  double _firstMatch(String text, List<RegExp> patterns) {
    for (final pattern in patterns) {
      final match = pattern.firstMatch(text);
      final value = match == null ? null : double.tryParse(match.group(1)!);
      if (value != null) return value;
    }
    return 0;
  }

  void _returnEntry() {
    context.pop(
      MealEntry(
        mealType: widget.mealType,
        foodName: _nameController.text.trim().isEmpty
            ? 'Packaged food'
            : _nameController.text.trim(),
        calories: int.tryParse(_caloriesController.text.trim()) ?? 0,
        protein: double.tryParse(_proteinController.text.trim()) ?? 0,
        carbs: double.tryParse(_carbsController.text.trim()) ?? 0,
        fat: double.tryParse(_fatController.text.trim()) ?? 0,
        quantity: 100,
        unit: 'grams',
      ),
    );
  }
}
