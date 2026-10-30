import 'dart:async';

import 'package:firebase_core/firebase_core.dart' show FirebaseException;
import 'package:flutter/material.dart';

import '../core/goal_rules.dart';
import '../models/workout.dart';
import '../repositories/workout_repository.dart';
import 'goal_page.dart';

/// MET: mức tiêu hao năng lượng của từng loại bài tập (dùng để ước tính calo).
const Map<String, double> _kMets = {
  'Đi bộ': 3.5,
  'Chạy bộ': 8.0,
  'Đạp xe': 7.5,
  'Yoga': 2.5,
  'Tập gym': 5.0,
};

/// Trang Tập luyện: tổng kết, bước chân hôm nay và lịch sử các buổi tập.
class WorkoutPage extends StatefulWidget {
  const WorkoutPage({super.key});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  final WorkoutRepository _repo = WorkoutRepository();
  late Stream<List<Workout>> _workoutsStream;
  late Stream<int> _stepsStream;

  @override
  void initState() {
    super.initState();
    // Tạo stream một lần ở đây để không đăng ký lại mỗi lần giao diện build lại.
    _workoutsStream = _repo.watchWorkouts();
    _stepsStream = _repo.watchStepsToday();
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  /// Chạy một thao tác ghi dữ liệu và báo kết quả hoặc lỗi cho người dùng.
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

  /// Mở hộp thoại thêm (old = null) hoặc sửa (old != null) một buổi tập.
  Future<void> _openWorkoutDialog({Workout? old}) async {
    final input = await showDialog<_WorkoutInput>(
      context: context,
      builder: (_) => _WorkoutDialog(existing: old),
    );
    if (input == null) return; // người dùng bấm Huỷ

    if (old == null) {
      await _run(() async {
        await _repo.addWorkout(name: input.name, minutes: input.minutes, calories: input.calories);
      }, 'Đã lưu buổi tập.');
    } else {
      final updated = Workout(
        id: old.id,
        userId: old.userId,
        name: input.name,
        minutes: input.minutes,
        calories: input.calories,
        date: old.date,
      );
      await _run(() => _repo.updateWorkout(updated), 'Đã cập nhật buổi tập.');
    }
  }

  Future<void> _deleteWorkout(Workout w) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Xoá buổi tập?'),
        content: Text('Buổi tập "${w.name}" sẽ bị xoá.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c, false), child: const Text('Huỷ')),
          FilledButton(onPressed: () => Navigator.pop(c, true), child: const Text('Xoá')),
        ],
      ),
    );
    if (yes == true) {
      await _run(() => _repo.deleteWorkout(w.id), 'Đã xoá buổi tập.');
    }
  }

  Future<void> _addSteps() async {
    final steps = await showDialog<int>(context: context, builder: (_) => const _StepsDialog());
    if (steps == null) return;
    await _run(() => _repo.addSteps(steps), 'Đã ghi $steps bước.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tập luyện'),
        actions: [
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
      // StreamBuilder tự vẽ lại giao diện mỗi khi dữ liệu Firestore thay đổi.
      body: StreamBuilder<List<Workout>>(
        stream: _workoutsStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Không tải được dữ liệu.\n${snapshot.error}', textAlign: TextAlign.center));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final workouts = snapshot.data!;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              _summaryCard(workouts),
              _stepsCard(),
              const SizedBox(height: 12),
              Text('Lịch sử tập luyện', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              if (workouts.isEmpty) const Center(child: Text('Chưa có buổi tập nào. Nhấn “Thêm buổi tập” để bắt đầu.')),
              for (final w in workouts) _workoutTile(w),
            ],
          );
        },
      ),
    );
  }

  /// Thẻ tổng kết: tổng buổi, phút, calo, chuỗi ngày và phút trong 7 ngày.
  Widget _summaryCard(List<Workout> workouts) {
    var totalMinutes = 0;
    var totalCalories = 0;
    for (final w in workouts) {
      totalMinutes += w.minutes;
      totalCalories += w.calories;
    }
    final streak = GoalRules.streak(workouts.map((w) => w.date).toList());
    final last7Minutes = workouts.where((w) => GoalRules.isInLastDays(w.date, 7)).map((w) => w.minutes).toList();
    final weekMinutes = GoalRules.weeklyMinutes(last7Minutes);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('Buổi tập', '${workouts.length}'),
                _stat('Thời gian', '$totalMinutes phút'),
                _stat('Calo đốt', '$totalCalories kcal'),
              ],
            ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('Chuỗi ngày tập', '$streak ngày'),
                _stat('7 ngày gần nhất', '$weekMinutes phút'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
        Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      ],
    );
  }

  /// Thẻ bước chân hôm nay, có nút + để ghi thêm bước.
  Widget _stepsCard() {
    return Card(
      child: ListTile(
        leading: const CircleAvatar(child: Icon(Icons.directions_walk)),
        title: const Text('Bước chân hôm nay'),
        subtitle: StreamBuilder<int>(
          stream: _stepsStream,
          builder: (context, snapshot) => Text('${snapshot.data ?? 0} bước'),
        ),
        trailing: IconButton.filledTonal(
          tooltip: 'Ghi thêm bước chân',
          icon: const Icon(Icons.add),
          onPressed: _addSteps,
        ),
      ),
    );
  }

  /// Một dòng trong lịch sử: chạm để sửa, nút thùng rác để xoá.
  Widget _workoutTile(Workout w) {
    return Card(
      child: ListTile(
        onTap: () => _openWorkoutDialog(old: w),
        leading: const CircleAvatar(child: Icon(Icons.fitness_center)),
        title: Text(w.name),
        subtitle: Text('${w.minutes} phút • ${w.calories} kcal • ${w.date.day}/${w.date.month}/${w.date.year}'),
        trailing: IconButton(
          tooltip: 'Xoá',
          icon: const Icon(Icons.delete_outline),
          onPressed: () => _deleteWorkout(w),
        ),
      ),
    );
  }
}

class _WorkoutInput {
  const _WorkoutInput(this.name, this.minutes, this.calories);

  final String name;
  final int minutes;
  final int calories;
}

/// Hộp thoại thêm (tính calo theo MET) hoặc sửa (nhập calo trực tiếp) một buổi tập.
class _WorkoutDialog extends StatefulWidget {
  const _WorkoutDialog({this.existing});

  final Workout? existing;

  @override
  State<_WorkoutDialog> createState() => _WorkoutDialogState();
}

class _WorkoutDialogState extends State<_WorkoutDialog> {
  late final TextEditingController _name;
  late final TextEditingController _minutes;
  late final TextEditingController _weight;
  late final TextEditingController _calories;
  String _activity = _kMets.keys.first;
  String? _error;

  bool get _editing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final w = widget.existing;
    _name = TextEditingController(text: w?.name ?? '');
    _minutes = TextEditingController(text: w == null ? '' : '${w.minutes}');
    _weight = TextEditingController(text: '60');
    _calories = TextEditingController(text: w == null ? '' : '${w.calories}');
  }

  @override
  void dispose() {
    _name.dispose();
    _minutes.dispose();
    _weight.dispose();
    _calories.dispose();
    super.dispose();
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
      calories = GoalRules.estimateCalories(met: _kMets[_activity]!, weightKg: weight, minutes: minutes);
    }
    final typed = _name.text.trim();
    final name = typed.isNotEmpty ? typed : (_editing ? widget.existing!.name : _activity);
    Navigator.pop(context, _WorkoutInput(name, minutes, calories));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_editing ? 'Sửa buổi tập' : 'Thêm buổi tập'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!_editing) ...[
              InputDecorator(
                decoration: const InputDecoration(labelText: 'Loại bài tập', border: OutlineInputBorder()),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    isDense: true,
                    value: _activity,
                    items: _kMets.keys.map((e) => DropdownMenuItem<String>(value: e, child: Text(e))).toList(),
                    onChanged: (v) => setState(() => _activity = v ?? _activity),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],
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
              decoration: const InputDecoration(labelText: 'Thời lượng (phút)', border: OutlineInputBorder()),
            ),
            const SizedBox(height: 12),
            if (_editing)
              TextField(
                controller: _calories,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Calo đốt (kcal)', border: OutlineInputBorder()),
              )
            else
              TextField(
                controller: _weight,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: 'Cân nặng (kg)',
                  helperText: 'Dùng để ước tính calo đốt',
                  border: OutlineInputBorder(),
                ),
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

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Ghi thêm bước chân'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(labelText: 'Số bước', errorText: _error, border: const OutlineInputBorder()),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Huỷ')),
        FilledButton(onPressed: _submit, child: const Text('Lưu')),
      ],
    );
  }
}
