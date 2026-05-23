import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/utils/health_utils.dart';

class AIService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const String _model = 'claude-sonnet-4-20250514';

  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
    UserModel? userContext,
  }) async {
    final apiKey = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('Missing ANTHROPIC_API_KEY in .env');
    }

    var systemPrompt = nutriBotSystemPrompt;
    if (userContext != null) {
      final bmi = double.tryParse(userContext.bmi ?? '0') ?? 0;
      systemPrompt += '''

Current user context:
- Name: ${userContext.name ?? 'not set'}
- BMI: ${userContext.bmi ?? 'not calculated'} (${getBmiCategory(bmi)})
- Weight: ${userContext.weight ?? 'not set'}kg
- Height: ${userContext.height ?? 'not set'}cm
- Gender: ${userContext.gender ?? 'not set'}
- Goal: ${userContext.weightGoal ?? 'not set'}
- Dietary preference: ${userContext.dietaryPreference ?? 'not specified'}
- Daily calorie goal: ${userContext.dailyCalorieGoal ?? 'not calculated'}
''';
    }

    final messages = [
      ...conversationHistory,
      {'role': 'user', 'content': userMessage},
    ];

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': messages,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['content'][0]['text'] as String;
    }
    throw Exception('AI request failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> estimateNutrition(String mealDescription) async {
    final response = await sendMessage(
      userMessage: buildNutritionPrompt(mealDescription),
      conversationHistory: const [],
    );
    final start = response.indexOf('{');
    final end = response.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception('AI response did not include valid JSON');
    }
    return jsonDecode(response.substring(start, end + 1)) as Map<String, dynamic>;
  }

  Future<void> saveChatMessage({
    required String uid,
    required String role,
    required String content,
  }) {
    return FirebaseFirestore.instance
        .collection('ai_chats')
        .doc(uid)
        .collection('messages')
        .add({
      'role': role,
      'content': content,
      'timestamp': Timestamp.now(),
    });
  }

  Stream<List<Map<String, String>>> watchChatHistory(String uid) {
    return FirebaseFirestore.instance
        .collection('ai_chats')
        .doc(uid)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'role': (doc.data()['role'] ?? 'user').toString(),
                  'content': (doc.data()['content'] ?? '').toString(),
                })
            .toList());
  }

  Future<void> clearChat(String uid) async {
    final messages = await FirebaseFirestore.instance
        .collection('ai_chats')
        .doc(uid)
        .collection('messages')
        .get();
    final batch = FirebaseFirestore.instance.batch();
    for (final doc in messages.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
  }
}

const nutriBotSystemPrompt = '''
You are NutriBot, an expert Indian nutrition and fitness assistant built into the NutriTrack India app. You have deep knowledge of:
- Indian cuisine, traditional foods, and their nutritional profiles
- Regional Indian diets: North Indian, South Indian, Bengali, Gujarati, Rajasthani, Maharashtrian, etc.
- Ayurvedic nutrition principles
- Calorie counting, macro tracking, BMI interpretation
- Weight loss and weight gain strategies suited to Indian dietary habits
- Indian festivals and their impact on diet (Navratri fasting, Ramadan, etc.)
- Common Indian health conditions: diabetes management, PCOD/PCOS diet, thyroid-friendly foods

Always give practical, actionable advice. Use Indian food examples (dal, sabzi, roti, rice, idli, dosa, etc.). When discussing calories, use common Indian serving sizes (e.g., "1 medium roti = ~80 calories"). Be warm, encouraging, and culturally sensitive.

When the user provides their health data (BMI, weight, goals), personalise your response to their specific situation. If they ask for a meal plan, always include Indian food options. Keep responses concise and formatted with bullet points where appropriate.
''';

String buildNutritionPrompt(String mealDescription) => '''
Analyse this Indian meal and provide nutritional estimates:
"$mealDescription"

Respond ONLY with a JSON object in this exact format, no other text:
{
  "mealName": "descriptive name",
  "calories": 450,
  "protein": 15.2,
  "carbs": 65.0,
  "fat": 12.5,
  "fiber": 8.0,
  "confidence": "high|medium|low",
  "notes": "brief note about the estimate",
  "servingSize": "2 rotis + 1 cup dal + 1 glass lassi"
}

Use standard Indian serving sizes. If unsure, err on the side of slight overestimation.
''';
