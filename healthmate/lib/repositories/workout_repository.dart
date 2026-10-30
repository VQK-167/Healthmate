import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/firestore_repository.dart';
import '../models/workout.dart';

/// Lớp trung gian giữa giao diện và Firestore cho phần tập luyện.
/// Giao diện không gọi Firestore trực tiếp mà luôn đi qua lớp này.
class WorkoutRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // FirestoreRepository (của Huy) lo các thao tác CRUD chung cho collection "workouts".
  final FirestoreRepository<Workout> _workouts =
      FirestoreRepository<Workout>(collectionPath: 'workouts', fromMap: Workout.fromMap);

  /// Id người dùng đang đăng nhập.
  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Bạn cần đăng nhập để sử dụng chức năng này.');
    return user.uid;
  }

  // ---------- Buổi tập: đọc, thêm, sửa, xoá ----------

  /// Đọc (realtime) các buổi tập của người dùng, mới nhất trước.
  /// Chỉ lọc theo userId rồi sắp xếp bằng Dart, nên không cần tạo index trên Firestore.
  Stream<List<Workout>> watchWorkouts() {
    return _workouts.watchAll(query: (q) => q.where('userId', isEqualTo: _uid)).map((list) {
      list.sort((a, b) => b.date.compareTo(a.date));
      return list;
    });
  }

  Future<String> addWorkout({required String name, required int minutes, required int calories}) async {
    _check(name, minutes, calories);
    final workout = Workout(
      id: '', // để trống, Firestore tự tạo id
      userId: _uid,
      name: name.trim(),
      minutes: minutes,
      calories: calories,
      date: DateTime.now(),
    );
    return _workouts.add(workout);
  }

  Future<void> updateWorkout(Workout workout) async {
    _check(workout.name, workout.minutes, workout.calories);
    await _workouts.set(workout);
  }

  Future<void> deleteWorkout(String id) => _workouts.delete(id);

  /// Kiểm tra dữ liệu nhập vào.
  void _check(String name, int minutes, int calories) {
    if (name.trim().isEmpty || minutes <= 0 || calories < 0) {
      throw ArgumentError('Thông tin buổi tập không hợp lệ.');
    }
  }

  // ---------- Các hàm cho trang Home ----------

  Stream<int> watchStepsToday() => _watchDailyNumber('steps');

  Stream<int> watchCaloriesBurnedToday() => _watchDailyNumber('caloriesBurned');

  /// Mục tiêu (con số cần đạt) của một loại, ví dụ 'steps'. Chưa có thì trả về 0.
  Stream<double> watchGoal(String type) {
    return _firestore
        .collection('goals')
        .where('userId', isEqualTo: _uid)
        .where('type', isEqualTo: type)
        .limit(1)
        .snapshots()
        .map((snapshot) {
      if (snapshot.docs.isEmpty) return 0.0;
      return (snapshot.docs.first.data()['target'] as num?)?.toDouble() ?? 0.0;
    });
  }

  /// Cộng thêm số bước vào bản ghi của hôm nay (dùng transaction để cộng dồn đúng).
  Future<void> addSteps(int steps) async {
    if (steps <= 0) throw ArgumentError('Số bước phải lớn hơn 0.');
    final uid = _uid;
    final ref = _dailyRef();
    await _firestore.runTransaction((tx) async {
      final snap = await tx.get(ref);
      final old = (snap.data()?['steps'] as num?)?.toInt() ?? 0;
      tx.set(ref, {'userId': uid, 'date': _dateKey(), 'steps': old + steps}, SetOptions(merge: true));
    });
  }

  // ---------- Nội bộ ----------

  /// Mỗi người mỗi ngày có một tài liệu trong "daily_logs", id dạng "uid_2026-10-30".
  DocumentReference<Map<String, dynamic>> _dailyRef() {
    return _firestore.collection('daily_logs').doc('${_uid}_${_dateKey()}');
  }

  Stream<int> _watchDailyNumber(String field) {
    return _dailyRef().snapshots().map((snap) => (snap.data()?[field] as num?)?.toInt() ?? 0);
  }

  String _dateKey() {
    final d = DateTime.now();
    final month = d.month.toString().padLeft(2, '0');
    final day = d.day.toString().padLeft(2, '0');
    return '${d.year}-$month-$day';
  }
}
