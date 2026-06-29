import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nutri_tracker/models/exercise.dart';
import 'package:nutri_tracker/repositories/workout_repository.dart';
import 'package:nutri_tracker/routes/app_routes.dart';

class ExerciseLibraryScreen extends StatefulWidget {
  const ExerciseLibraryScreen({super.key});

  @override
  State<ExerciseLibraryScreen> createState() => _ExerciseLibraryScreenState();
}

class _ExerciseLibraryScreenState extends State<ExerciseLibraryScreen> {
  final _search = TextEditingController();
  String _category = 'all';
  String _level = 'all';
  String _equipment = 'all';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Exercise library')),
      body: FutureBuilder<List<Exercise>>(
        future: WorkoutRepository().loadExercises(),
        builder: (context, snapshot) {
          final exercises = _filtered(snapshot.data ?? const <Exercise>[]);
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _search,
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    labelText: 'Search exercises',
                  ),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _FilterMenu(
                      value: _category,
                      values: const [
                        'all',
                        'strength',
                        'cardio',
                        'mobility',
                        'yoga',
                        'core',
                      ],
                      onChanged: (value) => setState(() => _category = value),
                    ),
                    _FilterMenu(
                      value: _level,
                      values: const [
                        'all',
                        'beginner',
                        'intermediate',
                        'advanced'
                      ],
                      onChanged: (value) => setState(() => _level = value),
                    ),
                    _FilterMenu(
                      value: _equipment,
                      values: const ['all', 'none', 'chair', 'dumbbells'],
                      onChanged: (value) => setState(() => _equipment = value),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: exercises.isEmpty
                    ? const Center(
                        child: Text('No exercises match the filters.'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: exercises.length,
                        itemBuilder: (context, index) {
                          final exercise = exercises[index];
                          return Card(
                            child: ListTile(
                              leading: const CircleAvatar(
                                child: Icon(Icons.fitness_center),
                              ),
                              title: Text(exercise.name),
                              subtitle: Text(
                                '${exercise.category} - ${exercise.level} - ${exercise.equipment}',
                              ),
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => context.push(
                                AppRoutes.exerciseDetail,
                                extra: exercise,
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  List<Exercise> _filtered(List<Exercise> exercises) {
    final query = _search.text.toLowerCase().trim();
    return exercises.where((exercise) {
      final matchesQuery =
          query.isEmpty || exercise.name.toLowerCase().contains(query);
      final matchesCategory =
          _category == 'all' || exercise.category == _category;
      final matchesLevel = _level == 'all' || exercise.level == _level;
      final matchesEquipment =
          _equipment == 'all' || exercise.equipment == _equipment;
      return matchesQuery &&
          matchesCategory &&
          matchesLevel &&
          matchesEquipment;
    }).toList();
  }
}

class _FilterMenu extends StatelessWidget {
  const _FilterMenu({
    required this.value,
    required this.values,
    required this.onChanged,
  });

  final String value;
  final List<String> values;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: value,
      items: [
        for (final item in values)
          DropdownMenuItem(value: item, child: Text(item)),
      ],
      onChanged: (value) {
        if (value != null) onChanged(value);
      },
    );
  }
}
