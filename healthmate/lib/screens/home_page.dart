import 'dart:math' as math;
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final ValueChanged<int> onSelectTab;

  const HomePage({super.key, required this.onSelectTab});

  static const int _calorieGoal = 2000;
  static const int _caloriesIn = 1250;
  static const int _caloriesBurned = 450;
  static const double _bmi = 22.5;
  static const String _bmiLabel = 'Bình thường';
  static const double _weight = 65.0;
  static const int _steps = 6420;
  static const int _waterMl = 1500;
  static const int _waterGoalMl = 2000;
  static const List<double> _weekWeights = [65.5, 65.4, 65.2, 65.3, 65.1, 65.0, 65.0];

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final percent = (_caloriesIn / _calorieGoal).clamp(0.0, 1.0).toDouble();
    final net = _caloriesIn - _caloriesBurned;
    final waterPercent = (_waterMl / _waterGoalMl).clamp(0.0, 1.0).toDouble();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF0F766E), Color(0xFF14B8A6)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF14B8A6).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CircularProgressIndicator(
                          value: percent,
                          strokeWidth: 8,
                          backgroundColor: Colors.white24,
                          valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                        Center(
                          child: Text(
                            '${(percent * 100).round()}%',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Calories hôm nay',
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$_caloriesIn kcal',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Mục tiêu $_calorieGoal · Đốt $_caloriesBurned · Ròng $net',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _QuickChip(
                  icon: Icons.water_drop,
                  label: '+250 ml nước',
                  onTap: () => onSelectTab(2),
                ),
                _QuickChip(
                  icon: Icons.directions_walk,
                  label: '+500 bước',
                  onTap: () => onSelectTab(3),
                ),
                _QuickChip(
                  icon: Icons.restaurant,
                  label: 'Thêm món ăn',
                  onTap: () => onSelectTab(2),
                ),
                _QuickChip(
                  icon: Icons.fitness_center,
                  label: 'Ghi nhận tập',
                  onTap: () => onSelectTab(3),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Tổng quan sức khỏe',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.15,
              children: [
                _StatCard(
                  icon: Icons.favorite,
                  label: 'BMI',
                  value: _bmi.toStringAsFixed(1),
                  unit: _bmiLabel,
                  onTap: () => onSelectTab(1),
                ),
                _StatCard(
                  icon: Icons.monitor_weight,
                  label: 'Cân nặng',
                  value: _weight.toStringAsFixed(1),
                  unit: 'kg',
                  onTap: () => onSelectTab(1),
                ),
                _StatCard(
                  icon: Icons.directions_walk,
                  label: 'Bước chân',
                  value: '$_steps',
                  unit: 'bước',
                  onTap: () => onSelectTab(3),
                ),
                _StatCard(
                  icon: Icons.water_drop,
                  label: 'Nước uống',
                  value: '$_waterMl',
                  unit: 'ml',
                  onTap: () => onSelectTab(2),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Cân nặng 7 ngày',
                  style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Text('kg', style: TextStyle(color: Colors.black54, fontSize: 12)),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE3EBE9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Biểu đồ thay đổi',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 160,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _WeightChartPainter(
                        values: _weekWeights,
                        lineColor: const Color(0xFF0F766E),
                        gridColor: const Color(0xFFE3EBE9),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Nhật ký nước uống',
              style: text.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE3EBE9)),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0EBE8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.water_drop, color: Color(0xFF0F766E)),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Mục tiêu hàng ngày',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      Text(
                        '$_waterMl/$_waterGoalMl ml',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF0F766E)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: waterPercent,
                      minHeight: 10,
                      backgroundColor: const Color(0xFFCFE5DF),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF0F766E)),
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

class _StatCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final String unit;
  final VoidCallback onTap;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE3EBE9)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE0EBE8),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: const Color(0xFF0F766E), size: 20),
              ),
              const Spacer(),
              Text(label, style: const TextStyle(color: Colors.black54, fontSize: 13)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              Text(unit, style: const TextStyle(color: Colors.black54, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickChip({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFD1E7E2),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 16, color: const Color(0xFF0F766E)),
              const SizedBox(width: 6),
              Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Color(0xFF0F766E))),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeightChartPainter extends CustomPainter {
  final List<double> values;
  final Color lineColor;
  final Color gridColor;

  _WeightChartPainter({
    required this.values,
    required this.lineColor,
    required this.gridColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const rows = 4;
    const pad = 12.0;
    final top = pad;
    final bottom = size.height - pad;

    final gridPaint = Paint()
      ..color = gridColor
      ..strokeWidth = 1;
    for (var i = 0; i < rows; i++) {
      final y = top + (bottom - top) * i / (rows - 1);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    if (values.isEmpty) return;

    final minV = values.reduce(math.min);
    final maxV = values.reduce(math.max);
    final range = maxV - minV;

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = values.length == 1
          ? size.width / 2
          : size.width * i / (values.length - 1);
      final y = range == 0
          ? (top + bottom) / 2
          : bottom - (values[i] - minV) / range * (bottom - top);
      points.add(Offset(x, y));
    }

    if (points.length > 1) {
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    final dotPaint = Paint()..color = lineColor;
    for (final p in points) {
      canvas.drawCircle(p, 5, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _WeightChartPainter oldDelegate) {
    return oldDelegate.values != values ||
        oldDelegate.lineColor != lineColor ||
        oldDelegate.gridColor != gridColor;
  }
}