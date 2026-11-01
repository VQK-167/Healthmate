import 'package:flutter/material.dart';

import '../models/health_metric.dart';
import '../models/nutrition.dart';
import '../models/user.dart';
import '../models/workout.dart';
import '../repositories/health_repository.dart';
import '../repositories/nutrition_repository.dart';
import '../repositories/workout_repository.dart';
import '../services/auth_service.dart';
import '../widgets/user_avatar.dart';
import 'add_meal_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onSelectTab, this.onOpenWorkout});

  final void Function(int) onSelectTab;
  final VoidCallback? onOpenWorkout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final firebaseUser = auth.currentUser;
    final uid = firebaseUser?.uid;

    if (uid == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final nutrition = NutritionRepository(uid: uid);
    return Scaffold(
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFF8FBF9), Color(0xFFF1F7F4), Color(0xFFFFFFFF)],
            ),
          ),
          child: StreamBuilder<AppUser?>(
            stream: auth.watchProfile(uid),
            builder: (context, profileSnapshot) {
              final profile = profileSnapshot.data;
              final name = profile?.displayName.isNotEmpty == true
                  ? profile!.displayName
                  : firebaseUser?.displayName ?? 'Bạn';
              return StreamBuilder<List<Meal>>(
                stream: nutrition.watchMealsOn(DateTime.now()),
                builder: (context, mealsSnapshot) {
                  final summary = DaySummary.of(mealsSnapshot.data ?? const []);
                  return StreamBuilder<List<WaterLog>>(
                    stream: nutrition.watchWaterLogsOn(DateTime.now()),
                    builder: (context, waterSnapshot) {
                      final waterMl = waterSnapshot.hasData
                          ? sumWaterMl(waterSnapshot.data!)
                          : 0;
                      return StreamBuilder<List<Workout>>(
                        stream: _workoutRepository.watchWorkouts(),
                        builder: (context, workoutsSnapshot) {
                          final today = DateTime.now();
                          final workouts =
                              (workoutsSnapshot.data ?? const <Workout>[])
                                  .where(
                                    (workout) => isSameDay(workout.date, today),
                                  )
                                  .toList();
                          final burnedCalories = workouts.fold<int>(
                            0,
                            (total, workout) => total + workout.calories,
                          );
                          return StreamBuilder<int>(
                            stream: _workoutRepository.watchStepsToday(),
                            builder: (context, stepsSnapshot) {
                              final steps = stepsSnapshot.data ?? 0;
                              return CustomScrollView(
                                slivers: [
                                  SliverToBoxAdapter(
                                    child: _buildHeader(context, profile, name),
                                  ),
                                  SliverPadding(
                                    padding: const EdgeInsets.fromLTRB(
                                      16,
                                      8,
                                      16,
                                      24,
                                    ),
                                    sliver: SliverList(
                                      delegate: SliverChildListDelegate([
                                        _buildPrimaryFeatureGrid(
                                          context,
                                          summary,
                                        ),
                                        const SizedBox(height: 14),
                                        _buildShortcutRow(
                                          context,
                                          onAddWater: () =>
                                              nutrition.addWater(250),
                                        ),
                                        const SizedBox(height: 20),
                                        _buildSectionTitle(
                                          context,
                                          'Tóm tắt hôm nay',
                                        ),
                                        const SizedBox(height: 8),
                                        _DailyCaloriesCard(
                                          dailyTarget:
                                              profile?.dailyCalorieTarget ??
                                              2000,
                                          consumed: summary.calories.round(),
                                          burned: burnedCalories,
                                        ),
                                        const SizedBox(height: 10),
                                        _buildMacroCard(
                                          context,
                                          summary,
                                          profile,
                                        ),
                                        const SizedBox(height: 18),
                                        _buildSectionTitle(
                                          context,
                                          'Tiến độ hôm nay',
                                        ),
                                        const SizedBox(height: 8),
                                        _buildMetricGrid(
                                          context,
                                          profile,
                                          steps: steps,
                                          burnedCalories: burnedCalories,
                                          waterMl: waterMl,
                                        ),
                                        const SizedBox(height: 18),
                                        _buildSectionTitle(
                                          context,
                                          'Gợi ý hôm nay',
                                        ),
                                        const SizedBox(height: 8),
                                        _buildRecommendationCard(context),
                                      ]),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildPrimaryFeatureGrid(BuildContext context, DaySummary summary) {
    final features = [
      _FeatureTileData(
        title: 'Dinh dưỡng',
        subtitle: '${summary.mealCount} bữa hôm nay',
        icon: Icons.restaurant_outlined,
        color: const Color(0xFF72B9FF),
        onTap: () => widget.onSelectTab(2),
      ),
      _FeatureTileData(
        title: 'Sức khỏe',
        subtitle: 'Theo dõi chỉ số',
        icon: Icons.monitor_heart_outlined,
        color: const Color(0xFF69C995),
        onTap: () => widget.onSelectTab(1),
      ),
      _FeatureTileData(
        title: 'Tập luyện',
        subtitle: 'Xem hoạt động hôm nay',
        icon: Icons.fitness_center_outlined,
        color: const Color(0xFFF0B85A),
        onTap: () => widget.onSelectTab(3),
      ),
      _FeatureTileData(
        title: 'Hành trình',
        subtitle: 'Mục tiêu cá nhân',
        icon: Icons.flag_outlined,
        color: const Color(0xFF9F83E8),
        onTap: () => widget.onSelectTab(4),
      ),
    ];
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _PrimaryFeatureCard(data: features[0])),
            const SizedBox(width: 10),
            Expanded(child: _PrimaryFeatureCard(data: features[1])),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(child: _PrimaryFeatureCard(data: features[2])),
            const SizedBox(width: 10),
            Expanded(child: _PrimaryFeatureCard(data: features[3])),
            const SizedBox(width: 10),
            Expanded(
              child: _PrimaryFeatureCard(
                data: _FeatureTileData(
                  title: 'Mục tiêu',
                  subtitle: 'Calo, bước, nước',
                  icon: Icons.track_changes_outlined,
                  color: const Color(0xFFE98B83),
                  onTap: () => widget.onSelectTab(4),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildShortcutRow(
    BuildContext context, {
    required Future<void> Function() onAddWater,
  }) {
    final shortcuts = [
      ('Thêm món', Icons.add_circle_outline, () => _quickAddMeal(context)),
      (
        'Uống nước',
        Icons.water_drop_outlined,
        () => _quickAddWater(context, onAddWater),
      ),
      (
        'Cân nặng',
        Icons.monitor_weight_outlined,
        () => _quickAddWeight(context),
      ),
      (
        'Buổi tập',
        Icons.directions_run_outlined,
        () {
          if (widget.onOpenWorkout != null) {
            widget.onOpenWorkout!();
          } else {
            widget.onSelectTab(3);
          }
        },
      ),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            for (final shortcut in shortcuts)
              Expanded(
                child: InkWell(
                  onTap: shortcut.$3,
                  borderRadius: BorderRadius.circular(12),
                  child: Column(
                    children: [
                      Icon(
                        shortcut.$2,
                        color: Theme.of(context).colorScheme.primary,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        shortcut.$1,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 11),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationCard(BuildContext context) => Card(
    child: ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: const CircleAvatar(
        backgroundColor: Color(0xFFE4F2EC),
        child: Icon(Icons.auto_awesome_outlined, color: Color(0xFF2E8B68)),
      ),
      title: const Text(
        'Gợi ý cho hôm nay',
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: const Text(
        'Ghi nhận đều bữa ăn và vận động để theo dõi tiến độ chính xác hơn.',
      ),
    ),
  );
  Future<void> _quickAddMeal(BuildContext context) async {
    final meal = await Navigator.push<Meal>(
      context,
      MaterialPageRoute(builder: (_) => const AddMealPage()),
    );
    if (meal == null || !mounted) return;
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;
    try {
      await NutritionRepository(uid: uid).addMeal(meal);
    } catch (error) {
      if (mounted) _showHomeMessage('Không thể lưu món ăn: $error');
    }
  }

  Future<void> _quickAddWater(
    BuildContext context,
    Future<void> Function() fallback,
  ) async {
    final controller = TextEditingController(text: '250');
    final amount = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Uống nước'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Số ml'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.pop(dialogContext, int.tryParse(controller.text)),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (amount == null || amount <= 0) return;
    final uid = AuthService().currentUser?.uid;
    if (uid == null) return;
    try {
      await NutritionRepository(uid: uid).addWater(amount);
    } catch (_) {
      await fallback();
    }
  }

  Future<void> _quickAddWeight(BuildContext context) async {
    final controller = TextEditingController();
    final weight = await showDialog<double>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Cập nhật cân nặng'),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(labelText: 'Cân nặng (kg)'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Hủy'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              dialogContext,
              double.tryParse(controller.text.replaceAll(',', '.')),
            ),
            child: const Text('Lưu'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (weight == null || weight <= 0) return;
    final user = AuthService().currentUser;
    if (user == null) return;
    try {
      await HealthRepository(userId: user.uid).add(
        HealthMetric(
          userId: user.uid,
          recordedAt: DateTime.now(),
          weightKg: weight,
        ),
      );
      if (mounted) {
        _showHomeMessage('Đã cập nhật cân nặng và thêm vào Hành trình.');
      }
    } catch (error) {
      if (mounted) _showHomeMessage('Không thể lưu cân nặng: $error');
    }
  }

  void _showHomeMessage(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Widget _buildSectionTitle(BuildContext context, String title) => Padding(
    padding: const EdgeInsets.only(left: 2),
    child: Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
        color: Theme.of(context).colorScheme.onSurface,
        fontWeight: FontWeight.w700,
        letterSpacing: -.2,
      ),
    ),
  );

  Widget _buildHeader(BuildContext context, AppUser? profile, String name) {
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
    final hour = now.hour;
    final greeting = hour < 11
        ? 'Chào buổi sáng'
        : hour < 14
        ? 'Chào buổi trưa'
        : hour < 18
        ? 'Chào buổi chiều'
        : 'Chào buổi tối';
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
      child: Row(
        children: [
          UserAvatar(user: profile, radius: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(greeting, style: Theme.of(context).textTheme.bodySmall),
                Text(
                  name,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Hôm nay', style: TextStyle(fontSize: 12)),
              Text(
                date,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => widget.onSelectTab(4),
            icon: const Icon(Icons.notifications_none),
          ),
        ],
      ),
    );
  }

  Widget _buildMacroCard(
    BuildContext context,
    DaySummary summary,
    AppUser? profile,
  ) {
    final targetCalories = profile?.dailyCalorieTarget ?? 2000;
    final proteinTarget = (targetCalories * .2 / 4).round();
    final carbTarget = (targetCalories * .5 / 4).round();
    final fatTarget = (targetCalories * .3 / 9).round();
    return Card(
      color: const Color(0xFFEAF6EF),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: _MacroStat(
                icon: Icons.bolt,
                label: 'Protein',
                value: '${summary.protein.round()} / ${proteinTarget}g',
                color: Colors.redAccent,
              ),
            ),
            Expanded(
              child: _MacroStat(
                icon: Icons.grain,
                label: 'Carb',
                value: '${summary.carbs.round()} / ${carbTarget}g',
                color: Colors.lightBlueAccent,
              ),
            ),
            Expanded(
              child: _MacroStat(
                icon: Icons.water_drop,
                label: 'Fat',
                value: '${summary.fat.round()} / ${fatTarget}g',
                color: Colors.amber,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetricGrid(
    BuildContext context,
    AppUser? profile, {
    required int steps,
    required int burnedCalories,
    required int waterMl,
  }) {
    final stepsTarget = profile?.dailyStepsTarget ?? 10000;
    final waterTarget = profile?.dailyWaterTargetMl ?? 2000;
    return Column(
      children: [
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.35,
          children: [
            _MetricCard(
              icon: Icons.directions_walk_outlined,
              color: const Color(0xFFF0B85A),
              title: 'Bước chân',
              value: steps.toString(),
              subtitle: 'Mục tiêu $stepsTarget bước',
              progress: (steps / stepsTarget).clamp(0.0, 1.0),
              onTap: () {},
            ),
            _MetricCard(
              icon: Icons.local_fire_department_outlined,
              color: const Color(0xFFE7B34D),
              title: 'Tập luyện',
              value: '$burnedCalories kcal',
              subtitle: 'Hôm nay',
              progress: (burnedCalories / 500).clamp(0.0, 1.0),
              onTap: () {},
            ),
          ],
        ),
        const SizedBox(height: 12),
        _buildWaterCard(context, waterMl, waterTarget),
      ],
    );
  }

  Widget _buildWaterCard(BuildContext context, int waterMl, int target) {
    final progress = (waterMl / target).clamp(0.0, 1.0);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const CircleAvatar(
              backgroundColor: Color(0xFFDDF1F4),
              child: Icon(Icons.water_drop_outlined, color: Color(0xFF4AAFC0)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nước uống',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$waterMl / $target ml',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FeatureTileData {
  const _FeatureTileData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
}

class _PrimaryFeatureCard extends StatelessWidget {
  const _PrimaryFeatureCard({required this.data});

  final _FeatureTileData data;

  @override
  Widget build(BuildContext context) => Card(
    color: data.color.withValues(alpha: .18),
    child: InkWell(
      onTap: data.onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11),
                  ),
                ],
              ),
            ),
            CircleAvatar(
              backgroundColor: data.color.withValues(alpha: .3),
              child: Icon(data.icon, color: data.color),
            ),
          ],
        ),
      ),
    ),
  );
}

class _DailyCaloriesCard extends StatefulWidget {
  const _DailyCaloriesCard({
    required this.dailyTarget,
    required this.consumed,
    required this.burned,
  });

  final int dailyTarget;
  final int consumed;
  final int burned;

  @override
  State<_DailyCaloriesCard> createState() => _DailyCaloriesCardState();
}

class _DailyCaloriesCardState extends State<_DailyCaloriesCard> {
  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final dateText =
        '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';

    final progress = (widget.consumed / widget.dailyTarget).clamp(0.0, 1.0);
    final remaining = (widget.dailyTarget - widget.consumed + widget.burned)
        .clamp(0, 99999);
    return Card(
      color: const Color(0xFFDDF1E5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Mục tiêu calo',
                    style: TextStyle(
                      color: Color(0xFF17352D),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  dateText,
                  style: const TextStyle(
                    color: Color(0xFF5E786D),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                SizedBox(
                  width: 104,
                  height: 104,
                  child: _RemainingCaloriesRing(
                    remaining: remaining,
                    target: widget.dailyTarget,
                  ),
                ),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Calo còn lại',
                        style: TextStyle(
                          color: Color(0xFF5E786D),
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '$remaining kcal',
                        style: const TextStyle(
                          color: Color(0xFF17352D),
                          fontSize: 25,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        widget.consumed == 0
                            ? 'Chưa ghi nhận bữa ăn'
                            : 'Bạn còn có thể nạp hôm nay',
                        style: const TextStyle(
                          color: Color(0xFF5E786D),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Nạp vào và vận động sẽ được cập nhật tự động',
              style: TextStyle(
                color: const Color(0xFF5E786D).withValues(alpha: .72),
                fontSize: 11,
              ),
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 7,
                color: const Color(0xFFB8DCC8),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFF3E9B72),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _CalorieStat(
                    value: '${widget.dailyTarget}',
                    label: 'Mục tiêu',
                    unit: 'kcal',
                  ),
                ),
                Expanded(
                  child: _CalorieStat(
                    value: '${widget.consumed}',
                    label: 'Đã nạp',
                    unit: 'kcal',
                  ),
                ),
                Expanded(
                  child: _CalorieStat(
                    value: '${widget.burned}',
                    label: 'Tập luyện',
                    unit: 'kcal',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RemainingCaloriesRing extends StatelessWidget {
  const _RemainingCaloriesRing({required this.remaining, required this.target});
  final int remaining;
  final int target;

  @override
  Widget build(BuildContext context) {
    final progress = (remaining / target).clamp(0.0, 1.0);
    return CustomPaint(
      painter: _CaloriesRingPainter(progress),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$remaining',
              style: const TextStyle(
                color: Color(0xFF2E8B68),
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'kcal còn',
              style: TextStyle(color: Color(0xFF5E786D), fontSize: 10),
            ),
          ],
        ),
      ),
    );
  }
}

class _CaloriesRingPainter extends CustomPainter {
  const _CaloriesRingPainter(this.progress);
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = (size.shortestSide / 2) - 6;
    final background = Paint()
      ..color = const Color(0xFFC8E5D5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final foreground = Paint()
      ..color = const Color(0xFF3E9B72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, background);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -3.14159 / 2,
      2 * 3.14159 * progress,
      false,
      foreground,
    );
  }

  @override
  bool shouldRepaint(covariant _CaloriesRingPainter oldDelegate) =>
      oldDelegate.progress != progress;
}

class _CalorieStat extends StatelessWidget {
  const _CalorieStat({
    required this.value,
    required this.label,
    required this.unit,
  });
  final String value;
  final String label;
  final String unit;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(
        value,
        style: const TextStyle(
          color: Color(0xFF17352D),
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      Text(
        unit,
        style: const TextStyle(color: Color(0xFF5E786D), fontSize: 10),
      ),
      const SizedBox(height: 3),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF5E786D), fontSize: 11),
      ),
    ],
  );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.subtitle,
    required this.progress,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;
  final double progress;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 6),
            Text(title, style: Theme.of(context).textTheme.bodySmall),
            Text(
              value,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodySmall
                  ?.copyWith(fontSize: 10, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: progress,
              minHeight: 5,
              color: color,
            ),
          ],
        ),
      ),
    ),
  );
}

class _MacroStat extends StatelessWidget {
  const _MacroStat({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
    children: [
      Icon(icon, color: color, size: 22),
      const SizedBox(height: 5),
      Text(
        label,
        style: const TextStyle(color: Color(0xFF5E786D), fontSize: 11),
      ),
      const SizedBox(height: 3),
      Text(
        value,
        style: const TextStyle(
          color: Color(0xFF17352D),
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    ],
  );
}
