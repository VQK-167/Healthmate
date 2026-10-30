import 'package:cloud_firestore/cloud_firestore.dart';

import 'base_model.dart';

typedef ModelFactory<T extends BaseModel> =
    T Function(String id, Map<String, dynamic> data);

/// Generic Firestore CRUD and realtime query wrapper.
///
/// Feature repositories should add domain-specific methods around this class
/// instead of accessing Firestore directly from screens.
class FirestoreRepository<T extends BaseModel> {
  FirestoreRepository({
    required String collectionPath,
    required this.fromMap,
    FirebaseFirestore? firestore,
  }) : _collection = (firestore ?? FirebaseFirestore.instance)
            .collection(collectionPath);

  final CollectionReference<Map<String, dynamic>> _collection;
  final ModelFactory<T> fromMap;

  /// Watches all documents, optionally applying a feature-specific query.
  Stream<List<T>> watchAll({
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        query,
  }) {
    final source = query?.call(_collection) ?? _collection;
    return source.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => fromMap(doc.id, doc.data()))
              .toList(growable: false),
        );
  }

  Future<List<T>> getAll({
    Query<Map<String, dynamic>> Function(Query<Map<String, dynamic>> query)?
        query,
  }) async {
    final source = query?.call(_collection) ?? _collection;
    final snapshot = await source.get();
    return snapshot.docs
        .map((doc) => fromMap(doc.id, doc.data()))
        .toList(growable: false);
  }

  Future<T?> get(String id) async {
    final snapshot = await _collection.doc(id).get();
    final data = snapshot.data();
    return snapshot.exists && data != null ? fromMap(snapshot.id, data) : null;
  }

  /// Creates a document and returns its generated or supplied id.
  Future<String> add(T value) async {
    if (value.id.isEmpty) {
      final reference = await _collection.add(value.toMap());
      return reference.id;
    }
    await _collection.doc(value.id).set(value.toMap());
    return value.id;
  }

  Future<void> set(T value, {bool merge = false}) {
    if (value.id.isEmpty) {
      throw ArgumentError('Cannot set a model without an id. Use add() instead.');
    }
    return _collection.doc(value.id).set(
          value.toMap(),
          SetOptions(merge: merge),
        );
  }

  Future<void> update(String id, Map<String, dynamic> data) =>
      _collection.doc(id).update(data);

  Future<void> delete(String id) => _collection.doc(id).delete();
}
