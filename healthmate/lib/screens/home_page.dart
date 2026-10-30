import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onSelectTab});

  final void Function(int) onSelectTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('HealthMate'), actions: [IconButton(onPressed: () => onSelectTab(4), icon: const Icon(Icons.person_outline))]),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text('Xin chào 👋', style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text('Sẵn sàng chăm sóc sức khỏe hôm nay?', style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.primary,
            child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Tổng quan hôm nay', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)), const SizedBox(height: 16), Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: const [_SummaryItem(icon: Icons.water_drop, value: '0 ml', label: 'Nước'), _SummaryItem(icon: Icons.local_fire_department, value: '0 kcal', label: 'Calo'), _SummaryItem(icon: Icons.directions_walk, value: '0', label: 'Bước')])])),
          ),
          const SizedBox(height: 20),
          Text('Truy cập nhanh', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.5, children: [_QuickAction(icon: Icons.monitor_heart_outlined, label: 'Chỉ số sức khỏe', color: Colors.red, onTap: () => onSelectTab(1)), _QuickAction(icon: Icons.restaurant_outlined, label: 'Nhật ký dinh dưỡng', color: Colors.orange, onTap: () => onSelectTab(2)), _QuickAction(icon: Icons.fitness_center, label: 'Buổi tập', color: Colors.blue, onTap: () => onSelectTab(3)), _QuickAction(icon: Icons.flag_outlined, label: 'Mục tiêu', color: Colors.purple, onTap: () => onSelectTab(3))]),
          const SizedBox(height: 20),
          Card(child: ListTile(leading: const Icon(Icons.lightbulb_outline, color: Colors.amber), title: const Text('Mẹo sức khỏe'), subtitle: const Text('Uống đủ nước và vận động nhẹ trong ngày nhé!'))),
        ],
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  const _SummaryItem({required this.icon, required this.value, required this.label});
  final IconData icon;
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Column(children: [Icon(icon, color: Colors.white), const SizedBox(height: 4), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)), Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12))]);
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.icon, required this.label, required this.color, required this.onTap});
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 8),
                Text(label, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      );
}
