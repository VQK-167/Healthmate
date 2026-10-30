// lib/core/preset_foods.dart
// Phụ trách: Khánh. Danh sách món có sẵn để chọn nhanh khi thêm bữa ăn.
// Giá trị dinh dưỡng là ước tính cho 1 phần.
 
import '../models/nutrition.dart';
 
class PresetFood {
  final String name;
  final String unit; // ví dụ: tô, dĩa, quả, 100g
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
 
  const PresetFood({
    required this.name,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
  });
 
  /// Tạo một bữa ăn từ món có sẵn (id rỗng: Firestore sẽ tự sinh khi lưu).
  Meal toMeal({
    String id = '',
    required MealType mealType,
    double quantity = 1,
    DateTime? at,
  }) =>
      Meal(
        id: id,
        name: name,
        mealType: mealType,
        calories: calories,
        protein: protein,
        carbs: carbs,
        fat: fat,
        quantity: quantity,
        loggedAt: at ?? DateTime.now(),
      );
}
 
const List<PresetFood> presetFoods = [
  PresetFood(name: 'Cơm trắng', unit: 'chén', calories: 195, protein: 4, carbs: 43, fat: 0.4),
  PresetFood(name: 'Cơm tấm sườn nướng', unit: 'dĩa', calories: 550, protein: 25, carbs: 65, fat: 18),
  PresetFood(name: 'Phở bò', unit: 'tô', calories: 450, protein: 22, carbs: 60, fat: 12),
  PresetFood(name: 'Bún bò Huế', unit: 'tô', calories: 500, protein: 25, carbs: 60, fat: 15),
  PresetFood(name: 'Bún chả', unit: 'phần', calories: 550, protein: 28, carbs: 60, fat: 22),
  PresetFood(name: 'Bánh mì thịt', unit: 'ổ', calories: 400, protein: 15, carbs: 50, fat: 15),
  PresetFood(name: 'Ức gà luộc', unit: '100g', calories: 165, protein: 31, carbs: 0, fat: 3.6),
  PresetFood(name: 'Cá hồi nướng', unit: '100g', calories: 208, protein: 20, carbs: 0, fat: 13),
  PresetFood(name: 'Đậu phụ', unit: '100g', calories: 76, protein: 8, carbs: 1.9, fat: 4.8),
  PresetFood(name: 'Trứng luộc', unit: 'quả', calories: 78, protein: 6.3, carbs: 0.6, fat: 5.3),
  PresetFood(name: 'Rau muống xào tỏi', unit: 'dĩa', calories: 90, protein: 3, carbs: 8, fat: 5),
  PresetFood(name: 'Khoai lang luộc', unit: '100g', calories: 90, protein: 2, carbs: 21, fat: 0.1),
  PresetFood(name: 'Chuối', unit: 'quả', calories: 105, protein: 1.3, carbs: 27, fat: 0.4),
  PresetFood(name: 'Táo', unit: 'quả', calories: 95, protein: 0.5, carbs: 25, fat: 0.3),
  PresetFood(name: 'Sữa tươi không đường', unit: '200ml', calories: 120, protein: 6.4, carbs: 9.4, fat: 6.4),
  PresetFood(name: 'Sữa chua', unit: 'hộp', calories: 100, protein: 3.5, carbs: 17, fat: 2),
];