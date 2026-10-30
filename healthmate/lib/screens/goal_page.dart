import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';

import '../core/goal_rules.dart';
import '../models/workout.dart';
import '../repositories/goal_repository.dart';
import '../repositories/workout_repository.dart';

/// Thông tin hiển thị của từng loại mục tiêu.
class _GoalType {
  const _GoalType(this.label, this.unit, this.period);

  final String label;
  final String unit;
  final String period;
}

const Map<String, _GoalType> _kTypes = {
  'steps': _GoalType('Số bước chân', 'bước', 'hôm nay'),
  'calories': _GoalType('Calo tiêu hao', 'kcal', 'hôm nay'),
  'workouts': _GoalType('Số buổi tập', 'buổi', '7 ngày gần nhất'),
};

/// Trang Mục tiêu: tạo, xem tiến độ (tự tính từ dữ liệu thật) và xoá mục tiêu.
class GoalPage extends StatefulWidget {
  const GoalPage({super.key});

  @override
  State<GoalPage> createState() => _GoalPageState();
}

class _GoalPageState extends State<GoalPage> {
  final GoalRepository _repo = GoalRepository();
  final WorkoutRepository _workoutRepo = WorkoutRepository();
  late Stream<List<Goal>> _goalsStream;
  late Stream<List<Workout>> _workoutsStream;
  late Stream<int> _stepsStream;

  @override
  void initState() {
    super.initState();
    _goalsStream = _repo.watchGoals();
    _workoutsStream = _workoutRepo.watchWorkouts();
    _stepsStream = _workoutRepo.watchStepsToday();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _run(Future<void> Function() action, String success) async {
    try {
      await action().timeout(const Duration(seconds: 10));
      _toast(success);
    } on TimeoutException {
      _toast('Chưa kết nối được máy chủ. Dữ liệu sẽ tự đồng bộ khi có mạng.');
    } on ArgumentError catch (e) {
      _toast('${e.message}');
    } on FirebaseException catch (e) {
      _toast('Lỗi Firestore: ${e.code}');
    } catch (e) {
      _toast('Có lỗi xảy ra: $e');
    }
  }

  Future<void> _createGoal() async {
    final input = await showDialog<_GoalInput>(context: context, builder: (_) => const _GoalDialog());
    if (input == null) return;
    await _run(() async {
      await _repo.saveGoal(type: input.type, title: input.title, target: input.target, unit: input.unit);
    }, 'Đã tạo mục tiêu.');
  }

  Future<void> _deleteGoal(Goal g) async {
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
    if (yes == true) {
      await _run(() => _repo.deleteGoal(g.id), 'Đã xoá mục tiêu.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mục tiêu của tôi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _createGoal,
        icon: const Icon(Icons.add),
        label: const Text('Tạo mục tiêu'),
      ),
      body: StreamBuilder<List<Goal>>(
        stream: _goalsStream,
        builder: (context, goalSnap) {
          if (goalSnap.hasError) {
            return Center(child: Text('Không tải được mục tiêu.\n${goalSnap.error}', textAlign: TextAlign.center));
          }
          if (!goalSnap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final goals = goalSnap.data!;
          if (goals.isEmpty) {
            return const Center(child: Text('Bạn chưa có mục tiêu. Hãy tạo mục tiêu đầu tiên!'));
          }
          // Tiến độ cần số buổi tập và số bước hôm nay nên nghe thêm 2 stream này.
          return StreamBuilder<List<Workout>>(
            stream: _workoutsStream,
            builder: (context, workoutSnap) {
              final workouts = workoutSnap.data ?? <Workout>[];
              return StreamBuilder<int>(
                stream: _stepsStream,
                builder: (context, stepSnap) {
                  final steps = stepSnap.data ?? 0;
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
                    children: [
                      for (final g in goals)
                        _goalCard(g, GoalRules.currentValue(type: g.type, stepsToday: steps, workouts: workouts)),
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

  Widget _goalCard(Goal g, double current) {
    final progress = GoalRules.progress(current: current, target: g.target);
    final done = progress >= 1;
    final period = _kTypes[g.type]?.period ?? '';
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text(g.title, style: Theme.of(context).textTheme.titleMedium)),
                IconButton(tooltip: 'Xoá', icon: const Icon(Icons.delete_outline), onPressed: () => _deleteGoal(g)),
              ],
            ),
            Text('${current.toStringAsFixed(0)} / ${g.target.toStringAsFixed(0)} ${g.unit} ($period)'),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progress, minHeight: 8),
            const SizedBox(height: 4),
            Align(
              alignment: Alignment.centerRight,
              child: Text(done ? 'Đã đạt mục tiêu' : '${(progress * 100).toStringAsFixed(0)}%'),
            ),
          ],
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

class _GoalDialog extends StatefulWidget {
  const _GoalDialog();

  @override
  State<_GoalDialog> createState() => _GoalDialogState();
}

class _GoalDialogState extends State<_GoalDialog> {
  final TextEditingController _title = TextEditingController();
  final TextEditingController _target = TextEditingController();
  String _type = 'steps';
  String? _error;

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
    Navigator.pop(context, _GoalInput(_type, typed.isEmpty ? 'Mục tiêu ${info.label.toLowerCase()}' : typed, value, info.unit));
  }

  @override
  Widget build(BuildContext context) {
    final info = _kTypes[_type]!;
    return AlertDialog(
      title: const Text('Tạo mục tiêu'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
                  onChanged: (v) => setState(() => _type = v ?? _type),
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
