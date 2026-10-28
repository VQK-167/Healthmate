import 'package:flutter/material.dart';
import 'widgets/bottom_navigation_page.dart'; 
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Healthmate',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF003580)),
        useMaterial3: true,
      ),
      home: const BottomNavigationPage(),
    );
  }
}