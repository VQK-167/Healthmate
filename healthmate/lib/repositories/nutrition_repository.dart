
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/nutrition.dart';

/// Mục tiêu nước uống mặc định (ml) khi Profile chưa có giá trị.
const int defaultWaterGoalMl = 2000;

/// Lỗi nghiệp vụ có thông báo tiếng Việt, hiển thị thẳng cho người dùng.
class NutritionException implements Exception {
  const NutritionException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Hai thời điểm có cùng ngày dương lịch không.
bool isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;

/// Tổng dinh dưỡng của một ngày.
class DaySummary {
  const DaySummary({
    required this.mealCount,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });

  final int mealCount;
  final double calories;
  final double protein;
  final double carbs;
  final double fat;

  factory DaySummary.of(Iterable<Meal> meals) {
    var count = 0;
    var cal = 0.0, p = 0.0, c = 0.0, f = 0.0;
    for (final m in meals) {
      count++;
      cal += m.totalCalories;
      p += m.totalProtein;
      c += m.totalCarbs;
      f += m.totalFat;
    }
    return DaySummary(
      mealCount: count,
      calories: cal,
      protein: p,
      carbs: c,
      fat: f,
    );
  }
}


String? validateMeal(Meal m) {
  final error = validateMealInput(
    name: m.name,
    calories: m.calories.toString(),
    quantity: m.quantity.toString(),
  );
  if (error != null) return error;
  if (m.protein < 0 || m.carbs < 0 || m.fat < 0) {
    return 'Protein, carbs và fat không được âm';
  }
  return null;
}


abstract class NutritionStore {
  /// Các món của một ngày, sắp theo giờ ăn, tự cập nhật khi dữ liệu đổi.
  Stream<List<Meal>> watchMealsOn(DateTime day);

  /// Thêm món, trả về id được gán.
  Future<String> addMeal(Meal meal);

  /// Sửa món (theo `meal.id`).
  Future<void> updateMeal(Meal meal);

  Future<void> deleteMeal(String id);

  /// Các lần uống nước của một ngày, sắp theo giờ.
  Stream<List<WaterLog>> watchWaterLogsOn(DateTime day);

  Future<void> addWater(int ml, {DateTime? at});

  Future<void> deleteWaterLog(String id);

  /// Mục tiêu nước uống (ml) của người dùng.
  Future<int> getWaterGoalMl();

  // ----- Hàm cho màn hình Home -----

 
  Stream<double> watchCaloriesToday() =>
      watchMealsOn(DateTime.now()).map(sumCalories);


  Stream<int> watchWaterToday() =>
      watchWaterLogsOn(DateTime.now()).map(sumWaterMl);
}


class NutritionRepository extends NutritionStore {
  NutritionRepository({required this.uid, FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;


  final String uid;
  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> get _userDoc =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> get _meals =>
      _userDoc.collection('meals');

  CollectionReference<Map<String, dynamic>> get _water =>
      _userDoc.collection('water_logs');


  Query<Map<String, dynamic>> _dayQuery(
    CollectionReference<Map<String, dynamic>> collection,
    DateTime day,
  ) {
    final start = startOfDay(day);
    final end = DateTime(day.year, day.month, day.day + 1);
    return collection
        .where('loggedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('loggedAt', isLessThan: Timestamp.fromDate(end))
        .orderBy('loggedAt');
  }

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw const NutritionException('Bạn không có quyền ghi dữ liệu này');
        case 'not-found':
          throw const NutritionException('Không tìm thấy dữ liệu cần sửa');
        case 'unavailable':
          throw const NutritionException('Mất kết nối, vui lòng thử lại');
        default:
          throw NutritionException('Lỗi lưu dữ liệu: ${e.message ?? e.code}');
      }
    }
  }

  // ---------- Bữa ăn ----------

  @override
  Stream<List<Meal>> watchMealsOn(DateTime day) =>
      _dayQuery(_meals, day).snapshots().map(
            (snap) =>
                snap.docs.map((d) => Meal.fromMap(d.id, d.data())).toList(),
          );

  @override
  Future<String> addMeal(Meal meal) {
    final error = validateMeal(meal);
    if (error != null) throw NutritionException(error);
    return _guard(() async => (await _meals.add(meal.toMap())).id);
  }

  @override
  Future<void> updateMeal(Meal meal) {
    if (meal.id.isEmpty) {
      throw const NutritionException('Món chưa được lưu nên không sửa được');
    }
    final error = validateMeal(meal);
    if (error != null) throw NutritionException(error);
    return _guard(() => _meals.doc(meal.id).update(meal.toMap()));
  }

  @override
  Future<void> deleteMeal(String id) {
    if (id.isEmpty) {
      throw const NutritionException('Món chưa được lưu nên không xóa được');
    }
    return _guard(() => _meals.doc(id).delete());
  }

  // ---------- Nước uống ----------

  @override
  Stream<List<WaterLog>> watchWaterLogsOn(DateTime day) =>
      _dayQuery(_water, day).snapshots().map(
            (snap) =>
                snap.docs.map((d) => WaterLog.fromMap(d.id, d.data())).toList(),
          );

  @override
  Future<void> addWater(int ml, {DateTime? at}) {
    if (ml <= 0) {
      throw const NutritionException('Lượng nước phải lớn hơn 0');
    }
    final log = WaterLog(amountMl: ml, loggedAt: at ?? DateTime.now());
    return _guard(() => _water.add(log.toMap()));
  }

  @override
  Future<void> deleteWaterLog(String id) {
    if (id.isEmpty) {
      throw const NutritionException('Lần uống chưa được lưu nên không xóa được');
    }
    return _guard(() => _water.doc(id).delete());
  }

  @override
  Future<int> getWaterGoalMl() async {
    try {
      final snap = await _userDoc.get();
      final value = snap.data()?['waterGoalMl'];
      if (value is num && value > 0) return value.toInt();
    } on FirebaseException {
      // Bỏ qua, dùng mặc định.
    }
    return defaultWaterGoalMl;
  }
}