import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class IndianFoodsAdminScreen extends StatefulWidget {
  const IndianFoodsAdminScreen({super.key});

  @override
  State<IndianFoodsAdminScreen> createState() => _IndianFoodsAdminScreenState();
}

class _IndianFoodsAdminScreenState extends State<IndianFoodsAdminScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _nameHindi = TextEditingController();
  final _category = TextEditingController(text: 'lunch');
  final _cuisine = TextEditingController(text: 'North Indian');
  final _dietType = TextEditingController(text: 'vegetarian');
  final _calories = TextEditingController();
  final _protein = TextEditingController();
  final _carbs = TextEditingController();
  final _fat = TextEditingController();
  final _fiber = TextEditingController();
  final _imageUrl = TextEditingController();
  final _serving = TextEditingController(text: '100');
  final _tags = TextEditingController();

  @override
  void dispose() {
    for (final controller in [
      _name,
      _nameHindi,
      _category,
      _cuisine,
      _dietType,
      _calories,
      _protein,
      _carbs,
      _fat,
      _fiber,
      _imageUrl,
      _serving,
      _tags,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Indian Foods')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _field(_name, 'Name'),
            _field(_nameHindi, 'Hindi name'),
            _field(_category, 'Category'),
            _field(_cuisine, 'Cuisine'),
            _field(_dietType, 'Diet type'),
            _field(_calories, 'Calories / 100g', number: true),
            _field(_protein, 'Protein / 100g', number: true),
            _field(_carbs, 'Carbs / 100g', number: true),
            _field(_fat, 'Fat / 100g', number: true),
            _field(_fiber, 'Fiber / 100g', number: true),
            _field(_imageUrl, 'Image URL'),
            _field(_serving, 'Serving size grams', number: true),
            _field(_tags, 'Tags comma-separated'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: _saveFood,
              icon: const Icon(Icons.save),
              label: const Text('Save Food'),
            ),
            OutlinedButton.icon(
              onPressed: _seedFoods,
              icon: const Icon(Icons.dataset),
              label: const Text('Seed 50 Indian Foods'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label, {bool number = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: number ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label),
        validator: (value) => value == null || value.trim().isEmpty ? 'Required' : null,
      ),
    );
  }

  Future<void> _saveFood() async {
    if (!_formKey.currentState!.validate()) return;
    await FirebaseFirestore.instance.collection('indian_foods').add(_foodMap(
          name: _name.text,
          nameHindi: _nameHindi.text,
          category: _category.text,
          cuisine: _cuisine.text,
          dietType: _dietType.text,
          calories: int.tryParse(_calories.text) ?? 0,
          protein: double.tryParse(_protein.text) ?? 0,
          carbs: double.tryParse(_carbs.text) ?? 0,
          fat: double.tryParse(_fat.text) ?? 0,
          fiber: double.tryParse(_fiber.text) ?? 0,
          imageUrl: _imageUrl.text,
          servingSize: int.tryParse(_serving.text) ?? 100,
          tags: _tags.text.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
        ));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Food saved')));
    }
  }

  Future<void> _seedFoods() async {
    final batch = FirebaseFirestore.instance.batch();
    final collection = FirebaseFirestore.instance.collection('indian_foods');
    for (final food in seedIndianFoods) {
      batch.set(collection.doc(food['name'].toString().toLowerCase().replaceAll(' ', '_')), food);
    }
    await batch.commit();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Seeded Indian foods')));
    }
  }
}

Map<String, dynamic> _foodMap({
  required String name,
  required String nameHindi,
  required String category,
  required String cuisine,
  required String dietType,
  required int calories,
  required double protein,
  required double carbs,
  required double fat,
  required double fiber,
  required String imageUrl,
  required int servingSize,
  required List<String> tags,
}) {
  return {
    'name': name,
    'nameHindi': nameHindi,
    'category': category,
    'cuisine': cuisine,
    'dietType': dietType,
    'caloriesPer100g': calories,
    'proteinPer100g': protein,
    'carbsPer100g': carbs,
    'fatPer100g': fat,
    'fiberPer100g': fiber,
    'imageUrl': imageUrl,
    'servingSize': servingSize,
    'tags': tags,
  };
}

final seedIndianFoods = <Map<String, dynamic>>[
  for (final item in _seedRows)
    _foodMap(
      name: item[0] as String,
      nameHindi: item[1] as String,
      category: item[2] as String,
      cuisine: item[3] as String,
      dietType: item[4] as String,
      calories: item[5] as int,
      protein: item[6] as double,
      carbs: item[7] as double,
      fat: item[8] as double,
      fiber: item[9] as double,
      imageUrl: '',
      servingSize: 100,
      tags: List<String>.from(item[10] as List),
    ),
];

const _seedRows = [
  ['Dal Makhani', 'दाल मखनी', 'lunch', 'North Indian', 'vegetarian', 180, 7.0, 20.0, 8.0, 5.0, ['high_protein']],
  ['Rajma Chawal', 'राजमा चावल', 'lunch', 'North Indian', 'vegetarian', 170, 5.5, 28.0, 3.5, 5.0, ['fiber_rich']],
  ['Chole', 'छोले', 'lunch', 'North Indian', 'vegetarian', 164, 8.0, 27.0, 3.0, 7.0, ['high_protein']],
  ['Samosa', 'समोसा', 'snack', 'North Indian', 'vegetarian', 308, 6.0, 32.0, 18.0, 3.0, ['festival']],
  ['Idli', 'इडली', 'breakfast', 'South Indian', 'vegan', 128, 4.0, 26.0, 1.0, 2.0, ['light']],
  ['Dosa', 'डोसा', 'breakfast', 'South Indian', 'vegan', 168, 4.0, 30.0, 4.0, 2.0, ['breakfast']],
  ['Medu Vada', 'मेदु वड़ा', 'breakfast', 'South Indian', 'vegan', 290, 10.0, 32.0, 14.0, 5.0, ['protein']],
  ['Upma', 'उपमा', 'breakfast', 'South Indian', 'vegan', 130, 3.5, 23.0, 3.0, 2.5, ['light']],
  ['Poha', 'पोहा', 'breakfast', 'Maharashtrian', 'vegan', 130, 2.5, 25.0, 2.5, 2.0, ['light']],
  ['Aloo Paratha', 'आलू पराठा', 'breakfast', 'Punjabi', 'vegetarian', 220, 5.0, 32.0, 8.0, 4.0, ['energy']],
  ['Veg Biryani', 'वेज बिरयानी', 'lunch', 'Hyderabadi', 'vegetarian', 170, 4.0, 28.0, 5.0, 3.0, ['rice']],
  ['Chicken Biryani', 'चिकन बिरयानी', 'lunch', 'Hyderabadi', 'non_vegetarian', 190, 11.0, 24.0, 6.0, 2.0, ['high_protein']],
  ['Kadai Paneer', 'कड़ाही पनीर', 'dinner', 'North Indian', 'vegetarian', 235, 10.0, 10.0, 17.0, 2.0, ['high_protein']],
  ['Palak Paneer', 'पालक पनीर', 'dinner', 'North Indian', 'vegetarian', 190, 9.0, 8.0, 14.0, 3.0, ['iron_rich']],
  ['Aloo Gobi', 'आलू गोभी', 'lunch', 'North Indian', 'vegan', 95, 3.0, 14.0, 3.0, 4.0, ['fiber_rich']],
  ['Methi Thepla', 'मेथी थेपला', 'breakfast', 'Gujarati', 'vegetarian', 210, 6.0, 32.0, 7.0, 5.0, ['travel_friendly']],
  ['Dhokla', 'ढोकला', 'snack', 'Gujarati', 'vegetarian', 160, 6.0, 26.0, 4.0, 3.0, ['steamed']],
  ['Pav Bhaji', 'पाव भाजी', 'snack', 'Maharashtrian', 'vegetarian', 190, 4.0, 28.0, 7.0, 4.0, ['street_food']],
  ['Vada Pav', 'वड़ा पाव', 'snack', 'Maharashtrian', 'vegetarian', 290, 6.0, 42.0, 11.0, 4.0, ['street_food']],
  ['Butter Chicken', 'बटर चिकन', 'dinner', 'North Indian', 'non_vegetarian', 240, 18.0, 6.0, 16.0, 1.0, ['high_protein']],
  ['Mutton Curry', 'मटन करी', 'dinner', 'North Indian', 'non_vegetarian', 250, 20.0, 4.0, 18.0, 1.0, ['high_protein']],
  ['Egg Curry', 'अंडा करी', 'dinner', 'North Indian', 'eggetarian', 180, 12.0, 6.0, 12.0, 1.0, ['high_protein']],
  ['Fish Curry', 'फिश करी', 'lunch', 'Bengali', 'non_vegetarian', 170, 19.0, 4.0, 9.0, 1.0, ['omega_3']],
  ['Khichdi', 'खिचड़ी', 'dinner', 'Indian', 'vegetarian', 120, 4.0, 22.0, 2.0, 3.0, ['light']],
  ['Veg Pulao', 'पुलाव', 'lunch', 'Indian', 'vegan', 150, 3.0, 28.0, 3.0, 3.0, ['rice']],
  ['Raita', 'रायता', 'side', 'North Indian', 'vegetarian', 75, 3.5, 7.0, 3.0, 1.0, ['cooling']],
  ['Lassi', 'लस्सी', 'drink', 'Punjabi', 'vegetarian', 110, 3.5, 18.0, 3.0, 0.0, ['drink']],
  ['Chaas', 'छाछ', 'drink', 'Gujarati', 'vegetarian', 40, 2.0, 5.0, 1.0, 0.0, ['low_calorie']],
  ['Chai', 'चाय', 'drink', 'Indian', 'vegetarian', 70, 2.0, 10.0, 2.5, 0.0, ['drink']],
  ['Nimbu Pani', 'नींबू पानी', 'drink', 'Indian', 'vegan', 35, 0.0, 9.0, 0.0, 0.0, ['hydrating']],
  ['Moong Sprouts Chaat', 'मूंग स्प्राउट चाट', 'snack', 'Indian', 'vegan', 105, 7.0, 18.0, 1.0, 5.0, ['high_protein']],
  ['Paneer Bhurji', 'पनीर भुर्जी', 'dinner', 'North Indian', 'vegetarian', 220, 14.0, 7.0, 15.0, 2.0, ['high_protein']],
  ['Masala Oats', 'मसाला ओट्स', 'breakfast', 'Indian', 'vegetarian', 120, 4.0, 20.0, 3.0, 4.0, ['fiber_rich']],
  ['Besan Chilla', 'बेसन चीला', 'breakfast', 'North Indian', 'vegan', 180, 9.0, 22.0, 6.0, 4.0, ['high_protein']],
  ['Ragi Dosa', 'रागी डोसा', 'breakfast', 'South Indian', 'vegan', 150, 4.0, 28.0, 2.0, 4.0, ['diabetic_friendly']],
  ['Curd Rice', 'दही चावल', 'lunch', 'South Indian', 'vegetarian', 130, 4.0, 22.0, 3.0, 1.0, ['cooling']],
  ['Lemon Rice', 'लेमन राइस', 'lunch', 'South Indian', 'vegan', 165, 3.0, 30.0, 4.0, 2.0, ['rice']],
  ['Sambar', 'सांभर', 'side', 'South Indian', 'vegan', 80, 4.0, 13.0, 2.0, 4.0, ['fiber_rich']],
  ['Rasam', 'रसम', 'side', 'South Indian', 'vegan', 45, 2.0, 8.0, 1.0, 1.5, ['light']],
  ['Chicken Tikka', 'चिकन टिक्का', 'snack', 'North Indian', 'non_vegetarian', 150, 22.0, 3.0, 6.0, 1.0, ['high_protein']],
  ['Tandoori Roti', 'तंदूरी रोटी', 'side', 'North Indian', 'vegan', 260, 8.0, 52.0, 2.0, 8.0, ['whole_wheat']],
  ['Plain Roti', 'रोटी', 'side', 'Indian', 'vegan', 260, 9.0, 50.0, 3.0, 8.0, ['whole_wheat']],
  ['Jeera Rice', 'जीरा राइस', 'lunch', 'North Indian', 'vegan', 170, 3.0, 32.0, 4.0, 1.0, ['rice']],
  ['Bhindi Masala', 'भिंडी मसाला', 'lunch', 'North Indian', 'vegan', 110, 3.0, 12.0, 6.0, 4.0, ['fiber_rich']],
  ['Baingan Bharta', 'बैंगन भरता', 'dinner', 'North Indian', 'vegan', 95, 2.0, 12.0, 5.0, 5.0, ['fiber_rich']],
  ['Misal Pav', 'मिसळ पाव', 'breakfast', 'Maharashtrian', 'vegetarian', 210, 8.0, 30.0, 7.0, 6.0, ['spicy']],
  ['Khandvi', 'खंडवी', 'snack', 'Gujarati', 'vegetarian', 140, 6.0, 18.0, 5.0, 2.0, ['light']],
  ['Appam', 'अप्पम', 'breakfast', 'Kerala', 'vegan', 150, 3.0, 31.0, 2.0, 1.0, ['breakfast']],
  ['Avial', 'अवियल', 'lunch', 'Kerala', 'vegetarian', 120, 3.0, 13.0, 6.0, 5.0, ['vegetable_rich']],
  ['Pesarattu', 'पेसरट्टू', 'breakfast', 'Andhra', 'vegan', 170, 9.0, 25.0, 4.0, 5.0, ['high_protein']],
  ['Kheer', 'खीर', 'dessert', 'Indian', 'vegetarian', 160, 4.0, 25.0, 5.0, 1.0, ['dessert']],
];
