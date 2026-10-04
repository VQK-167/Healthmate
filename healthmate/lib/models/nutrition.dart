
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
 
  static MealType fromName(String name) =>
      MealType.values.firstWhere((e) => e.name == name,
          orElse: () => MealType.snack);
}
 
/// Thông tin dinh dưỡng (calo + 3 chất đa lượng)
class Nutrition {
  final double calories; // kcal
  final double protein; // gram
  final double carbs; // gram
  final double fat; // gram
 
  const Nutrition({
    this.calories = 0,
    this.protein = 0,
    this.carbs = 0,
    this.fat = 0,
  });
 
  static const Nutrition zero = Nutrition();
 
  Nutrition operator +(Nutrition other) => Nutrition(
        calories: calories + other.calories,
        protein: protein + other.protein,
        carbs: carbs + other.carbs,
        fat: fat + other.fat,
      );
 
  Nutrition operator *(double factor) => Nutrition(
        calories: calories * factor,
        protein: protein * factor,
        carbs: carbs * factor,
        fat: fat * factor,
      );
 
  factory Nutrition.fromJson(Map<String, dynamic> json) => Nutrition(
        calories: (json['calories'] as num?)?.toDouble() ?? 0,
        protein: (json['protein'] as num?)?.toDouble() ?? 0,
        carbs: (json['carbs'] as num?)?.toDouble() ?? 0,
        fat: (json['fat'] as num?)?.toDouble() ?? 0,
      );
 
  Map<String, dynamic> toJson() => {
        'calories': calories,
        'protein': protein,
        'carbs': carbs,
        'fat': fat,
      };
}
 
/// Một món ăn trong danh mục (thông tin cho 1 khẩu phần)
class Food {
  final String id;
  final String name;
  final double servingSize; // ví dụ 100
  final String servingUnit; // ví dụ 'g', 'ml', 'bát'
  final Nutrition nutrition; // dinh dưỡng cho 1 khẩu phần
 
  const Food({
    required this.id,
    required this.name,
    this.servingSize = 100,
    this.servingUnit = 'g',
    required this.nutrition,
  });
 
  Food copyWith({
    String? id,
    String? name,
    double? servingSize,
    String? servingUnit,
    Nutrition? nutrition,
  }) =>
      Food(
        id: id ?? this.id,
        name: name ?? this.name,
        servingSize: servingSize ?? this.servingSize,
        servingUnit: servingUnit ?? this.servingUnit,
        nutrition: nutrition ?? this.nutrition,
      );
 
  factory Food.fromJson(Map<String, dynamic> json) => Food(
        id: json['id'] as String,
        name: json['name'] as String,
        servingSize: (json['servingSize'] as num?)?.toDouble() ?? 100,
        servingUnit: json['servingUnit'] as String? ?? 'g',
        nutrition:
            Nutrition.fromJson(json['nutrition'] as Map<String, dynamic>),
      );
 
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'servingSize': servingSize,
        'servingUnit': servingUnit,
        'nutrition': nutrition.toJson(),
      };
}