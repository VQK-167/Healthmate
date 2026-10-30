import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../core/health_rules.dart';
import '../models/health_metric.dart';
import '../repositories/health_repository.dart';
import '../services/auth_service.dart';

class HealthPage extends StatefulWidget {
  const HealthPage({super.key});

  @override
  State<HealthPage> createState() => _HealthPageState();
}

class _HealthPageState extends State<HealthPage> {
  final _auth = AuthService();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Chưa đăng nhập')));
    }
    final repository = HealthRepository(userId: user.uid);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sức khỏe'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Ghi chỉ số mới',
            onPressed: () => _showAddSheet(context, repository, user.uid),
          ),
        ],
      ),
      body: StreamBuilder<List<HealthMetric>>(
        stream: repository.watchAll(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final metrics = snapshot.data ?? const <HealthMetric>[];
          if (metrics.isEmpty) {
            return _EmptyState(onAdd: () => _showAddSheet(context, repository, user.uid));
          }
          final latest = metrics.first;
          return ListView(
            padding: const EdgeInsets.all(20),
            children: [
              if (latest.isAbnormal) const _WarningBanner(),
              if (latest.isAbnormal) const SizedBox(height: 16),
              _LatestSummary(metric: latest),
              const SizedBox(height: 20),
              _WeightTrendChart(metrics: metrics),
              const SizedBox(height: 20),
              Text('Lịch sử', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              ...metrics.map((metric) => _HistoryTile(
                    metric: metric,
                    onDelete: () => repository.delete(metric.id),
                  )),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showAddSheet(BuildContext context, HealthRepository repository, String userId) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMetricSheet(repository: repository, userId: userId),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.monitor_heart_outlined, size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              const Text('Chưa có chỉ số nào được ghi nhận'),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: onAdd, icon: const Icon(Icons.add), label: const Text('Ghi chỉ số đầu tiên')),
            ],
          ),
        ),
      );
}

class _WarningBanner extends StatelessWidget {
  const _WarningBanner();

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.warning_amber_rounded, color: Colors.red.shade700),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'Một số chỉ số gần nhất nằm ngoài mức bình thường. Hãy theo dõi thêm hoặc hỏi ý kiến bác sĩ.',
                style: TextStyle(color: Colors.red.shade700, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      );
}

class _LatestSummary extends StatelessWidget {
  const _LatestSummary({required this.metric});
  final HealthMetric metric;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: _MetricCard(
              icon: Icons.monitor_weight_outlined,
              color: Colors.indigo,
              title: 'BMI',
              value: metric.bmi?.toStringAsFixed(1) ?? '--',
              subtitle: metric.bmiCategory == null ? 'Chưa có dữ liệu' : bmiCategoryLabel(metric.bmiCategory!),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              icon: Icons.favorite_outline,
              color: Colors.pink,
              title: 'Huyết áp',
              value: metric.hasBloodPressure ? '${metric.systolic}/${metric.diastolic}' : '--',
              subtitle: metric.bloodPressureCategory == null
                  ? 'Chưa có dữ liệu'
                  : bloodPressureCategoryLabel(metric.bloodPressureCategory!),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _MetricCard(
              icon: Icons.monitor_heart_outlined,
              color: Colors.teal,
              title: 'Nhịp tim',
              value: metric.heartRate?.toString() ?? '--',
              subtitle: metric.heartRateCategory == null ? 'Chưa có dữ liệu' : heartRateCategoryLabel(metric.heartRateCategory!),
            ),
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
  });

  final IconData icon;
  final Color color;
  final String title;
  final String value;
  final String subtitle;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color),
              const SizedBox(height: 8),
              Text(title, style: Theme.of(context).textTheme.bodySmall),
              Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: color), maxLines: 2),
            ],
          ),
        ),
      );
}

class _WeightTrendChart extends StatelessWidget {
  const _WeightTrendChart({required this.metrics});
  final List<HealthMetric> metrics;

  @override
  Widget build(BuildContext context) {
    // Chart wants oldest -> newest, repository returns newest-first.
    final points = metrics
        .where((m) => m.weightKg != null)
        .toList()
        .reversed
        .toList();
    if (points.length < 2) {
      return const SizedBox.shrink();
    }
    final spots = [
      for (var i = 0; i < points.length; i++) FlSpot(i.toDouble(), points[i].weightKg!),
    ];
    final minY = points.map((p) => p.weightKg!).reduce((a, b) => a < b ? a : b);
    final maxY = points.map((p) => p.weightKg!).reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY).abs() < 1 ? 1.0 : (maxY - minY) * 0.2;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Xu hướng cân nặng', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  minY: minY - padding,
                  maxY: maxY + padding,
                  gridData: const FlGridData(show: true, drawVerticalLine: false),
                  titlesData: const FlTitlesData(
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: true),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context).colorScheme.primary.withValues(alpha: .12),
                      ),
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
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.metric, required this.onDelete});
  final HealthMetric metric;
  final VoidCallback onDelete;

  String _formatDate(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

  @override
  Widget build(BuildContext context) => Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: metric.isAbnormal ? Colors.red.shade50 : Colors.green.shade50,
            child: Icon(
              metric.isAbnormal ? Icons.warning_amber_rounded : Icons.check,
              color: metric.isAbnormal ? Colors.red : Colors.green,
            ),
          ),
          title: Text(_formatDate(metric.recordedAt)),
          subtitle: Text([
            if (metric.weightKg != null) '${metric.weightKg!.toStringAsFixed(1)} kg',
            if (metric.bmi != null) 'BMI ${metric.bmi!.toStringAsFixed(1)}',
            if (metric.hasBloodPressure) '${metric.systolic}/${metric.diastolic} mmHg',
            if (metric.heartRate != null) '${metric.heartRate} bpm',
          ].join(' · ')),
          trailing: IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: onDelete,
          ),
        ),
      );
}

class _AddMetricSheet extends StatefulWidget {
  const _AddMetricSheet({required this.repository, required this.userId});
  final HealthRepository repository;
  final String userId;

  @override
  State<_AddMetricSheet> createState() => _AddMetricSheetState();
}

class _AddMetricSheetState extends State<_AddMetricSheet> {
  final _formKey = GlobalKey<FormState>();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _heartRateController = TextEditingController();
  bool _isSaving = false;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    _systolicController.dispose();
    _diastolicController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  double? _parseDouble(String text) => text.trim().isEmpty ? null : double.tryParse(text.trim());
  int? _parseInt(String text) => text.trim().isEmpty ? null : int.tryParse(text.trim());

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final metric = HealthMetric(
        userId: widget.userId,
        recordedAt: DateTime.now(),
        heightCm: _parseDouble(_heightController.text),
        weightKg: _parseDouble(_weightController.text),
        systolic: _parseInt(_systolicController.text),
        diastolic: _parseInt(_diastolicController.text),
        heartRate: _parseInt(_heartRateController.text),
      );
      await widget.repository.add(metric);
      if (mounted) Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không thể lưu chỉ số. Vui lòng thử lại.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  String? _rangeValidator(String? value, {double min = 0, double max = double.infinity}) {
    if (value == null || value.trim().isEmpty) return null;
    final parsed = double.tryParse(value.trim());
    if (parsed == null || parsed < min || parsed > max) return 'Giá trị từ $min đến $max';
    return null;
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(child: Container(width: 42, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(4)))),
                    const SizedBox(height: 16),
                    Text('Ghi chỉ số sức khỏe', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text('Nhập các chỉ số bạn có, có thể bỏ trống ô chưa đo.', style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 16),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _heightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Chiều cao (cm)'),
                          validator: (v) => _rangeValidator(v, min: 50, max: 250),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _weightController,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: const InputDecoration(labelText: 'Cân nặng (kg)'),
                          validator: (v) => _rangeValidator(v, min: 10, max: 400),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(
                        child: TextFormField(
                          controller: _systolicController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Huyết áp tâm thu'),
                          validator: (v) => _rangeValidator(v, min: 50, max: 260),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _diastolicController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Huyết áp tâm trương'),
                          validator: (v) => _rangeValidator(v, min: 30, max: 180),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _heartRateController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Nhịp tim (bpm)'),
                      validator: (v) => _rangeValidator(v, min: 20, max: 250),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        onPressed: _isSaving ? null : _save,
                        child: _isSaving
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : const Text('Lưu'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
}
