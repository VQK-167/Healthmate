// lib/screens/nutrition_page.dart
// Phụ trách: Khánh - trang Dinh dưỡng.
// Bản đầu: dữ liệu lưu tạm trong bộ nhớ, sau sẽ đổi sang nutrition_repository.
 
import 'package:flutter/material.dart';
 
import '../models/nutrition.dart';
import 'add_meal_page.dart';
 
class NutritionPage extends StatefulWidget {
  const NutritionPage({super.key});
 
  @override
  State<NutritionPage> createState() => _NutritionPageState();
}
 
class _NutritionPageState extends State<NutritionPage> {
  static const double _calorieGoal = 2000;
  static const int _waterGoalMl = 2000;
 
  final List<Meal> _meals = [];
  final List<WaterLog> _water = [];
  int _counter = 0;
 
  String _n(double v) => v.toStringAsFixed(0);
 
  String _q(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
 
  Future<void> _addMeal() async {
    final meal = await Navigator.of(context).push<Meal>(
      MaterialPageRoute(builder: (_) => const AddMealPage()),
    );
    if (meal == null || !mounted) return;
    setState(() => _meals.add(meal.copyWith(id: 'local${++_counter}')));
  }
 
  void _removeMeal(Meal meal) {
    setState(() => _meals.removeWhere((m) => m.id == meal.id));
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text('Đã xóa ${meal.name}'),
          action: SnackBarAction(
            label: 'Hoàn tác',
            onPressed: () => setState(() => _meals.add(meal)),
          ),
        ),
      );
  }
 
  void _addWater(int ml) {
    setState(() {
      _water.add(WaterLog(
        id: 'w${++_counter}',
        amountMl: ml,
        loggedAt: DateTime.now(),
      ));
    });
  }
 
  void _undoWater() {
    if (_water.isEmpty) return;
    setState(() => _water.removeLast());
  }
 
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final grouped = groupByMealType(_meals);
 
    return Scaffold(
      appBar: AppBar(title: const Text('Dinh dưỡng')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addMeal,
        icon: const Icon(Icons.add),
        label: const Text('Thêm món'),
      ),
      body: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 640),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
            children: [
              _summaryCard(cs),
              const SizedBox(height: 12),
              _waterCard(cs),
              for (final type in MealType.values)
                ..._mealSection(cs, type, grouped[type]!),
            ],
          ),
        ),
      ),
    );
  }
 
  Widget _summaryCard(ColorScheme cs) {
    final kcal = sumCalories(_meals);
    final protein = _meals.fold(0.0, (s, m) => s + m.totalProtein);
    final carbs = _meals.fold(0.0, (s, m) => s + m.totalCarbs);
    final fat = _meals.fold(0.0, (s, m) => s + m.totalFat);
    final remaining = _calorieGoal - kcal;
    final over = remaining < 0;
 
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Hôm nay', style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              '${_n(kcal)} / ${_n(_calorieGoal)} kcal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: over ? cs.error : cs.primary,
                  ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (kcal / _calorieGoal).clamp(0.0, 1.0).toDouble(),
              minHeight: 10,
              borderRadius: BorderRadius.circular(6),
              color: over ? cs.error : null,
            ),
            const SizedBox(height: 8),
            Text(over
                ? 'Vượt ${_n(-remaining)} kcal'
                : 'Còn lại ${_n(remaining)} kcal'),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _macro('Protein', protein),
                _macro('Carbs', carbs),
                _macro('Fat', fat),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  Widget _macro(String label, double grams) {
    return Column(
      children: [
        Text(
          '${_q(grams)}g',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(label),
      ],
    );
  }
 
  Widget _waterCard(ColorScheme cs) {
    final ml = sumWaterMl(_water);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.water_drop_outlined),
                const SizedBox(width: 8),
                const Text('Nước uống',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text('$ml / $_waterGoalMl ml'),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (ml / _waterGoalMl).clamp(0.0, 1.0).toDouble(),
              minHeight: 8,
              borderRadius: BorderRadius.circular(6),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                OutlinedButton(
                    onPressed: () => _addWater(250),
                    child: const Text('+250 ml')),
                OutlinedButton(
                    onPressed: () => _addWater(500),
                    child: const Text('+500 ml')),
                TextButton(
                    onPressed: _water.isEmpty ? null : _undoWater,
                    child: const Text('Hoàn tác')),
              ],
            ),
          ],
        ),
      ),
    );
  }
 
  List<Widget> _mealSection(ColorScheme cs, MealType type, List<Meal> meals) {
    return [
      Padding(
        padding: const EdgeInsets.fromLTRB(4, 16, 4, 4),
        child: Row(
          children: [
            Text(
              type.label,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text('${_n(sumCalories(meals))} kcal',
                style: TextStyle(color: cs.onSurfaceVariant)),
          ],
        ),
      ),
      if (meals.isEmpty)
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Text('Chưa có món nào',
              style: TextStyle(color: cs.onSurfaceVariant)),
        ),
      for (final meal in meals) _mealTile(cs, meal),
    ];
  }
 
  Widget _mealTile(ColorScheme cs, Meal meal) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Dismissible(
          key: ValueKey(meal.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: cs.errorContainer,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
          ),
          onDismissed: (_) => _removeMeal(meal),
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              title: Text(meal.name,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text(
                'x${_q(meal.quantity)} phần · P ${_q(meal.totalProtein)}g · '
                'C ${_q(meal.totalCarbs)}g · F ${_q(meal.totalFat)}g',
              ),
              trailing: Text(
                '${_n(meal.totalCalories)} kcal',
                style: TextStyle(
                    color: cs.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            ),
          ),
        ),
      ),
    );
  }
}