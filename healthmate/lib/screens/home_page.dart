import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/user_avatar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.onSelectTab});

  final void Function(int) onSelectTab;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
                      _DailyCaloriesCard(
                        dailyTarget: profile?.dailyCalorieTarget ?? 2000,
                      ),
                      const SizedBox(height: 12),
                      _buildOverviewCharts(context),
                      const SizedBox(height: 12),
                      _buildMetricGrid(context, profile),
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

  Widget _buildHeader(BuildContext context, AppUser? profile, String name) {
    final now = DateTime.now();
    final date = '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}';
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
                Text('Chào buổi sáng', style: Theme.of(context).textTheme.bodySmall),
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

  Widget _buildOverviewCharts(BuildContext context) => Column(
        children: [
          _OverviewChartCard(
            title: 'Sức khỏe',
            subtitle: 'Cân nặng 7 ngày',
            icon: Icons.monitor_heart_outlined,
            color: Colors.indigo,
            value: '68,4 kg',
            detail: 'Giảm 0,6 kg so với tuần trước',
            chart: const _MiniLineChart(color: Colors.indigo),
            onTap: () => widget.onSelectTab(1),
          ),
          const SizedBox(height: 10),
          _OverviewChartCard(
            title: 'Dinh dưỡng',
            subtitle: 'Bữa ăn hôm nay',
            icon: Icons.restaurant_outlined,
            color: Colors.orange,
            value: '3 bữa ăn',
            detail: 'Đã ghi nhận đầy đủ hôm nay',
            chart: const _MiniBarChart(color: Colors.orange),
            onTap: () => widget.onSelectTab(2),
          ),
          const SizedBox(height: 10),
          _OverviewChartCard(
            title: 'Thể thao',
            subtitle: 'Hoạt động tuần này',
            icon: Icons.fitness_center,
            color: Colors.deepOrange,
            value: '6.230 bước',
            detail: '320 kcal đã đốt hôm nay',
            chart: const _MiniBarChart(color: Colors.deepOrange),
            onTap: () => widget.onSelectTab(3),
          ),
        ],
      );
  Widget _buildMetricGrid(BuildContext context, AppUser? profile) => Column(
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.9,
            children: [
              _MetricCard(
                icon: Icons.directions_walk_outlined,
                color: Colors.deepOrange,
                title: 'Bước chân',
                value: '6.230',
                subtitle: 'Mục tiêu ${profile?.dailyStepsTarget ?? 10000} bước',
                onTap: () => widget.onSelectTab(3),
              ),
              _MetricCard(
                icon: Icons.local_fire_department_outlined,
                color: Colors.orange,
                title: 'Tập luyện',
                value: '320 kcal',
                subtitle: '1 buổi tập hôm nay',
                onTap: () => widget.onSelectTab(3),
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(7, (index) {
                  final day = index + 1;
                  final selected = day == _selectedDay;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedDay = day),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 160),
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: selected ? Colors.white : Colors.white.withValues(alpha: .14), shape: BoxShape.circle),
                      child: Text(_shortWeekday(day), style: TextStyle(color: selected ? const Color(0xFF5847E8) : Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
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
  const _MetricCard({required this.icon, required this.color, required this.title, required this.value, required this.subtitle, required this.onTap});
  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(padding: const EdgeInsets.all(12), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: color, size: 20), const SizedBox(height: 6), Text(title, style: Theme.of(context).textTheme.bodySmall), Text(value, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold)), const SizedBox(height: 3), Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10, color: Colors.grey.shade600))])),
        ),
      );
}

class _OverviewChartCard extends StatelessWidget {
  const _OverviewChartCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.value,
    required this.detail,
    required this.chart,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String value;
  final String detail;
  final Widget chart;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 12, 14),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(height: 8),
                      Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(detail, maxLines: 1, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(width: 86, height: 58, child: chart),
                const Icon(Icons.chevron_right, size: 20),
              ],
            ),
          ),
        ),
      );
}

class _MiniLineChart extends StatelessWidget {
  const _MiniLineChart({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _MiniLineChartPainter(color),
        child: const SizedBox.expand(),
      );
}

class _MiniLineChartPainter extends CustomPainter {
  const _MiniLineChartPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final values = [0.72, 0.58, 0.64, 0.42, 0.5, 0.32, 0.2];
    final path = Path();
    final line = Paint()
      ..color = color
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (var i = 0; i < values.length; i++) {
      final x = size.width * i / (values.length - 1);
      final y = values[i] * size.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    canvas.drawPath(path, line);
    canvas.drawCircle(Offset(size.width, values.last * size.height), 3.5, Paint()..color = color);
  }

  @override
  bool shouldRepaint(covariant _MiniLineChartPainter oldDelegate) => oldDelegate.color != color;
}

class _MiniBarChart extends StatelessWidget {
  const _MiniBarChart({required this.color});
  final Color color;

  @override
  Widget build(BuildContext context) => CustomPaint(
        painter: _MiniBarChartPainter(color),
        child: const SizedBox.expand(),
      );
}

class _MiniBarChartPainter extends CustomPainter {
  const _MiniBarChartPainter(this.color);
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final values = [0.42, 0.68, 0.55, 0.82, 0.58, 0.72, 0.48];
    final barWidth = (size.width - 12) / values.length;
    final paint = Paint()..color = color;
    for (var i = 0; i < values.length; i++) {
      final height = values[i] * size.height;
      final left = i * barWidth + 1;
      final top = size.height - height;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(left, top, barWidth - 3, height),
          const Radius.circular(4),
        ),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBarChartPainter oldDelegate) => oldDelegate.color != color;
}
