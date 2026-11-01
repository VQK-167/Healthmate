
import 'dart:async';

import '../models/nutrition.dart';
import 'nutrition_repository.dart';

class InMemoryNutritionStore extends NutritionStore {
  InMemoryNutritionStore({this.waterGoalMl = defaultWaterGoalMl});

  final int waterGoalMl;

  final List<Meal> _meals = [];
  final List<WaterLog> _water = [];
  final StreamController<void> _changes = StreamController<void>.broadcast();
  int _counter = 0;

  void dispose() => _changes.close();

  List<Meal> _mealsOn(DateTime day) {
    final list = _meals.where((m) => isSameDay(m.loggedAt, day)).toList();
    list.sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    return list;
  }

  List<WaterLog> _waterOn(DateTime day) {
    final list = _water.where((w) => isSameDay(w.loggedAt, day)).toList();
    list.sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
    return list;
  }

  @override
  Stream<List<Meal>> watchMealsOn(DateTime day) async* {
    yield _mealsOn(day);
    await for (final _ in _changes.stream) {
      yield _mealsOn(day);
    }
  }

  @override
  Future<String> addMeal(Meal meal) async {
    final id = 'local${++_counter}';
    _meals.add(meal.copyWith(id: id));
    _changes.add(null);
    return id;
  }

  @override
  Future<void> updateMeal(Meal meal) async {
    final index = _meals.indexWhere((m) => m.id == meal.id);
    if (index < 0) {
      throw const NutritionException('Không tìm thấy món cần sửa');
    }
    _meals[index] = meal;
    _changes.add(null);
  }

  @override
  Future<void> deleteMeal(String id) async {
    _meals.removeWhere((m) => m.id == id);
    _changes.add(null);
  }

  @override
  Stream<List<WaterLog>> watchWaterLogsOn(DateTime day) async* {
    yield _waterOn(day);
    await for (final _ in _changes.stream) {
      yield _waterOn(day);
    }
  }

  @override
  Future<void> addWater(int ml, {DateTime? at}) async {
    if (ml <= 0) {
      throw const NutritionException('Lượng nước phải lớn hơn 0');
    }
    _water.add(WaterLog(
      id: 'local${++_counter}',
      amountMl: ml,
      loggedAt: at ?? DateTime.now(),
    ));
    _changes.add(null);
  }

  @override
  Future<void> deleteWaterLog(String id) async {
    _water.removeWhere((w) => w.id == id);
    _changes.add(null);
  }

  @override
  Future<int> getWaterGoalMl() async => waterGoalMl;
}