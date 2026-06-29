import 'package:nutri_tracker/services/health_service.dart';

class HealthSyncSnapshot {
  const HealthSyncSnapshot({
    this.steps = 0,
    this.activeCalories = 0,
    this.weightKg,
    this.bmi,
    this.permissionDenied = false,
    this.message = 'Health data synced.',
  });

  final int steps;
  final double activeCalories;
  final double? weightKg;
  final double? bmi;
  final bool permissionDenied;
  final String message;
}

class HealthSyncService {
  HealthSyncService({HealthService? healthService})
      : _healthService = healthService ?? HealthService();

  final HealthService _healthService;

  Future<HealthSyncSnapshot> syncToday() async {
    try {
      final steps = await _healthService.getTodaySteps();
      final activeCalories = await _healthService.getTodayActiveCalories();
      return HealthSyncSnapshot(
        steps: steps,
        activeCalories: activeCalories,
      );
    } catch (error) {
      return const HealthSyncSnapshot(
        permissionDenied: true,
        message:
            'Health permissions are unavailable. You can keep using manual tracking.',
      );
    }
  }
}
