import '../core/base_model.dart';

class Workout implements BaseModel {
  const Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.minutes,
    required this.calories,
    required this.date,
    this.type = 'other',
    this.note = '',
  });

  @override
  final String id;
  final String userId;
  final String name;
  final int minutes;
  final int calories;
  final DateTime date;

  /// Loại bài tập: run, walk, bike, swim, yoga, gym, ball, other.
  /// Buổi tập cũ không có trường này nên mặc định là 'other'.
  final String type;
  final String note;

  Workout copyWith({
    String? name,
    int? minutes,
    int? calories,
    DateTime? date,
    String? type,
    String? note,
  }) =>
      Workout(
        id: id,
        userId: userId,
        name: name ?? this.name,
        minutes: minutes ?? this.minutes,
        calories: calories ?? this.calories,
        date: date ?? this.date,
        type: type ?? this.type,
        note: note ?? this.note,
      );

  @override
  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'minutes': minutes,
        'calories': calories,
        'date': dateTimeToFirestore(date),
        'type': type,
        'note': note,
      };

  factory Workout.fromMap(String id, Map<String, dynamic> map) => Workout(
        id: id,
        userId: map['userId'] as String? ?? '',
        name: map['name'] as String? ?? '',
        minutes: (map['minutes'] as num?)?.toInt() ?? 0,
        calories: (map['calories'] as num?)?.toInt() ?? 0,
        date: dateTimeFromFirestore(map['date']) ?? DateTime.now(),
        type: map['type'] as String? ?? 'other',
        note: map['note'] as String? ?? '',
      );
}

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
  final double target;
  final double current;
  final String unit;
  final DateTime? updatedAt;

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
