// lib/models/nutrition.dart
// Phụ trách: Khánh - trang Dinh dưỡng
// Model món ăn (Meal) và nước uống (WaterLog), cài BaseModel của Huy.
 
import '../core/base_model.dart';
 
/// Loại bữa ăn
enum MealType {
  breakfast,
  lunch,
  dinner,
  snack;
 
  /// Tên hiển thị tiếng Việt
  String get label {
    switch (this) {
      case MealType.breakfast:
        return 'Bữa sáng';
      case MealType.lunch:
        return 'Bữa trưa';
      case MealType.dinner:
        return 'Bữa tối';
      case MealType.snack:
        return 'Ăn vặt';
    }
  }
 
  /// Đọc từ chuỗi lưu trên Firestore, không nhận ra thì coi là ăn vặt.
  static MealType fromName(String? name) => MealType.values
      .firstWhere((e) => e.name == name, orElse: () => MealType.snack);
}
 
double _toDouble(Object? v) => (v as num?)?.toDouble() ?? 0;
 
/// Một lần ăn: calo và dinh dưỡng tính cho 1 phần, nhân với số phần.
class Meal implements BaseModel {
  const Meal({
    this.id = '',
    required this.name,
    required this.mealType,
    required this.calories,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
    this.quantity = 1,
    required this.loggedAt,
  });
 
  /// Rỗng khi chưa lưu, Firestore sẽ tự sinh id.
  @override
  final String id;
  final String name;
  final MealType mealType;
  final double calories; // kcal cho 1 phần
  final double protein; // gram cho 1 phần
  final double carbs; // gram cho 1 phần
  final double fat; // gram cho 1 phần
  final double quantity; // số phần
  final DateTime loggedAt;
 
  double get totalCalories => calories * quantity;
  double get totalProtein => protein * quantity;
  double get totalCarbs => carbs * quantity;
  double get totalFat => fat * quantity;
 
  /// Đọc từ document Firestore (khớp ModelFactory của FirestoreRepository).
  factory Meal.fromMap(String id, Map<String, dynamic> data) => Meal(
        id: id,
        name: data['name'] as String? ?? '',
        mealType: MealType.fromName(data['mealType'] as String?),
        calories: _toDouble(data['calories']),
        protein: _toDouble(data['protein']),
        carbs: _toDouble(data['carbs']),
        fat: _toDouble(data['fat']),
        quantity: data['quantity'] == null ? 1 : _toDouble(data['quantity']),
        loggedAt: dateTimeFromFirestore(data['loggedAt']) ?? DateTime.now(),
      );
 
  /// Chuyển thành Map để ghi lên Firestore (id là id của document nên không lưu).
  @override
  Map<String, dynamic> toMap() => {
        'name': name,
        'mealType': mealType.name,
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
        'quantity': quantity,
        'loggedAt': dateTimeToFirestore(loggedAt),
      };
 
  Meal copyWith({
    String? id,
    String? name,
    MealType? mealType,
    double? calories,
    double? protein,
    double? carbs,
    double? fat,
    double? quantity,
    DateTime? loggedAt,
  }) =>
      Meal(
        id: id ?? this.id,
        name: name ?? this.name,
        mealType: mealType ?? this.mealType,
        calories: calories ?? this.calories,
        protein: protein ?? this.protein,
        carbs: carbs ?? this.carbs,
        fat: fat ?? this.fat,
        quantity: quantity ?? this.quantity,
        loggedAt: loggedAt ?? this.loggedAt,
      );
}
 
/// Một lần uống nước (ml).
class WaterLog implements BaseModel {
  const WaterLog({
    this.id = '',
    required this.amountMl,
    required this.loggedAt,
  });
 
  @override
  final String id;
  final int amountMl;
  final DateTime loggedAt;
 
  factory WaterLog.fromMap(String id, Map<String, dynamic> data) => WaterLog(
        id: id,
        amountMl: (data['amountMl'] as num?)?.toInt() ?? 0,
        loggedAt: dateTimeFromFirestore(data['loggedAt']) ?? DateTime.now(),
      );
 
  @override
  Map<String, dynamic> toMap() => {
        'amountMl': amountMl,
        'loggedAt': dateTimeToFirestore(loggedAt),
      };
}
 
// ---------- Các hàm thuần, dùng cho Home và cho unit test ----------
 
/// Tổng calo của danh sách bữa ăn.
double sumCalories(Iterable<Meal> meals) =>
    meals.fold(0.0, (sum, m) => sum + m.totalCalories);
 
/// Tổng nước uống (ml).
int sumWaterMl(Iterable<WaterLog> logs) =>
    logs.fold(0, (sum, l) => sum + l.amountMl);
 
/// Gom bữa ăn theo loại bữa; bữa nào chưa có món thì là danh sách rỗng.
Map<MealType, List<Meal>> groupByMealType(Iterable<Meal> meals) => {
      for (final type in MealType.values)
        type: meals.where((m) => m.mealType == type).toList(),
    };
 
/// 0h sáng của ngày [d] (dùng để lọc "hôm nay").
DateTime startOfDay(DateTime d) => DateTime(d.year, d.month, d.day);
 
/// Kiểm tra dữ liệu người dùng nhập. Trả về thông báo lỗi, hoặc null nếu hợp lệ.
String? validateMealInput({
  required String name,
  required String calories,
  String quantity = '1',
}) {
  final n = name.trim();
  if (n.isEmpty) return 'Vui lòng nhập tên món';
  if (n.length > 60) return 'Tên món tối đa 60 ký tự';
  final cal = double.tryParse(calories.trim().replaceAll(',', '.'));
  if (cal == null || cal < 0) return 'Calo phải là số không âm';
  final qty = double.tryParse(quantity.trim().replaceAll(',', '.'));
  if (qty == null || qty <= 0) return 'Số phần phải lớn hơn 0';
  return null;
}