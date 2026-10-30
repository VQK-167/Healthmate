class Goal {
  final String userId;
  final int kcalGoal;
  final int stepGoal;
  final int waterGoal;

  const Goal({
    required this.userId,
    this.kcalGoal = 2000,
    this.stepGoal = 10000,
    this.waterGoal = 2000,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      kcalGoal: (json['kcalGoal'] ?? json['kcal_goal'] as num?)?.toInt() ?? 2000,
      stepGoal: (json['stepGoal'] ?? json['step_goal'] as num?)?.toInt() ?? 10000,
      waterGoal: (json['waterGoal'] ?? json['water_goal'] as num?)?.toInt() ?? 2000,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'kcalGoal': kcalGoal,
      'stepGoal': stepGoal,
      'waterGoal': waterGoal,
    };
  }
}
