
import '../exercises/generic/health_object.dart';

class HealthMetric extends HealthObject<String> {
  // Thong tin co ban
  double weight;
  double height;

  // Chi so suc khoe
  int heartRate;
  int steps;
  double caloriesBurned;
  double waterIntake;

  // Thoi gian ghi nhan
  DateTime recordedAt;

  HealthMetric({
    required this.weight,
    required this.height,
    required this.heartRate,
    required this.steps,
    required this.caloriesBurned,
    required this.waterIntake,
    required this.recordedAt,
  }) : super('HealthMetric');

  // Tinh BMI
  double get bmi {
    if (height <= 0) {
      return 0;
    }

    return weight / (height * height);
  }

  // Phan loai BMI
  String get bmiStatus {
    if (bmi < 18.5) {
      return 'Thiếu cân';
    } else if (bmi < 25) {
      return 'Bình thường';
    } else if (bmi < 30) {
      return 'Thừa cân';
    } else {
      return 'Béo phì';
    }
  }
}
