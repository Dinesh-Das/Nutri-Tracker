import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/workout_program.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/routes/app_routes.dart';
import 'package:nutri_tracker/services/ai_service.dart';
import 'package:nutri_tracker/services/firestore_service.dart';
import 'package:nutri_tracker/widgets/loading_shimmer.dart';

class AIWorkoutPlanScreen extends StatefulWidget {
  const AIWorkoutPlanScreen({super.key});

  @override
  State<AIWorkoutPlanScreen> createState() => _AIWorkoutPlanScreenState();
}

class _AIWorkoutPlanScreenState extends State<AIWorkoutPlanScreen> {
  final _ai = AIService();
  final _repository = WorkoutRepository();
  String _goal = 'fitness';
  String _level = 'beginner';
  String _equipment = 'none';
  WorkoutProgram? _program;
  bool _loading = false;
  bool _saving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Workout Plan')),
      body: _loading
          ? const LoadingShimmer(itemCount: 4)
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                DropdownButtonFormField<String>(
                  value: _goal,
                  decoration: const InputDecoration(labelText: 'Goal'),
                  items: const [
                    DropdownMenuItem(value: 'fitness', child: Text('Fitness')),
                    DropdownMenuItem(
                        value: 'lose_weight', child: Text('Lose weight')),
                    DropdownMenuItem(
                        value: 'gain_muscle', child: Text('Gain muscle')),
                    DropdownMenuItem(
                        value: 'mobility', child: Text('Mobility')),
                  ],
                  onChanged: (value) => setState(() => _goal = value ?? _goal),
                ),
                DropdownButtonFormField<String>(
                  value: _level,
                  decoration: const InputDecoration(labelText: 'Level'),
                  items: const [
                    DropdownMenuItem(
                        value: 'beginner', child: Text('Beginner')),
                    DropdownMenuItem(
                        value: 'intermediate', child: Text('Intermediate')),
                    DropdownMenuItem(
                        value: 'advanced', child: Text('Advanced')),
                  ],
                  onChanged: (value) =>
                      setState(() => _level = value ?? _level),
                ),
                DropdownButtonFormField<String>(
                  value: _equipment,
                  decoration: const InputDecoration(labelText: 'Equipment'),
                  items: const [
                    DropdownMenuItem(value: 'none', child: Text('None')),
                    DropdownMenuItem(value: 'chair', child: Text('Chair')),
                    DropdownMenuItem(
                        value: 'dumbbells', child: Text('Dumbbells')),
                    DropdownMenuItem(
                        value: 'resistance_band',
                        child: Text('Resistance band')),
                  ],
                  onChanged: (value) =>
                      setState(() => _equipment = value ?? _equipment),
                ),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: _loading ? null : _generate,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Generate workout plan'),
                ),
                if (_program != null) ...[
                  const SizedBox(height: 16),
                  _ProgramPreview(program: _program!),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _saving ? null : _saveProgram,
                    icon: _saving
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.save_outlined),
                    label: const Text('Save as custom program'),
                  ),
                ],
              ],
            ),
    );
  }

  Future<void> _generate() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    setState(() => _loading = true);
    try {
      final user = await FirestoreService().getUser(uid);
      final program = await _ai.generateWorkoutProgram(
        user,
        goal: _goal,
        level: _level,
        equipment: _equipment,
      );
      setState(() => _program = program);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to generate workout plan: $error')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _saveProgram() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final program = _program;
    if (uid == null || program == null) return;
    setState(() => _saving = true);
    try {
      final saved = await _repository.saveCustomProgram(uid, program);
      if (!mounted) return;
      context.pushReplacement(AppRoutes.workoutDetail, extra: saved);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }
}

class _ProgramPreview extends StatelessWidget {
  const _ProgramPreview({required this.program});

  final WorkoutProgram program;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(program.title, style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(program.description),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(label: Text(program.level)),
                Chip(label: Text(program.equipment)),
                Chip(label: Text('${program.durationWeeks} weeks')),
                Chip(label: Text('${program.daysPerWeek} days/week')),
              ],
            ),
            const SizedBox(height: 12),
            for (final day in program.workoutDays)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Day ${day.day}: ${day.title}'),
                subtitle: Text(day.exerciseIds.join(', ')),
              ),
          ],
        ),
      ),
    );
  }
}
