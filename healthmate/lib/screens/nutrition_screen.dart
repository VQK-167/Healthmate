import 'package:flutter/material.dart';
import '../models/nutrition.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  // Danh sách dữ liệu mẫu để test
  final List<Nutrition> nutritionList = [
    Nutrition(
      foodName: 'Cơm tấm sườn nướng',
      calories: 550,
      protein: 25,
      carbs: 65,
      fat: 18,
      date: DateTime.now(),
    ),
    Nutrition(
      foodName: 'Ức gà luộc',
      calories: 165,
      protein: 31,
      carbs: 0,
      fat: 3.6,
      date: DateTime.now(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nhật Ký Dinh Dưỡng'),
        backgroundColor: Colors.green,
      ),
      body: ListView.builder(
        itemCount: nutritionList.length,
        itemBuilder: (context, index) {
          final item = nutritionList[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: ListTile(
              title: Text(
                item.foodName,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(
                'Protein: ${item.protein}g | Carbs: ${item.carbs}g | Fat: ${item.fat}g',
              ),
              trailing: Text(
                '${item.calories} kcal',
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
    );
  }
}