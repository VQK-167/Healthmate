import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/firestore_repository.dart';
import '../models/workout.dart';

class WorkoutRepository {
  WorkoutRepository({FirebaseFirestore? firestore, FirebaseAuth? auth})
      : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance,
        _workouts = FirestoreRepository<Workout>(
          collectionPath: 'workouts',
          fromMap: Workout.fromMap,
          firestore: firestore,
        );

  static const String _loginMessage = 'Bạn cần đăng nhập để sử dụng chức năng này.';

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FirestoreRepository<Workout> _workouts;

  String? get _uidOrNull => _auth.currentUser?.uid;
  String get _uid => _uidOrNull ?? (throw StateError(_loginMessage));

  /// Danh sách buổi tập của người dùng, mới nhất trước.
  /// Sắp xếp bằng Dart nên không cần tạo composite index trên Firestore.
  Stream<List<Workout>> watchWorkouts() {
    final uid = _uidOrNull;
    if (uid == null) return Stream<List<Workout>>.error(StateError(_loginMessage));
    return _workouts
        .watchAll(query: (q) => q.where('userId', isEqualTo: uid))
        .map((list) => [...list]..sort((a, b) => b.date.compareTo(a.date)));
  }

  Future<String> addWorkout({
    required String name,
    required int minutes,
    required int calories,
    DateTime? date,
    String type = 'other',
    String note = '',
  }) async {
    _validate(name, minutes, calories);
    return _workouts.add(Workout(
      id: '',
      userId: _uid,
      name: name.trim(),
      minutes: minutes,
      calories: calories,
      date: date ?? DateTime.now(),
      type: type,
      note: note.trim(),
    ));
  }

  Future<void> updateWorkout(Workout workout) async {
    _validate(workout.name, workout.minutes, workout.calories);
    await _workouts.set(Workout(
      id: workout.id,
      userId: _uid,
      name: workout.name.trim(),
      minutes: workout.minutes,
      calories: workout.calories,
      date: workout.date,
      type: workout.type,
      note: workout.note.trim(),
    ));
  }

  Future<void> deleteWorkout(String id) => _workouts.delete(id);

  // ----- Các hàm cho trang Home -----

  Stream<int> watchStepsToday() => watchStepsOn(DateTime.now());

  Stream<int> watchStepsOn(DateTime day) {
    final uid = _uidOrNull;
    if (uid == null) return Stream<int>.value(0);
    return _firestore
        .collection('daily_logs')
        .doc('${uid}_${dateKeyOf(day)}')
        .snapshots()
        .map((s) => (s.data()?['steps'] as num?)?.toInt() ?? 0);
  }

  Stream<int> watchCaloriesBurnedToday() => _watchDailyNumber('caloriesBurned');

  Stream<double> watchGoal(String type) {
    final uid = _uidOrNull;
    if (uid == null) return Stream<double>.value(0.0);
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: uid)
        .where('type', isEqualTo: type)
        .limit(1)
        .snapshots()
        .map((s) => s.docs.isEmpty ? 0.0 : ((s.docs.first.data()['target'] as num?)?.toDouble() ?? 0.0));
  }

  /// Số bước chân của từng ngày: khoá dạng "2026-10-30". Chỉ lọc theo userId nên không cần index.
  Stream<Map<String, int>> watchStepsHistory() {
    final uid = _uidOrNull;
    if (uid == null) return Stream<Map<String, int>>.value(<String, int>{});
    return _firestore.collection('daily_logs').where('userId', isEqualTo: uid).snapshots().map((snap) {
      final result = <String, int>{};
      for (final doc in snap.docs) {
        final data = doc.data();
        final key = data['date'];
        if (key is String) result[key] = (data['steps'] as num?)?.toInt() ?? 0;
      }
      return result;
    });
  }

  /// Khoá ngày dạng "yyyy-MM-dd", dùng cho bản ghi bước chân.
  static String dateKeyOf(DateTime d) {
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year.toString().padLeft(4, '0')}-$month-$day';
  }

  Future<void> addSteps(int steps) async {
    if (steps <= 0) throw ArgumentError('Số bước phải lớn hơn 0.');
    final uid = _uid;
    final ref = _dailyRef(uid);
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final old = (snap.data()?['steps'] as num?)?.toInt() ?? 0;
      tx.set(ref, {'userId': uid, 'date': _dateKey(), 'steps': old + steps}, SetOptions(merge: true));
    });
  }

  // ----- Nội bộ -----

  void _validate(String name, int minutes, int calories) {
    if (name.trim().isEmpty || minutes <= 0 || calories < 0) {
      throw ArgumentError('Thông tin buổi tập không hợp lệ.');
    }
  }

  Stream<int> _watchDailyNumber(String field) {
    final uid = _uidOrNull;
    if (uid == null) return Stream<int>.value(0);
    return _dailyRef(uid).snapshots().map((s) => (s.data()?[field] as num?)?.toInt() ?? 0);
  }

  DocumentReference<Map<String, dynamic>> _dailyRef(String uid) =>
      _firestore.collection('daily_logs').doc('${uid}_${_dateKey()}');

  String _dateKey() => dateKeyOf(DateTime.now());
}
