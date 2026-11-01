import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/firestore_repository.dart';
import '../models/workout.dart';

class GoalRepository {
  GoalRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _auth = auth ?? FirebaseAuth.instance,
        _goals = FirestoreRepository<Goal>(
          collectionPath: 'goals',
          fromMap: Goal.fromMap,
          firestore: firestore,
        );

  static const String _loginMessage = 'Bạn cần đăng nhập để sử dụng chức năng này.';

  final FirebaseAuth _auth;
  final FirestoreRepository<Goal> _goals;

  String? get _uidOrNull => _auth.currentUser?.uid;
  String get _uid => _uidOrNull ?? (throw StateError(_loginMessage));

  /// Danh sách mục tiêu của người dùng, mới nhất trước (sắp xếp bằng Dart, không cần index).
  Stream<List<Goal>> watchGoals() {
    final uid = _uidOrNull;
    if (uid == null) return Stream<List<Goal>>.error(StateError(_loginMessage));
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    return _goals
        .watchAll(query: (q) => q.where('userId', isEqualTo: uid))
        .map((list) => [...list]..sort((a, b) => (b.updatedAt ?? epoch).compareTo(a.updatedAt ?? epoch)));
  }

  Future<String> saveGoal({
    required String type,
    required String title,
    required double target,
    required String unit,
    String? id,
  }) async {
    if (target <= 0) throw ArgumentError('Mục tiêu phải lớn hơn 0.');
    final goal = Goal(
      id: id ?? '',
      userId: _uid,
      type: type,
      title: title,
      target: target,
      unit: unit,
      updatedAt: DateTime.now(),
    );
    return _goals.add(goal);
  }

  Future<void> updateProgress(Goal goal, double current) => _goals.set(Goal(
        id: goal.id,
        userId: _uid,
        type: goal.type,
        title: goal.title,
        target: goal.target,
        current: current,
        unit: goal.unit,
        updatedAt: DateTime.now(),
      ));

  Future<void> deleteGoal(String id) => _goals.delete(id);
}
