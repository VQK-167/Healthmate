import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  final void Function(int) onSelectTab;

  const HomePage({super.key, required this.onSelectTab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: const Center(child: Text('Đang phát triển')),
    );
  }
}