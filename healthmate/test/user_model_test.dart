import 'package:flutter_test/flutter_test.dart';
import 'package:healthmate/models/user.dart';

void main() {
  final createdAt = DateTime(2026, 1, 15, 8, 30);

  test('AppUser round-trips profile and daily goals', () {
    final original = AppUser(
      id: 'user-1',
      email: 'huy@example.com',
      displayName: 'Huy',
      createdAt: createdAt,
      age: 21,
      gender: 'Nam',
      heightCm: 175,
      weightKg: 70.5,
      avatarIndex: 2,
      targetWeightKg: 65,
      dailyCalorieTarget: 2200,
      dailyStepsTarget: 9000,
      dailyWaterTargetMl: 2500,
    );

    final restored = AppUser.fromMap(
      original.id,
      original.toMap()..remove('createdAt'),
    );

    expect(restored.id, original.id);
    expect(restored.email, original.email);
    expect(restored.displayName, original.displayName);
    expect(restored.age, original.age);
    expect(restored.heightCm, original.heightCm);
    expect(restored.weightKg, original.weightKg);
    expect(restored.avatarIndex, original.avatarIndex);
    expect(restored.targetWeightKg, original.targetWeightKg);
    expect(restored.dailyCalorieTarget, original.dailyCalorieTarget);
    expect(restored.dailyStepsTarget, original.dailyStepsTarget);
    expect(restored.dailyWaterTargetMl, original.dailyWaterTargetMl);
  });

  test('copyWith updates one profile field and preserves goals', () {
    const profile = AppUser(
      id: 'user-1',
      email: 'huy@example.com',
      displayName: 'Huy',
      weightKg: 70,
      targetWeightKg: 65,
      dailyCalorieTarget: 2200,
      dailyStepsTarget: 9000,
      dailyWaterTargetMl: 2500,
      avatarIndex: 3,
    );

    final updated = profile.copyWith(weightKg: 69.5);

    expect(updated.weightKg, 69.5);
    expect(updated.targetWeightKg, 65);
    expect(updated.dailyCalorieTarget, 2200);
    expect(updated.dailyStepsTarget, 9000);
    expect(updated.dailyWaterTargetMl, 2500);
    expect(updated.avatarIndex, 3);
  });

  test('copyWith can clear avatar data without clearing profile goals', () {
    const profile = AppUser(
      id: 'user-1',
      email: 'huy@example.com',
      avatarBase64: 'encoded-image',
      avatarIndex: 1,
      targetWeightKg: 65,
      dailyWaterTargetMl: 2000,
    );

    final updated = profile.copyWith(clearAvatar: true);

    expect(updated.avatarBase64, isNull);
    expect(updated.avatarIndex, isNull);
    expect(updated.targetWeightKg, 65);
    expect(updated.dailyWaterTargetMl, 2000);
  });
}
