import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/workout.dart';
import 'package:healthmate/screens/workout_widgets.dart';

void main() {
  final date = DateTime(2026, 10, 30);

  test('Workout chuyển đổi map (có loại và ghi chú)', () {
    final w = Workout(id: 'a', userId: 'u1', name: 'Chạy bộ', minutes: 30, calories: 250, date: date, type: 'run', note: 'Công viên');
    final copy = Workout.fromMap(w.id, w.toMap());
    expect(copy.name, 'Chạy bộ');
    expect(copy.minutes, 30);
    expect(copy.calories, 250);
    expect(copy.userId, 'u1');
    expect(copy.type, 'run');
    expect(copy.note, 'Công viên');
  });

  test('Buổi tập cũ không có type và note vẫn đọc được', () {
    final old = Workout.fromMap('x', {'userId': 'u', 'name': 'Đi bộ', 'minutes': 20, 'calories': 70});
    expect(old.type, 'other');
    expect(old.note, '');
  });

  test('Workout.copyWith giữ id và userId', () {
    final w = Workout(id: 'a', userId: 'u1', name: 'Chạy bộ', minutes: 30, calories: 250, date: date);
    final edited = w.copyWith(minutes: 45, type: 'bike');
    expect(edited.id, 'a');
    expect(edited.userId, 'u1');
    expect(edited.minutes, 45);
    expect(edited.type, 'bike');
  });

  test('Đoán loại bài tập từ tên khi chưa có type', () {
    Workout named(String n) => Workout(id: 'a', userId: 'u', name: n, minutes: 10, calories: 50, date: date);
    expect(sportKindOf(named('Chạy bộ sáng')).key, 'run');
    expect(sportKindOf(named('Yoga buổi tối')).key, 'yoga');
    expect(sportKindOf(named('abc')).key, 'other');
    expect(sportKindOf(named('abc').copyWith(type: 'swim')).key, 'swim');
  });

  test('Goal tính tiến độ', () {
    const g = Goal(id: 'g', userId: 'u', type: 'steps', title: 'Đi bộ', target: 10000, current: 5000);
    expect(g.progress, 0.5);
    const empty = Goal(id: 'g', userId: 'u', type: 'steps', title: 'x', target: 0);
    expect(empty.progress, 0);
  });

  test('Goal chuyển đổi map', () {
    const g = Goal(id: 'g', userId: 'u', type: 'calories', title: 'Đốt calo', target: 500, unit: 'kcal');
    final copy = Goal.fromMap('g', g.toMap());
    expect(copy.type, 'calories');
    expect(copy.target, 500);
    expect(copy.unit, 'kcal');
  });
}
