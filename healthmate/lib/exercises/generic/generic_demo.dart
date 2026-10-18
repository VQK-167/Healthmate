import 'health_object.dart';
import 'weight_metric.dart';
import 'heart_rate_metric.dart';
import 'water_metric.dart';
import '../../models/health_metric.dart';

// Ham tong quat hoa cac doi tuong
void showObject(Object obj) {
  print('Doi tuong: $obj');
  print('Kieu du lieu: ${obj.runtimeType}');

  if (obj is HealthObject) {
    obj.showInfo();
  }

  print('--------------------');
}

void main() {
  WeightMetric weight = WeightMetric(65.5);
  HeartRateMetric heart = HeartRateMetric(75);
  WaterMetric water = WaterMetric(2.0);

  // Danh sach cac doi tuong HealthMate
  List<Object> objects = [
    weight,
    heart,
    water,
  ];

  print('=== HEALTHMATE GENERICS ===');

  for (Object obj in objects) {
    showObject(obj);
  }

HealthMetric health = HealthMetric(
  weight: 65,
  height: 1.7,
  heartRate: 75,
  steps: 5000,
  caloriesBurned: 250,
  waterIntake: 2.0,
  recordedAt: DateTime.now(),
);

print('=== HEALTH METRIC ===');

health.showInfo();
print('BMI: ${health.bmi.toStringAsFixed(2)}');
print('Tinh trang: ${health.bmiStatus}');

showObject(health);

}
