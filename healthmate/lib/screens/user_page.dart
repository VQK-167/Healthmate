import 'package:flutter/material.dart';

const kUserColor = Colors.red;

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        UserHeader(name: 'Nguyễn Hữu Huy', email: 'huy@example.com'),
        SizedBox(height: 16),
        UserSectionTitle('THÔNG TIN CÁ NHÂN'),
        UserInfoTile(icon: Icons.cake, label: 'Tuổi', value: '21'),
        UserInfoTile(icon: Icons.height, label: 'Chiều cao', value: '172 cm'),
        UserInfoTile(icon: Icons.monitor_weight, label: 'Cân nặng', value: '65 kg'),
        UserInfoTile(icon: Icons.analytics, label: 'BMI', value: '22.0 (Bình thường)'),
        SizedBox(height: 8),
        UserSectionTitle('CÀI ĐẶT'),
        UserInfoTile(icon: Icons.notifications, label: 'Thông báo', value: 'Bật'),
        UserInfoTile(icon: Icons.language, label: 'Ngôn ngữ', value: 'Tiếng Việt'),
        SizedBox(height: 8),
        UserLogoutButton(),
      ],
    );
  }
}

class UserHeader extends StatelessWidget {
  final String name;
  final String email;
  const UserHeader({super.key, required this.name, required this.email});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF44336), Color(0xFFFF7A70)],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, size: 48, color: kUserColor),
          ),
          const SizedBox(height: 12),
          Text(name,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }
}

class UserSectionTitle extends StatelessWidget {
  final String text;
  const UserSectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(text,
          style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black54)),
    );
  }
}

// ===== Widget StatelessWidget nộp cho câu 4 =====
class UserInfoTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const UserInfoTile({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Row(
        children: [
          Icon(icon, color: kUserColor),
          const SizedBox(width: 14),
          Expanded(
            child: Text(label,
                style: const TextStyle(fontSize: 16, color: Colors.grey)),
          ),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class UserLogoutButton extends StatelessWidget {
  const UserLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text('Đăng xuất', style: TextStyle(color: Colors.red)),
    );
  }
}