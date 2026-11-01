import 'dart:async';

import 'package:flutter/material.dart';

import 'workout_widgets.dart';

/// Kết quả trả về khi bấm "Kết thúc & lưu".
class WorkoutTimerResult {
  const WorkoutTimerResult(this.kindKey, this.minutes);

  final String kindKey;
  final int minutes;
}

/// Đồng hồ bấm giờ buổi tập. Kết thúc thì trả về loại bài tập và số phút
/// (làm tròn lên) để trang Tập luyện mở hộp thoại lưu.
class WorkoutTimerPage extends StatefulWidget {
  const WorkoutTimerPage({super.key});

  @override
  State<WorkoutTimerPage> createState() => _WorkoutTimerPageState();
}

class _WorkoutTimerPageState extends State<WorkoutTimerPage> {
  final Stopwatch _watch = Stopwatch();
  Timer? _ticker;
  String _kindKey = 'run';

  int get _seconds => _watch.elapsed.inSeconds;

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  void _toggle() {
    if (_watch.isRunning) {
      _watch.stop();
      _ticker?.cancel();
    } else {
      _watch.start();
      _ticker?.cancel();
      _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
        if (mounted) setState(() {});
      });
    }
    setState(() {});
  }

  void _reset() {
    _watch.stop();
    _watch.reset();
    _ticker?.cancel();
    setState(() {});
  }

  void _finish() {
    _watch.stop();
    _ticker?.cancel();
    final minutes = (_seconds / 60).ceil();
    if (minutes <= 0) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Hãy bấm “Bắt đầu” và tập một lúc trước khi kết thúc.')),
      );
      return;
    }
    Navigator.pop(context, WorkoutTimerResult(_kindKey, minutes));
  }

  String _two(int n) => n.toString().padLeft(2, '0');

  String _format(int total) {
    final h = total ~/ 3600;
    final m = (total % 3600) ~/ 60;
    final s = total % 60;
    if (h > 0) return '${_two(h)}:${_two(m)}:${_two(s)}';
    return '${_two(m)}:${_two(s)}';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final kind = sportKindByKey(_kindKey);
    final running = _watch.isRunning;
    final seconds = _seconds;
    final status = running ? 'Đang tập...' : (seconds > 0 ? 'Tạm dừng' : 'Sẵn sàng');

    return Scaffold(
      appBar: AppBar(title: const Text('Bấm giờ buổi tập')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Wrap(
                spacing: 6,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: [
                  for (final k in kSportKinds)
                    ChoiceChip(
                      avatar: Icon(k.icon, size: 18),
                      label: Text(k.label),
                      selected: _kindKey == k.key,
                      onSelected: (_) => setState(() => _kindKey = k.key),
                    ),
                ],
              ),
              Expanded(
                child: Center(
                  child: SizedBox(
                    width: 250,
                    height: 250,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 250,
                          height: 250,
                          child: CircularProgressIndicator(
                            value: (seconds % 60) / 60,
                            strokeWidth: 10,
                            color: kind.color,
                            backgroundColor: scheme.surfaceContainerHighest,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(kind.icon, size: 36, color: kind.color),
                            const SizedBox(height: 8),
                            Text(
                              _format(seconds),
                              style: const TextStyle(fontSize: 52, fontWeight: FontWeight.bold),
                            ),
                            Text(status, style: TextStyle(color: scheme.onSurfaceVariant)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Row(
                children: [
                  IconButton.outlined(
                    tooltip: 'Đặt lại',
                    onPressed: seconds > 0 ? _reset : null,
                    icon: const Icon(Icons.restart_alt),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: _toggle,
                      icon: Icon(running ? Icons.pause : Icons.play_arrow),
                      label: Text(running ? 'Tạm dừng' : (seconds > 0 ? 'Tiếp tục' : 'Bắt đầu')),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: seconds > 0 ? _finish : null,
                      icon: const Icon(Icons.flag),
                      label: const Text('Kết thúc & lưu'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
