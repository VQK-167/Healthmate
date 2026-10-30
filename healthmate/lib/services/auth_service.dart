import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/user.dart';

class AuthService {
  AuthService({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  Future<AppUser> register({required String email, required String password, required String displayName}) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    final user = credential.user!;
    await user.updateDisplayName(displayName.trim());
    final profile = AppUser(id: user.uid, email: user.email ?? email.trim(), displayName: displayName.trim(), createdAt: DateTime.now());
    await _firestore.collection('users').doc(user.uid).set(profile.toMap());
    return profile;
  }

  Future<UserCredential> signIn({required String email, required String password}) =>
      _auth.signInWithEmailAndPassword(email: email.trim(), password: password);

  Future<void> signOut() => _auth.signOut();

  Stream<AppUser?> watchProfile(String uid) => _firestore.collection('users').doc(uid).snapshots().map(
        (snapshot) => snapshot.exists && snapshot.data() != null ? AppUser.fromMap(snapshot.id, snapshot.data()!) : null,
      );

  Future<void> updateProfile(AppUser profile) async {
    await _firestore.collection('users').doc(profile.id).set(
          profile.toMap(),
          SetOptions(merge: true),
        );
    if (_auth.currentUser?.uid == profile.id &&
        _auth.currentUser?.displayName != profile.displayName) {
      await _auth.currentUser?.updateDisplayName(profile.displayName);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw FirebaseAuthException(code: 'user-not-found');
    }

    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _firestore.collection('users').doc(user.uid).delete();
    await user.delete();
  }
}
