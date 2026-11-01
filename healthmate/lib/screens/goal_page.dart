import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';

import '../core/goal_rules.dart';
import '../models/workout.dart';
import '../repositories/goal_repository.dart';
import '../repositories/workout_repository.dart';
import 'workout_widgets.dart';

class _GoalType {
  const _GoalType(this.label, this.unit, this.period, this.icon, this.suggestions);

  final String label;
  final String unit;
  final String period;
  final IconData icon;
  final List<int> suggestions;
}

const Map<String, _GoalType> _kTypes = {
  'steps': _GoalType('Số bước chân', 'bước', 'hôm nay', Icons.directions_walk, [5000, 8000, 10000]),
  'calories': _GoalType('Calo tiêu hao', 'kcal', 'hôm nay', Icons.local_fire_department_outlined, [300, 500, 800]),
  'workouts': _GoalType('Số buổi tập', 'buổi', '7 ngày gần nhất', Icons.fitness_center, [3, 5, 7]),
  'minutes': _GoalType('Thời gian tập', 'phút', '7 ngày gần nhất', Icons.timer_outlined, [90, 150, 210]),
  'streak': _GoalType('Chuỗi ngày tập', 'ngày', 'liên tiếp hiện tại', Icons.bolt, [3, 7, 14]),
};

class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  final GoalRepository _repo = GoalRepository();
  final WorkoutRepository _workoutRepo = WorkoutRepository();
  late Stream<List<Goal>> _goals;
  late Stream<List<Workout>> _workouts;
  late Stream<int> _steps;

  @override
  void initState() {
    super.initState();
    _subscribe();
  }

  void _subscribe() {
    _goals = _repo.watchGoals();
    _workouts = _workoutRepo.watchWorkouts();
    _steps = _workoutRepo.watchStepsToday();
  }

  void _reload() => setState(_subscribe);

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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

  Future<void> _run(Future<void> Function() action, String success) async {
    try {
      await action().timeout(const Duration(seconds: 10));
      _toast(success);
    } on TimeoutException {
      _toast('Chưa kết nối được máy chủ. Dữ liệu sẽ tự đồng bộ khi có mạng.');
    } catch (e) {
      _toast(_errorText(e));
    }
  }

  /// Tạo mục tiêu mới (existing = null) hoặc sửa mục tiêu đã có.
  Future<void> _openGoalDialog({Goal? existing}) async {
    final input = await showDialog<_GoalInput>(context: context, builder: (_) => _GoalDialog(existing: existing));
    if (input == null) return;
    await _run(() async {
      await _repo.saveGoal(
        id: existing?.id,
        type: input.type,
        title: input.title,
        target: input.target,
        unit: input.unit,
      );
    }, existing == null ? 'Đã tạo mục tiêu.' : 'Đã cập nhật mục tiêu.');
  }

  Future<void> _confirmDelete(Goal g) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xoá mục tiêu?'),
        content: Text('Mục tiêu "${g.title}" sẽ bị xoá.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (yes == true) await _run(() => _repo.deleteGoal(g.id), 'Đã xoá mục tiêu.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mục tiêu của tôi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openGoalDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Tạo mục tiêu'),
      ),
      body: StreamBuilder<List<Goal>>(
        stream: _goals,
        builder: (context, goalSnap) {
          if (goalSnap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Không tải được mục tiêu: ${goalSnap.error}', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    FilledButton.icon(onPressed: _reload, icon: const Icon(Icons.refresh), label: const Text('Thử lại')),
                  ],
                ),
              ),
            );
          }
          if (!goalSnap.hasData) return const Center(child: CircularProgressIndicator());
          final goals = goalSnap.data!;
          if (goals.isEmpty) return _emptyState(context);
          return StreamBuilder<List<Workout>>(
            stream: _workouts,
            builder: (context, workoutSnap) {
              final workouts = workoutSnap.data ?? const <Workout>[];
              return StreamBuilder<int>(
                stream: _steps,
                builder: (context, stepSnap) {
                  final steps = stepSnap.data ?? 0;
                  final currents = goals
                      .map((g) => GoalRules.currentValue(type: g.type, stepsToday: steps, workouts: workouts))
                      .toList();
                  var achieved = 0;
                  for (var i = 0; i < goals.length; i++) {
                    if (GoalRules.progress(current: currents[i], target: goals[i].target) >= 1) achieved++;
                  }
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
                    children: [
                      SportFadeIn(index: 0, child: _header(context, achieved, goals.length)),
                      const SizedBox(height: 12),
                      for (var i = 0; i < goals.length; i++)
                        SportFadeIn(
                          key: ValueKey('g_${goals[i].id}'),
                          index: i + 1,
                          child: _goalCard(context, goals[i], currents[i]),
                        ),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _emptyState(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 36,
            backgroundColor: scheme.primaryContainer,
            child: Icon(Icons.flag_outlined, size: 36, color: scheme.onPrimaryContainer),
          ),
          const SizedBox(height: 12),
          const Text('Bạn chưa có mục tiêu.\nHãy tạo mục tiêu đầu tiên!', textAlign: TextAlign.center),
        ],
      ),
    );
  }

  /// Thẻ đầu trang: số mục tiêu đã đạt.
  Widget _header(BuildContext context, int achieved, int total) {
    final scheme = Theme.of(context).colorScheme;
    final onColor = scheme.onPrimary;
    final endColor = Color.lerp(scheme.primary, scheme.primaryContainer, 0.25) ?? scheme.primary;
    final allDone = total > 0 && achieved == total;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [scheme.primary, endColor]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: scheme.primary.withAlpha(70), blurRadius: 18, offset: const Offset(0, 8))],
      ),
      child: Row(
        children: [
          SportRing(
            progress: total == 0 ? 0 : achieved / total,
            color: onColor,
            trackColor: onColor.withAlpha(60),
            size: 80,
            stroke: 8,
            child: Text('$achieved/$total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onColor)),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Mục tiêu đã đạt', style: TextStyle(color: onColor.withAlpha(225))),
                const SizedBox(height: 4),
                Text(
                  allDone ? 'Tuyệt vời! Bạn đã hoàn thành tất cả.' : 'Còn ${total - achieved} mục tiêu nữa, cố lên!',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _goalCard(BuildContext context, Goal g, double current) {
    final type = _kTypes[g.type];
    final progress = GoalRules.progress(current: current, target: g.target);
    final done = progress >= 1;
    final scheme = Theme.of(context).colorScheme;
    final color = done ? Colors.green.shade600 : scheme.primary;
    final remaining = g.target - current;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => _openGoalDialog(existing: g),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              SportRing(
                progress: progress,
                color: color,
                child: done
                    ? Icon(Icons.check_rounded, size: 34, color: color)
                    : Text('${(progress * 100).toStringAsFixed(0)}%', style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(type?.icon ?? Icons.flag_outlined, size: 18, color: scheme.primary),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            g.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${current.toStringAsFixed(0)} / ${g.target.toStringAsFixed(0)} ${g.unit}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: [
                        if (type != null) SportChip(Icons.schedule, type.period),
                        if (!done) SportChip(Icons.trending_up, 'Còn ${remaining.toStringAsFixed(0)} ${g.unit}'),
                        if (done)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(20)),
                            child: Text(
                              'Đã đạt',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.green.shade700),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(tooltip: 'Sửa', onPressed: () => _openGoalDialog(existing: g), icon: const Icon(Icons.edit_outlined)),
                  IconButton(tooltip: 'Xoá', onPressed: () => _confirmDelete(g), icon: const Icon(Icons.delete_outline)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoalInput {
  const _GoalInput(this.type, this.title, this.target, this.unit);

  final String type;
  final String title;
  final double target;
  final String unit;
}

/// Hộp thoại tạo mục tiêu hoặc sửa (không đổi được loại khi sửa).
class _GoalDialog extends StatefulWidget {
  const _GoalDialog({this.existing});

  final Goal? existing;

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  late final TextEditingController _title;
  late final TextEditingController _target;
  late String _type;
  String? _error;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final g = widget.existing;
    _title = TextEditingController(text: g?.title ?? '');
    _target = TextEditingController(text: g == null ? '' : g.target.toStringAsFixed(0));
    _type = (g != null && _kTypes.containsKey(g.type)) ? g.type : 'steps';
  }

  @override
  void dispose() {
    _title.dispose();
    _target.dispose();
    super.dispose();
  }

  void _submit() {
    final value = double.tryParse(_target.text.trim().replaceAll(',', '.'));
    if (value == null || value <= 0) {
      setState(() => _error = 'Mục tiêu phải là số lớn hơn 0.');
      return;
    }
    final info = _kTypes[_type]!;
    final typed = _title.text.trim();
    Navigator.pop(
      context,
      _GoalInput(_type, typed.isEmpty ? 'Mục tiêu ${info.label.toLowerCase()}' : typed, value, info.unit),
    );
  }

  @override
  Widget build(BuildContext context) {
    final info = _kTypes[_type]!;
    return AlertDialog(
      title: Text(_editing ? 'Sửa mục tiêu' : 'Tạo mục tiêu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InputDecorator(
              decoration: const InputDecoration(labelText: 'Loại mục tiêu', border: OutlineInputBorder()),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  isDense: true,
                  value: _type,
                  items: _kTypes.entries
                      .map((e) => DropdownMenuItem<String>(value: e.key, child: Text('${e.value.label} (${e.value.period})')))
                      .toList(),
                  onChanged: _editing ? null : (v) => setState(() => _type = v ?? _type),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _title,
              decoration: const InputDecoration(labelText: 'Tên mục tiêu (tuỳ chọn)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _target,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: 'Mục tiêu (${info.unit})', errorText: _error, border: const OutlineInputBorder()),
            ),
            const SizedBox(height: 10),
            Text('Gợi ý nhanh', style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.onSurfaceVariant)),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final n in info.suggestions)
                  ActionChip(
                    label: Text('$n ${info.unit}'),
                    onPressed: () => setState(() {
                      _target.text = '$n';
                      _error = null;
                    }),
                  ),
              ],
            ),
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
