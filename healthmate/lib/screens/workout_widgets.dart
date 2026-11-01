import 'package:flutter/material.dart';

import '../models/workout.dart';

// ======================================================================
// Các thành phần giao diện dùng chung cho phần Thể thao (chỉ dùng trong
// các trang Tập luyện, Thống kê, Bấm giờ và Mục tiêu). Tên có tiền tố
// "Sport" để không trùng với widget của các thành viên khác trong nhóm.
// ======================================================================

/// Một loại bài tập: tên, biểu tượng, màu và hệ số MET để ước tính calo.
class SportKind {
  const SportKind(this.key, this.label, this.icon, this.color, this.met);

  final String key;
  final String label;
  final IconData icon;
  final Color color;
  final double met;
}

const List<SportKind> kSportKinds = [
  SportKind('run', 'Chạy bộ', Icons.directions_run, Color(0xFFE57373), 8.0),
  SportKind('walk', 'Đi bộ', Icons.directions_walk, Color(0xFF4DB6AC), 3.5),
  SportKind('bike', 'Đạp xe', Icons.directions_bike, Color(0xFF64B5F6), 7.5),
  SportKind('swim', 'Bơi lội', Icons.pool, Color(0xFF4FC3F7), 6.0),
  SportKind('yoga', 'Yoga', Icons.self_improvement, Color(0xFFBA68C8), 2.5),
  SportKind('gym', 'Tập gym', Icons.fitness_center, Color(0xFFFFB74D), 5.0),
  SportKind('ball', 'Bóng đá', Icons.sports_soccer, Color(0xFF81C784), 7.0),
  SportKind('other', 'Khác', Icons.bolt, Color(0xFF90A4AE), 4.0),
];

SportKind sportKindByKey(String key) {
  for (final k in kSportKinds) {
    if (k.key == key) return k;
  }
  return kSportKinds.last;
}

/// Loại của một buổi tập. Buổi tập cũ chưa có loại thì đoán theo tên.
SportKind sportKindOf(Workout w) {
  if (w.type != 'other') return sportKindByKey(w.type);
  final n = w.name.toLowerCase();
  if (n.contains('chạy')) return sportKindByKey('run');
  if (n.contains('đi bộ')) return sportKindByKey('walk');
  if (n.contains('đạp') || n.contains('xe')) return sportKindByKey('bike');
  if (n.contains('bơi')) return sportKindByKey('swim');
  if (n.contains('yoga')) return sportKindByKey('yoga');
  if (n.contains('gym') || n.contains('tạ')) return sportKindByKey('gym');
  if (n.contains('bóng')) return sportKindByKey('ball');
  return sportKindByKey('other');
}

/// Vòng tròn tiến độ, chạy từ 0 đến giá trị có hiệu ứng.
class SportRing extends StatelessWidget {
  const SportRing({
    super.key,
    required this.progress,
    required this.color,
    required this.child,
    this.size = 76,
    this.stroke = 8,
    this.trackColor,
  });

  final double progress;
  final Color color;
  final Widget child;
  final double size;
  final double stroke;
  final Color? trackColor;

  @override
  Widget build(BuildContext context) {
    final track = trackColor ?? Theme.of(context).colorScheme.surfaceContainerHighest;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progress.clamp(0.0, 1.0).toDouble()),
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(value: v, strokeWidth: stroke, color: color, backgroundColor: track),
            ),
          ),
          child,
        ],
      ),
    );
  }
}

/// Hiện dần và trượt nhẹ từ dưới lên khi widget xuất hiện.
class SportFadeIn extends StatelessWidget {
  const SportFadeIn({super.key, required this.child, this.index = 0});

  final Widget child;
  final int index;

  @override
  Widget build(BuildContext context) {
    final delay = (index > 8 ? 8 : index) * 60;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 350 + delay),
      curve: Curves.easeOutCubic,
      builder: (context, t, c) => Opacity(
        opacity: t,
        child: Transform.translate(offset: Offset(0, 16 * (1 - t)), child: c),
      ),
      child: child,
    );
  }
}

/// Số đếm tăng dần đến [value].
class SportCountUp extends StatelessWidget {
  const SportCountUp({super.key, required this.value, required this.style});

  final int value;
  final TextStyle style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: value.toDouble()),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) => Text('${v.round()}', style: style),
    );
  }
}

/// Nhãn nhỏ bo tròn gồm biểu tượng và chữ.
class SportChip extends StatelessWidget {
  const SportChip(this.icon, this.label, {super.key});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: scheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: scheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label, style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}

/// Biểu đồ cột có hiệu ứng mọc lên. Cột cuối cùng (hôm nay) được tô đậm.
/// [values], [labels], [tips] phải có cùng độ dài.
class SportBarChart extends StatelessWidget {
  const SportBarChart({
    super.key,
    required this.values,
    required this.labels,
    required this.tips,
    this.barArea = 90,
  });

  final List<int> values;
  final List<String> labels;
  final List<String> tips;
  final double barArea;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    var maxValue = 0;
    for (final v in values) {
      if (v > maxValue) maxValue = v;
    }
    final few = values.length <= 8;
    final gap = few ? 6.0 : 1.0;
    return SizedBox(
      height: barArea + 44,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    height: 14,
                    child: few && values[i] > 0 ? Text('${values[i]}', style: const TextStyle(fontSize: 11)) : null,
                  ),
                  const SizedBox(height: 4),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: gap),
                    child: Tooltip(message: tips[i], child: _bar(scheme, i, maxValue)),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    height: 14,
                    child: OverflowBox(
                      maxWidth: 40,
                      child: Text(
                        labels[i],
                        softWrap: false,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: i == values.length - 1 ? FontWeight.bold : FontWeight.normal,
                          color: i == values.length - 1 ? scheme.primary : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _bar(ColorScheme scheme, int i, int maxValue) {
    final value = values[i];
    final double target = (maxValue == 0 || value == 0) ? 4.0 : (value / maxValue * barArea).clamp(4.0, barArea).toDouble();
    final bool last = i == values.length - 1;
    final Color top = last ? scheme.primary : scheme.primaryContainer;
    final Color bottom = Color.lerp(top, scheme.primary, last ? 0.0 : 0.35) ?? top;
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: target),
      duration: Duration(milliseconds: 500 + (i > 10 ? 10 : i) * 50),
      curve: Curves.easeOutCubic,
      builder: (context, h, _) => Container(
        width: double.infinity,
        height: h,
        decoration: BoxDecoration(
          color: value == 0 ? scheme.surfaceContainerHighest : null,
          gradient: value == 0
              ? null
              : LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [top, bottom]),
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }
}
