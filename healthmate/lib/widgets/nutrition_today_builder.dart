
import 'package:flutter/widgets.dart';

import '../repositories/nutrition_repository.dart';
import '../repositories/nutrition_store_factory.dart';

typedef NutritionTodayWidgetBuilder = Widget Function(
  BuildContext context,
  double calories,
  int waterMl,
);

class NutritionTodayBuilder extends StatefulWidget {
  const NutritionTodayBuilder({
    super.key,
    this.store,
    required this.builder,
  });

  /// Không truyền thì dùng `createDefaultNutritionStore()`.
  final NutritionStore? store;
  final NutritionTodayWidgetBuilder builder;

  @override
  State<NutritionTodayBuilder> createState() => _NutritionTodayBuilderState();
}

class _NutritionTodayBuilderState extends State<NutritionTodayBuilder> {
  late NutritionStore _store;
  late Stream<double> _calories;
  late Stream<int> _water;

  void _subscribe() {
    _calories = _store.watchCaloriesToday();
    _water = _store.watchWaterToday();
  }

  @override
  void initState() {
    super.initState();
    _store = widget.store ?? createDefaultNutritionStore();
    _subscribe();
  }

  @override
  void didUpdateWidget(NutritionTodayBuilder oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.store;
    if (next != null && next != _store) {
      _store = next;
      _subscribe();
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<double>(
      stream: _calories,
      initialData: 0,
      builder: (context, calSnap) => StreamBuilder<int>(
        stream: _water,
        initialData: 0,
        builder: (context, waterSnap) =>
            widget.builder(context, calSnap.data ?? 0, waterSnap.data ?? 0),
      ),
    );
  }
}