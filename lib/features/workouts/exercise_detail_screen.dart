import 'package:flutter/material.dart';
import 'package:nutri_tracker/models/exercise.dart';

class ExerciseDetailScreen extends StatelessWidget {
  const ExerciseDetailScreen({super.key, required this.exercise});

  final Exercise exercise;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exercise.name)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  Chip(label: Text(exercise.category)),
                  Chip(label: Text(exercise.level)),
                  Chip(label: Text(exercise.equipment)),
                  Chip(label: Text('MET ${exercise.metValue}')),
                ],
              ),
            ),
          ),
          _ListCard(title: 'Instructions', items: exercise.instructions),
          _ListCard(title: 'Form tips', items: exercise.formTips),
          _ListCard(title: 'Common mistakes', items: exercise.commonMistakes),
          _ListCard(
            title: 'Alternatives',
            items: exercise.alternatives.isEmpty
                ? const ['No listed alternatives.']
                : exercise.alternatives,
          ),
        ],
      ),
    );
  }
}

class _ListCard extends StatelessWidget {
  const _ListCard({required this.title, required this.items});

  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final item in items)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('- '),
                    Expanded(child: Text(item)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
