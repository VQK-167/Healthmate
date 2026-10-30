import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/auth_service.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = AuthService();
    final firebaseUser = auth.currentUser;
    return Scaffold(
      appBar: AppBar(title: const Text('Hồ sơ')),
      body: StreamBuilder<AppUser?>(
        stream: firebaseUser == null ? const Stream.empty() : auth.watchProfile(firebaseUser.uid),
        builder: (context, snapshot) {
          final profile = snapshot.data;
          final name = profile?.displayName.isNotEmpty == true ? profile!.displayName : firebaseUser?.displayName ?? 'Bạn';
          return ListView(padding: const EdgeInsets.all(20), children: [
            Center(child: CircleAvatar(radius: 44, child: Text(name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 32)))),
            const SizedBox(height: 12),
            Center(child: Text(name, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold))),
            Center(child: Text(profile?.email ?? firebaseUser?.email ?? '', style: Theme.of(context).textTheme.bodyMedium)),
            const SizedBox(height: 28),
            Card(child: Column(children: const [ListTile(leading: Icon(Icons.height), title: Text('Chiều cao'), trailing: Text('Chưa cập nhật')), ListTile(leading: Icon(Icons.monitor_weight_outlined), title: Text('Cân nặng'), trailing: Text('Chưa cập nhật'))])),
            const SizedBox(height: 12),
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings_outlined),
                    title: const Text('Cài đặt'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {},
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
                    onTap: () => _confirmSignOut(context, auth),
                  ),
                ],
              ),
            ),
          ]);
        },
      ),
    );
  }

  Future<void> _confirmSignOut(BuildContext context, AuthService auth) async {
    final confirmed = await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Đăng xuất?'), content: const Text('Bạn có chắc muốn đăng xuất không?'), actions: [TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')), FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Đăng xuất'))]));
    if (confirmed == true) await auth.signOut();
  }
}
