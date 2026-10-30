import '../core/base_model.dart';
import '../core/health_rules.dart';

/// A single health check-in: body metrics plus vitals recorded at one point
/// in time. Height/weight, blood pressure and heart rate are each optional
/// so a user can log just the readings they have on hand.
class HealthMetric implements BaseModel {
  const HealthMetric({
    this.id = '',
    required this.userId,
    required this.recordedAt,
    this.heightCm,
    this.weightKg,
    this.systolic,
    this.diastolic,
    this.heartRate,
  });

  @override
  final String id;
  final String userId;
  final DateTime recordedAt;
  final double? heightCm;
  final double? weightKg;
  final int? systolic;
  final int? diastolic;
  final int? heartRate;

  bool get hasBloodPressure => systolic != null && diastolic != null;

  double? get bmi => heightCm != null && weightKg != null
      ? calculateBmi(heightCm: heightCm!, weightKg: weightKg!)
      : null;

  BmiCategory? get bmiCategory {
    final value = bmi;
    return value == null ? null : classifyBmi(value);
  }

  BloodPressureCategory? get bloodPressureCategory => hasBloodPressure
      ? classifyBloodPressure(systolic: systolic!, diastolic: diastolic!)
      : null;

  HeartRateCategory? get heartRateCategory =>
      heartRate == null ? null : classifyHeartRate(heartRate!);

  bool get isAbnormal => isAbnormalReading(
        bmi: bmi,
        systolic: systolic,
        diastolic: diastolic,
        heartRate: heartRate,
      );

  factory HealthMetric.fromMap(String id, Map<String, dynamic> data) =>
      HealthMetric(
        id: id,
        userId: data['userId'] as String? ?? '',
        recordedAt: dateTimeFromFirestore(data['recordedAt']) ?? DateTime.now(),
        heightCm: (data['heightCm'] as num?)?.toDouble(),
        weightKg: (data['weightKg'] as num?)?.toDouble(),
        systolic: (data['systolic'] as num?)?.toInt(),
        diastolic: (data['diastolic'] as num?)?.toInt(),
        heartRate: (data['heartRate'] as num?)?.toInt(),
      );

  @override
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'recordedAt': dateTimeToFirestore(recordedAt),
        'heightCm': heightCm,
        'weightKg': weightKg,
        'systolic': systolic,
        'diastolic': diastolic,
        'heartRate': heartRate,
      };

  HealthMetric copyWith({
    DateTime? recordedAt,
    double? heightCm,
    double? weightKg,
    int? systolic,
    int? diastolic,
    int? heartRate,
  }) => HealthMetric(
        id: id,
        userId: userId,
        recordedAt: recordedAt ?? this.recordedAt,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        systolic: systolic ?? this.systolic,
        diastolic: diastolic ?? this.diastolic,
        heartRate: heartRate ?? this.heartRate,
      );
}
