import '../models/workout.dart';

class GoalRules {
  /// MET-based estimate: kcal = MET × 3.5 × weight(kg) / 200 × minutes.
  static int estimateCalories({required double met, required double weightKg, required int minutes}) {
    if (met <= 0 || weightKg <= 0 || minutes <= 0) return 0;
    return (met * 3.5 * weightKg / 200 * minutes).round();
  }

  static double progress({required double current, required double target}) =>
      target <= 0 ? 0 : (current / target).clamp(0, 1).toDouble();

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Số ngày tập liên tiếp tính đến hôm nay (hôm nay chưa tập thì tính từ hôm qua).
  static int streak(List<DateTime> workoutDates, {DateTime? today}) {
    final now = today ?? DateTime.now();
    final days = workoutDates.map(_day).toSet();
    var cursor = _day(now);
    if (!days.contains(cursor)) cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    var count = 0;
    while (days.contains(cursor)) {
      count++;
      cursor = DateTime(cursor.year, cursor.month, cursor.day - 1);
    }
    return count;
  }

  static int weeklyMinutes(List<int> minutes) => minutes.fold(0, (sum, value) => sum + (value < 0 ? 0 : value));

  /// Ngày [date] có nằm trong [days] ngày gần nhất (tính cả hôm nay) không.
  static bool isInLastDays(DateTime date, int days, {DateTime? now}) {
    final n = now ?? DateTime.now();
    final today = DateTime(n.year, n.month, n.day);
    final start = DateTime(n.year, n.month, n.day - (days - 1));
    final d = _day(date);
    return !d.isBefore(start) && !d.isAfter(today);
  }

  /// Chuỗi ngày tập liên tiếp dài nhất từ trước đến nay.
  static int bestStreak(List<DateTime> workoutDates) {
    final days = workoutDates.map(_day).toSet().toList()..sort();
    var best = 0;
    var run = 0;
    DateTime? prev;
    for (final d in days) {
      if (prev != null && d == DateTime(prev.year, prev.month, prev.day + 1)) {
        run++;
      } else {
        run = 1;
      }
      if (run > best) best = run;
      prev = d;
    }
    return best;
  }

  /// Tổng số phút tập theo từng ngày (khoá là 0 giờ của ngày đó).
  static Map<DateTime, int> minutesByDay(List<Workout> workouts) {
    final map = <DateTime, int>{};
    for (final w in workouts) {
      final d = _day(w.date);
      map[d] = (map[d] ?? 0) + w.minutes;
    }
    return map;
  }

  /// Các buổi tập trong [days] ngày gần nhất (tính cả hôm nay).
  static List<Workout> inLastDays(List<Workout> workouts, int days, {DateTime? now}) {
    final today = _day(now ?? DateTime.now());
    final from = DateTime(today.year, today.month, today.day - (days - 1));
    return workouts.where((w) => !_day(w.date).isBefore(from)).toList();
  }

  /// Giá trị hiện tại của một mục tiêu, tính tự động từ dữ liệu thật.
  /// steps: số bước hôm nay; calories: calo đốt hôm nay; workouts: số buổi tập 7 ngày gần nhất;
  /// minutes: số phút tập 7 ngày gần nhất; streak: chuỗi ngày tập hiện tại.
  static double currentValue({
    required String type,
    required int stepsToday,
    required List<Workout> workouts,
    DateTime? now,
  }) {
    switch (type) {
      case 'steps':
        return stepsToday.toDouble();
      case 'calories':
        return inLastDays(workouts, 1, now: now).fold<int>(0, (sum, w) => sum + w.calories).toDouble();
      case 'workouts':
        return inLastDays(workouts, 7, now: now).length.toDouble();
      case 'minutes':
        return inLastDays(workouts, 7, now: now).fold<int>(0, (sum, w) => sum + w.minutes).toDouble();
      case 'streak':
        return streak(workouts.map((w) => w.date).toList(), today: now).toDouble();
      default:
        return 0;
    }
  }
}
