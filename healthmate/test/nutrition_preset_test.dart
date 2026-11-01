import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/core/preset_foods.dart';

void main() {
  group('normalizeText', () {
    test('bỏ dấu và đổi sang chữ thường', () {
      expect(normalizeText('Phở Bò'), 'pho bo');
      expect(normalizeText('Đậu phụ'), 'dau phu');
      expect(normalizeText('CƠM TẤM'), 'com tam');
      expect(normalizeText('  Bún chả  '), 'bun cha');
    });

    test('giữ nguyên chữ không dấu và số', () {
      expect(normalizeText('Pizza 2'), 'pizza 2');
    });
  });

  group('searchPresetFoods', () {
    List<String> names(List<PresetFood> foods) => foods.map((f) => f.name).toList();

    test('gõ không dấu vẫn tìm ra món có dấu', () {
      expect(names(searchPresetFoods('pho')), contains('Phở bò'));
    });

    test('không phân biệt chữ hoa chữ thường', () {
      final result = names(searchPresetFoods('COM'));
      expect(result, contains('Cơm trắng'));
      expect(result, contains('Cơm tấm sườn nướng'));
    });

    test('từ khóa rỗng trả về tất cả món', () {
      expect(searchPresetFoods('').length, presetFoods.length);
    });

    test('không có món phù hợp thì rỗng', () {
      expect(searchPresetFoods('xyz123'), isEmpty);
    });

    test('lọc theo nhóm đồ uống', () {
      final drinks = searchPresetFoods('', category: PresetCategory.drink);
      expect(drinks, isNotEmpty);
      expect(drinks.every((f) => f.category == PresetCategory.drink), isTrue);
      expect(searchPresetFoods('pho', category: PresetCategory.drink), isEmpty);
    });
  });

  group('presetFoods', () {
    test('tên món không trùng nhau', () {
      final names = presetFoods.map((f) => f.name).toSet();
      expect(names.length, presetFoods.length);
    });

    test('mỗi nhóm đều có món', () {
      for (final c in PresetCategory.values) {
        expect(presetFoods.where((f) => f.category == c), isNotEmpty, reason: c.label);
      }
    });

    test('nhãn nhóm đúng như yêu cầu', () {
      expect(PresetCategory.vietnamese.label, 'Món Việt');
      expect(PresetCategory.drink.label, 'Đồ uống');
      expect(PresetCategory.breakfast.label, 'Đồ ăn sáng');
      expect(PresetCategory.fastFood.label, 'Đồ ăn nhanh');
    });
  });
}