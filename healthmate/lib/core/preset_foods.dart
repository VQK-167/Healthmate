
import '../models/nutrition.dart';

/// Nhóm món có sẵn.
enum PresetCategory {
  vietnamese('Món Việt'),
  drink('Đồ uống'),
  breakfast('Đồ ăn sáng'),
  fastFood('Đồ ăn nhanh');

  const PresetCategory(this.label);

  /// Tên hiển thị tiếng Việt.
  final String label;
}

class PresetFood {
  final String name;
  final String unit; // ví dụ: tô, dĩa, quả, 100g
  final double calories;
  final double protein;
  final double carbs;
  final double fat;
  final PresetCategory category;

  /// Biểu tượng minh họa (emoji), dùng thay cho ảnh khi chưa có ảnh thật.
  final String emoji;

  const PresetFood({
    required this.name,
    required this.unit,
    required this.calories,
    required this.protein,
    required this.carbs,
    required this.fat,
    this.category = PresetCategory.vietnamese,
    this.emoji = '🍽️',
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

const Map<String, String> _accentGroups = {
  'a': 'àáạảãâầấậẩẫăằắặẳẵ',
  'e': 'èéẹẻẽêềếệểễ',
  'i': 'ìíịỉĩ',
  'o': 'òóọỏõôồốộổỗơờớợởỡ',
  'u': 'ùúụủũưừứựửữ',
  'y': 'ỳýỵỷỹ',
  'd': 'đ',
};


final Map<String, String> _accentMap = {
  for (final e in _accentGroups.entries)
    for (final ch in e.value.split('')) ch: e.key,
};

final RegExp _combiningMarks = RegExp('[\u0300-\u036f]');
final RegExp _spaces = RegExp(r'\s+');

String normalizeText(String input) {
  final buffer = StringBuffer();
  for (final ch in input.toLowerCase().split('')) {
    buffer.write(_accentMap[ch] ?? ch);
  }
  return buffer
      .toString()
      .replaceAll(_combiningMarks, '') // trường hợp dấu rời (NFD)
      .replaceAll(_spaces, ' ')
      .trim();
}

List<PresetFood> searchPresetFoods(String query, {PresetCategory? category}) {
  final keyword = normalizeText(query);
  return presetFoods
      .where((f) => category == null || f.category == category)
      .where((f) => keyword.isEmpty || normalizeText(f.name).contains(keyword))
      .toList();
}

const List<PresetFood> presetFoods = [
  // ----- Món Việt -----
  PresetFood(name: 'Cơm trắng', unit: 'chén', calories: 195, protein: 4, carbs: 43, fat: 0.4, emoji: '🍚'),
  PresetFood(name: 'Cơm tấm sườn nướng', unit: 'dĩa', calories: 550, protein: 25, carbs: 65, fat: 18, emoji: '🍛'),
  PresetFood(name: 'Cơm gà', unit: 'dĩa', calories: 600, protein: 30, carbs: 70, fat: 20, emoji: '🍗'),
  PresetFood(name: 'Phở bò', unit: 'tô', calories: 450, protein: 22, carbs: 60, fat: 12, emoji: '🍜'),
  PresetFood(name: 'Phở gà', unit: 'tô', calories: 400, protein: 24, carbs: 58, fat: 8, emoji: '🍜'),
  PresetFood(name: 'Bún bò Huế', unit: 'tô', calories: 500, protein: 25, carbs: 60, fat: 15, emoji: '🍜'),
  PresetFood(name: 'Bún chả', unit: 'phần', calories: 550, protein: 28, carbs: 60, fat: 22, emoji: '🍢'),
  PresetFood(name: 'Bún riêu', unit: 'tô', calories: 400, protein: 20, carbs: 55, fat: 11, emoji: '🍜'),
  PresetFood(name: 'Bún thịt nướng', unit: 'tô', calories: 520, protein: 24, carbs: 70, fat: 16, emoji: '🍜'),
  PresetFood(name: 'Hủ tiếu', unit: 'tô', calories: 420, protein: 20, carbs: 60, fat: 11, emoji: '🍜'),
  PresetFood(name: 'Mì Quảng', unit: 'tô', calories: 480, protein: 24, carbs: 62, fat: 14, emoji: '🍜'),
  PresetFood(name: 'Gỏi cuốn', unit: 'cuốn', calories: 70, protein: 4, carbs: 10, fat: 1.5, emoji: '🥬'),
  PresetFood(name: 'Canh chua cá', unit: 'bát', calories: 120, protein: 12, carbs: 10, fat: 3, emoji: '🥣'),
  PresetFood(name: 'Cá kho tộ', unit: 'phần', calories: 180, protein: 20, carbs: 6, fat: 8, emoji: '🐟'),
  PresetFood(name: 'Thịt kho trứng', unit: 'phần', calories: 350, protein: 22, carbs: 8, fat: 25, emoji: '🍖'),
  PresetFood(name: 'Rau muống xào tỏi', unit: 'dĩa', calories: 90, protein: 3, carbs: 8, fat: 5, emoji: '🥬'),
  PresetFood(name: 'Ức gà luộc', unit: '100g', calories: 165, protein: 31, carbs: 0, fat: 3.6, emoji: '🍗'),
  PresetFood(name: 'Cá hồi nướng', unit: '100g', calories: 208, protein: 20, carbs: 0, fat: 13, emoji: '🐟'),
  PresetFood(name: 'Đậu phụ', unit: '100g', calories: 76, protein: 8, carbs: 1.9, fat: 4.8, emoji: '🧈'),
  PresetFood(name: 'Khoai lang luộc', unit: '100g', calories: 90, protein: 2, carbs: 21, fat: 0.1, emoji: '🍠'),

  // ----- Đồ ăn sáng -----
  PresetFood(name: 'Bánh mì thịt', unit: 'ổ', calories: 400, protein: 15, carbs: 50, fat: 15, category: PresetCategory.breakfast, emoji: '🥖'),
  PresetFood(name: 'Bánh mì trứng', unit: 'ổ', calories: 350, protein: 14, carbs: 45, fat: 13, category: PresetCategory.breakfast, emoji: '🥖'),
  PresetFood(name: 'Xôi mặn', unit: 'gói', calories: 450, protein: 14, carbs: 70, fat: 13, category: PresetCategory.breakfast, emoji: '🍙'),
  PresetFood(name: 'Bánh cuốn', unit: 'dĩa', calories: 350, protein: 12, carbs: 55, fat: 8, category: PresetCategory.breakfast, emoji: '🥟'),
  PresetFood(name: 'Cháo thịt bằm', unit: 'tô', calories: 250, protein: 12, carbs: 38, fat: 5, category: PresetCategory.breakfast, emoji: '🥣'),
  PresetFood(name: 'Trứng ốp la', unit: '2 quả', calories: 180, protein: 12, carbs: 1, fat: 14, category: PresetCategory.breakfast, emoji: '🍳'),
  PresetFood(name: 'Trứng luộc', unit: 'quả', calories: 78, protein: 6.3, carbs: 0.6, fat: 5.3, category: PresetCategory.breakfast, emoji: '🥚'),
  PresetFood(name: 'Yến mạch sữa', unit: 'tô', calories: 300, protein: 12, carbs: 45, fat: 8, category: PresetCategory.breakfast, emoji: '🥣'),
  PresetFood(name: 'Sữa chua', unit: 'hộp', calories: 100, protein: 3.5, carbs: 17, fat: 2, category: PresetCategory.breakfast, emoji: '🥛'),
  PresetFood(name: 'Chuối', unit: 'quả', calories: 105, protein: 1.3, carbs: 27, fat: 0.4, category: PresetCategory.breakfast, emoji: '🍌'),
  PresetFood(name: 'Táo', unit: 'quả', calories: 95, protein: 0.5, carbs: 25, fat: 0.3, category: PresetCategory.breakfast, emoji: '🍎'),

  // ----- Đồ uống -----
  PresetFood(name: 'Sữa tươi không đường', unit: '200ml', calories: 120, protein: 6.4, carbs: 9.4, fat: 6.4, category: PresetCategory.drink, emoji: '🥛'),
  PresetFood(name: 'Cà phê đen không đường', unit: 'ly', calories: 5, protein: 0.3, carbs: 0, fat: 0, category: PresetCategory.drink, emoji: '☕'),
  PresetFood(name: 'Cà phê sữa đá', unit: 'ly', calories: 130, protein: 2.5, carbs: 20, fat: 4, category: PresetCategory.drink, emoji: '☕'),
  PresetFood(name: 'Trà sữa trân châu', unit: 'ly', calories: 450, protein: 3, carbs: 80, fat: 12, category: PresetCategory.drink, emoji: '🧋'),
  PresetFood(name: 'Nước cam vắt', unit: 'ly', calories: 110, protein: 1.7, carbs: 26, fat: 0.5, category: PresetCategory.drink, emoji: '🍊'),
  PresetFood(name: 'Nước mía', unit: 'ly', calories: 180, protein: 0, carbs: 45, fat: 0, category: PresetCategory.drink, emoji: '🥤'),
  PresetFood(name: 'Nước dừa', unit: 'quả', calories: 60, protein: 1, carbs: 15, fat: 0.5, category: PresetCategory.drink, emoji: '🥥'),
  PresetFood(name: 'Sinh tố bơ', unit: 'ly', calories: 300, protein: 3, carbs: 30, fat: 20, category: PresetCategory.drink, emoji: '🥑'),
  PresetFood(name: 'Nước ngọt có ga', unit: 'lon 330ml', calories: 140, protein: 0, carbs: 35, fat: 0, category: PresetCategory.drink, emoji: '🥤'),

  // ----- Đồ ăn nhanh -----
  PresetFood(name: 'Pizza phô mai', unit: 'lát', calories: 285, protein: 12, carbs: 36, fat: 10, category: PresetCategory.fastFood, emoji: '🍕'),
  PresetFood(name: 'Hamburger bò', unit: 'cái', calories: 500, protein: 25, carbs: 45, fat: 25, category: PresetCategory.fastFood, emoji: '🍔'),
  PresetFood(name: 'Khoai tây chiên', unit: 'phần vừa', calories: 365, protein: 4, carbs: 48, fat: 17, category: PresetCategory.fastFood, emoji: '🍟'),
  PresetFood(name: 'Gà rán', unit: 'miếng', calories: 320, protein: 19, carbs: 11, fat: 22, category: PresetCategory.fastFood, emoji: '🍗'),
  PresetFood(name: 'Hot dog', unit: 'cái', calories: 300, protein: 11, carbs: 25, fat: 17, category: PresetCategory.fastFood, emoji: '🌭'),
  PresetFood(name: 'Mì gói', unit: 'gói', calories: 380, protein: 8, carbs: 52, fat: 14, category: PresetCategory.fastFood, emoji: '🍜'),
  PresetFood(name: 'Mì Ý sốt bò bằm', unit: 'dĩa', calories: 550, protein: 22, carbs: 70, fat: 18, category: PresetCategory.fastFood, emoji: '🍝'),
];