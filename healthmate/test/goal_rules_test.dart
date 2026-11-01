import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/goal_rules.dart';
import 'package:healthmate/models/workout.dart';

Workout _w(DateTime date, {int minutes = 30, int calories = 200}) =>
    Workout(id: 'w', userId: 'u', name: 'Tập', minutes: minutes, calories: calories, date: date);

void main() {
  test('ước tính calo theo MET', () {
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
    expect(GoalRules.streak([today, today.subtract(const Duration(days: 1))], today: today), 2);
    expect(GoalRules.streak([], today: today), 0);
    expect(GoalRules.streak([DateTime(2026, 10, 29)], today: today), 1);
    expect(GoalRules.streak([DateTime(2026, 10, 27)], today: today), 0);
  });

  test('chuỗi ngày dài nhất', () {
    final dates = [
      DateTime(2026, 10, 1),
      DateTime(2026, 10, 2),
      DateTime(2026, 10, 3),
      DateTime(2026, 10, 3, 18), // cùng ngày, không tính thêm
      DateTime(2026, 10, 10),
      DateTime(2026, 10, 11),
    ];
    expect(GoalRules.bestStreak(dates), 3);
    expect(GoalRules.bestStreak([]), 0);
  });

  test('tổng thời gian tuần bỏ qua số âm', () {
    expect(GoalRules.weeklyMinutes([20, 30, -2]), 50);
  });

  test('ngày nằm trong N ngày gần nhất', () {
    final now = DateTime(2026, 10, 30, 15);
    expect(GoalRules.isInLastDays(DateTime(2026, 10, 30, 7), 1, now: now), true);
    expect(GoalRules.isInLastDays(DateTime(2026, 10, 29), 1, now: now), false);
    expect(GoalRules.isInLastDays(DateTime(2026, 10, 24), 7, now: now), true);
    expect(GoalRules.isInLastDays(DateTime(2026, 10, 23), 7, now: now), false);
    expect(GoalRules.isInLastDays(DateTime(2026, 10, 31), 7, now: now), false); // tương lai
  });

  test('tổng phút theo ngày', () {
    final map = GoalRules.minutesByDay([
      _w(DateTime(2026, 10, 30, 7), minutes: 20),
      _w(DateTime(2026, 10, 30, 18), minutes: 25),
      _w(DateTime(2026, 10, 29), minutes: 10),
    ]);
    expect(map[DateTime(2026, 10, 30)], 45);
    expect(map[DateTime(2026, 10, 29)], 10);
    expect(map[DateTime(2026, 10, 1)], null);
  });

  test('giá trị hiện tại của mục tiêu', () {
    final now = DateTime(2026, 10, 30, 15);
    final workouts = [
      _w(DateTime(2026, 10, 30, 7), calories: 250, minutes: 30),
      _w(DateTime(2026, 10, 29), calories: 100, minutes: 20),
      _w(DateTime(2026, 10, 20), calories: 300, minutes: 60),
    ];
    double value(String type, {int steps = 0}) =>
        GoalRules.currentValue(type: type, stepsToday: steps, workouts: workouts, now: now);
    expect(value('steps', steps: 4200), 4200);
    expect(value('calories'), 250);
    expect(value('workouts'), 2);
    expect(value('minutes'), 50);
    expect(value('streak'), 2);
    expect(value('khac'), 0);
  });
}
