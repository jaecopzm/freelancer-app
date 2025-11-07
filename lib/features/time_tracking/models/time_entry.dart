/// Time entry model
class TimeEntry {
  final String id;
  final String userId;
  final String? projectId;
  final String? clientId;
  final String description;
  final DateTime startTime;
  final DateTime? endTime;
  final int? durationSeconds;
  final bool isRunning;
  final double? hourlyRate;
  final double? amount;
  final String? tags;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const TimeEntry({
    required this.id,
    required this.userId,
    this.projectId,
    this.clientId,
    required this.description,
    required this.startTime,
    this.endTime,
    this.durationSeconds,
    required this.isRunning,
    this.hourlyRate,
    this.amount,
    this.tags,
    required this.createdAt,
    this.updatedAt,
  });

  factory TimeEntry.fromJson(Map<String, dynamic> json) {
    return TimeEntry(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String?,
      clientId: json['client_id'] as String?,
      description: json['description'] as String,
      startTime: DateTime.parse(json['start_time'] as String),
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'] as String)
          : null,
      durationSeconds: json['duration_seconds'] as int?,
      isRunning: json['is_running'] as bool,
      hourlyRate: json['hourly_rate'] != null
          ? (json['hourly_rate'] as num).toDouble()
          : null,
      amount: json['amount'] != null
          ? (json['amount'] as num).toDouble()
          : null,
      tags: json['tags'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'project_id': projectId,
      'client_id': clientId,
      'description': description,
      'start_time': startTime.toIso8601String(),
      'end_time': endTime?.toIso8601String(),
      'duration_seconds': durationSeconds,
      'is_running': isRunning,
      'hourly_rate': hourlyRate,
      'amount': amount,
      'tags': tags,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  TimeEntry copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? clientId,
    String? description,
    DateTime? startTime,
    DateTime? endTime,
    int? durationSeconds,
    bool? isRunning,
    double? hourlyRate,
    double? amount,
    String? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TimeEntry(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      clientId: clientId ?? this.clientId,
      description: description ?? this.description,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      isRunning: isRunning ?? this.isRunning,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      amount: amount ?? this.amount,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Get duration in hours
  double get durationHours {
    if (durationSeconds == null) return 0;
    return durationSeconds! / 3600;
  }

  /// Get formatted duration (HH:MM:SS)
  String get formattedDuration {
    if (durationSeconds == null) return '00:00:00';
    final hours = durationSeconds! ~/ 3600;
    final minutes = (durationSeconds! % 3600) ~/ 60;
    final seconds = durationSeconds! % 60;
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get current running duration
  int get currentDuration {
    if (!isRunning) return durationSeconds ?? 0;
    final now = DateTime.now();
    return now.difference(startTime).inSeconds;
  }

  /// Calculate amount based on duration and hourly rate
  double calculateAmount() {
    if (hourlyRate == null || durationSeconds == null) return 0;
    return durationHours * hourlyRate!;
  }
}

/// Time entry statistics
class TimeStats {
  final double totalHours;
  final double billableHours;
  final double totalAmount;
  final int totalEntries;
  final Map<String, double> hoursByProject;
  final Map<String, double> hoursByClient;

  const TimeStats({
    required this.totalHours,
    required this.billableHours,
    required this.totalAmount,
    required this.totalEntries,
    required this.hoursByProject,
    required this.hoursByClient,
  });

  factory TimeStats.empty() {
    return const TimeStats(
      totalHours: 0,
      billableHours: 0,
      totalAmount: 0,
      totalEntries: 0,
      hoursByProject: {},
      hoursByClient: {},
    );
  }
}
