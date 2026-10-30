class DailyLog {
  final String userId;
  final String logDate;
  final int steps;
  final int waterMl;

  const DailyLog({
    required this.userId,
    required this.logDate,
    this.steps = 0,
    this.waterMl = 0,
  });

  factory DailyLog.fromJson(Map<String, dynamic> json) {
    return DailyLog(
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),
      logDate: (json['logDate'] ?? json['log_date'] ?? '').toString(),
      steps: (json['steps'] as num?)?.toInt() ?? 0,
      waterMl: (json['waterMl'] ?? json['water_ml'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'logDate': logDate,
      'steps': steps,
      'waterMl': waterMl,
    };
  }
}
