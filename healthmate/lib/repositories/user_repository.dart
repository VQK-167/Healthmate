import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user.dart';

class UserRepository {
  UserRepository({FirebaseFirestore? firestore})
      : _users = (firestore ?? FirebaseFirestore.instance).collection('users');

  final CollectionReference<Map<String, dynamic>> _users;

  Future<void> create(AppUser user) => _users.doc(user.id).set(user.toMap());

  Future<AppUser?> get(String uid) async {
    final snapshot = await _users.doc(uid).get();
    final data = snapshot.data();
    if (!snapshot.exists || data == null) return null;
    return AppUser.fromMap(snapshot.id, data);
  }

  Stream<AppUser?> watch(String uid) => _users.doc(uid).snapshots().map(
        (snapshot) {
          final data = snapshot.data();
          if (!snapshot.exists || data == null) return null;
          return AppUser.fromMap(snapshot.id, data);
        },
      );

  Future<void> update(AppUser user) => _users.doc(user.id).set(
        user.toMap(),
        SetOptions(merge: true),
      );

  Future<void> delete(String uid) => _users.doc(uid).delete();
}
