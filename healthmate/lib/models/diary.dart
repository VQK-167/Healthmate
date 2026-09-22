import 'nutrition.dart';

class Diary {
  final DateTime date;
  final List<Nutrition> items;

  Diary({
    required this.date,
    required this.items,
  });


  double get totalCalories {
    return items.fold(0, (sum, item) => sum + item.calories);
  }
}