
import 'package:flutter/material.dart';

import '../models/nutrition.dart';
import '../repositories/in_memory_nutrition_store.dart';
import '../repositories/nutrition_repository.dart';
import 'add_meal_page.dart';

class NutritionPage extends StatefulWidget {
  const NutritionPage({
    super.key,
    this.store,
    this.calorieGoal = 2000,
    this.waterGoalMl,
  });

 
  final NutritionStore? store;

  /// Mục tiêu calo mỗi ngày, truyền từ `AppUser.dailyCalorieTarget`.
  final double calorieGoal;

  /// Mục tiêu nước (ml). Không truyền thì lấy từ store (Profile), rồi mặc định 2000.
  final int? waterGoalMl;

  @override
  State<NutritionPage> createState() => _NutritionPageState();
}

class _NutritionPageState extends State<NutritionPage> {
  double get _calorieGoal => widget.calorieGoal;

  late final NutritionStore _store;
  InMemoryNutritionStore? _ownedStore;

  late DateTime _day;
  late Stream<List<Meal>> _mealsStream;
  late Stream<List<WaterLog>> _waterStream;
  int _waterGoalMl = defaultWaterGoalMl;

 
  final Set<String> _hiddenMeals = {};

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? (_ownedStore = InMemoryNutritionStore());
    _day = startOfDay(DateTime.now());
    _waterGoalMl = widget.waterGoalMl ?? defaultWaterGoalMl;
    _subscribe();
    _loadWaterGoal();
  }

  @override
  void dispose() {
    _ownedStore?.dispose();
    super.dispose();
  }

  void _subscribe() {
    _mealsStream = _store.watchMealsOn(_day);
    _waterStream = _store.watchWaterLogsOn(_day);
  }

  void _loadWaterGoal() {
    if (widget.waterGoalMl != null) return; // đã được truyền từ Profile
    _store.getWaterGoalMl().then((goal) {
      if (mounted) setState(() => _waterGoalMl = goal);
    }).catchError((_) {
      // Giữ mục tiêu mặc định.
    });
  }

  // ---------- Ngày đang xem ----------

  bool get _isToday => isSameDay(_day, DateTime.now());

  String get _dayLabel {
    final now = DateTime.now();
    if (isSameDay(_day, now)) return 'Hôm nay';
    if (isSameDay(_day, now.subtract(const Duration(days: 1)))) {
      return 'Hôm qua';
    }
    String two(int v) => v.toString().padLeft(2, '0');
    return '${two(_day.day)}/${two(_day.month)}/${_day.year}';
  }

  void _setDay(DateTime day) {
    setState(() {
      _day = startOfDay(day);
      _subscribe();
    });
  }

  void _changeDay(int delta) =>
      _setDay(DateTime(_day.year, _day.month, _day.day + delta));

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _day,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) _setDay(picked);
  }

  /// Thời điểm ghi cho dữ liệu mới: bây giờ nếu đang xem hôm nay,
  /// ngược lại là giờ hiện tại nhưng nằm trong ngày đang xem.
  DateTime _stamp() {
    final now = DateTime.now();
    if (_isToday) return now;
    return DateTime(_day.year, _day.month, _day.day, now.hour, now.minute);
  }

  // ---------- Thao tác dữ liệu ----------

  void _toast(String message, {SnackBarAction? action}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message), action: action));
  }

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on NutritionException catch (e) {
      _toast(e.message);
    } catch (_) {
      _toast('Có lỗi xảy ra, vui lòng thử lại');
    }
  }

  Future<void> _addMeal() async {
    final meal = await Navigator.of(context).push<Meal>(
      MaterialPageRoute(builder: (_) => const AddMealPage()),
    );
    if (meal == null || !mounted) return;
    await _run(() => _store.addMeal(meal.copyWith(loggedAt: _stamp())));
  }

  Future<void> _editMeal(Meal meal) async {
    final edited = await Navigator.of(context).push<Meal>(
      MaterialPageRoute(builder: (_) => AddMealPage(initialMeal: meal)),
    );
    if (edited == null || !mounted) return;
    await _run(() => _store.updateMeal(edited));
  }

  Future<void> _deleteMeal(Meal meal) async {
    setState(() => _hiddenMeals.add(meal.id));
    await _run(() => _store.deleteMeal(meal.id));
    _toast(
      'Đã xóa ${meal.name}',
      action: SnackBarAction(
        label: 'Hoàn tác',
        onPressed: () => _run(() => _store.addMeal(meal.copyWith(id: ''))),
      ),
    );
  }

  Future<void> _addWater(int ml) =>
      _run(() => _store.addWater(ml, at: _stamp()));

  Future<void> _undoWater(List<WaterLog> logs) {
    if (logs.isEmpty) return Future.value();
    return _run(() => _store.deleteWaterLog(logs.last.id));
  }

  // ---------- Giao diện ----------

  String _n(double v) => v.toStringAsFixed(0);

  String _q(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  String _two(int v) => v.toString().padLeft(2, '0');

  String _time(DateTime t) => '${_two(t.hour)}:${_two(t.minute)}';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
          child: StreamBuilder<List<Meal>>(
            stream: _mealsStream,
            builder: (context, mealSnap) {
              if (mealSnap.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(
                      'Không tải được dữ liệu: ${mealSnap.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: cs.error),
                    ),
                  ),
                );
              }
              final meals = (mealSnap.data ?? const <Meal>[])
                  .where((m) => !_hiddenMeals.contains(m.id))
                  .toList();
              final grouped = groupByMealType(meals);

              return StreamBuilder<List<WaterLog>>(
                stream: _waterStream,
                builder: (context, waterSnap) {
                  final water = waterSnap.data ?? const <WaterLog>[];
                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      _dayBar(),
                      _summaryCard(cs, DaySummary.of(meals), grouped),
                      const SizedBox(height: 12),
                      _waterCard(cs, water),
                      for (final type in MealType.values)
                        ..._mealSection(cs, type, grouped[type]!),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _dayBar() {
    return Row(
      children: [
        IconButton(
          tooltip: 'Ngày trước',
          icon: const Icon(Icons.chevron_left),
          onPressed: () => _changeDay(-1),
        ),
        Expanded(
          child: TextButton.icon(
            onPressed: _pickDate,
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: Text(_dayLabel),
          ),
        ),
        IconButton(
          tooltip: 'Ngày sau',
          icon: const Icon(Icons.chevron_right),
          onPressed: _isToday ? null : () => _changeDay(1),
        ),
      ],
    );
  }

  Widget _summaryCard(
    ColorScheme cs,
    DaySummary s,
    Map<MealType, List<Meal>> grouped,
  ) {
    final remaining = _calorieGoal - s.calories;
    final over = remaining < 0;
    final mealTimes = grouped.values.where((l) => l.isNotEmpty).length;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${s.mealCount} món · $mealTimes bữa',
                style: TextStyle(color: cs.onSurfaceVariant)),
            const SizedBox(height: 4),
            Text(
              '${_n(s.calories)} / ${_n(_calorieGoal)} kcal',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: over ? cs.error : cs.primary,
                  ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: (s.calories / _calorieGoal).clamp(0.0, 1.0).toDouble(),
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
                _macro('Protein', s.protein),
                _macro('Carbs', s.carbs),
                _macro('Fat', s.fat),
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

  Widget _waterCard(ColorScheme cs, List<WaterLog> logs) {
    final ml = sumWaterMl(logs);
    final missing = _waterGoalMl - ml;
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
            Text(
              missing <= 0
                  ? 'Đã đạt mục tiêu nước uống'
                  : 'Còn thiếu $missing ml',
              style: TextStyle(color: cs.onSurfaceVariant),
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
                    onPressed: logs.isEmpty ? null : () => _undoWater(logs),
                    child: const Text('Hoàn tác')),
                TextButton(
                    onPressed: _showWaterHistory,
                    child: const Text('Lịch sử')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Lịch sử các lần uống nước trong ngày đang xem, có thể xóa từng lần.
  void _showWaterHistory() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: StreamBuilder<List<WaterLog>>(
          stream: _store.watchWaterLogsOn(_day),
          builder: (context, snap) {
            final logs = snap.data ?? const <WaterLog>[];
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lịch sử uống nước · ${sumWaterMl(logs)} ml',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  if (logs.isEmpty)
                    const Text('Chưa có lần uống nào')
                  else
                    Flexible(
                      child: ListView(
                        shrinkWrap: true,
                        children: [
                          for (final log in logs.reversed)
                            ListTile(
                              dense: true,
                              leading: const Icon(Icons.water_drop_outlined),
                              title: Text('${log.amountMl} ml'),
                              subtitle: Text(_time(log.loggedAt)),
                              trailing: IconButton(
                                tooltip: 'Xóa lần uống này',
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () =>
                                    _run(() => _store.deleteWaterLog(log.id)),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            );
          },
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
          onDismissed: (_) => _deleteMeal(meal),
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              onTap: () => _showMealDetail(meal),
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

  /// Xem chi tiết một món, có nút Sửa và Xóa.
  void _showMealDetail(Meal meal) {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(meal.name,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 20)),
              const SizedBox(height: 4),
              Text('${meal.mealType.label} · ${_time(meal.loggedAt)}'),
              const SizedBox(height: 12),
              Text('Số phần: ${_q(meal.quantity)}'),
              Text('Mỗi phần: ${_n(meal.calories)} kcal'),
              Text('Tổng: ${_n(meal.totalCalories)} kcal',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Protein ${_q(meal.totalProtein)}g · '
                  'Carbs ${_q(meal.totalCarbs)}g · '
                  'Fat ${_q(meal.totalFat)}g'),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _editMeal(meal);
                      },
                      child: const Text('Sửa'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.of(sheetContext).pop();
                        _deleteMeal(meal);
                      },
                      child: const Text('Xóa'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}