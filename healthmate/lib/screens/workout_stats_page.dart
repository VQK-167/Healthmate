import 'package:flutter/material.dart';

import '../core/goal_rules.dart';
import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import 'workout_widgets.dart';

const List<String> _kWeekdayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

/// Trang thống kê: tổng quan theo kỳ, biểu đồ, phân bổ theo loại bài tập,
/// lịch tập 5 tuần, bước chân, kỷ lục cá nhân và huy hiệu.
class WorkoutStatsPage extends StatefulWidget {
  const WorkoutStatsPage({super.key});

  @override
  State<WorkoutStatsPage> createState() => _WorkoutStatsPageState();
}

class _WorkoutStatsPageState extends State<WorkoutStatsPage> {
  final WorkoutRepository _repo = WorkoutRepository();
  late Stream<List<Workout>> _workouts;
  late Stream<Map<String, int>> _stepsHistory;
  int _days = 7;

  @override
  void initState() {
    super.initState();
    _workouts = _repo.watchWorkouts();
    _stepsHistory = _repo.watchStepsHistory();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Thống kê tập luyện')),
      body: StreamBuilder<List<Workout>>(
        stream: _workouts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Không tải được dữ liệu.\n${snapshot.error}', textAlign: TextAlign.center));
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final all = snapshot.data!;
          if (all.isEmpty) {
            return const Center(child: Text('Chưa có dữ liệu để thống kê.\nHãy thêm buổi tập đầu tiên!', textAlign: TextAlign.center));
          }
          final period = all.where((w) => GoalRules.isInLastDays(w.date, _days)).toList();
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            children: [
              SportFadeIn(index: 0, child: _periodSelector()),
              const SizedBox(height: 12),
              SportFadeIn(index: 1, child: _summary(period)),
              const SizedBox(height: 8),
              SportFadeIn(index: 2, child: _minutesChart(all)),
              SportFadeIn(index: 3, child: _breakdown(period)),
              SportFadeIn(index: 4, child: _heatmap(all)),
              SportFadeIn(index: 5, child: _stepsCard()),
              SportFadeIn(index: 6, child: _records(all)),
              SportFadeIn(index: 7, child: _badges(all)),
            ],
          );
        },
      ),
    );
  }

  Widget _periodSelector() {
    return Row(
      children: [
        const Text('Xem theo:'),
        const SizedBox(width: 10),
        ChoiceChip(label: const Text('7 ngày'), selected: _days == 7, onSelected: (_) => setState(() => _days = 7)),
        const SizedBox(width: 6),
        ChoiceChip(label: const Text('30 ngày'), selected: _days == 30, onSelected: (_) => setState(() => _days = 30)),
      ],
    );
  }

  // ---------------- Tổng quan ----------------

  Widget _summary(List<Workout> period) {
    final minutes = period.fold<int>(0, (s, w) => s + w.minutes);
    final calories = period.fold<int>(0, (s, w) => s + w.calories);
    final avg = period.isEmpty ? 0 : (minutes / period.length).round();
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _statTile(Icons.fitness_center, '${period.length}', 'Buổi tập')),
            const SizedBox(width: 8),
            Expanded(child: _statTile(Icons.timer_outlined, '$minutes', 'Tổng phút')),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: _statTile(Icons.local_fire_department_outlined, '$calories', 'Tổng kcal')),
            const SizedBox(width: 8),
            Expanded(child: _statTile(Icons.speed, '$avg', 'Phút / buổi')),
          ],
        ),
      ],
    );
  }

  Widget _statTile(IconData icon, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: scheme.primaryContainer, borderRadius: BorderRadius.circular(18)),
      child: Row(
        children: [
          Icon(icon, color: scheme.onPrimaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SportCountUp(value: int.tryParse(value) ?? 0, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: scheme.onPrimaryContainer)),
                Text(label, style: TextStyle(fontSize: 12, color: scheme.onPrimaryContainer)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Biểu đồ phút theo ngày ----------------

  Widget _minutesChart(List<Workout> all) {
    final now = DateTime.now();
    final days = List<DateTime>.generate(_days, (i) => DateTime(now.year, now.month, now.day - (_days - 1 - i)));
    final byDay = GoalRules.minutesByDay(all);
    final values = days.map((d) => byDay[d] ?? 0).toList();
    final labels = <String>[];
    for (var i = 0; i < days.length; i++) {
      if (_days == 7) {
        labels.add(_kWeekdayLabels[days[i].weekday - 1]);
      } else {
        labels.add(i % 5 == 4 ? '${days[i].day}' : '');
      }
    }
    final tips = [for (var i = 0; i < days.length; i++) '${days[i].day}/${days[i].month}: ${values[i]} phút'];
    return _card(
      title: 'Phút tập mỗi ngày',
      child: SportBarChart(values: values, labels: labels, tips: tips),
    );
  }

  // ---------------- Phân bổ theo loại ----------------

  Widget _breakdown(List<Workout> period) {
    final scheme = Theme.of(context).colorScheme;
    final byKind = <String, int>{};
    var total = 0;
    for (final w in period) {
      final key = sportKindOf(w).key;
      byKind[key] = (byKind[key] ?? 0) + w.minutes;
      total += w.minutes;
    }
    final entries = byKind.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    return _card(
      title: 'Phân bổ theo loại bài tập',
      child: total == 0
          ? const Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Chưa có buổi tập trong khoảng này.'))
          : Column(
              children: [
                for (final e in entries)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: sportKindByKey(e.key).color.withAlpha(45),
                          foregroundColor: sportKindByKey(e.key).color,
                          child: Icon(sportKindByKey(e.key).icon, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(sportKindByKey(e.key).label, style: const TextStyle(fontWeight: FontWeight.w600)),
                                  const Spacer(),
                                  Text('${e.value} phút • ${(e.value / total * 100).toStringAsFixed(0)}%', style: const TextStyle(fontSize: 12)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: LinearProgressIndicator(
                                  value: e.value / total,
                                  minHeight: 8,
                                  color: sportKindByKey(e.key).color,
                                  backgroundColor: scheme.surfaceContainerHighest,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }

  // ---------------- Lịch tập 5 tuần ----------------

  Widget _heatmap(List<Workout> all) {
    final scheme = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = DateTime(today.year, today.month, today.day - (today.weekday - 1));
    final start = DateTime(monday.year, monday.month, monday.day - 28);
    final byDay = GoalRules.minutesByDay(all);

    // Mức độ 0-4 theo số phút tập trong ngày.
    int levelOf(int minutes) {
      if (minutes >= 60) return 4;
      if (minutes >= 40) return 3;
      if (minutes >= 20) return 2;
      if (minutes > 0) return 1;
      return 0;
    }

    // Dải màu từ nhạt đến đậm (theo màu chủ đạo của app).
    Color levelColor(int level) {
      const mix = [0.0, 0.28, 0.5, 0.75, 1.0];
      return Color.lerp(const Color(0xFFB2DFDB), scheme.primary, mix[level])!;
    }

    // Thống kê nhanh trong 5 tuần.
    var activeDays = 0;
    var totalMinutes = 0;
    for (var i = 0; i < 35; i++) {
      final d = DateTime(start.year, start.month, start.day + i);
      if (d.isAfter(today)) continue;
      final m = byDay[d] ?? 0;
      if (m > 0) activeDays++;
      totalMinutes += m;
    }

    Widget cell(DateTime d, double size) {
      final future = d.isAfter(today);
      final minutes = byDay[d] ?? 0;
      final level = levelOf(minutes);
      final isToday = d == today;
      final active = level > 0 && !future;
      final Color textColor = future
          ? scheme.onSurfaceVariant.withAlpha(90)
          : (level >= 2 ? Colors.white : (active ? scheme.primary : scheme.onSurfaceVariant));
      return Tooltip(
        message: future ? '${d.day}/${d.month}' : '${d.day}/${d.month}: $minutes phút',
        child: Container(
          width: size,
          height: size,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: future ? Colors.transparent : (active ? levelColor(level) : scheme.surfaceContainerHighest.withAlpha(170)),
            borderRadius: BorderRadius.circular(size * 0.3),
            border: isToday
                ? Border.all(color: scheme.primary, width: 2)
                : (future ? Border.all(color: scheme.outlineVariant.withAlpha(120)) : null),
            boxShadow: level >= 3 && !future
                ? [BoxShadow(color: scheme.primary.withAlpha(60), blurRadius: 6, offset: const Offset(0, 2))]
                : null,
          ),
          child: Text(
            '${d.day}',
            style: TextStyle(
              fontSize: size >= 38 ? 12 : 10,
              fontWeight: (active || isToday) ? FontWeight.w700 : FontWeight.normal,
              color: textColor,
            ),
          ),
        ),
      );
    }

    return _card(
      title: 'Lịch tập 5 tuần gần nhất',
      trailing: SportChip(Icons.local_fire_department_rounded, '$activeDays ngày tập'),
      child: Column(
        children: [
          LayoutBuilder(
            builder: (context, c) {
              const gap = 6.0;
              const maxCell = 44.0;
              final cellSize = ((c.maxWidth - gap * 6) / 7).clamp(24.0, maxCell).toDouble();
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (var i = 0; i < 7; i++)
                          Container(
                            width: cellSize,
                            margin: EdgeInsets.only(right: i == 6 ? 0 : gap),
                            alignment: Alignment.center,
                            child: Text(
                              _kWeekdayLabels[i],
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: i >= 5 ? scheme.primary : scheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    for (var r = 0; r < 5; r++)
                      Padding(
                        padding: EdgeInsets.only(bottom: r == 4 ? 0 : gap),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            for (var col = 0; col < 7; col++)
                              Padding(
                                padding: EdgeInsets.only(right: col == 6 ? 0 : gap),
                                child: cell(DateTime(start.year, start.month, start.day + r * 7 + col), cellSize),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Icon(Icons.timer_outlined, size: 14, color: scheme.onSurfaceVariant),
              const SizedBox(width: 4),
              Text('Tổng $totalMinutes phút', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
              const Spacer(),
              Text('Ít', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
              const SizedBox(width: 6),
              for (var l = 0; l <= 4; l++)
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color: l == 0 ? scheme.surfaceContainerHighest : levelColor(l),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              const SizedBox(width: 6),
              Text('Nhiều', style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Bước chân 7 ngày ----------------

  Widget _stepsCard() {
    return StreamBuilder<Map<String, int>>(
      stream: _stepsHistory,
      builder: (context, snapshot) {
        final data = snapshot.data ?? <String, int>{};
        final now = DateTime.now();
        final days = List<DateTime>.generate(7, (i) => DateTime(now.year, now.month, now.day - (6 - i)));
        final values = days.map((d) => data[WorkoutRepository.dateKeyOf(d)] ?? 0).toList();
        final total = values.fold<int>(0, (s, v) => s + v);
        final avg = (total / 7).round();
        return _card(
          title: 'Bước chân 7 ngày gần nhất',
          trailing: SportChip(Icons.directions_walk, 'TB $avg bước/ngày'),
          child: SportBarChart(
            values: values,
            labels: days.map((d) => _kWeekdayLabels[d.weekday - 1]).toList(),
            tips: [for (var i = 0; i < 7; i++) '${days[i].day}/${days[i].month}: ${values[i]} bước'],
          ),
        );
      },
    );
  }

  // ---------------- Kỷ lục cá nhân ----------------

  Widget _records(List<Workout> all) {
    var longest = 0;
    var mostCalories = 0;
    for (final w in all) {
      if (w.minutes > longest) longest = w.minutes;
      if (w.calories > mostCalories) mostCalories = w.calories;
    }
    final byDay = GoalRules.minutesByDay(all);
    var bestDay = 0;
    for (final v in byDay.values) {
      if (v > bestDay) bestDay = v;
    }
    final bestStreak = GoalRules.bestStreak(all.map((w) => w.date).toList());
    return _card(
      title: 'Kỷ lục cá nhân',
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _recordTile(Icons.timer, '$longest phút', 'Buổi tập dài nhất')),
              const SizedBox(width: 8),
              Expanded(child: _recordTile(Icons.local_fire_department, '$mostCalories kcal', 'Đốt nhiều nhất / buổi')),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: _recordTile(Icons.bolt, '$bestStreak ngày', 'Chuỗi dài nhất')),
              const SizedBox(width: 8),
              Expanded(child: _recordTile(Icons.today, '$bestDay phút', 'Ngày tập nhiều nhất')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recordTile(IconData icon, String value, String label) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(14)),
      child: Row(
        children: [
          Icon(icon, color: scheme.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(label, style: TextStyle(fontSize: 11, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- Huy hiệu ----------------

  Widget _badges(List<Workout> all) {
    final scheme = Theme.of(context).colorScheme;
    final kinds = <String>{};
    var calories = 0;
    var minutes = 0;
    for (final w in all) {
      kinds.add(sportKindOf(w).key);
      calories += w.calories;
      minutes += w.minutes;
    }
    final best = GoalRules.bestStreak(all.map((w) => w.date).toList());
    final week = all.where((w) => GoalRules.isInLastDays(w.date, 7)).length;
    final badges = <_Badge>[
      _Badge(Icons.flag_rounded, 'Khởi đầu', 'Hoàn thành buổi tập đầu tiên', const Color(0xFF26A69A), all.length, 1, 'buổi'),
      _Badge(Icons.repeat_rounded, 'Chăm chỉ', 'Tập từ 10 buổi trở lên', const Color(0xFF42A5F5), all.length, 10, 'buổi'),
      _Badge(Icons.bolt_rounded, 'Bền bỉ', 'Chuỗi 3 ngày liên tiếp', const Color(0xFFFFB300), best, 3, 'ngày'),
      _Badge(Icons.whatshot_rounded, 'Hoàn hảo', 'Chuỗi 7 ngày liên tiếp', const Color(0xFFFF7043), best, 7, 'ngày'),
      _Badge(Icons.local_fire_department_rounded, 'Đốt mỡ', 'Đốt tổng cộng 1000 kcal', const Color(0xFFE53935), calories, 1000, 'kcal'),
      _Badge(Icons.timer_rounded, 'Kiên trì', 'Tập tổng cộng 300 phút', const Color(0xFF8E24AA), minutes, 300, 'phút'),
      _Badge(Icons.category_rounded, 'Đa năng', 'Thử từ 3 loại bài tập', const Color(0xFFEC407A), kinds.length, 3, 'loại'),
      _Badge(Icons.calendar_month_rounded, 'Chiến binh tuần', '3 buổi tập trong 7 ngày', const Color(0xFF5C6BC0), week, 3, 'buổi'),
    ];
    final unlocked = badges.where((b) => b.unlocked).length;
    return _card(
      title: 'Huy hiệu',
      trailing: SportChip(Icons.workspace_premium_outlined, 'Đã mở $unlocked/${badges.length}'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh tiến độ tổng
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0, end: unlocked / badges.length),
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutCubic,
              builder: (context, v, _) => LinearProgressIndicator(
                value: v,
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
                color: const Color(0xFFFFB300),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            unlocked == badges.length
                ? 'Tuyệt vời! Bạn đã mở toàn bộ huy hiệu 🎉'
                : 'Còn ${badges.length - unlocked} huy hiệu nữa, cố lên! Chạm vào huy hiệu để xem chi tiết.',
            style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, c) {
              const gap = 8.0;
              const maxTile = 120.0;
              final tileW = ((c.maxWidth - gap * 3) / 4).clamp(60.0, maxTile).toDouble();
              return Wrap(
                spacing: gap,
                runSpacing: 16,
                alignment: tileW >= maxTile ? WrapAlignment.spaceEvenly : WrapAlignment.start,
                children: [
                  for (var i = 0; i < badges.length; i++)
                    SizedBox(
                      width: tileW,
                      child: _badgeTile(badges[i], tileW, i),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _badgeTile(_Badge b, double tileW, int index) {
    final scheme = Theme.of(context).colorScheme;
    final size = (tileW * 0.82).clamp(52.0, 76.0).toDouble();
    final u = b.unlocked;
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: () => _showBadgeDetail(b),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween<double>(begin: 0.6, end: 1),
              duration: Duration(milliseconds: 450 + index * 70),
              curve: Curves.elasticOut,
              builder: (context, s, child) => Transform.scale(scale: s, child: child),
              child: SizedBox(
                width: size + 6,
                height: size + 6,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    // Vòng tiến độ (huy hiệu chưa mở) hoặc viền sáng (đã mở)
                    SizedBox(
                      width: size + 6,
                      height: size + 6,
                      child: CircularProgressIndicator(
                        value: u ? 1 : b.progress,
                        strokeWidth: 3,
                        color: u ? b.color : b.color.withAlpha(150),
                        backgroundColor: scheme.surfaceContainerHighest,
                      ),
                    ),
                    Container(
                      width: size - 8,
                      height: size - 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: u
                            ? LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [Color.lerp(b.color, Colors.white, 0.25)!, b.color],
                              )
                            : null,
                        color: u ? null : scheme.surfaceContainerHighest,
                        boxShadow: u
                            ? [BoxShadow(color: b.color.withAlpha(90), blurRadius: 12, offset: const Offset(0, 4))]
                            : null,
                      ),
                      child: Icon(
                        b.icon,
                        size: size * 0.45,
                        color: u ? Colors.white : scheme.onSurfaceVariant.withAlpha(110),
                      ),
                    ),
                    // Dấu nhỏ ở góc: tick (đã mở) hoặc khóa (chưa mở)
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardTheme.color ?? scheme.surface,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          u ? Icons.check_circle : Icons.lock,
                          size: 17,
                          color: u ? const Color(0xFF2E9E5B) : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              b.title,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 12,
                fontWeight: u ? FontWeight.w700 : FontWeight.w500,
                color: u ? scheme.onSurface : scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              u ? 'Đã đạt' : '${b.current}/${b.target}',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: u ? const Color(0xFF2E9E5B) : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showBadgeDetail(_Badge b) {
    final scheme = Theme.of(context).colorScheme;
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      constraints: const BoxConstraints(maxWidth: 520),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: b.unlocked
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color.lerp(b.color, Colors.white, 0.25)!, b.color],
                      )
                    : null,
                color: b.unlocked ? null : scheme.surfaceContainerHighest,
                boxShadow: b.unlocked ? [BoxShadow(color: b.color.withAlpha(100), blurRadius: 18, offset: const Offset(0, 6))] : null,
              ),
              child: Icon(b.icon, size: 42, color: b.unlocked ? Colors.white : scheme.onSurfaceVariant.withAlpha(120)),
            ),
            const SizedBox(height: 14),
            Text(b.title, style: Theme.of(ctx).textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(b.description, textAlign: TextAlign.center, style: TextStyle(color: scheme.onSurfaceVariant)),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: b.unlocked ? 1 : b.progress,
                minHeight: 10,
                color: b.color,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              b.unlocked
                  ? '🎉 Bạn đã mở huy hiệu này (${b.current} ${b.unit})'
                  : 'Tiến độ: ${b.current}/${b.target} ${b.unit} - còn ${b.target - b.current} ${b.unit} nữa',
              style: TextStyle(fontWeight: FontWeight.w600, color: b.unlocked ? const Color(0xFF2E9E5B) : scheme.onSurface),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Khung thẻ dùng chung ----------------

  Widget _card({required String title, required Widget child, Widget? trailing}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(title, style: Theme.of(context).textTheme.titleMedium)),
                if (trailing != null) trailing,
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}

class _Badge {
  const _Badge(this.icon, this.title, this.description, this.color, this.current, this.target, this.unit);

  final IconData icon;
  final String title;
  final String description;
  final Color color;
  final int current;
  final int target;
  final String unit;

  bool get unlocked => current >= target;
  double get progress => target == 0 ? 1.0 : (current / target).clamp(0.0, 1.0).toDouble();
}
