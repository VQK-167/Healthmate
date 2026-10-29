import 'package:flutter/material.dart';

import '../../models/workout.dart';

class AddWorkoutDialog extends StatefulWidget {
  const AddWorkoutDialog({super.key});

  @override
  State<AddWorkoutDialog> createState() => _AddWorkoutDialogState();
}

class _AddWorkoutDialogState extends State<AddWorkoutDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _minutesController = TextEditingController();
  final _caloriesController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _minutesController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final workout = Workout(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      userId: 'demo-user',
      name: _nameController.text.trim(),
      minutes: int.parse(_minutesController.text.trim()),
      calories: int.parse(_caloriesController.text.trim()),
      logDate: DateTime.now().toIso8601String(),
    );

    Navigator.of(context).pop(workout);
  }

  String? _validatePositiveInteger(String? value, String label) {
    final number = int.tryParse(value?.trim() ?? '');
    if (number == null || number < 1) {
      return 'Nhập $label là số nguyên lớn hơn 0';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Thêm hoạt động'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Tên hoạt động',
                  hintText: 'Ví dụ: Chạy bộ',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Vui lòng nhập tên hoạt động';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _minutesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Thời gian (phút)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) =>
                    _validatePositiveInteger(value, 'thời gian'),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _caloriesController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Calo tiêu thụ (kcal)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) => _validatePositiveInteger(value, 'calo'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Hủy'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Lưu'),
        ),
      ],
    );
  }
}
