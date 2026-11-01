
import 'package:flutter/material.dart';

import '../core/preset_foods.dart';
import '../models/nutrition.dart';

String _fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

class AddMealPage extends StatefulWidget {
  const AddMealPage({super.key, this.initialMeal});

  /// Có giá trị: chế độ sửa, các ô điền sẵn và giữ nguyên id, giờ ăn.
  final Meal? initialMeal;

  @override
  State<AddMealPage> createState() => _AddMealPageState();
}

class _AddMealPageState extends State<AddMealPage> {
  late final TextEditingController _name;
  late final TextEditingController _cal;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  late final TextEditingController _quantity;

  late MealType _type;
  String _search = '';
  PresetCategory? _category; // null = tất cả nhóm
  String? _error;

  static const TextInputType _numberKeyboard =
      TextInputType.numberWithOptions(decimal: true);

  bool get _isEditing => widget.initialMeal != null;

  @override
  void initState() {
    super.initState();
    final m = widget.initialMeal;
    _name = TextEditingController(text: m?.name ?? '');
    _cal = TextEditingController(text: m == null ? '' : _fmt(m.calories));
    _protein = TextEditingController(text: m == null ? '' : _fmt(m.protein));
    _carbs = TextEditingController(text: m == null ? '' : _fmt(m.carbs));
    _fat = TextEditingController(text: m == null ? '' : _fmt(m.fat));
    _quantity = TextEditingController(text: m == null ? '1' : _fmt(m.quantity));
    _type = m?.mealType ?? MealType.breakfast;
  }

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
    final initial = widget.initialMeal;
    Navigator.of(context).pop(
      Meal(
        id: initial?.id ?? '',
        name: _name.text.trim(),
        mealType: _type,
        calories: _num(_cal),
        protein: _num(_protein),
        carbs: _num(_carbs),
        fat: _num(_fat),
        quantity: _num(_quantity),
        loggedAt: initial?.loggedAt ?? DateTime.now(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final foods = searchPresetFoods(_search, category: _category);

    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Sửa món' : 'Thêm món')),
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
                key: const Key('search_field'),
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Tìm món (gõ không dấu cũng được)...',
                ),
                onChanged: (v) => setState(() => _search = v),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  ChoiceChip(
                    label: const Text('Tất cả'),
                    selected: _category == null,
                    onSelected: (_) => setState(() => _category = null),
                  ),
                  for (final c in PresetCategory.values)
                    ChoiceChip(
                      label: Text(c.label),
                      selected: _category == c,
                      onSelected: (_) => setState(() => _category = c),
                    ),
                ],
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
                        avatar: Text(f.emoji),
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
                key: const Key('name_field'),
                controller: _name,
                decoration: const InputDecoration(labelText: 'Tên món'),
              ),
              TextField(
                key: const Key('calories_field'),
                controller: _cal,
                keyboardType: _numberKeyboard,
                decoration: const InputDecoration(
                    labelText: 'Calo (kcal cho 1 phần)'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('protein_field'),
                      controller: _protein,
                      keyboardType: _numberKeyboard,
                      decoration:
                          const InputDecoration(labelText: 'Protein (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      key: const Key('carbs_field'),
                      controller: _carbs,
                      keyboardType: _numberKeyboard,
                      decoration:
                          const InputDecoration(labelText: 'Carbs (g)'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      key: const Key('fat_field'),
                      controller: _fat,
                      keyboardType: _numberKeyboard,
                      decoration: const InputDecoration(labelText: 'Fat (g)'),
                    ),
                  ),
                ],
              ),
              TextField(
                key: const Key('quantity_field'),
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
              FilledButton(
                key: const Key('save_button'),
                onPressed: _save,
                child: const Text('Lưu'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}