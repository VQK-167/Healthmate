import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'health_screen.dart';
import 'nutrition_screen.dart';
import 'workout_screen.dart';
import 'user_screen.dart';

class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomeScreen(),
    HealthScreen(),
    NutritionScreen(),
    WorkoutScreen(),
    UserScreen(),
  ];

  BottomNavigationBarItem _item(String emoji, String label) =>
      BottomNavigationBarItem(
        icon: Text(emoji, style: const TextStyle(fontSize: 24)),
        label: label,
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: _pages[_currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF673AB7),
        unselectedItemColor: Colors.grey,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        onTap: (i) => setState(() => _currentIndex = i),
        items: [
          _item('🏠', 'Home'),
          _item('❤️', 'Sức khỏe'),
          _item('🍽️', 'Dinh dưỡng'),
          _item('🏋️', 'Thể thao'),
          _item('👤', 'Hồ sơ'),
        ],
      ),
    );
  }
}