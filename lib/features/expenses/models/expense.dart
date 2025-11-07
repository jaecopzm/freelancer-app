import 'package:uuid/uuid.dart';

/// Expense model for tracking business expenses
class Expense {
  final String id;
  final String userId;
  final String? projectId;
  final String? clientId;
  final String category;
  final double amount;
  final String currency;
  final String description;
  final DateTime date;
  final String? receiptUrl;
  final bool isTaxDeductible;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Expense({
    required this.id,
    required this.userId,
    this.projectId,
    this.clientId,
    required this.category,
    required this.amount,
    required this.currency,
    required this.description,
    required this.date,
    this.receiptUrl,
    this.isTaxDeductible = true,
    this.notes,
    required this.createdAt,
    this.updatedAt,
  });

  factory Expense.create({
    required String userId,
    String? projectId,
    String? clientId,
    required String category,
    required double amount,
    required String currency,
    required String description,
    required DateTime date,
    String? receiptUrl,
    bool isTaxDeductible = true,
    String? notes,
  }) {
    return Expense(
      id: const Uuid().v4(),
      userId: userId,
      projectId: projectId,
      clientId: clientId,
      category: category,
      amount: amount,
      currency: currency,
      description: description,
      date: date,
      receiptUrl: receiptUrl,
      isTaxDeductible: isTaxDeductible,
      notes: notes,
      createdAt: DateTime.now(),
    );
  }

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      projectId: json['project_id'] as String?,
      clientId: json['client_id'] as String?,
      category: json['category'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
      description: json['description'] as String,
      date: DateTime.parse(json['date'] as String),
      receiptUrl: json['receipt_url'] as String?,
      isTaxDeductible: json['is_tax_deductible'] as bool? ?? true,
      notes: json['notes'] as String?,
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
      'category': category,
      'amount': amount,
      'currency': currency,
      'description': description,
      'date': date.toIso8601String(),
      'receipt_url': receiptUrl,
      'is_tax_deductible': isTaxDeductible,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Expense copyWith({
    String? id,
    String? userId,
    String? projectId,
    String? clientId,
    String? category,
    double? amount,
    String? currency,
    String? description,
    DateTime? date,
    String? receiptUrl,
    bool? isTaxDeductible,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Expense(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      projectId: projectId ?? this.projectId,
      clientId: clientId ?? this.clientId,
      category: category ?? this.category,
      amount: amount ?? this.amount,
      currency: currency ?? this.currency,
      description: description ?? this.description,
      date: date ?? this.date,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      isTaxDeductible: isTaxDeductible ?? this.isTaxDeductible,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

/// Expense categories
class ExpenseCategory {
  static const String software = 'Software & Subscriptions';
  static const String equipment = 'Equipment & Hardware';
  static const String office = 'Office Supplies';
  static const String travel = 'Travel & Transportation';
  static const String meals = 'Meals & Entertainment';
  static const String marketing = 'Marketing & Advertising';
  static const String education = 'Education & Training';
  static const String professional = 'Professional Services';
  static const String utilities = 'Utilities & Internet';
  static const String insurance = 'Insurance';
  static const String taxes = 'Taxes & Fees';
  static const String other = 'Other';

  static List<String> get all => [
    software,
    equipment,
    office,
    travel,
    meals,
    marketing,
    education,
    professional,
    utilities,
    insurance,
    taxes,
    other,
  ];

  static String getIcon(String category) {
    switch (category) {
      case software:
        return '💻';
      case equipment:
        return '🖥️';
      case office:
        return '📎';
      case travel:
        return '✈️';
      case meals:
        return '🍽️';
      case marketing:
        return '📢';
      case education:
        return '📚';
      case professional:
        return '👔';
      case utilities:
        return '🔌';
      case insurance:
        return '🛡️';
      case taxes:
        return '💰';
      default:
        return '📝';
    }
  }
}
