import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/nutrition.dart';
import 'package:healthmate/screens/add_meal_page.dart';

void main() {
  /// Mở AddMealPage từ một nút, gọi [onResult] với giá trị trang trả về.
  Future<void> openPage(
    WidgetTester tester, {
    Meal? initial,
    void Function(Meal? result)? onResult,
  }) async {
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<Meal>(
                    MaterialPageRoute(
                      builder: (_) => AddMealPage(initialMeal: initial),
                    ),
                  );
                  onResult?.call(result);
                },
                child: const Text('mở'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('mở'));
    await tester.pumpAndSettle();
  }

  String textOf(WidgetTester tester, String key) =>
      tester.widget<TextField>(find.byKey(Key(key))).controller!.text;

  testWidgets('tên rỗng: báo lỗi và không đóng trang', (tester) async {
    await openPage(tester);
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pump();
    expect(find.text('Vui lòng nhập tên món'), findsOneWidget);
    expect(find.byKey(const Key('save_button')), findsOneWidget);
  });

  testWidgets('calo không phải số bị từ chối', (tester) async {
    await openPage(tester);
    await tester.enterText(find.byKey(const Key('name_field')), 'Bánh mì');
    await tester.enterText(find.byKey(const Key('calories_field')), 'abc');
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pump();
    expect(find.text('Calo phải là số không âm'), findsOneWidget);
  });

  testWidgets('số phần bằng 0 bị từ chối', (tester) async {
    await openPage(tester);
    await tester.enterText(find.byKey(const Key('name_field')), 'Bánh mì');
    await tester.enterText(find.byKey(const Key('calories_field')), '400');
    await tester.enterText(find.byKey(const Key('quantity_field')), '0');
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pump();
    expect(find.text('Số phần phải lớn hơn 0'), findsOneWidget);
  });

  testWidgets('bấm món có sẵn thì tự điền thông tin', (tester) async {
    await openPage(tester);
    await tester.tap(find.textContaining('Phở bò'));
    await tester.pump();
    expect(textOf(tester, 'name_field'), 'Phở bò');
    expect(textOf(tester, 'calories_field'), '450');
  });

  testWidgets('tìm không dấu vẫn ra món có dấu', (tester) async {
    await openPage(tester);
    await tester.enterText(find.byKey(const Key('search_field')), 'pho bo');
    await tester.pump();
    expect(find.textContaining('Phở bò'), findsOneWidget);
    expect(find.textContaining('Cơm trắng'), findsNothing);
  });

  testWidgets('lọc theo nhóm Đồ uống', (tester) async {
    await openPage(tester);
    await tester.tap(find.text('Đồ uống'));
    await tester.pump();
    expect(find.textContaining('Phở bò'), findsNothing);
    expect(find.textContaining('Trà sữa trân châu'), findsOneWidget);
  });

  testWidgets('lưu hợp lệ thì trả về Meal', (tester) async {
    Meal? result;
    await openPage(tester, onResult: (m) => result = m);
    await tester.enterText(find.byKey(const Key('name_field')), 'Bánh mì');
    await tester.enterText(find.byKey(const Key('calories_field')), '400');
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.name, 'Bánh mì');
    expect(result!.calories, 400);
    expect(result!.quantity, 1);
  });

  testWidgets('chế độ sửa: điền sẵn và giữ id, giờ ăn', (tester) async {
    final at = DateTime(2026, 10, 30, 7, 30);
    final initial = Meal(
      id: 'm1',
      name: 'Phở',
      mealType: MealType.breakfast,
      calories: 450,
      quantity: 1.5,
      loggedAt: at,
    );
    Meal? result;
    await openPage(tester, initial: initial, onResult: (m) => result = m);

    expect(find.text('Sửa món'), findsOneWidget);
    expect(textOf(tester, 'name_field'), 'Phở');
    expect(textOf(tester, 'quantity_field'), '1.5');

    await tester.enterText(find.byKey(const Key('name_field')), 'Phở tái');
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(result, isNotNull);
    expect(result!.id, 'm1');
    expect(result!.name, 'Phở tái');
    expect(result!.loggedAt, at);
  });
}