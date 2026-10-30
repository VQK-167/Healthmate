import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/goal_rules.dart';
import 'package:healthmate/models/workout.dart';

Workout _workout(DateTime date, {int calories = 200}) {
  return Workout(id: 'w', userId: 'u', name: 'Tập', minutes: 30, calories: calories, date: date);
}

void main() {
  test('ước tính calo theo MET', () {
    // 8 x 3.5 x 60 / 200 x 30 = 252
    expect(GoalRules.estimateCalories(met: 8, weightKg: 60, minutes: 30), 252);
    expect(GoalRules.estimateCalories(met: 8, weightKg: 0, minutes: 30), 0);
  });

  test('tiến độ không vượt quá 100%', () {
    expect(GoalRules.progress(current: 120, target: 100), 1);
    expect(GoalRules.progress(current: 2, target: 0), 0);
    expect(GoalRules.progress(current: 50, target: 100), 0.5);
  });

  test('tính chuỗi ngày tập liên tiếp', () {
    final today = DateTime(2026, 10, 30);
    expect(GoalRules.streak([today, DateTime(2026, 10, 29)], today: today), 2);
    expect(GoalRules.streak([], today: today), 0);
    expect(GoalRules.streak([DateTime(2026, 10, 29)], today: today), 1); // hôm nay chưa tập vẫn giữ chuỗi
    expect(GoalRules.streak([DateTime(2026, 10, 27)], today: today), 0); // đứt chuỗi
  });

  test('tổng thời gian bỏ qua số âm', () {
    expect(GoalRules.weeklyMinutes([20, 30, -2]), 50);
  });

  test('kiểm tra ngày nằm trong N ngày gần nhất', () {
    final now = DateTime(2026, 10, 30, 15);
    expect(GoalRules.isInLastDays(DateTime(2026, 10, 30, 7), 1, now: now), true);
    expect(GoalRules.isInLastDays(DateTime(2026, 10, 29), 1, now: now), false);
    expect(GoalRules.isInLastDays(DateTime(2026, 10, 24), 7, now: now), true);
    expect(GoalRules.isInLastDays(DateTime(2026, 10, 23), 7, now: now), false);
  });

  test('giá trị hiện tại của mục tiêu', () {
    final now = DateTime(2026, 10, 30, 15);
    final workouts = [
      _workout(DateTime(2026, 10, 30, 7), calories: 250),
      _workout(DateTime(2026, 10, 29), calories: 100),
      _workout(DateTime(2026, 10, 20), calories: 300),
    ];
    expect(GoalRules.currentValue(type: 'steps', stepsToday: 4200, workouts: workouts, now: now), 4200);
    expect(GoalRules.currentValue(type: 'calories', stepsToday: 0, workouts: workouts, now: now), 250);
    expect(GoalRules.currentValue(type: 'workouts', stepsToday: 0, workouts: workouts, now: now), 2);
  });
}
