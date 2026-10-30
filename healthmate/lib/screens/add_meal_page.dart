// lib/screens/add_meal_page.dart
// Phụ trách: Khánh. Trả về một Meal qua Navigator.pop khi bấm Lưu.
 
import 'package:flutter/material.dart';
 
import '../core/preset_foods.dart';
import '../models/nutrition.dart';
 
String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
 
class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key});
 
  @override
  State<AddMealPage> createState() => _AddMealPageState();
}
 
class _AddMealPageState extends State<AddMealPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _cal = TextEditingController();
  final TextEditingController _protein = TextEditingController();
  final TextEditingController _carbs = TextEditingController();
  final TextEditingController _fat = TextEditingController();
  final TextEditingController _quantity = TextEditingController(text: '1');
 
  MealType _type = MealType.breakfast;
  String _search = '';
  String? _error;
 
  static const TextInputType _numberKeyboard =
      TextInputType.numberWithOptions(decimal: true);
 
  @override
  void dispose() {
    _name.dispose();
    _cal.dispose();
    _protein.dispose();
    _carbs.dispose();
    _fat.dispose();
    _quantity.dispose();
    super.dispose();
  }
 
  double _num(TextEditingController c) =>
      double.tryParse(c.text.trim().replaceAll(',', '.')) ?? 0;
 
  /// Điền sẵn các ô từ món có sẵn.
  void _fillFrom(PresetFood f) {
    setState(() {
      _name.text = f.name;
      _cal.text = _fmt(f.calories);
      _protein.text = _fmt(f.protein);
      _carbs.text = _fmt(f.carbs);
      _fat.text = _fmt(f.fat);
      _error = null;
    });
  }
 
  void _save() {
    final error = validateMealInput(
      name: _name.text,
      calories: _cal.text,
      quantity: _quantity.text,
    );
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.of(context).pop(
      Meal(
        name: _name.text.trim(),
        mealType: _type,
        calories: _num(_cal),
        protein: _num(_protein),
        carbs: _num(_carbs),
        fat: _num(_fat),
        quantity: _num(_quantity),
        loggedAt: DateTime.now(),
      ),
    );
  }
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final keyword = _search.trim().toLowerCase();
    final foods = presetFoods
        .where((f) => f.name.toLowerCase().contains(keyword))
        .toList();
 
    return Scaffold(
      appBar: AppBar(title: const Text('Thêm món')),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              const Text('Bữa ăn',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final t in MealType.values)
                    ChoiceChip(
                      label: Text(t.label),
                      selected: _type == t,
                      onSelected: (_) => setState(() => _type = t),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              const Text('Chọn nhanh món có sẵn',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm món...',
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
              const SizedBox(height: 8),
              if (foods.isEmpty)
                Text('Không có món phù hợp',
                    style: TextStyle(color: cs.onSurfaceVariant))
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    for (final f in foods)
                      ActionChip(
                        label: Text(
                            '${f.name} (${f.unit}) · ${_fmt(f.calories)} kcal'),
                        onPressed: () => _fillFrom(f),
                      ),
                  ],
                ),
              const SizedBox(height: 16),
              const Text('Thông tin món',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Tên món'),
              ),
              TextField(
                controller: _cal,
                keyboardType: _numberKeyboard,
                decoration: const InputDecoration(
                    labelText: 'Calo (kcal cho 1 phần)'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _protein,
                      keyboardType: _numberKeyboard,
                      decoration:
                          const InputDecoration(labelText: 'Protein (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _carbs,
                      keyboardType: _numberKeyboard,
                      decoration:
                          const InputDecoration(labelText: 'Carbs (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _fat,
                      keyboardType: _numberKeyboard,
                      decoration: const InputDecoration(labelText: 'Fat (g)'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: _quantity,
                keyboardType: _numberKeyboard,
                decoration: const InputDecoration(labelText: 'Số phần'),
              ),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Text(_error!, style: TextStyle(color: cs.error)),
                ),
              const SizedBox(height: 16),
              FilledButton(onPressed: _save, child: const Text('Lưu')),
            ],
          ),
        ),
      ),
    );
  }
}