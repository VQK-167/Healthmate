import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/nutrition.dart';
import 'package:healthmate/repositories/nutrition_repository.dart';

void main() {
  final noon = DateTime(2026, 10, 30, 12, 0);

  Meal meal({
    String name = 'Phở',
    double calories = 450,
    double protein = 20,
    double quantity = 1,
  }) =>
      Meal(
        name: name,
        mealType: MealType.lunch,
        calories: calories,
        protein: protein,
        quantity: quantity,
        loggedAt: noon,
      );

  group('validateMeal', () {
    test('món hợp lệ trả về null', () {
      expect(validateMeal(meal()), isNull);
    });

    test('tên rỗng, calo âm, số phần <= 0, protein âm đều bị từ chối', () {
      expect(validateMeal(meal(name: ' ')), isNotNull);
      expect(validateMeal(meal(calories: -1)), isNotNull);
      expect(validateMeal(meal(quantity: 0)), isNotNull);
      expect(validateMeal(meal(protein: -3)), isNotNull);
    });
  });

  group('DaySummary', () {
    test('ngày không có món thì toàn số 0', () {
      final s = DaySummary.of(const []);
      expect(s.mealCount, 0);
      expect(s.calories, 0);
      expect(s.protein, 0);
    });

    test('cộng đúng theo số phần', () {
      final s = DaySummary.of([
        meal(calories: 100, protein: 10),
        meal(calories: 50, protein: 5, quantity: 2),
      ]);
      expect(s.mealCount, 2);
      expect(s.calories, closeTo(200, 0.001));
      expect(s.protein, closeTo(20, 0.001));
    });
  });

  test('isSameDay phân biệt theo ngày dương lịch', () {
    expect(isSameDay(DateTime(2026, 10, 30, 0, 1), DateTime(2026, 10, 30, 23, 59)), isTrue);
    expect(isSameDay(DateTime(2026, 10, 30, 23, 59), DateTime(2026, 10, 31, 0, 1)), isFalse);
  });
}