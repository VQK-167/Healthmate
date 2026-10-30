import '../models/workout.dart';

/// Các hàm tính toán thuần (không dùng Firestore) nên rất dễ viết unit test.
class GoalRules {
  /// Ước tính calo theo MET: kcal = MET x 3.5 x cân nặng(kg) / 200 x số phút.
  static int estimateCalories({required double met, required double weightKg, required int minutes}) {
    if (met <= 0 || weightKg <= 0 || minutes <= 0) return 0;
    return (met * 3.5 * weightKg / 200 * minutes).round();
  }

  /// Tiến độ từ 0 đến 1 (không vượt quá 100%).
  static double progress({required double current, required double target}) {
    if (target <= 0) return 0;
    if (current >= target) return 1;
    return current / target;
  }

  /// Hai thời điểm có cùng ngày không.
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  /// Ngày [date] có nằm trong [days] ngày gần nhất (tính cả hôm nay) không.
  static bool isInLastDays(DateTime date, int days, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final start = DateTime(n.year, n.month, n.day - (days - 1));
    final d = DateTime(date.year, date.month, date.day);
    return !d.isBefore(start) && !d.isAfter(today);
  }

  static bool _hasWorkout(List<DateTime> dates, DateTime day) {
    for (final d in dates) {
      if (isSameDay(d, day)) return true;
    }
    return false;
  }

  /// Số ngày tập liên tiếp. Nếu hôm nay chưa tập thì đếm lùi từ hôm qua.
  static int streak(List<DateTime> workoutDates, {DateTime? today}) {
    var day = today ?? DateTime.now();
    if (!_hasWorkout(workoutDates, day)) {
      day = DateTime(day.year, day.month, day.day - 1);
    }
    var count = 0;
    while (_hasWorkout(workoutDates, day)) {
      count++;
      day = DateTime(day.year, day.month, day.day - 1);
    }
    return count;
  }

  /// Tổng số phút (bỏ qua số âm).
  static int weeklyMinutes(List<int> minutes) {
    var total = 0;
    for (final m in minutes) {
      if (m > 0) total += m;
    }
    return total;
  }

  /// Giá trị hiện tại của một mục tiêu, tính từ dữ liệu thật:
  /// steps = số bước hôm nay, calories = calo đốt hôm nay, workouts = số buổi tập 7 ngày gần nhất.
  static double currentValue({
    required String type,
    required int stepsToday,
    required List<Workout> workouts,
    DateTime? now,
  }) {
    if (type == 'steps') return stepsToday.toDouble();
    if (type == 'calories') {
      var sum = 0;
      for (final w in workouts) {
        if (isInLastDays(w.date, 1, now: now)) sum += w.calories;
      }
      return sum.toDouble();
    }
    if (type == 'workouts') {
      var count = 0;
      for (final w in workouts) {
        if (isInLastDays(w.date, 7, now: now)) count++;
      }
      return count.toDouble();
    }
    return 0;
  }
}
