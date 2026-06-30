import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:nutri_tracker/database/user_model.dart';
import 'package:nutri_tracker/models/meal_plan.dart';
import 'package:nutri_tracker/models/workout_program.dart';
import 'package:nutri_tracker/services/config_service.dart';
import 'package:nutri_tracker/utils/health_utils.dart';
import 'package:uuid/uuid.dart';

class AIService {
  static const String _model = 'claude-sonnet-4-20250514';

  AIService({Dio? dio, ConfigService? configService})
      : _dio = dio ?? Dio(),
        _configService = configService ?? ConfigService();

  final Dio _dio;
  final ConfigService _configService;

  Future<String> sendMessage({
    required String userMessage,
    required List<Map<String, String>> conversationHistory,
    UserModel? userContext,
  }) async {
    final proxyUrl = await _configService.getNutriBotProxyUrl();
    if (proxyUrl.trim().isEmpty) {
      throw Exception(
        'NutriBot is not configured. Set nutribot_proxy_url in Firebase Remote Config.',
      );
    }

    var systemPrompt = nutriBotSystemPrompt;
    if (userContext != null) {
      final bmi = userContext.bmi ?? 0.0;
      systemPrompt += '''

Current user context:
- Name: ${userContext.name ?? 'not set'}
- BMI: ${userContext.bmi?.toStringAsFixed(1) ?? 'not calculated'} (${getBmiCategory(bmi)})
- Weight: ${userContext.weight ?? 'not set'}kg
- Height: ${userContext.height ?? 'not set'}cm
- Gender: ${userContext.gender ?? 'not set'}
- Goal: ${userContext.weightGoal ?? 'not set'}
- Dietary preference: ${userContext.dietaryPreference ?? 'not specified'}
- Daily calorie goal: ${userContext.dailyCalorieGoal ?? 'not calculated'}
''';
    }

    final cleanedHistory = conversationHistory
        .where((message) =>
            (message['role'] == 'user' || message['role'] == 'assistant') &&
            (message['content']?.trim().isNotEmpty ?? false))
        .map((message) => {
              'role': message['role']!,
              'content': message['content']!.trim(),
            })
        .toList();
    final recentHistory = cleanedHistory.length <= 20
        ? cleanedHistory
        : cleanedHistory.sublist(cleanedHistory.length - 20);
    final messages = [
      ...recentHistory,
      {'role': 'user', 'content': userMessage},
    ];

    final idToken = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await _dio.post<dynamic>(
      proxyUrl,
      options: Options(
        headers: {
          'Content-Type': 'application/json',
          if (idToken != null) 'Authorization': 'Bearer $idToken',
        },
      ),
      data: {
        'model': _model,
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': messages,
      },
    );

    if (response.statusCode == 200) {
      final data = response.data is String
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data as Map);
      final text = data['text'];
      if (text is String) return text;
      final content = data['content'];
      if (content is List && content.isNotEmpty) {
        final first = content.first;
        if (first is Map && first['text'] is String) {
          return first['text'] as String;
        }
      }
      throw Exception('AI proxy returned an unexpected response format.');
    }
    throw Exception('AI request failed: ${response.statusCode}');
  }

  Future<Map<String, dynamic>> estimateNutrition(String mealDescription) async {
    final response = await sendMessage(
      userMessage: buildNutritionPrompt(mealDescription),
      conversationHistory: const [],
    );
    return _extractJsonMap(response);
  }

  Future<Map<String, dynamic>> estimateNutritionFromPhoto(
      File imageFile) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Sign in before analysing meal photos.');

    final id = const Uuid().v4();
    final ref =
        FirebaseStorage.instance.ref().child('food_photos/${user.uid}/$id.jpg');
    await ref.putFile(
      imageFile,
      SettableMetadata(contentType: 'image/jpeg'),
    );

    try {
      await ref.getDownloadURL();
      final proxyUrl = await _configService.getNutriBotProxyUrl();
      if (proxyUrl.trim().isEmpty) {
        throw Exception(
          'NutriBot is not configured. Set nutribot_proxy_url in Firebase Remote Config.',
        );
      }
      final idToken = await user.getIdToken();
      final base64Image = base64Encode(await imageFile.readAsBytes());
      final response = await _dio.post<dynamic>(
        proxyUrl,
        options: Options(
          headers: {
            'Content-Type': 'application/json',
            if (idToken != null) 'Authorization': 'Bearer $idToken',
          },
        ),
        data: {
          'model': _model,
          'max_tokens': 1024,
          'system': nutriBotSystemPrompt,
          'messages': [
            {
              'role': 'user',
              'content': [
                {
                  'type': 'image',
                  'source': {
                    'type': 'base64',
                    'media_type': 'image/jpeg',
                    'data': base64Image,
                  },
                },
                {
                  'type': 'text',
                  'text': buildNutritionPrompt('this meal in the photo'),
                },
              ],
            },
          ],
        },
      );
      if (response.statusCode != 200) {
        throw Exception('AI request failed: ${response.statusCode}');
      }
      final data = response.data is String
          ? jsonDecode(response.data as String) as Map<String, dynamic>
          : Map<String, dynamic>.from(response.data as Map);
      final text = data['text']?.toString() ??
          ((data['content'] as List?)?.firstOrNull as Map?)?['text']
              ?.toString();
      if (text == null || text.isEmpty) {
        throw Exception('AI proxy returned an unexpected response format.');
      }
      return _extractJsonMap(text);
    } finally {
      await ref.delete().catchError((_) {});
    }
  }

  Future<List<MealPlanDay>> generateMealPlan(
    UserModel user, {
    String? goal,
  }) async {
    final bmi = user.bmi ?? 0.0;
    final response = await sendMessage(
      userMessage: '''
Generate a 7-day personalised Indian meal plan as JSON.

User:
- BMI: ${user.bmi?.toStringAsFixed(1) ?? 'not calculated'} (${getBmiCategory(bmi)})
- Weight: ${user.weight ?? 'not set'} kg
- Goal: ${goal ?? user.weightGoal ?? 'not set'}
- Dietary preference: ${user.dietaryPreference ?? 'not specified'}
- Allergies: ${(user.allergies ?? const <String>[]).join(', ')}
- Daily calorie goal: ${user.dailyCalorieGoal ?? 2000}

Return ONLY this JSON shape:
{
  "days": [
    {
      "day": 1,
      "totalCalories": 1800,
      "meals": {
        "breakfast": {"name": "", "calories": 0, "protein": 0, "carbs": 0, "fat": 0, "description": ""},
        "lunch": {"name": "", "calories": 0, "protein": 0, "carbs": 0, "fat": 0, "description": ""},
        "dinner": {"name": "", "calories": 0, "protein": 0, "carbs": 0, "fat": 0, "description": ""},
        "snack": {"name": "", "calories": 0, "protein": 0, "carbs": 0, "fat": 0, "description": ""}
      }
    }
  ]
}

Use practical Indian meals, regional variety, and clear portion descriptions.
''',
      conversationHistory: const [],
      userContext: user,
    );
    return MealPlan.fromJson(_extractJsonMap(response)).days;
  }

  Future<WorkoutProgram> generateWorkoutProgram(
    UserModel user, {
    String goal = 'fitness',
    String level = 'beginner',
    String equipment = 'none',
  }) async {
    final response = await sendMessage(
      userMessage: '''
Generate a safe Indian home-workout program as JSON.

User:
- BMI: ${user.bmi?.toStringAsFixed(1) ?? 'not calculated'}
- Weight: ${user.weight ?? 'not set'} kg
- Goal: $goal
- Fitness level: $level
- Equipment: $equipment
- Injuries/limitations: ${user.injuriesOrLimitations ?? 'none'}

Use only these exercise ids when possible:
jumping_jacks, push_ups, knee_push_ups, squats, lunges, glute_bridge, plank,
side_plank, mountain_climbers, burpees, high_knees, crunches, leg_raises,
superman, wall_sit, chair_dips, surya_namaskar, yoga_child_pose,
cobra_stretch, cat_cow_stretch.

Return ONLY this JSON shape:
{
  "title": "No-equipment beginner strength",
  "description": "Short safety-focused description. No diagnosis.",
  "goal": "fitness",
  "level": "beginner",
  "durationWeeks": 4,
  "daysPerWeek": 3,
  "estimatedMinutesPerDay": 25,
  "equipment": "none",
  "workoutDays": [
    {"day": 1, "title": "Full body basics", "exerciseIds": ["squats", "knee_push_ups", "plank"]}
  ]
}
''',
      conversationHistory: const [],
      userContext: user,
    );
    return validateWorkoutProgramJson(_extractJsonMap(response));
  }

  Future<void> saveChatMessage({
    required String uid,
    required String role,
    required String content,
  }) {
    if (role != 'user' && role != 'assistant') {
      throw ArgumentError.value(role, 'role', 'Role must be user or assistant');
    }
    if (content.trim().isEmpty) return Future.value();
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
        .map((snapshot) => snapshot.docs.map((doc) {
              final role = (doc.data()['role'] ?? 'user').toString();
              return {
                'role': role == 'assistant' ? 'assistant' : 'user',
                'content': (doc.data()['content'] ?? '').toString(),
              };
            }).toList());
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

  Map<String, dynamic> _extractJsonMap(String response) {
    final start = response.indexOf('{');
    final end = response.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception('AI response did not include valid JSON');
    }
    return jsonDecode(response.substring(start, end + 1))
        as Map<String, dynamic>;
  }
}

WorkoutProgram validateWorkoutProgramJson(Map<String, dynamic> map) {
  final title = map['title']?.toString().trim();
  final days = (map['workoutDays'] as List?) ?? const [];
  if (title == null || title.isEmpty || days.isEmpty) {
    throw const FormatException('Workout plan is missing title or days.');
  }
  final program = WorkoutProgram.fromMap({
    'id': map['id']?.toString() ?? '',
    'title': title,
    'description': map['description']?.toString() ?? '',
    'goal': map['goal']?.toString() ?? 'fitness',
    'level': map['level']?.toString() ?? 'beginner',
    'durationWeeks': (map['durationWeeks'] as num?)?.toInt() ?? 4,
    'daysPerWeek': (map['daysPerWeek'] as num?)?.toInt() ?? days.length,
    'estimatedMinutesPerDay':
        (map['estimatedMinutesPerDay'] as num?)?.toInt() ?? 25,
    'equipment': map['equipment']?.toString() ?? 'none',
    'workoutDays': days,
  });
  if (program.durationWeeks < 1 ||
      program.durationWeeks > 16 ||
      program.daysPerWeek < 1 ||
      program.daysPerWeek > 7 ||
      program.workoutDays.any((day) => day.exerciseIds.isEmpty)) {
    throw const FormatException('Workout plan values are out of range.');
  }
  return program;
}

extension _FirstOrNull<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
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

Do not diagnose medical conditions or present advice as a substitute for care from a doctor or registered dietitian. For diabetes, PCOS/PCOD, thyroid disease, pregnancy, eating disorders, injuries, chest pain, fainting, severe pain, or other health conditions, provide general education and encourage the user to consult a qualified clinician. For workout advice, suggest safe home-friendly modifications and tell users to stop if they feel pain, dizziness, or breathlessness beyond normal exertion.
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
