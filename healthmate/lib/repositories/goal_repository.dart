import 'package:firebase_auth/firebase_auth.dart';

import '../core/firestore_repository.dart';
import '../models/workout.dart';

/// Lớp trung gian giữa giao diện và Firestore cho phần mục tiêu.
class GoalRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final FirestoreRepository<Goal> _goals =
      FirestoreRepository<Goal>(collectionPath: 'goals', fromMap: Goal.fromMap);

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Bạn cần đăng nhập để sử dụng chức năng này.');
    return user.uid;
  }

  /// Đọc (realtime) các mục tiêu của người dùng. Không cần index vì chỉ lọc một trường.
  Stream<List<Goal>> watchGoals() {
    return _goals.watchAll(query: (q) => q.where('userId', isEqualTo: _uid));
  }

  Future<String> saveGoal({
    required String type,
    required String title,
    required double target,
    required String unit,
  }) async {
    if (target <= 0) throw ArgumentError('Mục tiêu phải lớn hơn 0.');
    final goal = Goal(
      id: '',
      userId: _uid,
      type: type,
      title: title,
      target: target,
      unit: unit,
      updatedAt: DateTime.now(),
    );
    return _goals.add(goal);
  }

  Future<void> deleteGoal(String id) => _goals.delete(id);
}
