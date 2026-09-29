import 'package:flutter/material.dart';
import 'screens/bottom_navigation_page.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Healthmate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(scaffoldBackgroundColor: const Color(0xFFF3F2F8)),
      home: const BottomNavigationPage(),
    );
  }
}