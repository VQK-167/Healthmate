import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/workout.dart';

void main() {
  test('Workout chuyển qua lại giữa object và map', () {
    final w = Workout(id: 'a', userId: 'u1', name: 'Chạy bộ', minutes: 30, calories: 250, date: DateTime(2026, 10, 30));
    final copy = Workout.fromMap(w.id, w.toMap());
    expect(copy.name, 'Chạy bộ');
    expect(copy.minutes, 30);
    expect(copy.calories, 250);
    expect(copy.userId, 'u1');
  });

  test('Goal tính tiến độ', () {
    const g = Goal(id: 'g', userId: 'u', type: 'steps', title: 'Đi bộ', target: 10000, current: 5000);
    expect(g.progress, 0.5);
    const empty = Goal(id: 'g', userId: 'u', type: 'steps', title: 'x', target: 0);
    expect(empty.progress, 0);
  });

  test('Goal chuyển qua lại giữa object và map', () {
    const g = Goal(id: 'g', userId: 'u', type: 'calories', title: 'Đốt calo', target: 500, unit: 'kcal');
    final copy = Goal.fromMap('g', g.toMap());
    expect(copy.type, 'calories');
    expect(copy.target, 500);
    expect(copy.unit, 'kcal');
  });
}
