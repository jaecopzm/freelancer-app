/// Payment model for tracking invoice payments
class Payment {
  final String id;
  final String invoiceId;
  final double amount;
  final DateTime paymentDate;
  final String
  paymentMethod; // cash, check, bank_transfer, credit_card, paypal, etc.
  final String? reference; // check number, transaction ID, etc.
  final String? notes;
  final DateTime createdAt;

  const Payment({
    required this.id,
    required this.invoiceId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMethod,
    this.reference,
    this.notes,
    required this.createdAt,
  });

  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['id'] as String,
      invoiceId: json['invoice_id'] as String,
      amount: (json['amount'] as num).toDouble(),
      paymentDate: DateTime.parse(json['payment_date'] as String),
      paymentMethod: json['payment_method'] as String,
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'amount': amount,
      'payment_date': paymentDate.toIso8601String(),
      'payment_method': paymentMethod,
      'reference': reference,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

/// Payment method constants
class PaymentMethod {
  static const String cash = 'cash';
  static const String check = 'check';
  static const String bankTransfer = 'bank_transfer';
  static const String creditCard = 'credit_card';
  static const String paypal = 'paypal';
  static const String stripe = 'stripe';
  static const String other = 'other';

  static List<String> get all => [
    cash,
    check,
    bankTransfer,
    creditCard,
    paypal,
    stripe,
    other,
  ];

  static String getLabel(String method) {
    switch (method) {
      case cash:
        return 'Cash';
      case check:
        return 'Check';
      case bankTransfer:
        return 'Bank Transfer';
      case creditCard:
        return 'Credit Card';
      case paypal:
        return 'PayPal';
      case stripe:
        return 'Stripe';
      case other:
        return 'Other';
      default:
        return method;
    }
  }
}
