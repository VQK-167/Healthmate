import 'package:flutter/material.dart';
import 'screens/nutrition_screen.dart'; // Đã sửa tên file cho đúng

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HealthMate',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const NutritionScreen(),
    );
  }
}