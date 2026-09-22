import 'package:flutter/material.dart';
import 'models/user.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HealthMate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'HealthMate'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Khởi tạo và gán dữ liệu cho User
  final User _user = User();

  @override
  void initState() {
    super.initState();
    _user.setUser('1', 'Nguyễn Hữu Huy', 'huy@example.com', 20, 'Nam', 170, 65);
  }

  // Hàm xử lý khi bấm nút - cập nhật lại cân nặng để test thay đổi BMI
  void _updateWeight() {
    setState(() {
      _user.setUser(
        _user.id,
        _user.name,
        _user.email,
        _user.age,
        _user.gender,
        _user.height,
        _user.weight + 1, // tăng cân nặng thêm 1kg mỗi lần bấm
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_user.getFullInfo()),
            const SizedBox(height: 10),
            Text('Cân nặng: ${_user.weight} kg'),
            Text('BMI: ${_user.getBMI().toStringAsFixed(1)}'),
            Text('Tình trạng: ${_user.getBMIStatus()}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _updateWeight,
              child: const Text('Cập nhật cân nặng (+1kg)'),
            ),
          ],
        ),
      ),
    );
  }
}