import 'package:flutter/material.dart';
import '../models/diary.dart';
import '../models/nutrition.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  // Dữ liệu mẫu để test: nhật ký của 1 ngày
  late DiaryDay diary = DiaryDay(
    userId: 'demo',
    date: DateTime.now(),
    calorieGoal: 2000,
    entries: [
      MealEntry(
        id: '1',
        food: const Food(
          id: 'f1',
          name: 'Cơm tấm sườn nướng',
          servingSize: 1,
          servingUnit: 'dĩa',
          nutrition: Nutrition(calories: 550, protein: 25, carbs: 65, fat: 18),
        ),
        mealType: MealType.lunch,
        loggedAt: DateTime.now(),
      ),
      MealEntry(
        id: '2',
        food: const Food(
          id: 'f2',
          name: 'Ức gà luộc',
          servingSize: 100,
          servingUnit: 'g',
          nutrition: Nutrition(calories: 165, protein: 31, carbs: 0, fat: 3.6),
        ),
        mealType: MealType.dinner,
        loggedAt: DateTime.now(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final total = diary.totalNutrition;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật Ký Dinh Dưỡng'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        children: [
          // Thẻ tổng kết trong ngày
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${total.calories.toStringAsFixed(0)} / '
                    '${diary.calorieGoal.toStringAsFixed(0)} kcal',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    diary.caloriesRemaining >= 0
                        ? 'Còn lại ${diary.caloriesRemaining.toStringAsFixed(0)} kcal'
                        : 'Vượt ${(-diary.caloriesRemaining).toStringAsFixed(0)} kcal',
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Protein: ${total.protein.toStringAsFixed(1)}g | '
                    'Carbs: ${total.carbs.toStringAsFixed(1)}g | '
                    'Fat: ${total.fat.toStringAsFixed(1)}g',
                  ),
                ],
              ),
            ),
          ),
          // Danh sách món đã ăn
          Expanded(
            child: ListView.builder(
              itemCount: diary.entries.length,
              itemBuilder: (context, index) {
                final entry = diary.entries[index];
                final n = entry.totalNutrition;
                return Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: ListTile(
                    title: Text(
                      entry.food.name,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text(
                      '${entry.mealType.label}\n'
                      'Protein: ${n.protein.toStringAsFixed(1)}g | '
                      'Carbs: ${n.carbs.toStringAsFixed(1)}g | '
                      'Fat: ${n.fat.toStringAsFixed(1)}g',
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      '${n.calories.toStringAsFixed(0)} kcal',
                      style: const TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}