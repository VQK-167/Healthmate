import 'package:flutter/material.dart';

import 'screens/health_screen.dart';
import 'screens/nutrition_screen.dart';
import 'widgets/bottom_nav_bar.dart';

void main() {
  runApp(const HealthMateApp());
}

class HealthMateApp extends StatelessWidget {
  const HealthMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthMate',

      theme: ThemeData(
        useMaterial3: true,
      ),

      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {

  // 1 = Sức khỏe
  int currentIndex = 1;

  final List<Widget> screens = [
    const Center(
      child: Text(
        'Home',
        style: TextStyle(fontSize: 24),
      ),
    ),

    const HealthScreen(),

    const NutritionScreen(),

    const Center(
      child: Text(
        'Thể thao',
        style: TextStyle(fontSize: 24),
      ),
    ),

    const Center(
      child: Text(
        'Hồ sơ',
        style: TextStyle(fontSize: 24),
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[currentIndex],

      bottomNavigationBar: BottomNavBar(
        currentIndex: currentIndex,

        onTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
