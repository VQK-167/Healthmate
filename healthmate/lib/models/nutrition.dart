class Nutrition {
  String foodName;
  double calories;
  double protein;
  double carbs;
  double fat;
  DateTime date;

  Nutrition({
    required this.foodName,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    required this.date,
  });

  
  factory Nutrition.fromJson(Map<String, dynamic> json) {
    return Nutrition(
      foodName: json['foodName'] ?? '',
      calories: (json['calories'] ?? 0).toDouble(),
      protein: (json['protein'] ?? 0).toDouble(),
      carbs: (json['carbs'] ?? 0).toDouble(),
      fat: (json['fat'] ?? 0).toDouble(),
      date: DateTime.parse(json['date']),
    );
  }


  Map<String, dynamic> toJson() {
    return {
      'foodName': foodName,
      'calories': calories,
      'protein': protein,
      'carbs': carbs,
      'fat': fat,
      'date': date.toIso8601String(),
    };
  }
}