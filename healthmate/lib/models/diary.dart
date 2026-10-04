import 'nutrition.dart';
 
/// Một lần ghi món ăn vào nhật ký
class MealEntry {
  final String id;
  final Food food;
  final double quantity; // số khẩu phần (1.5 = một rưỡi khẩu phần)
  final MealType mealType;
  final DateTime loggedAt;
 
  const MealEntry({
    required this.id,
    required this.food,
    this.quantity = 1,
    required this.mealType,
    required this.loggedAt,
  });
 
  /// Tổng dinh dưỡng của entry = dinh dưỡng 1 khẩu phần x số khẩu phần
  Nutrition get totalNutrition => food.nutrition * quantity;
 
  MealEntry copyWith({
    String? id,
    Food? food,
    double? quantity,
    MealType? mealType,
    DateTime? loggedAt,
  }) =>
      MealEntry(
        id: id ?? this.id,
        food: food ?? this.food,
        quantity: quantity ?? this.quantity,
        mealType: mealType ?? this.mealType,
        loggedAt: loggedAt ?? this.loggedAt,
      );
 
  factory MealEntry.fromJson(Map<String, dynamic> json) => MealEntry(
        id: json['id'] as String,
        food: Food.fromJson(json['food'] as Map<String, dynamic>),
        quantity: (json['quantity'] as num?)?.toDouble() ?? 1,
        mealType: MealType.fromName(json['mealType'] as String),
        loggedAt: DateTime.parse(json['loggedAt'] as String),
      );
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'food': food.toJson(),
        'quantity': quantity,
        'mealType': mealType.name,
        'loggedAt': loggedAt.toIso8601String(),
      };
}
 
/// Nhật ký ăn uống của 1 người dùng trong 1 ngày
class DiaryDay {
  final String userId; // khớp với User.id bên models/user.dart
  final DateTime date;
  final double calorieGoal; // mục tiêu calo/ngày
  final List<MealEntry> entries;
 
  const DiaryDay({
    required this.userId,
    required this.date,
    this.calorieGoal = 2000,
    this.entries = const [],
  });
 
  /// Tổng dinh dưỡng cả ngày
  Nutrition get totalNutrition =>
      entries.fold(Nutrition.zero, (sum, e) => sum + e.totalNutrition);
 
  /// Calo còn lại so với mục tiêu (có thể âm nếu ăn vượt)
  double get caloriesRemaining => calorieGoal - totalNutrition.calories;
 
  /// Lấy các entry theo từng bữa
  List<MealEntry> entriesOf(MealType type) =>
      entries.where((e) => e.mealType == type).toList();
 
  /// Tổng dinh dưỡng của 1 bữa
  Nutrition nutritionOf(MealType type) => entriesOf(type)
      .fold(Nutrition.zero, (sum, e) => sum + e.totalNutrition);
 
  DiaryDay addEntry(MealEntry entry) => copyWith(entries: [...entries, entry]);
 
  DiaryDay removeEntry(String entryId) =>
      copyWith(entries: entries.where((e) => e.id != entryId).toList());
 
  DiaryDay copyWith({
    String? userId,
    DateTime? date,
    double? calorieGoal,
    List<MealEntry>? entries,
  }) =>
      DiaryDay(
        userId: userId ?? this.userId,
        date: date ?? this.date,
        calorieGoal: calorieGoal ?? this.calorieGoal,
        entries: entries ?? this.entries,
      );
 
  factory DiaryDay.fromJson(Map<String, dynamic> json) => DiaryDay(
        userId: json['userId'] as String,
        date: DateTime.parse(json['date'] as String),
        calorieGoal: (json['calorieGoal'] as num?)?.toDouble() ?? 2000,
        entries: (json['entries'] as List<dynamic>? ?? [])
            .map((e) => MealEntry.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
 
  Map<String, dynamic> toJson() => {
        'userId': userId,
        'date': date.toIso8601String(),
        'calorieGoal': calorieGoal,
        'entries': entries.map((e) => e.toJson()).toList(),
      };
}