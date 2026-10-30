import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';
import '../widgets/user_avatar.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key, required this.onSelectTab});

  final void Function(int) onSelectTab;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final auth = AuthService();
    final firebaseUser = auth.currentUser;

    return Scaffold(
      appBar: AppBar(
        title: const Text('HealthMate'),
        actions: [
          StreamBuilder<AppUser?>(
            stream: firebaseUser == null
                ? const Stream.empty()
                : auth.watchProfile(firebaseUser.uid),
            builder: (context, snapshot) => IconButton(
              onPressed: () => onSelectTab(4),
              icon: UserAvatar(user: snapshot.data, radius: 16),
              tooltip: 'Hồ sơ',
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          StreamBuilder<AppUser?>(
            stream: firebaseUser == null
                ? const Stream.empty()
                : auth.watchProfile(firebaseUser.uid),
            builder: (context, snapshot) {
              final profile = snapshot.data;
              final name = profile?.displayName.isNotEmpty == true
                  ? profile!.displayName
                  : firebaseUser?.displayName ?? 'Bạn';
              return Row(
                children: [
                  UserAvatar(user: profile, radius: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Xin chào 👋', style: theme.textTheme.titleMedium),
                        Text(name, style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 8),
          Text('Sẵn sàng chăm sóc sức khỏe hôm nay?', style: theme.textTheme.bodyMedium),
          const SizedBox(height: 24),
          Card(
            color: theme.colorScheme.primary,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tổng quan hôm nay', style: theme.textTheme.titleLarge?.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _SummaryItem(icon: Icons.water_drop, value: '0 ml', label: 'Nước'),
                      _SummaryItem(icon: Icons.local_fire_department, value: '0 kcal', label: 'Calo'),
                      _SummaryItem(icon: Icons.directions_walk, value: '0', label: 'Bước'),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          _HomeReportCard(onTap: () => onSelectTab(1)),
          const SizedBox(height: 20),
          Text('Truy cập nhanh', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.5,
            children: [
              _QuickAction(icon: Icons.monitor_heart_outlined, label: 'Chỉ số sức khỏe', color: Colors.red, onTap: () => onSelectTab(1)),
              _QuickAction(icon: Icons.restaurant_outlined, label: 'Nhật ký dinh dưỡng', color: Colors.orange, onTap: () => onSelectTab(2)),
              _QuickAction(icon: Icons.fitness_center, label: 'Buổi tập', color: Colors.blue, onTap: () => onSelectTab(3)),
              _QuickAction(icon: Icons.flag_outlined, label: 'Mục tiêu', color: Colors.purple, onTap: () => onSelectTab(3)),
            ],
          ),
          const SizedBox(height: 20),
          const Card(
            child: ListTile(
              leading: Icon(Icons.lightbulb_outline, color: Colors.amber),
              title: Text('Mẹo sức khỏe'),
              subtitle: Text('Uống đủ nước và vận động nhẹ trong ngày nhé!'),
            ),
          ),
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
  Widget build(BuildContext context) => Column(
        children: [
          Icon(icon, color: Colors.white),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        ],
      );
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

class _HomeReportCard extends StatelessWidget {
  const _HomeReportCard({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text('Báo cáo thống kê', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold))),
                TextButton(onPressed: onTap, child: const Text('Chi tiết')),
              ]),
              const Text('Tổng quan sức khỏe trong tuần này', style: TextStyle(color: Colors.green)),
              const SizedBox(height: 14),
              const Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _HomeReportStat(value: '68,6 kg', label: 'Cân nặng TB'),
                _HomeReportStat(value: '72 bpm', label: 'Nhịp tim TB'),
                _HomeReportStat(value: '118/76', label: 'Huyết áp TB'),
              ]),
            ]),
          ),
        ),
      );
}

class _HomeReportStat extends StatelessWidget {
  const _HomeReportStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) => Expanded(
        child: Column(children: [
          Text(value, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF4F46E5))),
          const SizedBox(height: 4),
          Text(label, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodySmall),
        ]),
      );
}
