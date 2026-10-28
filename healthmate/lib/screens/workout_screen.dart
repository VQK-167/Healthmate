import 'package:flutter/material.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});

  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  // Danh sách bài tập mẫu (Bạn có thể thay thế bằng dữ liệu lấy từ API hoặc Database sau)
  final List<Map<String, dynamic>> _workouts = [
    {'name': 'Chạy bộ sáng', 'minutes': 30, 'calories': 320, 'date': 'Hôm nay'},
    {'name': 'Đạp xe', 'minutes': 45, 'calories': 400, 'date': 'Hôm nay'},
    {'name': 'Yoga thư giãn', 'minutes': 20, 'calories': 100, 'date': 'Hôm qua'},
  ];

  void _showAddWorkoutDialog(BuildContext context) {
    final nameController = TextEditingController();
    final minutesController = TextEditingController();
    final caloriesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Thêm bài tập mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(
                labelText: 'Tên bài tập (VD: Chạy bộ, Gym...)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: minutesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Số phút tập',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: caloriesController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Calories tiêu hao (kcal)',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F766E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              if (nameController.text.isNotEmpty &&
                  minutesController.text.isNotEmpty &&
                  caloriesController.text.isNotEmpty) {
                setState(() {
                  _workouts.insert(0, {
                    'name': nameController.text,
                    'minutes': int.tryParse(minutesController.text) ?? 0,
                    'calories': int.tryParse(caloriesController.text) ?? 0,
                    'date': 'Hôm nay',
                  });
                });
                Navigator.pop(context);
              }
            },
            child: const Text('Thêm'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Nhật ký Thể thao',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _workouts.length,
        itemBuilder: (context, index) {
          final item = _workouts[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE3EBE9)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0EBE8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.fitness_center, color: Color(0xFF0F766E), size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black87),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Thời gian: ${item['minutes']} phút  •  ${item['date']}',
                        style: const TextStyle(fontSize: 12, color: Colors.black54),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFFD1E7E2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '-${item['calories']} kcal',
                    style: const TextStyle(
                      color: Color(0xFF0F766E),
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF0F766E),
        foregroundColor: Colors.white,
        onPressed: () => _showAddWorkoutDialog(context),
        icon: const Icon(Icons.add),
        label: const Text('Thêm bài tập'),
      ),
    );
  }
}