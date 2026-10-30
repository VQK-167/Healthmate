import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/base_model.dart';

class AppUser implements BaseModel {
  const AppUser({
    required this.id,
    required this.email,
    this.displayName = '',
    this.photoUrl,
    this.createdAt,
    this.age,
    this.gender,
    this.heightCm,
    this.weightKg,
    this.avatarBase64,
    this.avatarIndex,
  });

  @override
  final String id;
  final String email;
  final String displayName;
  final String? photoUrl;
  final DateTime? createdAt;
  final int? age;
  final String? gender;
  final double? heightCm;
  final double? weightKg;
  final String? avatarBase64;
  final int? avatarIndex;

  factory AppUser.fromMap(String id, Map<String, dynamic> data) => AppUser(
        id: id,
        email: data['email'] as String? ?? '',
        displayName: data['displayName'] as String? ?? '',
        photoUrl: data['photoUrl'] as String?,
        createdAt: dateTimeFromFirestore(data['createdAt']),
        age: (data['age'] as num?)?.toInt(),
        gender: data['gender'] as String?,
        heightCm: (data['heightCm'] as num?)?.toDouble(),
        weightKg: (data['weightKg'] as num?)?.toDouble(),
        avatarBase64: data['avatarBase64'] as String?,
        avatarIndex: (data['avatarIndex'] as num?)?.toInt(),
      );

  @override
  Map<String, dynamic> toMap() => {
        'email': email,
        'displayName': displayName,
        'photoUrl': photoUrl,
        'createdAt': createdAt == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(createdAt!),
        'age': age,
        'gender': gender,
        'heightCm': heightCm,
        'weightKg': weightKg,
        'avatarBase64': avatarBase64,
        'avatarIndex': avatarIndex,
      };

  AppUser copyWith({
    String? displayName,
    int? age,
    String? gender,
    double? heightCm,
    double? weightKg,
    String? avatarBase64,
    int? avatarIndex,
    bool clearAvatar = false,
    bool clearAvatarBase64 = false,
    bool clearAvatarIndex = false,
  }) => AppUser(
        id: id,
        email: email,
        displayName: displayName ?? this.displayName,
        photoUrl: photoUrl,
        createdAt: createdAt,
        age: age ?? this.age,
        gender: gender ?? this.gender,
        heightCm: heightCm ?? this.heightCm,
        weightKg: weightKg ?? this.weightKg,
        avatarBase64: clearAvatar || clearAvatarBase64
            ? null
            : avatarBase64 ?? this.avatarBase64,
        avatarIndex: clearAvatar || clearAvatarIndex
            ? null
            : avatarIndex ?? this.avatarIndex,
      );
}
