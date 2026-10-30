import 'package:cloud_firestore/cloud_firestore.dart';

/// Contract implemented by models persisted in Cloud Firestore.
abstract class BaseModel {
  String get id;

  Map<String, dynamic> toMap();
}

/// Converts Firestore date values without making models depend on a specific
/// Firestore representation.
DateTime? dateTimeFromFirestore(Object? value) {
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}

/// Converts a Dart date to a Firestore-compatible value.
Object? dateTimeToFirestore(DateTime? value) =>
    value == null ? null : Timestamp.fromDate(value);
