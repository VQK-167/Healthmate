import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/health_metric.dart';
import 'package:healthmate/repositories/health_repository.dart';
import 'package:healthmate/screens/health_page.dart';

void main() {
  const uid = 'u1';
  late FakeFirebaseFirestore firestore;
  late HealthRepository repository;

  Future<void> pumpHealthPage(WidgetTester tester) async {
    tester.view.physicalSize = const Size(900, 3200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MaterialApp(
        home: HealthPage(userId: uid, repository: repository),
      ),
    );
    await tester.pumpAndSettle();
  }

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = HealthRepository(userId: uid, firestore: firestore);
  });

  testWidgets('chưa có bản ghi: hiện trạng thái rỗng', (tester) async {
    await pumpHealthPage(tester);

    expect(find.text('Chưa có chỉ số nào được ghi nhận'), findsOneWidget);
  });

  testWidgets('thêm chỉ số qua UI: hiện ngay trong lịch sử', (tester) async {
    await pumpHealthPage(tester);

    await tester.tap(find.text('Ghi chỉ số đầu tiên'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('weight_field')), '65');
    await tester.enterText(find.byKey(const Key('heart_rate_field')), '72');
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có chỉ số nào được ghi nhận'), findsNothing);
    expect(find.textContaining('65.0 kg'), findsOneWidget);
    expect(find.textContaining('72 bpm'), findsOneWidget);
  });

  testWidgets('thêm với giá trị ngoài khoảng hợp lệ: báo lỗi, không lưu', (tester) async {
    await pumpHealthPage(tester);

    await tester.tap(find.text('Ghi chỉ số đầu tiên'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('weight_field')), '999');
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pump();

    expect(find.textContaining('Giá trị từ'), findsOneWidget);
    expect(await repository.watchAll().first, isEmpty);
  });

  testWidgets('sửa chỉ số qua UI: form hiện sẵn dữ liệu cũ và lưu giá trị mới', (tester) async {
    await repository.add(HealthMetric(
      userId: uid,
      recordedAt: DateTime(2026, 10, 30),
      weightKg: 65,
    ));
    await pumpHealthPage(tester);

    await tester.tap(find.byTooltip('Sửa'));
    await tester.pumpAndSettle();

    expect(find.text('Sửa chỉ số sức khỏe'), findsOneWidget);
    expect(
      tester.widget<TextFormField>(find.byKey(const Key('weight_field'))).controller!.text,
      '65.0',
    );

    await tester.enterText(find.byKey(const Key('weight_field')), '70');
    await tester.tap(find.byKey(const Key('save_button')));
    await tester.pumpAndSettle();

    expect(find.textContaining('70.0 kg'), findsOneWidget);
    expect(find.textContaining('65.0 kg'), findsNothing);
  });

  testWidgets('xóa chỉ số qua UI: huỷ thì giữ lại, xác nhận thì xoá', (tester) async {
    await repository.add(HealthMetric(
      userId: uid,
      recordedAt: DateTime(2026, 10, 30),
      weightKg: 65,
    ));
    await pumpHealthPage(tester);

    await tester.tap(find.byTooltip('Xóa'));
    await tester.pumpAndSettle();
    expect(find.text('Xóa chỉ số?'), findsOneWidget);

    await tester.tap(find.text('Hủy'));
    await tester.pumpAndSettle();
    expect(find.textContaining('65.0 kg'), findsOneWidget);

    await tester.tap(find.byTooltip('Xóa'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Xóa'));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có chỉ số nào được ghi nhận'), findsOneWidget);
  });
}
