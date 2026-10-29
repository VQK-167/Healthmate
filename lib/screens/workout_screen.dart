import 'package:flutter/material.dart';

import '../models/workout.dart';
import 'widgets/add_workout_dialog.dart';
import 'widgets/workout_list.dart';
import 'widgets/workout_summary.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  final List<Workout> _workouts = [
    Workout(
      id: '1',
      userId: 'demo-user',
      name: 'Chạy bộ sáng',
      minutes: 30,
      calories: 250,
      logDate: DateTime.now().toIso8601String(),
    ),
    Workout(
      id: '2',
      userId: 'demo-user',
      name: 'Đạp xe',
      minutes: 45,
      calories: 320,
      logDate: DateTime.now().toIso8601String(),
    ),
    Workout(
      id: '3',
      userId: 'demo-user',
      name: 'Yoga thư giãn',
      minutes: 20,
      calories: 90,
      logDate: DateTime.now().toIso8601String(),
    ),
  ];

  int get _totalMinutes =>
      _workouts.fold(0, (total, workout) => total + workout.minutes);

  int get _totalCalories =>
      _workouts.fold(0, (total, workout) => total + workout.calories);

  Future<void> _showAddWorkoutDialog() async {
    final workout = await showDialog<Workout>(
      context: context,
      builder: (_) => const AddWorkoutDialog(),
    );

    if (workout != null && mounted) {
      setState(() => _workouts.insert(0, workout));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã thêm hoạt động')),
      );
    }
  }

  void _deleteWorkout(Workout workout) {
    setState(() => _workouts.removeWhere((item) => item.id == workout.id));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa hoạt động')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật ký vận động'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddWorkoutDialog,
        icon: const Icon(Icons.add),
        label: const Text('Thêm hoạt động'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
        children: [
          WorkoutSummary(
            totalMinutes: _totalMinutes,
            totalCalories: _totalCalories,
            workoutCount: _workouts.length,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Text(
                'Hoạt động gần đây',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const Spacer(),
              Text('${_workouts.length} hoạt động'),
            ],
          ),
          const SizedBox(height: 12),
          WorkoutList(
            workouts: _workouts,
            onDelete: _deleteWorkout,
          ),
        ],
      ),
    );
  }
}
