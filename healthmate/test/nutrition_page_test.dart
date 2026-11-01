import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/nutrition.dart';
import 'package:healthmate/repositories/in_memory_nutrition_store.dart';
import 'package:healthmate/screens/nutrition_page.dart';

void main() {
  Future<InMemoryNutritionStore> pumpPage(
    WidgetTester tester, {
    bool withMeal = true,
  }) async {
    tester.view.physicalSize = const Size(900, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final store = InMemoryNutritionStore();
    addTearDown(() async {
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      store.dispose();
    });
    if (withMeal) {
      await store.addMeal(
        Meal(
          name: 'Phở bò',
          mealType: MealType.breakfast,
          calories: 450,
          loggedAt: DateTime.now(),
        ),
      );
    }
    await tester.pumpWidget(MaterialApp(home: NutritionPage(store: store)));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    return store;
  }

  testWidgets('hiện món và tổng calo của hôm nay', (tester) async {
    await pumpPage(tester);
    expect(find.text('Phở bò'), findsOneWidget);
    expect(find.text('450 / 2000 kcal'), findsOneWidget);
  });

  testWidgets('ngày chưa có món thì báo chưa có món nào', (tester) async {
    await pumpPage(tester, withMeal: false);
    expect(find.text('0 / 2000 kcal'), findsOneWidget);
    expect(find.text('Chưa có món nào'), findsNWidgets(MealType.values.length));
  });

  testWidgets('bấm +250 ml thì cộng vào lượng nước', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('+250 ml'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.text('250 / 2000 ml'), findsOneWidget);
  });

  testWidgets('vuốt sang trái để xóa món', (tester) async {
    await pumpPage(tester);
    await tester.fling(find.text('Phở bò'), const Offset(-700, 0), 1000);
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.text('Phở bò'), findsNothing);
    expect(find.text('0 / 2000 kcal'), findsOneWidget);
  });

  testWidgets('sang ngày hôm qua thì không thấy món hôm nay', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.byTooltip('Ngày trước'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.text('Phở bò'), findsNothing);
    expect(find.text('0 / 2000 kcal'), findsOneWidget);
  });

  testWidgets('bấm vào món mở chi tiết có nút Sửa và Xóa', (tester) async {
    await pumpPage(tester);
    await tester.tap(find.text('Phở bò'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();
    expect(find.text('Sửa'), findsOneWidget);
    expect(find.text('Xóa'), findsOneWidget);
  });
}
