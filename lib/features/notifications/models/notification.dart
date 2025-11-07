import 'package:uuid/uuid.dart';

/// Notification model for in-app notifications
class AppNotification {
  final String id;
  final String userId;
  final String type;
  final String title;
  final String message;
  final String? actionUrl;
  final Map<String, dynamic>? metadata;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.actionUrl,
    this.metadata,
    this.isRead = false,
    required this.createdAt,
    this.readAt,
  });

  factory AppNotification.create({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
  }) {
    return AppNotification(
      id: const Uuid().v4(),
      userId: userId,
      type: type,
      title: title,
      message: message,
      actionUrl: actionUrl,
      metadata: metadata,
      createdAt: DateTime.now(),
    );
  }

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      type: json['type'] as String,
      title: json['title'] as String,
      message: json['message'] as String,
      actionUrl: json['action_url'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      readAt: json['read_at'] != null
          ? DateTime.parse(json['read_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'type': type,
      'title': title,
      'message': message,
      'action_url': actionUrl,
      'metadata': metadata,
      'is_read': isRead,
      'created_at': createdAt.toIso8601String(),
      'read_at': readAt?.toIso8601String(),
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? actionUrl,
    Map<String, dynamic>? metadata,
    bool? isRead,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      actionUrl: actionUrl ?? this.actionUrl,
      metadata: metadata ?? this.metadata,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}

/// Notification types
class NotificationType {
  static const String invoiceOverdue = 'invoice_overdue';
  static const String invoicePaid = 'invoice_paid';
  static const String paymentReceived = 'payment_received';
  static const String lowActivity = 'low_activity';
  static const String goalAchieved = 'goal_achieved';
  static const String goalProgress = 'goal_progress';
  static const String projectDeadline = 'project_deadline';
  static const String weeklySummary = 'weekly_summary';
  static const String monthlyReport = 'monthly_report';
  static const String clientInactive = 'client_inactive';
  static const String expenseReminder = 'expense_reminder';
}
