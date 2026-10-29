import 'package:flutter/material.dart';

import '../../models/workout.dart';

class WorkoutList extends StatelessWidget {
  final List<Workout> workouts;
  final ValueChanged<Workout> onDelete;

  const WorkoutList({
    super.key,
    required this.workouts,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (workouts.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('Chưa có hoạt động nào. Hãy thêm hoạt động đầu tiên!'),
          ),
        ),
      );
    }

    return Column(
      children: workouts.map((workout) {
        return Card(
          margin: const EdgeInsets.only(bottom: 10),
          child: ListTile(
            leading: const CircleAvatar(
              child: Icon(Icons.directions_run),
            ),
            title: Text(
              workout.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text('${workout.minutes} phút • ${workout.calories} kcal'),
            trailing: IconButton(
              tooltip: 'Xóa hoạt động',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => onDelete(workout),
            ),
          ),
        );
      }).toList(),
    );
  }
}
