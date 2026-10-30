/// Pure calculation and classification rules for health metrics.
///
/// Kept free of Flutter/Firebase imports so the logic can be unit tested
/// without a widget or database context.
library;

enum BmiCategory { underweight, normal, overweight, obese }

enum BloodPressureCategory {
  low,
  normal,
  elevated,
  hypertensionStage1,
  hypertensionStage2,
  hypertensiveCrisis,
}

enum HeartRateCategory { low, normal, high }

/// BMI = weight(kg) / height(m)^2.
///
/// Throws [ArgumentError] when either input is not a positive number, since
/// BMI is undefined in that case.
double calculateBmi({required double heightCm, required double weightKg}) {
  if (heightCm <= 0 || weightKg <= 0) {
    throw ArgumentError('heightCm and weightKg must be positive');
  }
  final heightM = heightCm / 100;
  return weightKg / (heightM * heightM);
}

/// WHO BMI thresholds.
BmiCategory classifyBmi(double bmi) {
  if (bmi < 18.5) return BmiCategory.underweight;
  if (bmi < 25) return BmiCategory.normal;
  if (bmi < 30) return BmiCategory.overweight;
  return BmiCategory.obese;
}

String bmiCategoryLabel(BmiCategory category) {
  switch (category) {
    case BmiCategory.underweight:
      return 'Thiếu cân';
    case BmiCategory.normal:
      return 'Bình thường';
    case BmiCategory.overweight:
      return 'Thừa cân';
    case BmiCategory.obese:
      return 'Béo phì';
  }
}

/// Based on AHA blood pressure categories (mmHg). The higher of the two
/// readings determines the category.
BloodPressureCategory classifyBloodPressure({
  required int systolic,
  required int diastolic,
}) {
  if (systolic > 180 || diastolic > 120) {
    return BloodPressureCategory.hypertensiveCrisis;
  }
  if (systolic >= 140 || diastolic >= 90) {
    return BloodPressureCategory.hypertensionStage2;
  }
  if (systolic >= 130 || diastolic >= 80) {
    return BloodPressureCategory.hypertensionStage1;
  }
  if (systolic >= 120) {
    return BloodPressureCategory.elevated;
  }
  if (systolic < 90 || diastolic < 60) {
    return BloodPressureCategory.low;
  }
  return BloodPressureCategory.normal;
}

String bloodPressureCategoryLabel(BloodPressureCategory category) {
  switch (category) {
    case BloodPressureCategory.low:
      return 'Huyết áp thấp';
    case BloodPressureCategory.normal:
      return 'Bình thường';
    case BloodPressureCategory.elevated:
      return 'Tiền tăng huyết áp';
    case BloodPressureCategory.hypertensionStage1:
      return 'Tăng huyết áp độ 1';
    case BloodPressureCategory.hypertensionStage2:
      return 'Tăng huyết áp độ 2';
    case BloodPressureCategory.hypertensiveCrisis:
      return 'Cơn tăng huyết áp (nguy hiểm)';
  }
}

/// Resting heart rate classification for a general adult (bpm).
HeartRateCategory classifyHeartRate(int bpm) {
  if (bpm < 60) return HeartRateCategory.low;
  if (bpm > 100) return HeartRateCategory.high;
  return HeartRateCategory.normal;
}

String heartRateCategoryLabel(HeartRateCategory category) {
  switch (category) {
    case HeartRateCategory.low:
      return 'Nhịp tim chậm';
    case HeartRateCategory.normal:
      return 'Bình thường';
    case HeartRateCategory.high:
      return 'Nhịp tim nhanh';
  }
}

/// True when any of the three readings falls outside the "normal" band —
/// used to drive the warning banner on the health page.
bool isAbnormalReading({
  double? bmi,
  int? systolic,
  int? diastolic,
  int? heartRate,
}) {
  if (bmi != null && classifyBmi(bmi) != BmiCategory.normal) return true;
  if (systolic != null && diastolic != null &&
      classifyBloodPressure(systolic: systolic, diastolic: diastolic) !=
          BloodPressureCategory.normal) {
    return true;
  }
  if (heartRate != null && classifyHeartRate(heartRate) != HeartRateCategory.normal) {
    return true;
  }
  return false;
}
