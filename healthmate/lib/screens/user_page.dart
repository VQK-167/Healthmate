import 'package:flutter/material.dart';

class UserPage extends StatelessWidget {
  const UserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Tài khoản',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: const Color(0xFF003580),
                    child: const Text(
                      'H',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Nguyễn Hữu Huy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'huy@example.com',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                children: const [
                  ListTile(
                    leading: Icon(Icons.person_outline, color: Color(0xFF003580)),
                    title: Text('Chỉnh sửa thông tin'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                  Divider(height: 1, indent: 50),
                  ListTile(
                    leading: Icon(Icons.notifications_outlined, color: Color(0xFF003580)),
                    title: Text('Thông báo'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                  Divider(height: 1, indent: 50),
                  ListTile(
                    leading: Icon(Icons.settings_outlined, color: Color(0xFF003580)),
                    title: Text('Cài đặt ứng dụng'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                  Divider(height: 1, indent: 50),
                  ListTile(
                    leading: Icon(Icons.help_outline, color: Color(0xFF003580)),
                    title: Text('Trợ giúp & Hỗ trợ'),
                    trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {},
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.redAccent),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}