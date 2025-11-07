/// Project model
class Project {
  final String id;
  final String userId;
  final String? clientId;
  final String name;
  final String? description;
  final String status; // active, completed, on_hold, archived
  final double? hourlyRate;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Project({
    required this.id,
    required this.userId,
    this.clientId,
    required this.name,
    this.description,
    required this.status,
    this.hourlyRate,
    this.startDate,
    this.endDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      status: json['status'] as String,
      hourlyRate: json['hourly_rate'] != null 
          ? (json['hourly_rate'] as num).toDouble() 
          : null,
      startDate: json['start_date'] != null 
          ? DateTime.parse(json['start_date'] as String) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.parse(json['end_date'] as String) 
          : null,
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
      'client_id': clientId,
      'name': name,
      'description': description,
      'status': status,
      'hourly_rate': hourlyRate,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Project copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? name,
    String? description,
    String? status,
    double? hourlyRate,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Project(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      name: name ?? this.name,
      description: description ?? this.description,
      status: status ?? this.status,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Project status constants
class ProjectStatus {
  static const String active = 'active';
  static const String completed = 'completed';
  static const String onHold = 'on_hold';
  static const String archived = 'archived';

  static List<String> get all => [active, completed, onHold, archived];
  
  static String getLabel(String status) {
    switch (status) {
      case active:
        return 'Active';
      case completed:
        return 'Completed';
      case onHold:
        return 'On Hold';
      case archived:
        return 'Archived';
      default:
        return status;
    }
  }
}
