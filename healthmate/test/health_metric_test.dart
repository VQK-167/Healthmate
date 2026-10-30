import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/health_rules.dart';
import 'package:healthmate/models/health_metric.dart';

void main() {
  final recordedAt = DateTime(2026, 10, 30, 8, 0);

  test('derives bmi/category/blood pressure/heart rate from raw fields', () {
    final metric = HealthMetric(
      userId: 'u1',
      recordedAt: recordedAt,
      heightCm: 170,
      weightKg: 65,
      systolic: 150,
      diastolic: 95,
      heartRate: 110,
    );

    expect(metric.bmi, closeTo(22.49, 0.01));
    expect(metric.bmiCategory, BmiCategory.normal);
    expect(metric.hasBloodPressure, isTrue);
    expect(metric.bloodPressureCategory, BloodPressureCategory.hypertensionStage2);
    expect(metric.heartRateCategory, HeartRateCategory.high);
    expect(metric.isAbnormal, isTrue);
  });

  test('leaves derived fields null when raw inputs are missing', () {
    final metric = HealthMetric(userId: 'u1', recordedAt: DateTime(2026, 10, 30));

    expect(metric.bmi, isNull);
    expect(metric.bmiCategory, isNull);
    expect(metric.hasBloodPressure, isFalse);
    expect(metric.bloodPressureCategory, isNull);
    expect(metric.heartRateCategory, isNull);
    expect(metric.isAbnormal, isFalse);
  });

  test('round-trips through toMap/fromMap', () {
    final metric = HealthMetric(
      userId: 'u1',
      recordedAt: recordedAt,
      heightCm: 170,
      weightKg: 65,
      systolic: 120,
      diastolic: 80,
      heartRate: 72,
    );

    final restored = HealthMetric.fromMap('doc1', metric.toMap());

    expect(restored.id, 'doc1');
    expect(restored.userId, metric.userId);
    expect(restored.recordedAt, metric.recordedAt);
    expect(restored.heightCm, metric.heightCm);
    expect(restored.weightKg, metric.weightKg);
    expect(restored.systolic, metric.systolic);
    expect(restored.diastolic, metric.diastolic);
    expect(restored.heartRate, metric.heartRate);
  });

  test('copyWith overrides only the given fields', () {
    final metric = HealthMetric(userId: 'u1', recordedAt: recordedAt, weightKg: 65);
    final updated = metric.copyWith(weightKg: 64);

    expect(updated.weightKg, 64);
    expect(updated.userId, metric.userId);
    expect(updated.recordedAt, metric.recordedAt);
  });
}
