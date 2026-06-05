import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nutri_tracker/models/achievement.dart';
import 'package:nutri_tracker/services/achievement_service.dart';

class AchievementsScreen extends StatelessWidget {
  const AchievementsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      return const Scaffold(body: Center(child: Text('Please sign in.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Achievements')),
      body: StreamBuilder<List<Achievement>>(
        stream: AchievementService().watchAchievements(uid),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text('Unable to load achievements: ${snapshot.error}'),
            );
          }
          final unlocked = {
            for (final achievement in snapshot.data ?? const <Achievement>[])
              achievement.type: achievement,
          };
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.15,
            ),
            itemCount: AchievementType.values.length,
            itemBuilder: (context, index) {
              final type = AchievementType.values[index];
              final achievement = unlocked[type];
              return _AchievementCard(
                type: type,
                achievement: achievement,
              );
            },
          );
        },
      ),
    );
  }
}

class _AchievementCard extends StatelessWidget {
  const _AchievementCard({
    required this.type,
    required this.achievement,
  });

  final AchievementType type;
  final Achievement? achievement;

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement != null;
    final title = Achievement(type: type, unlockedAt: DateTime.now()).title;
    return Card(
      color: unlocked
          ? Theme.of(context).colorScheme.primaryContainer
          : Theme.of(context).disabledColor.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              unlocked ? Icons.emoji_events : Icons.lock_outline,
              size: 42,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              unlocked
                  ? DateFormat.yMMMd().format(achievement!.unlockedAt)
                  : 'Locked',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
