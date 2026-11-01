import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/nutrition.dart';
import 'package:healthmate/repositories/in_memory_nutrition_store.dart';
import 'package:healthmate/repositories/nutrition_repository.dart';

void main() {
  final today = DateTime(2026, 10, 30, 12, 0);
  final yesterday = DateTime(2026, 10, 29, 12, 0);

  Meal meal(
    String name,
    double calories,
    DateTime at, {
    MealType type = MealType.lunch,
    double quantity = 1,
  }) =>
      Meal(
        name: name,
        mealType: type,
        calories: calories,
        protein: 10,
        carbs: 20,
        fat: 5,
        quantity: quantity,
        loggedAt: at,
      );

  late InMemoryNutritionStore store;

  setUp(() => store = InMemoryNutritionStore());
  tearDown(() => store.dispose());

  group('Bữa ăn', () {
    test('thêm món rồi đọc lại, món được gán id', () async {
      await store.addMeal(meal('Phở', 450, today));
      final list = await store.watchMealsOn(today).first;
      expect(list.length, 1);
      expect(list.first.name, 'Phở');
      expect(list.first.id, isNotEmpty);
    });

    test('lọc theo ngày: món ngày khác không lẫn vào', () async {
      await store.addMeal(meal('Hôm nay', 100, today));
      await store.addMeal(meal('Hôm qua', 200, yesterday));
      final a = await store.watchMealsOn(today).first;
      final b = await store.watchMealsOn(yesterday).first;
      expect(a.map((m) => m.name), ['Hôm nay']);
      expect(b.map((m) => m.name), ['Hôm qua']);
    });

    test('tổng dinh dưỡng trong ngày', () async {
      await store.addMeal(meal('A', 450, today));
      await store.addMeal(meal('B', 165, today, quantity: 2));
      final s = DaySummary.of(await store.watchMealsOn(today).first);
      expect(s.mealCount, 2);
      expect(s.calories, closeTo(780, 0.001));
    });

    test('sửa món', () async {
      await store.addMeal(meal('Cũ', 300, today));
      final saved = (await store.watchMealsOn(today).first).first;
      await store.updateMeal(saved.copyWith(name: 'Mới', calories: 100));
      final after = (await store.watchMealsOn(today).first).first;
      expect(after.name, 'Mới');
      expect(after.calories, 100);
      expect(after.id, saved.id);
    });

    test('sửa món không tồn tại thì báo lỗi', () async {
      await expectLater(
        store.updateMeal(meal('X', 1, today).copyWith(id: 'khong-co')),
        throwsA(isA<NutritionException>()),
      );
    });

    test('xóa món', () async {
      await store.addMeal(meal('A', 100, today));
      final saved = (await store.watchMealsOn(today).first).first;
      await store.deleteMeal(saved.id);
      expect(await store.watchMealsOn(today).first, isEmpty);
    });

    test('danh sách tự cập nhật khi thêm món', () async {
      final expectation = expectLater(
        store.watchMealsOn(today).map((l) => l.length),
        emitsInOrder([0, 1]),
      );
      await Future<void>.delayed(const Duration(milliseconds: 20));
      await store.addMeal(meal('A', 100, today));
      await expectation;
    });
  });

  group('Nước uống', () {
    test('cộng dồn và xóa từng lần', () async {
      await store.addWater(250, at: today);
      await store.addWater(500, at: today);
      var logs = await store.watchWaterLogsOn(today).first;
      expect(sumWaterMl(logs), 750);
      await store.deleteWaterLog(logs.first.id);
      logs = await store.watchWaterLogsOn(today).first;
      expect(sumWaterMl(logs), 500);
    });

    test('lọc theo ngày', () async {
      await store.addWater(250, at: today);
      await store.addWater(300, at: yesterday);
      expect(sumWaterMl(await store.watchWaterLogsOn(today).first), 250);
      expect(sumWaterMl(await store.watchWaterLogsOn(yesterday).first), 300);
    });

    test('lượng nước bằng 0 hoặc âm bị từ chối', () async {
      await expectLater(store.addWater(0), throwsA(isA<NutritionException>()));
      await expectLater(store.addWater(-100), throwsA(isA<NutritionException>()));
    });

    test('mục tiêu nước mặc định và tùy chỉnh', () async {
      expect(await store.getWaterGoalMl(), defaultWaterGoalMl);
      final custom = InMemoryNutritionStore(waterGoalMl: 2500);
      addTearDown(custom.dispose);
      expect(await custom.getWaterGoalMl(), 2500);
    });
  });

  group('Hàm cho Home', () {
    test('watchCaloriesToday chỉ tính hôm nay', () async {
      final now = DateTime.now();
      await store.addMeal(meal('Nay', 300, now));
      await store.addMeal(meal('Qua', 999, now.subtract(const Duration(days: 1))));
      expect(await store.watchCaloriesToday().first, closeTo(300, 0.001));
    });

    test('watchWaterToday chỉ tính hôm nay', () async {
      final now = DateTime.now();
      await store.addWater(250, at: now);
      await store.addWater(900, at: now.subtract(const Duration(days: 1)));
      expect(await store.watchWaterToday().first, 250);
    });
  });
}