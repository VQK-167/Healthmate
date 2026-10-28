import 'package:flutter/foundation.dart';

import 'health_object.dart';
import 'weight_metric.dart';
import 'heart_rate_metric.dart';
import 'water_metric.dart';
import '../../models/health_metric.dart';

// Ham tong quat hoa cac doi tuong
void showObject(Object obj) {
  debugPrint('Doi tuong: $obj');
  debugPrint('Kieu du lieu: ${obj.runtimeType}');

  if (obj is HealthObject) {
    obj.showInfo();
  }

  debugPrint('--------------------');
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

  debugPrint('=== HEALTHMATE GENERICS ===');

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

debugPrint('=== HEALTH METRIC ===');

health.showInfo();
debugPrint('BMI: ${health.bmi.toStringAsFixed(2)}');
debugPrint('Tinh trang: ${health.bmiStatus}');

showObject(health);

}
