import 'package:flutter/material.dart';

import '../models/health_metric.dart';
import '../models/user.dart';
import '../repositories/workout_repository.dart';
import '../services/auth_service.dart';
import '../widgets/user_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onSelectTab});

  final void Function(int) onSelectTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final WorkoutRepository _workoutRepository = WorkoutRepository();
  int _waterMl = 750;

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final firebaseUser = auth.currentUser;

    return Scaffold(
      body: SafeArea(
        child: StreamBuilder<AppUser?>(
          stream: firebaseUser == null
              ? const Stream.empty()
              : auth.watchProfile(firebaseUser.uid),
          builder: (context, snapshot) {
            final profile = snapshot.data;
            final name = profile?.displayName.isNotEmpty == true
                ? profile!.displayName
                : firebaseUser?.displayName ?? 'Bạn';
            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _buildHeader(context, profile, name)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildSectionTitle(context, 'Mục tiêu calo'),
                      const SizedBox(height: 8),
                      _DailyCaloriesCard(
                        dailyTarget: profile?.dailyCalorieTarget ?? 2000,
                      ),
                      const SizedBox(height: 14),
                      _buildMacroCard(context),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, 'Hoạt động tập luyện'),
                      const SizedBox(height: 8),
                      _buildActivityGrid(context),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, 'Tiến độ hôm nay'),
                      const SizedBox(height: 8),
                      _buildMetricGrid(context, profile),
                      const SizedBox(height: 18),
                      _buildSectionTitle(context, 'Thông báo cho bạn'),
                      const SizedBox(height: 8),
                      _buildNotifications(context, profile),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          const Icon(Icons.more_horiz, size: 20, color: Colors.grey),
        ],
      );
  Widget _buildHeader(BuildContext context, AppUser? profile, String name) {
    final now = DateTime.now();
    final date = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
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
                Text(name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('Hôm nay', style: Theme.of(context).textTheme.bodySmall),
              Text(date, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(width: 8),
          IconButton(onPressed: () => widget.onSelectTab(4), icon: const Icon(Icons.notifications_none)),
        ],
      ),
    );
  }

  Widget _buildMacroCard(BuildContext context) => Card(
        color: const Color(0xFF211A36),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Row(
            children: [
              Expanded(child: _MacroStat(icon: Icons.bolt, label: 'Protein', value: '0 / 96g', color: Colors.redAccent)),
              Expanded(child: _MacroStat(icon: Icons.grain, label: 'Carb', value: '0 / 240g', color: Colors.lightBlueAccent)),
              Expanded(child: _MacroStat(icon: Icons.water_drop, label: 'Fat', value: '0 / 64g', color: Colors.amber)),
            ],
          ),
        ),
      );

  Widget _buildActivityGrid(BuildContext context) {
    const activities = [
      (Icons.directions_run, 'Chạy bộ', 8.0),
      (Icons.directions_bike, 'Đạp xe', 7.5),
      (Icons.sports_tennis, 'Cầu lông', 5.5),
      (Icons.sports_baseball, 'Pickleball', 5.0),
      (Icons.self_improvement, 'Yoga', 2.5),
      (Icons.fitness_center, 'Khác', 5.0),
    ];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 14,
          crossAxisSpacing: 8,
          childAspectRatio: .95,
          children: [
            for (final activity in activities)
              _ActivityTile(
                icon: activity.$1,
                label: activity.$2,
                onTap: () => _addActivity(context, activity.$2, activity.$3),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _addActivity(BuildContext context, String name, double met) async {
    final minutesController = TextEditingController();
    final minutes = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Thêm $name'),
        content: TextField(
          controller: minutesController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Thời gian (phút)'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Hủy')),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, int.tryParse(minutesController.text)),
            child: const Text('Tính calo'),
          ),
        ],
      ),
    );
    minutesController.dispose();
    if (minutes == null || minutes <= 0 || !mounted) return;
    final calories = (met * minutes * 70 * 0.0175).round();
    try {
      await _workoutRepository.addWorkout(name: name, minutes: minutes, calories: calories);
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('$name: $minutes phút · $calories kcal')));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(this.context).showSnackBar(SnackBar(content: Text('Không thể lưu hoạt động: $error')));
    }
  }
  Widget _buildNotifications(BuildContext context, AppUser? profile) {
    final waterTarget = profile?.dailyWaterTargetMl ?? 2000;
    final stepsTarget = profile?.dailyStepsTarget ?? 10000;
    final notifications = <_HomeNotification>[
      if (_waterMl < waterTarget)
        _HomeNotification(
          icon: Icons.water_drop_outlined,
          color: Colors.blue,
          title: 'Nhắc bạn uống nước',
          message: 'Bạn còn ${waterTarget - _waterMl} ml để đạt mục tiêu hôm nay.',
        ),
      if (6230 < stepsTarget)
        _HomeNotification(
          icon: Icons.directions_walk_outlined,
          color: Colors.deepOrange,
          title: 'Tiếp tục vận động nhé',
          message: 'Bạn còn ${stepsTarget - 6230} bước để đạt mục tiêu.',
        ),
      const _HomeNotification(
        icon: Icons.restaurant_outlined,
        color: Colors.orange,
        title: 'Đừng quên ghi lại bữa ăn',
        message: 'Theo dõi bữa ăn giúp thống kê dinh dưỡng chính xác hơn.',
      ),
    ];

    return Column(
      children: [
        for (final notification in notifications)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: _NotificationCard(notification: notification),
          ),
      ],
    );
  }
  Widget _buildMetricGrid(BuildContext context, AppUser? profile) => Column(
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
                color: Colors.deepOrange,
                title: 'Bước chân',
                value: '6.230',
                subtitle: 'Mục tiêu ${profile?.dailyStepsTarget ?? 10000} bước',
                progress: (6230 / (profile?.dailyStepsTarget ?? 10000)).clamp(0.0, 1.0),
                onTap: () {},
              ),
              _MetricCard(
                icon: Icons.local_fire_department_outlined,
                color: Colors.orange,
                title: 'Tập luyện',
                value: '320 kcal',
                subtitle: '1 buổi tập hôm nay',
                progress: .64,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildWaterCard(context, profile),
        ],
      );

  Widget _buildWaterCard(BuildContext context, AppUser? profile) {
    final target = profile?.dailyWaterTargetMl ?? 2000;
    final progress = (_waterMl / target).clamp(0.0, 1.0);
    return Card(
      child: InkWell(
        onTap: () => setState(() => _waterMl = (_waterMl + 250).clamp(0, target)),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const CircleAvatar(
                backgroundColor: Color(0xFFE3F2FD),
                child: Icon(Icons.water_drop_outlined, color: Colors.blue),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Nước uống', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('$_waterMl / $target ml', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(value: progress, minHeight: 8),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              const Icon(Icons.add_circle_outline, color: Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

}

class _DailyCaloriesCard extends StatefulWidget {
  const _DailyCaloriesCard({required this.dailyTarget});
  final int dailyTarget;

  @override
  State<_DailyCaloriesCard> createState() => _DailyCaloriesCardState();
}

class _DailyCaloriesCardState extends State<_DailyCaloriesCard> {
  int _selectedDay = DateTime.now().weekday;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final selectedDate = now.add(Duration(days: _selectedDay - now.weekday));
    final dateText = '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';

    return Card(
      color: const Color(0xFF5847E8),
      child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              Text('${_weekdayLabel(_selectedDay)} · $dateText', style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 14),
              Row(
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final selected = day == _selectedDay;
                  return Expanded(
                    child: Center(
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedDay = day),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 160),
                          width: 32,
                          height: 32,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(color: selected ? Colors.white : Colors.white.withValues(alpha: .14), shape: BoxShape.circle),
                          child: Text(_shortWeekday(day), style: TextStyle(color: selected ? const Color(0xFF5847E8) : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 18),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 88,
                    height: 88,
                    child: _RemainingCaloriesRing(
                      remaining: widget.dailyTarget - 1240,
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
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          '${widget.dailyTarget - 1240} kcal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Bạn vẫn có thể nạp thêm hôm nay',
                          style: TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _CalorieStat(value: '${widget.dailyTarget}', label: 'Mục tiêu', unit: 'kcal'),
                  const _CalorieStat(value: '1.240', label: 'Đã nạp', unit: 'kcal'),
                  const _CalorieStat(value: '320', label: 'Tập luyện', unit: 'kcal'),
                ],
              ),
            ],
          ),
        ),
      );
  }

  String _shortWeekday(int day) => const ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'][day - 1];

  String _weekdayLabel(int day) => const ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'][day - 1];
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
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'kcal còn',
              style: TextStyle(color: Colors.white70, fontSize: 10, height: 1),
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
      ..color = Colors.white24
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;
    final foreground = Paint()
      ..color = Colors.white
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
  const _CalorieStat({required this.value, required this.label, required this.unit});
  final String value;
  final String label;
  final String unit;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          Text(unit, style: const TextStyle(color: Colors.white70, fontSize: 10)),
          const SizedBox(height: 3),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
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
    required this.onTap,
    this.progress,
  });
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;
  final double? progress;

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
                Row(
                  children: [
                    Icon(icon, color: color, size: 20),
                    const Spacer(),
                    Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 18),
                  ],
                ),
                const SizedBox(height: 6),
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
                const SizedBox(height: 3),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey.shade600)),
                if (progress != null) ...[
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 5,
                      color: color,
                      backgroundColor: color.withValues(alpha: .12),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      );
}

class _HomeNotification {
  const _HomeNotification({required this.icon, required this.color, required this.title, required this.message});

  final IconData icon;
  final Color color;
  final String title;
  final String message;
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.notification});

  final _HomeNotification notification;

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          leading: CircleAvatar(
            backgroundColor: notification.color.withValues(alpha: .12),
            child: Icon(notification.icon, color: notification.color, size: 20),
          ),
          title: Text(notification.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          subtitle: Text(notification.message, maxLines: 2, overflow: TextOverflow.ellipsis),
        ),
      );
}
class _MacroStat extends StatelessWidget {
  const _MacroStat({required this.icon, required this.label, required this.value, required this.color});

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(icon, color: color, size: 18), const SizedBox(width: 5), Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 8),
          ClipRRect(borderRadius: BorderRadius.circular(6), child: const LinearProgressIndicator(value: 0, minHeight: 5, backgroundColor: Color(0xFF4A435B))),
          const SizedBox(height: 6),
          Text(value, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );
}


class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.icon, required this.label, required this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 25,
              backgroundColor: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
              child: Icon(icon, color: Theme.of(context).colorScheme.primary),
            ),
            const SizedBox(height: 6),
            Text(label, textAlign: TextAlign.center, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      );
}

