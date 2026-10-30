import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/preset_foods.dart';
import 'package:healthmate/models/nutrition.dart';
 
void main() {
  final noon = DateTime(2026, 10, 30, 12, 0);
 
  Meal meal({
    String id = 'm1',
    MealType type = MealType.lunch,
    double calories = 550,
    double quantity = 1,
  }) =>
      Meal(
        id: id,
        name: 'Cơm tấm',
        mealType: type,
        calories: calories,
        protein: 25,
        carbs: 65,
        fat: 18,
        quantity: quantity,
        loggedAt: noon,
      );
 
  group('Meal', () {
    test('toMap lưu đúng kiểu dữ liệu và không lưu id', () {
      final map = meal().toMap();
      expect(map['name'], 'Cơm tấm');
      expect(map['mealType'], 'lunch');
      expect(map['calories'], 550);
      expect(map['loggedAt'], isA<Timestamp>());
      expect(map.containsKey('id'), isFalse);
    });
 
    test('toMap rồi fromMap giữ nguyên dữ liệu', () {
      final original = meal(quantity: 1.5);
      final copy = Meal.fromMap('m1', original.toMap());
      expect(copy.id, 'm1');
      expect(copy.name, 'Cơm tấm');
      expect(copy.mealType, MealType.lunch);
      expect(copy.calories, 550);
      expect(copy.quantity, 1.5);
      expect(copy.loggedAt, noon);
    });
 
    test('totalCalories bằng calo 1 phần nhân số phần', () {
      expect(meal(calories: 200, quantity: 2.5).totalCalories, closeTo(500, 0.001));
    });
 
    test('fromMap thiếu trường thì dùng giá trị mặc định', () {
      final m = Meal.fromMap('x', {'name': 'Chuối', 'loggedAt': noon});
      expect(m.id, 'x');
      expect(m.calories, 0);
      expect(m.quantity, 1);
      expect(m.mealType, MealType.snack);
    });
 
    test('fromMap đọc được loggedAt dạng chuỗi', () {
      final m = Meal.fromMap('x', {'name': 'A', 'loggedAt': noon.toIso8601String()});
      expect(m.loggedAt, noon);
    });
 
    test('copyWith chỉ đổi trường được truyền vào', () {
      final changed = meal().copyWith(name: 'Phở', quantity: 2);
      expect(changed.name, 'Phở');
      expect(changed.quantity, 2);
      expect(changed.calories, 550);
      expect(changed.id, 'm1');
    });
  });
 
  group('WaterLog', () {
    test('toMap rồi fromMap giữ nguyên dữ liệu', () {
      final log = WaterLog(id: 'w1', amountMl: 250, loggedAt: noon);
      final copy = WaterLog.fromMap('w1', log.toMap());
      expect(copy.id, 'w1');
      expect(copy.amountMl, 250);
      expect(copy.loggedAt, noon);
    });
  });
 
  group('Hàm tổng hợp', () {
    test('sumCalories cộng đúng, danh sách rỗng ra 0', () {
      expect(sumCalories([]), 0);
      expect(
        sumCalories([meal(calories: 550), meal(id: 'm2', calories: 165, quantity: 2)]),
        closeTo(880, 0.001),
      );
    });
 
    test('sumWaterMl cộng đúng', () {
      final logs = [
        WaterLog(id: '1', amountMl: 250, loggedAt: noon),
        WaterLog(id: '2', amountMl: 500, loggedAt: noon),
      ];
      expect(sumWaterMl(logs), 750);
      expect(sumWaterMl([]), 0);
    });
 
    test('groupByMealType có đủ 4 bữa và phân đúng món', () {
      final grouped = groupByMealType([
        meal(id: 'a', type: MealType.breakfast),
        meal(id: 'b', type: MealType.dinner),
        meal(id: 'c', type: MealType.dinner),
      ]);
      expect(grouped.keys.length, 4);
      expect(grouped[MealType.breakfast]!.length, 1);
      expect(grouped[MealType.lunch]!, isEmpty);
      expect(grouped[MealType.dinner]!.length, 2);
    });
 
    test('startOfDay đưa giờ về 0h', () {
      expect(startOfDay(noon), DateTime(2026, 10, 30));
    });
  });
 
  group('validateMealInput', () {
    test('hợp lệ trả về null', () {
      expect(validateMealInput(name: 'Phở', calories: '450'), isNull);
      expect(validateMealInput(name: 'Phở', calories: '450,5', quantity: '0.5'), isNull);
    });
 
    test('tên rỗng bị từ chối', () {
      expect(validateMealInput(name: '   ', calories: '100'), isNotNull);
    });
 
    test('calo sai bị từ chối', () {
      expect(validateMealInput(name: 'A', calories: 'abc'), isNotNull);
      expect(validateMealInput(name: 'A', calories: '-5'), isNotNull);
      expect(validateMealInput(name: 'A', calories: ''), isNotNull);
    });
 
    test('số phần phải lớn hơn 0', () {
      expect(validateMealInput(name: 'A', calories: '100', quantity: '0'), isNotNull);
      expect(validateMealInput(name: 'A', calories: '100', quantity: 'x'), isNotNull);
    });
  });
 
  group('presetFoods', () {
    test('có món và dữ liệu hợp lệ', () {
      expect(presetFoods, isNotEmpty);
      for (final f in presetFoods) {
        expect(f.name.trim(), isNotEmpty);
        expect(f.calories, greaterThan(0));
      }
    });
 
    test('toMeal tạo đúng bữa ăn, id rỗng để Firestore tự sinh', () {
      final first = presetFoods.first;
      final m = first.toMeal(mealType: MealType.breakfast, quantity: 2, at: noon);
      expect(m.id, '');
      expect(m.name, first.name);
      expect(m.mealType, MealType.breakfast);
      expect(m.totalCalories, closeTo(first.calories * 2, 0.001));
    });
  });
}