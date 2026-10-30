import '../core/base_model.dart';

/// Một buổi tập. Lưu trong collection "workouts" của Firestore.
class Workout implements BaseModel {
  const Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.minutes,
    required this.calories,
    required this.date,
  });

  @override
  final String id; // id tài liệu Firestore
  final String userId; // id người dùng sở hữu buổi tập
  final String name;
  final int minutes;
  final int calories;
  final DateTime date;

  /// Đổi object thành Map để ghi lên Firestore.
  @override
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'minutes': minutes,
        'calories': calories,
        'date': dateTimeToFirestore(date),
      };

  /// Đổi Map đọc từ Firestore thành object.
  factory Workout.fromMap(String id, Map<String, dynamic> map) => Workout(
        id: id,
        userId: map['userId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        minutes: (map['minutes'] as num?)?.toInt() ?? 0,
        calories: (map['calories'] as num?)?.toInt() ?? 0,
        date: dateTimeFromFirestore(map['date']) ?? DateTime.now(),
      );
}

/// Một mục tiêu. Lưu trong collection "goals" của Firestore.
/// type: 'steps' (bước chân), 'calories' (calo), 'workouts' (số buổi tập).
class Goal implements BaseModel {
  const Goal({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.target,
    this.current = 0,
    this.unit = '',
    this.updatedAt,
  });

  @override
  final String id;
  final String userId;
  final String type;
  final String title;
  final double target; // con số cần đạt
  final double current;
  final String unit;
  final DateTime? updatedAt;

  /// Tiến độ từ 0 đến 1.
  double get progress => target <= 0 ? 0 : (current / target).clamp(0, 1).toDouble();

  @override
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'type': type,
        'title': title,
        'target': target,
        'current': current,
        'unit': unit,
        'updatedAt': dateTimeToFirestore(updatedAt),
      };

  factory Goal.fromMap(String id, Map<String, dynamic> map) => Goal(
        id: id,
        userId: map['userId'] as String? ?? '',
        type: map['type'] as String? ?? 'steps',
        title: map['title'] as String? ?? 'Mục tiêu',
        target: (map['target'] as num?)?.toDouble() ?? 0,
        current: (map['current'] as num?)?.toDouble() ?? 0,
        unit: map['unit'] as String? ?? '',
        updatedAt: dateTimeFromFirestore(map['updatedAt']),
      );
}
