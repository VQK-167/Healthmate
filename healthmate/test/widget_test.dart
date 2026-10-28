
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/main.dart';

void main() {
  testWidgets('HealthMate app startup test', (WidgetTester tester) async {
    // Khoi dong ung dung HealthMate
    await tester.pumpWidget(const HealthMateApp());

    // Kiem tra ung dung hien thi man hinh Suc khoe
    expect(find.text('Sức khỏe'), findsWidgets);

    // Kiem tra ung dung co Scaffold
    expect(find.byType(Scaffold), findsWidgets);
  });
}
