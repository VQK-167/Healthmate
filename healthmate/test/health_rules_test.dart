import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/health_rules.dart';

void main() {
  group('calculateBmi', () {
    test('computes weight(kg) / height(m)^2', () {
      expect(calculateBmi(heightCm: 170, weightKg: 65), closeTo(22.49, 0.01));
    });

    test('rejects non-positive inputs', () {
      expect(() => calculateBmi(heightCm: 0, weightKg: 65), throwsArgumentError);
      expect(() => calculateBmi(heightCm: 170, weightKg: -1), throwsArgumentError);
    });
  });

  group('classifyBmi', () {
    test('boundaries follow WHO thresholds', () {
      expect(classifyBmi(18.4), BmiCategory.underweight);
      expect(classifyBmi(18.5), BmiCategory.normal);
      expect(classifyBmi(24.9), BmiCategory.normal);
      expect(classifyBmi(25), BmiCategory.overweight);
      expect(classifyBmi(29.9), BmiCategory.overweight);
      expect(classifyBmi(30), BmiCategory.obese);
    });
  });

  group('classifyBloodPressure', () {
    test('normal reading', () {
      expect(
        classifyBloodPressure(systolic: 110, diastolic: 70),
        BloodPressureCategory.normal,
      );
    });

    test('low reading', () {
      expect(
        classifyBloodPressure(systolic: 85, diastolic: 55),
        BloodPressureCategory.low,
      );
    });

    test('elevated reading', () {
      expect(
        classifyBloodPressure(systolic: 122, diastolic: 75),
        BloodPressureCategory.elevated,
      );
    });

    test('stage 1 hypertension when either reading crosses its threshold', () {
      expect(
        classifyBloodPressure(systolic: 132, diastolic: 78),
        BloodPressureCategory.hypertensionStage1,
      );
      expect(
        classifyBloodPressure(systolic: 125, diastolic: 82),
        BloodPressureCategory.hypertensionStage1,
      );
    });

    test('stage 2 hypertension', () {
      expect(
        classifyBloodPressure(systolic: 145, diastolic: 95),
        BloodPressureCategory.hypertensionStage2,
      );
    });

    test('hypertensive crisis', () {
      expect(
        classifyBloodPressure(systolic: 185, diastolic: 100),
        BloodPressureCategory.hypertensiveCrisis,
      );
      expect(
        classifyBloodPressure(systolic: 150, diastolic: 125),
        BloodPressureCategory.hypertensiveCrisis,
      );
    });
  });

  group('classifyHeartRate', () {
    test('boundaries', () {
      expect(classifyHeartRate(59), HeartRateCategory.low);
      expect(classifyHeartRate(60), HeartRateCategory.normal);
      expect(classifyHeartRate(100), HeartRateCategory.normal);
      expect(classifyHeartRate(101), HeartRateCategory.high);
    });
  });

  group('isAbnormalReading', () {
    test('false when every provided reading is normal', () {
      expect(
        isAbnormalReading(bmi: 22, systolic: 110, diastolic: 70, heartRate: 70),
        isFalse,
      );
    });

    test('true when any single reading is out of range', () {
      expect(isAbnormalReading(bmi: 31), isTrue);
      expect(isAbnormalReading(systolic: 150, diastolic: 95), isTrue);
      expect(isAbnormalReading(heartRate: 110), isTrue);
    });

    test('ignores readings that were not provided', () {
      expect(isAbnormalReading(), isFalse);
    });
  });
}
