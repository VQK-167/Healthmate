import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/health_metric.dart';
import 'package:healthmate/repositories/health_repository.dart';

void main() {
  late FakeFirebaseFirestore firestore;
  late HealthRepository repository;
  const uid = 'u1';

  setUp(() {
    firestore = FakeFirebaseFirestore();
    repository = HealthRepository(userId: uid, firestore: firestore);
  });

  HealthMetric metric({
    String id = '',
    DateTime? recordedAt,
    double? weightKg,
    String userId = uid,
  }) =>
      HealthMetric(
        id: id,
        userId: userId,
        recordedAt: recordedAt ?? DateTime(2026, 10, 30),
        weightKg: weightKg,
        heightCm: 170,
      );

  group('add', () {
    test('lưu đúng vào users/{uid}/health_metrics và trả về id', () async {
      final id = await repository.add(metric(weightKg: 65));

      final doc = await firestore
          .collection('users')
          .doc(uid)
          .collection('health_metrics')
          .doc(id)
          .get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['weightKg'], 65);
      expect(doc.data()!['userId'], uid);
    });

    test('từ chối khi userId của metric không khớp chủ sở hữu repository', () {
      expect(
        () => repository.add(metric(userId: 'other-user')),
        throwsArgumentError,
      );
    });
  });

  group('watchAll', () {
    test('trả về danh sách mới nhất trước', () async {
      await repository.add(metric(recordedAt: DateTime(2026, 10, 1), weightKg: 60));
      await repository.add(metric(recordedAt: DateTime(2026, 10, 15), weightKg: 62));
      await repository.add(metric(recordedAt: DateTime(2026, 10, 8), weightKg: 61));

      final list = await repository.watchAll().first;

      expect(list.map((m) => m.weightKg), [62, 61, 60]);
    });
  });

  group('watchRange', () {
    test('chỉ lấy bản ghi trong khoảng [from, to]', () async {
      await repository.add(metric(recordedAt: DateTime(2026, 9, 1), weightKg: 58));
      await repository.add(metric(recordedAt: DateTime(2026, 10, 10), weightKg: 63));
      await repository.add(metric(recordedAt: DateTime(2026, 11, 1), weightKg: 64));

      final list = await repository
          .watchRange(DateTime(2026, 10, 1), DateTime(2026, 10, 31))
          .first;

      expect(list.map((m) => m.weightKg), [63]);
    });
  });

  group('update', () {
    test('ghi đè đúng document đã có', () async {
      final id = await repository.add(metric(weightKg: 65));
      await repository.update(metric(id: id, weightKg: 70));

      final list = await repository.watchAll().first;
      expect(list.single.weightKg, 70);
    });

    test('từ chối khi id rỗng', () {
      expect(() => repository.update(metric()), throwsArgumentError);
    });

    test('từ chối khi userId không khớp chủ sở hữu repository', () {
      expect(
        () => repository.update(metric(id: 'doc1', userId: 'other-user')),
        throwsArgumentError,
      );
    });
  });

  group('delete', () {
    test('xóa đúng document theo id', () async {
      final id = await repository.add(metric(weightKg: 65));
      await repository.delete(id);

      final list = await repository.watchAll().first;
      expect(list, isEmpty);
    });
  });
}
