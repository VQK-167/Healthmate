import 'package:flutter/material.dart';

class WorkoutSummary extends StatelessWidget {
  final int totalMinutes;
  final int totalCalories;
  final int workoutCount;

  const WorkoutSummary({
    super.key,
    required this.totalMinutes,
    required this.totalCalories,
    required this.workoutCount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tổng quan hôm nay',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _SummaryValue(
                    icon: Icons.timer_outlined,
                    value: '$totalMinutes',
                    label: 'Phút tập',
                  ),
                ),
                Expanded(
                  child: _SummaryValue(
                    icon: Icons.local_fire_department_outlined,
                    value: '$totalCalories',
                    label: 'Kcal',
                  ),
                ),
                Expanded(
                  child: _SummaryValue(
                    icon: Icons.fitness_center,
                    value: '$workoutCount',
                    label: 'Hoạt động',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _SummaryValue({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 25),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(label, textAlign: TextAlign.center),
      ],
    );
  }
}
