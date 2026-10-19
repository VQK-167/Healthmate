import 'package:flutter/material.dart';

class HealthScreen extends StatelessWidget {
  const HealthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Sức khỏe',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Chỉ số sức khỏe
            const Text(
              'Chỉ số sức khỏe',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // BMI
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'Chỉ số cơ thể BMI',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      '22.5',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 5),

                    const Text(
                      'Bình thường',
                      style: TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Thông số
            const Text(
              'Thông số',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            // Cân nặng
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.monitor_weight,
                  size: 32,
                ),
                title: const Text('Cân nặng'),
                trailing: const Text(
                  '65 kg',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Chiều cao
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.height,
                  size: 32,
                ),
                title: const Text('Chiều cao'),
                trailing: const Text(
                  '170 cm',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Tuổi
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.cake,
                  size: 32,
                ),
                title: const Text('Tuổi'),
                trailing: const Text(
                  '20 tuổi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // Giới tính
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.person,
                  size: 32,
                ),
                title: const Text('Giới tính'),
                trailing: const Text(
                  'Nam',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Nút cập nhật
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {},
                child: const Text(
                  'Cập nhật chỉ số',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}