/// Invoice model
class Invoice {
  final String id;
  final String userId;
  final String? clientId;
  final String? projectId;
  final String invoiceNumber;
  final String status; // draft, sent, paid, overdue, cancelled
  final DateTime issueDate;
  final DateTime dueDate;
  final double subtotal;
  final double taxRate;
  final double taxAmount;
  final double total;
  final String? notes;
  final String? paymentTerms;
  final DateTime? paidDate;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Invoice({
    required this.id,
    required this.userId,
    this.clientId,
    this.projectId,
    required this.invoiceNumber,
    required this.status,
    required this.issueDate,
    required this.dueDate,
    required this.subtotal,
    required this.taxRate,
    required this.taxAmount,
    required this.total,
    this.notes,
    this.paymentTerms,
    this.paidDate,
    required this.createdAt,
    this.updatedAt,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) {
    return Invoice(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      clientId: json['client_id'] as String?,
      projectId: json['project_id'] as String?,
      invoiceNumber: json['invoice_number'] as String,
      status: json['status'] as String,
      issueDate: DateTime.parse(json['issue_date'] as String),
      dueDate: DateTime.parse(json['due_date'] as String),
      subtotal: (json['subtotal'] as num).toDouble(),
      taxRate: (json['tax_rate'] as num).toDouble(),
      taxAmount: (json['tax_amount'] as num).toDouble(),
      total: (json['total'] as num).toDouble(),
      notes: json['notes'] as String?,
      paymentTerms: json['payment_terms'] as String?,
      paidDate: json['paid_date'] != null
          ? DateTime.parse(json['paid_date'] as String)
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
      'project_id': projectId,
      'invoice_number': invoiceNumber,
      'status': status,
      'issue_date': issueDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'subtotal': subtotal,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'total': total,
      'notes': notes,
      'payment_terms': paymentTerms,
      'paid_date': paidDate?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  Invoice copyWith({
    String? id,
    String? userId,
    String? clientId,
    String? projectId,
    String? invoiceNumber,
    String? status,
    DateTime? issueDate,
    DateTime? dueDate,
    double? subtotal,
    double? taxRate,
    double? taxAmount,
    double? total,
    String? notes,
    String? paymentTerms,
    DateTime? paidDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Invoice(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      clientId: clientId ?? this.clientId,
      projectId: projectId ?? this.projectId,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      status: status ?? this.status,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      subtotal: subtotal ?? this.subtotal,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      total: total ?? this.total,
      notes: notes ?? this.notes,
      paymentTerms: paymentTerms ?? this.paymentTerms,
      paidDate: paidDate ?? this.paidDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool get isOverdue {
    if (status == InvoiceStatus.paid) return false;
    return DateTime.now().isAfter(dueDate);
  }

  int get daysUntilDue {
    return dueDate.difference(DateTime.now()).inDays;
  }

  int get daysOverdue {
    if (!isOverdue) return 0;
    return DateTime.now().difference(dueDate).inDays;
  }
}

/// Invoice status constants
class InvoiceStatus {
  static const String draft = 'draft';
  static const String sent = 'sent';
  static const String paid = 'paid';
  static const String overdue = 'overdue';
  static const String cancelled = 'cancelled';

  static List<String> get all => [draft, sent, paid, overdue, cancelled];

  static String getLabel(String status) {
    switch (status) {
      case draft:
        return 'Draft';
      case sent:
        return 'Sent';
      case paid:
        return 'Paid';
      case overdue:
        return 'Overdue';
      case cancelled:
        return 'Cancelled';
      default:
        return status;
    }
  }
}

/// Invoice line item model
class InvoiceItem {
  final String id;
  final String invoiceId;
  final String description;
  final double quantity;
  final double rate;
  final double amount;
  final int sortOrder;

  const InvoiceItem({
    required this.id,
    required this.invoiceId,
    required this.description,
    required this.quantity,
    required this.rate,
    required this.amount,
    this.sortOrder = 0,
  });

  factory InvoiceItem.fromJson(Map<String, dynamic> json) {
    return InvoiceItem(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      sortOrder: json['sort_order'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'description': description,
      'quantity': quantity,
      'rate': rate,
      'amount': amount,
      'sort_order': sortOrder,
    };
  }

  InvoiceItem copyWith({
    String? id,
    String? invoiceId,
    String? description,
    double? quantity,
    double? rate,
    double? amount,
    int? sortOrder,
  }) {
    return InvoiceItem(
      id: id ?? this.id,
      invoiceId: invoiceId ?? this.invoiceId,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
      rate: rate ?? this.rate,
      amount: amount ?? this.amount,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
