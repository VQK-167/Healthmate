class Workout {
  final String id;
  final String userId;
  final String name;
  final int minutes;
  final int calories;
  final String logDate;

  const Workout({
    required this.id,
    required this.userId,
    required this.name,
    required this.minutes,
    required this.calories,
    required this.logDate,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: (json['id'] ?? '').toString(),
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      minutes: (json['minutes'] as num?)?.toInt() ?? 0,
      calories: (json['calories'] as num?)?.toInt() ?? 0,
      logDate: (json['logDate'] ?? json['log_date'] ?? '').toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'minutes': minutes,
      'calories': calories,
      'logDate': logDate,
    };
  }
}
