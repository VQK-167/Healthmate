import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';

import '../core/goal_rules.dart';
import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import 'goal_page.dart';
import 'workout_stats_page.dart';
import 'workout_timer_page.dart';
import 'workout_widgets.dart';

String _two(int n) => n.toString().padLeft(2, '0');

String _dayLabel(DateTime d) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final diff = today.difference(d).inDays;
  if (diff == 0) return 'Hôm nay';
  if (diff == 1) return 'Hôm qua';
  return '${d.day}/${d.month}/${d.year}';
}

class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final WorkoutRepository _repo = WorkoutRepository();
  late Stream<List<Workout>> _workouts;
  late Stream<int> _steps;
  late Stream<double> _stepGoal;

  /// Các buổi tập vừa vuốt xoá, ẩn ngay trong lúc chờ Firestore cập nhật.
  final Set<String> _hiddenIds = <String>{};

  // Bộ lọc lịch sử
  final TextEditingController _search = TextEditingController();
  String _query = '';
  String _kindFilter = 'all';
  int _rangeDays = 0; // 0 = tất cả

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _subscribe() {
    _workouts = _repo.watchWorkouts();
    _steps = _repo.watchStepsToday();
    _stepGoal = _repo.watchGoal('steps');
  }

  void _reload() => setState(_subscribe);

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _toastUndo(String message, VoidCallback onUndo) {
    if (!mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 6),
        action: SnackBarAction(label: 'Hoàn tác', onPressed: onUndo),
      ),
    );
  }

  String _errorText(Object e) {
    if (e is ArgumentError) return '${e.message}';
    if (e is StateError) return e.message;
    if (e is FirebaseException) {
      if (e.code == 'permission-denied') return 'Không có quyền ghi dữ liệu. Kiểm tra Firestore Rules.';
      if (e.code == 'unavailable') return 'Mất kết nối mạng. Vui lòng thử lại.';
      return 'Lỗi Firestore (${e.code}).';
    }
    return 'Có lỗi xảy ra: $e';
  }

  /// Chạy một thao tác ghi dữ liệu, báo kết quả hoặc lỗi. Trả về false nếu thất bại.
  Future<bool> _run(Future<void> Function() action, String success) async {
    try {
      await action().timeout(const Duration(seconds: 10));
      if (success.isNotEmpty) _toast(success);
      return true;
    } on TimeoutException {
      _toast('Chưa kết nối được máy chủ. Dữ liệu sẽ tự đồng bộ khi có mạng.');
      return true;
    } catch (e) {
      _toast(_errorText(e));
      return false;
    }
  }

  // ---------------- Thêm / sửa / nhân đôi ----------------

  Future<void> _openWorkoutDialog({
    Workout? existing,
    String? initialKind,
    int? initialMinutes,
    String? initialName,
    String? initialNote,
  }) async {
    final input = await showDialog<_WorkoutInput>(
      context: context,
      builder: (_) => _WorkoutDialog(
        existing: existing,
        initialKind: initialKind,
        initialMinutes: initialMinutes,
        initialName: initialName,
        initialNote: initialNote,
      ),
    );
    if (input == null) return;
    if (existing == null) {
      await _run(() async {
        await _repo.addWorkout(
          name: input.name,
          minutes: input.minutes,
          calories: input.calories,
          date: input.date,
          type: input.kindKey,
          note: input.note,
        );
      }, 'Đã lưu buổi tập.');
    } else {
      await _run(
        () => _repo.updateWorkout(existing.copyWith(
          name: input.name,
          minutes: input.minutes,
          calories: input.calories,
          date: input.date,
          type: input.kindKey,
          note: input.note,
        )),
        'Đã cập nhật buổi tập.',
      );
    }
  }

  void _duplicate(Workout w) {
    _openWorkoutDialog(
      initialKind: sportKindOf(w).key,
      initialMinutes: w.minutes,
      initialName: w.name,
      initialNote: w.note,
    );
  }

  Future<void> _startTimer() async {
    final result = await Navigator.push<WorkoutTimerResult>(
      context,
      MaterialPageRoute(builder: (_) => const WorkoutTimerPage()),
    );
    if (result == null || !mounted) return;
    await _openWorkoutDialog(initialKind: result.kindKey, initialMinutes: result.minutes);
  }

  // ---------------- Xoá và hoàn tác ----------------

  Future<bool> _askDelete(Workout w) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xoá buổi tập?'),
        content: Text('Buổi tập "${w.name}" sẽ bị xoá. Bạn có thể hoàn tác ngay sau đó.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xoá')),
        ],
      ),
    );
    return yes == true;
  }

  Future<void> _deleteWorkout(Workout w, {bool hideFirst = false}) async {
    if (hideFirst) setState(() => _hiddenIds.add(w.id));
    final ok = await _run(() => _repo.deleteWorkout(w.id), '');
    if (!mounted) return;
    if (ok) {
      _toastUndo('Đã xoá buổi tập "${w.name}".', () => _restore(w));
    } else {
      setState(() => _hiddenIds.remove(w.id));
    }
  }

  Future<void> _restore(Workout w) async {
    final ok = await _run(() => _repo.updateWorkout(w), 'Đã khôi phục buổi tập.');
    if (ok && mounted) setState(() => _hiddenIds.remove(w.id));
  }

  Future<void> _addSteps() async {
    final steps = await showDialog<int>(context: context, builder: (_) => const _StepsDialog());
    if (steps == null) return;
    await _run(() => _repo.addSteps(steps), 'Đã ghi $steps bước.');
  }

  // ---------------- Giao diện ----------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tập luyện'),
        actions: [
          IconButton(
            tooltip: 'Thống kê',
            icon: const Icon(Icons.insights_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutStatsPage())),
          ),
          IconButton(
            tooltip: 'Mục tiêu',
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GoalPage())),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openWorkoutDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm buổi tập'),
      ),
      body: StreamBuilder<List<Workout>>(
        stream: _workouts,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text('Không tải được dữ liệu. Kiểm tra đăng nhập và kết nối Firestore.', textAlign: TextAlign.center),
                    const SizedBox(height: 8),
                    Text('${snapshot.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(onPressed: _reload, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
                  ],
                ),
              ),
            );
          }
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final all = snapshot.data!.where((w) => !_hiddenIds.contains(w.id)).toList();
          final shown = _applyFilters(all);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
            children: [
              SportFadeIn(index: 0, child: _hero(all)),
              const SizedBox(height: 10),
              SportFadeIn(index: 1, child: _quickActions()),
              const SizedBox(height: 6),
              SportFadeIn(index: 2, child: _weekCard(all)),
              const SizedBox(height: 4),
              SportFadeIn(index: 3, child: _stepsCard()),
              const SizedBox(height: 16),
              Text('Lịch sử tập luyện', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (all.isEmpty)
                _emptyState()
              else ...[
                _filters(all),
                const SizedBox(height: 4),
                if (shown.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 28),
                    child: Center(child: Text('Không có buổi tập nào khớp bộ lọc.')),
                  )
                else
                  ..._history(shown),
              ],
            ],
          );
        },
      ),
    );
  }

  List<Workout> _applyFilters(List<Workout> all) {
    final q = _query.trim().toLowerCase();
    return all.where((w) {
      if (_kindFilter != 'all' && sportKindOf(w).key != _kindFilter) return false;
      if (_rangeDays > 0 && !GoalRules.isInLastDays(w.date, _rangeDays)) return false;
      if (q.isNotEmpty && !w.name.toLowerCase().contains(q) && !w.note.toLowerCase().contains(q)) return false;
      return true;
    }).toList();
  }

  Widget _emptyState() {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32),
      child: Column(
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.fitness_center, size: 36, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 12),
          const Text('Chưa có buổi tập nào.\nNhấn “Thêm buổi tập” hoặc “Bấm giờ” để bắt đầu.', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _quickActions() {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: _startTimer,
            icon: const Icon(Icons.timer_outlined),
            label: const Text('Bấm giờ buổi tập'),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const WorkoutStatsPage())),
            icon: const Icon(Icons.insights_outlined),
            label: const Text('Thống kê'),
          ),
        ),
      ],
    );
  }

  /// Thẻ chính: calo đốt hôm nay (số đếm lên) và 4 chỉ số nhanh.
  Widget _hero(List<Workout> items) {
    final scheme = Theme.of(context).colorScheme;
    final today = GoalRules.inLastDays(items, 1);
    final todayCalories = today.fold<int>(0, (s, w) => s + w.calories);
    final todayMinutes = today.fold<int>(0, (s, w) => s + w.minutes);
    final totalCalories = items.fold<int>(0, (s, w) => s + w.calories);
    final totalMinutes = items.fold<int>(0, (s, w) => s + w.minutes);
    final last7 = GoalRules.inLastDays(items, 7);
    final weekMinutes = GoalRules.weeklyMinutes(last7.map((w) => w.minutes).toList());
    final streak = GoalRules.streak(items.map((w) => w.date).toList());
    final onColor = scheme.onPrimary;
    final endColor = Color.lerp(scheme.primary, scheme.primaryContainer, 0.25) ?? scheme.primary;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [scheme.primary, endColor],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: scheme.primary.withAlpha(70), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_fire_department, color: onColor, size: 20),
              const SizedBox(width: 6),
              Text('Hôm nay bạn đã đốt', style: TextStyle(color: onColor.withAlpha(225))),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              SportCountUp(
                value: todayCalories,
                style: TextStyle(fontSize: 46, height: 1.1, fontWeight: FontWeight.bold, color: onColor),
              ),
              const SizedBox(width: 8),
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text('kcal', style: TextStyle(fontSize: 16, color: onColor.withAlpha(225))),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Tổng cộng $totalMinutes phút • $totalCalories kcal', style: TextStyle(fontSize: 12, color: onColor.withAlpha(210))),
          const SizedBox(height: 16),
          Row(
            children: [
              _Pill('$todayMinutes', 'phút hôm nay', onColor),
              _Pill('${items.length}', 'buổi tập', onColor),
              _Pill('$streak', 'ngày liên tiếp', onColor),
              _Pill('$weekMinutes', 'phút / 7 ngày', onColor),
            ],
          ),
        ],
      ),
    );
  }

  Widget _weekCard(List<Workout> items) {
    const labels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    final now = DateTime.now();
    final days = List<DateTime>.generate(7, (i) => DateTime(now.year, now.month, now.day - (6 - i)));
    final byDay = GoalRules.minutesByDay(items);
    final values = days.map((d) => byDay[d] ?? 0).toList();
    final total = values.fold<int>(0, (s, v) => s + v);
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Phút tập 7 ngày gần nhất', style: Theme.of(context).textTheme.titleMedium)),
                SportChip(Icons.timer_outlined, 'Tổng $total phút'),
              ],
            ),
            const SizedBox(height: 12),
            SportBarChart(
              values: values,
              labels: days.map((d) => labels[d.weekday - 1]).toList(),
              tips: [for (var i = 0; i < 7; i++) '${days[i].day}/${days[i].month}: ${values[i]} phút'],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepsCard() {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: StreamBuilder<int>(
          stream: _steps,
          builder: (context, stepSnap) => StreamBuilder<double>(
            stream: _stepGoal,
            builder: (context, goalSnap) {
              final steps = stepSnap.data ?? 0;
              final target = goalSnap.data ?? 0.0;
              final progress = GoalRules.progress(current: steps.toDouble(), target: target);
              final done = target > 0 && progress >= 1;
              final color = done ? Colors.green.shade600 : scheme.primary;
              final text = target > 0 ? '$steps / ${target.toStringAsFixed(0)} bước' : '$steps bước';
              final Widget leading = target > 0
                  ? SportRing(
                      progress: progress,
                      color: color,
                      size: 60,
                      stroke: 7,
                      child: Icon(done ? Icons.check_rounded : Icons.directions_walk, color: color),
                    )
                  : CircleAvatar(
                      radius: 28,
                      backgroundColor: scheme.primaryContainer,
                      foregroundColor: scheme.onPrimaryContainer,
                      child: const Icon(Icons.directions_walk),
                    );
              return Row(
                children: [
                  leading,
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Bước chân hôm nay'),
                        Text(text, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                        Text(
                          target > 0
                              ? (done ? 'Đã đạt mục tiêu' : '${(progress * 100).toStringAsFixed(0)}% mục tiêu')
                              : 'Tạo mục tiêu bước chân (biểu tượng cờ) để theo dõi.',
                          style: TextStyle(fontSize: 12, color: done ? color : scheme.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    tooltip: 'Ghi thêm bước chân',
                    icon: const Icon(Icons.add),
                    onPressed: _addSteps,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Ô tìm kiếm và các nhóm lọc theo loại bài tập, theo thời gian.
  Widget _filters(List<Workout> all) {
    final present = <String>{};
    for (final w in all) {
      present.add(sportKindOf(w).key);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _search,
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: 'Tìm theo tên hoặc ghi chú',
            prefixIcon: const Icon(Icons.search),
            suffixIcon: _query.isEmpty
                ? null
                : IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _search.clear();
                      setState(() => _query = '');
                    },
                  ),
            isDense: true,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          ),
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _kindChip('all', 'Tất cả', Icons.apps),
              for (final k in kSportKinds)
                if (present.contains(k.key)) _kindChip(k.key, k.label, k.icon),
            ],
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _rangeChip(0, 'Mọi lúc'),
              _rangeChip(7, '7 ngày'),
              _rangeChip(30, '30 ngày'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _kindChip(String key, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        avatar: Icon(icon, size: 18),
        label: Text(label),
        selected: _kindFilter == key,
        onSelected: (_) => setState(() => _kindFilter = key),
      ),
    );
  }

  Widget _rangeChip(int days, String label) {
    return Padding(
      padding: const EdgeInsets.only(right: 6),
      child: ChoiceChip(
        label: Text(label),
        selected: _rangeDays == days,
        onSelected: (_) => setState(() => _rangeDays = days),
      ),
    );
  }

  /// Lịch sử gom theo ngày, mỗi ngày có tiêu đề kèm tổng phút và calo.
  List<Widget> _history(List<Workout> items) {
    final groups = <DateTime, List<Workout>>{};
    for (final w in items) {
      final day = DateTime(w.date.year, w.date.month, w.date.day);
      groups.putIfAbsent(day, () => <Workout>[]).add(w);
    }
    final out = <Widget>[];
    var index = 0;
    for (final entry in groups.entries) {
      final minutes = entry.value.fold<int>(0, (s, w) => s + w.minutes);
      final calories = entry.value.fold<int>(0, (s, w) => s + w.calories);
      out.add(_dayHeader(entry.key, minutes, calories));
      for (final w in entry.value) {
        out.add(SportFadeIn(key: ValueKey('w_${w.id}'), index: index, child: _tile(w)));
        index++;
      }
    }
    return out;
  }

  Widget _dayHeader(DateTime day, int minutes, int calories) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      key: ValueKey('h_${day.toIso8601String()}'),
      padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
      child: Row(
        children: [
          Text(_dayLabel(day), style: TextStyle(fontWeight: FontWeight.w600, color: scheme.primary)),
          const Spacer(),
          Text('$minutes phút • $calories kcal', style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _tile(Workout w) {
    final scheme = Theme.of(context).colorScheme;
    final kind = sportKindOf(w);
    return Dismissible(
      key: ValueKey('d_${w.id}'),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => _askDelete(w),
      onDismissed: (_) => _deleteWorkout(w, hideFirst: true),
      background: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: Alignment.centerRight,
        decoration: BoxDecoration(color: scheme.errorContainer, borderRadius: BorderRadius.circular(16)),
        child: Icon(Icons.delete_outline, color: scheme.onErrorContainer),
      ),
      child: Card(
        margin: const EdgeInsets.only(bottom: 8),
        child: ListTile(
          onTap: () => _openWorkoutDialog(existing: w),
          leading: CircleAvatar(
            backgroundColor: kind.color.withAlpha(45),
            foregroundColor: kind.color,
            child: Icon(kind.icon),
          ),
          title: Text(w.name, style: const TextStyle(fontWeight: FontWeight.w600)),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    SportChip(Icons.timer_outlined, '${w.minutes} phút'),
                    SportChip(Icons.local_fire_department_outlined, '${w.calories} kcal'),
                    SportChip(Icons.schedule, '${_two(w.date.hour)}:${_two(w.date.minute)}'),
                  ],
                ),
                if (w.note.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Text(
                      w.note,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                  ),
              ],
            ),
          ),
          trailing: PopupMenuButton<String>(
            tooltip: 'Tuỳ chọn',
            onSelected: (v) async {
              if (v == 'edit') {
                await _openWorkoutDialog(existing: w);
              } else if (v == 'dup') {
                _duplicate(w);
              } else if (v == 'del') {
                if (await _askDelete(w)) await _deleteWorkout(w);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem<String>(value: 'edit', child: Text('Sửa')),
              PopupMenuItem<String>(value: 'dup', child: Text('Nhân đôi (tập lại)')),
              PopupMenuItem<String>(value: 'del', child: Text('Xoá')),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ô chỉ số nhỏ trong thẻ chính.
class _Pill extends StatelessWidget {
  const _Pill(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(color: color.withAlpha(40), borderRadius: BorderRadius.circular(14)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 2),
            Text(label, textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: color.withAlpha(225))),
          ],
        ),
      ),
    );
  }
}

class _WorkoutInput {
  const _WorkoutInput({
    required this.name,
    required this.minutes,
    required this.calories,
    required this.kindKey,
    required this.note,
    required this.date,
  });

  final String name;
  final int minutes;
  final int calories;
  final String kindKey;
  final String note;
  final DateTime date;
}

/// Hộp thoại thêm (tính calo theo MET) hoặc sửa (nhập calo trực tiếp) một buổi tập.
class _WorkoutDialog extends StatefulWidget {
  const _WorkoutDialog({
    this.existing,
    this.initialKind,
    this.initialMinutes,
    this.initialName,
    this.initialNote,
  });

  final Workout? existing;
  final String? initialKind;
  final int? initialMinutes;
  final String? initialName;
  final String? initialNote;

  @override
  State<_WorkoutDialog> createState() => _WorkoutDialogState();
}

class _WorkoutDialogState extends State<_WorkoutDialog> {
  late final TextEditingController _name;
  late final TextEditingController _minutes;
  late final TextEditingController _weight;
  late final TextEditingController _calories;
  late final TextEditingController _note;
  late String _kindKey;
  late DateTime _date;
  String? _error;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final w = widget.existing;
    _name = TextEditingController(text: w?.name ?? widget.initialName ?? '');
    _minutes = TextEditingController(text: w != null ? '${w.minutes}' : (widget.initialMinutes != null ? '${widget.initialMinutes}' : ''));
    _weight = TextEditingController(text: '60');
    _calories = TextEditingController(text: w != null ? '${w.calories}' : '');
    _note = TextEditingController(text: w?.note ?? widget.initialNote ?? '');
    _kindKey = w != null ? sportKindOf(w).key : (widget.initialKind ?? 'run');
    _date = w?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _name.dispose();
    _minutes.dispose();
    _weight.dispose();
    _calories.dispose();
    _note.dispose();
    super.dispose();
  }

  int? get _estimate {
    final m = int.tryParse(_minutes.text.trim());
    final w = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
    if (m == null || m <= 0 || w == null || w <= 0) return null;
    return GoalRules.estimateCalories(met: sportKindByKey(_kindKey).met, weightKg: w, minutes: m);
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _date.isAfter(now) ? now : _date,
      firstDate: DateTime(2020),
      lastDate: now,
    );
    if (picked != null) {
      setState(() => _date = DateTime(picked.year, picked.month, picked.day, _date.hour, _date.minute));
    }
  }

  void _submit() {
    final minutes = int.tryParse(_minutes.text.trim());
    if (minutes == null || minutes <= 0) {
      setState(() => _error = 'Thời lượng phải là số phút lớn hơn 0.');
      return;
    }
    int calories;
    if (_editing) {
      final c = int.tryParse(_calories.text.trim());
      if (c == null || c < 0) {
        setState(() => _error = 'Calo phải là số nguyên không âm.');
        return;
      }
      calories = c;
    } else {
      final weight = double.tryParse(_weight.text.trim().replaceAll(',', '.'));
      if (weight == null || weight <= 0) {
        setState(() => _error = 'Cân nặng phải là số lớn hơn 0.');
        return;
      }
      calories = GoalRules.estimateCalories(met: sportKindByKey(_kindKey).met, weightKg: weight, minutes: minutes);
    }
    final typed = _name.text.trim();
    final name = typed.isNotEmpty ? typed : sportKindByKey(_kindKey).label;
    Navigator.pop(
      context,
      _WorkoutInput(
        name: name,
        minutes: minutes,
        calories: calories,
        kindKey: _kindKey,
        note: _note.text.trim(),
        date: _date,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final estimate = _estimate;
    return AlertDialog(
      title: Text(_editing ? 'Sửa buổi tập' : 'Thêm buổi tập'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final k in kSportKinds)
                  ChoiceChip(
                    avatar: Icon(k.icon, size: 18),
                    label: Text(k.label),
                    selected: _kindKey == k.key,
                    onSelected: (_) => setState(() => _kindKey = k.key),
                  ),
              ],
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _name,
              decoration: InputDecoration(
                labelText: _editing ? 'Tên buổi tập' : 'Tên buổi tập (tuỳ chọn)',
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _minutes,
              keyboardType: TextInputType.number,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(labelText: 'Thời lượng (phút)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            if (_editing)
              TextField(
                controller: _calories,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calo đốt (kcal)', border: OutlineInputBorder()),
              )
            else ...[
              TextField(
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: (_) => setState(() {}),
                decoration: const InputDecoration(
                  labelText: 'Cân nặng (kg)',
                  helperText: 'Dùng để ước tính calo đốt',
                  border: OutlineInputBorder(),
                ),
              ),
              if (estimate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: SportChip(Icons.local_fire_department_outlined, 'Ước tính ≈ $estimate kcal'),
                ),
            ],
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _pickDate,
                icon: const Icon(Icons.calendar_today_outlined, size: 18),
                label: Text('Ngày tập: ${_date.day}/${_date.month}/${_date.year}'),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _note,
              maxLines: 2,
              decoration: const InputDecoration(labelText: 'Ghi chú (tuỳ chọn)', border: OutlineInputBorder()),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(_error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}

class _StepsDialog extends StatefulWidget {
  const _StepsDialog();

  @override
  State<_StepsDialog> createState() => _StepsDialogState();
}

class _StepsDialogState extends State<_StepsDialog> {
  final TextEditingController _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final steps = int.tryParse(_controller.text.trim());
    if (steps == null || steps <= 0) {
      setState(() => _error = 'Số bước phải là số nguyên lớn hơn 0.');
      return;
    }
    Navigator.pop(context, steps);
  }

  void _addQuick(int n) {
    final current = int.tryParse(_controller.text.trim()) ?? 0;
    setState(() {
      _controller.text = '${current + n}';
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ghi thêm bước chân'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(labelText: 'Số bước', errorText: _error, border: const OutlineInputBorder()),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final n in const [500, 1000, 2000, 5000])
                ActionChip(label: Text('+$n'), onPressed: () => _addQuick(n)),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}
