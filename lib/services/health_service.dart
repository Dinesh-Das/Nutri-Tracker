import 'dart:io';

import 'package:health/health.dart';
import 'package:permission_handler/permission_handler.dart';

class HealthService {
  HealthService() {
    _health.configure();
  }

  final Health _health = Health();

  static const _types = [
    HealthDataType.STEPS,
    HealthDataType.ACTIVE_ENERGY_BURNED,
    HealthDataType.WEIGHT,
    HealthDataType.BODY_MASS_INDEX,
    HealthDataType.HEART_RATE,
    HealthDataType.WATER,
  ];

  static const _permissions = [
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ_WRITE,
    HealthDataAccess.READ,
    HealthDataAccess.READ,
    HealthDataAccess.READ_WRITE,
  ];

  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      await Permission.activityRecognition.request();
    }
    return _health.requestAuthorization(_types, permissions: _permissions);
  }

  Future<int> getTodaySteps() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final hasPermission =
        await _health.hasPermissions([HealthDataType.STEPS]) ?? false;
    if (!hasPermission) {
      final granted =
          await _health.requestAuthorization([HealthDataType.STEPS]);
      if (!granted) return 0;
    }
    return await _health.getTotalStepsInInterval(start, now) ?? 0;
  }

  Future<double> getTodayActiveCalories() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final granted = await requestPermissions();
    if (!granted) return 0;
    final data = await _health.getHealthDataFromTypes(
      types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      startTime: start,
      endTime: now,
    );
    return _health.removeDuplicates(data).fold<double>(
          0,
          (total, point) => total + _numericValue(point.value),
        );
  }

  Future<void> writeWeightEntry(double kg, DateTime date) async {
    final granted = await requestPermissions();
    if (!granted) return;
    await _health.writeHealthData(
      value: kg,
      type: HealthDataType.WEIGHT,
      startTime: date,
      recordingMethod: RecordingMethod.manual,
    );
  }

  Future<void> writeWaterIntake(double ml, DateTime date) async {
    final granted = await requestPermissions();
    if (!granted) return;
    await _health.writeHealthData(
      value: ml / 1000,
      type: HealthDataType.WATER,
      startTime: date,
      recordingMethod: RecordingMethod.manual,
    );
  }

  double _numericValue(HealthValue value) {
    if (value is NumericHealthValue) return value.numericValue.toDouble();
    final json = value.toJson();
    return (json['numeric_value'] as num?)?.toDouble() ?? 0;
  }
}
