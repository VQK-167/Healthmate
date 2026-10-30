import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/firestore_repository.dart';
import '../models/health_metric.dart';

/// Stores a user's health check-ins under `users/{uid}/health_metrics`.
class HealthRepository {
  HealthRepository({required String userId, FirebaseFirestore? firestore})
      : _userId = userId,
        _repository = FirestoreRepository<HealthMetric>(
          collectionPath: 'users/$userId/health_metrics',
          fromMap: HealthMetric.fromMap,
          firestore: firestore,
        );

  final String _userId;
  final FirestoreRepository<HealthMetric> _repository;

  /// Newest-first stream of all check-ins.
  Stream<List<HealthMetric>> watchAll() => _repository.watchAll(
        query: (q) => q.orderBy('recordedAt', descending: true),
      );

  /// Newest-first check-ins within [from, to] (inclusive), for charting a
  /// specific range (e.g. last 7/30 days).
  Stream<List<HealthMetric>> watchRange(DateTime from, DateTime to) =>
      _repository.watchAll(
        query: (q) => q
            .where('recordedAt', isGreaterThanOrEqualTo: Timestamp.fromDate(from))
            .where('recordedAt', isLessThanOrEqualTo: Timestamp.fromDate(to))
            .orderBy('recordedAt', descending: true),
      );

  Future<String> add(HealthMetric metric) {
    if (metric.userId != _userId) {
      throw ArgumentError('HealthMetric.userId must match the repository owner');
    }
    return _repository.add(metric);
  }

  Future<void> delete(String id) => _repository.delete(id);
}
