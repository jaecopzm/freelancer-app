/// User settings model
class UserSettings {
  final String userId;
  final String? businessName;
  final String? businessEmail;
  final String? businessPhone;
  final String? businessAddress;
  final String? taxId;
  final String? website;
  final String? currency;
  final double? defaultHourlyRate;
  final int? defaultPaymentTerms; // days
  final double? defaultTaxRate;
  final String? invoicePrefix;
  final int? invoiceStartNumber;
  final String? timeFormat; // 12h or 24h
  final String? dateFormat;
  final bool? emailNotifications;
  final bool? pushNotifications;
  final bool? reminderNotifications;
  final String? theme; // light, dark, system
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const UserSettings({
    required this.userId,
    this.businessName,
    this.businessEmail,
    this.businessPhone,
    this.businessAddress,
    this.taxId,
    this.website,
    this.currency,
    this.defaultHourlyRate,
    this.defaultPaymentTerms,
    this.defaultTaxRate,
    this.invoicePrefix,
    this.invoiceStartNumber,
    this.timeFormat,
    this.dateFormat,
    this.emailNotifications,
    this.pushNotifications,
    this.reminderNotifications,
    this.theme,
    this.createdAt,
    this.updatedAt,
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      userId: json['user_id'] as String,
      businessName: json['business_name'] as String?,
      businessEmail: json['business_email'] as String?,
      businessPhone: json['business_phone'] as String?,
      businessAddress: json['business_address'] as String?,
      taxId: json['tax_id'] as String?,
      website: json['website'] as String?,
      currency: json['currency'] as String?,
      defaultHourlyRate: json['default_hourly_rate'] != null
          ? (json['default_hourly_rate'] as num).toDouble()
          : null,
      defaultPaymentTerms: json['default_payment_terms'] as int?,
      defaultTaxRate: json['default_tax_rate'] != null
          ? (json['default_tax_rate'] as num).toDouble()
          : null,
      invoicePrefix: json['invoice_prefix'] as String?,
      invoiceStartNumber: json['invoice_start_number'] as int?,
      timeFormat: json['time_format'] as String?,
      dateFormat: json['date_format'] as String?,
      emailNotifications: json['email_notifications'] as bool?,
      pushNotifications: json['push_notifications'] as bool?,
      reminderNotifications: json['reminder_notifications'] as bool?,
      theme: json['theme'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'business_name': businessName,
      'business_email': businessEmail,
      'business_phone': businessPhone,
      'business_address': businessAddress,
      'tax_id': taxId,
      'website': website,
      'currency': currency,
      'default_hourly_rate': defaultHourlyRate,
      'default_payment_terms': defaultPaymentTerms,
      'default_tax_rate': defaultTaxRate,
      'invoice_prefix': invoicePrefix,
      'invoice_start_number': invoiceStartNumber,
      'time_format': timeFormat,
      'date_format': dateFormat,
      'email_notifications': emailNotifications,
      'push_notifications': pushNotifications,
      'reminder_notifications': reminderNotifications,
      'theme': theme,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  UserSettings copyWith({
    String? userId,
    String? businessName,
    String? businessEmail,
    String? businessPhone,
    String? businessAddress,
    String? taxId,
    String? website,
    String? currency,
    double? defaultHourlyRate,
    int? defaultPaymentTerms,
    double? defaultTaxRate,
    String? invoicePrefix,
    int? invoiceStartNumber,
    String? timeFormat,
    String? dateFormat,
    bool? emailNotifications,
    bool? pushNotifications,
    bool? reminderNotifications,
    String? theme,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      userId: userId ?? this.userId,
      businessName: businessName ?? this.businessName,
      businessEmail: businessEmail ?? this.businessEmail,
      businessPhone: businessPhone ?? this.businessPhone,
      businessAddress: businessAddress ?? this.businessAddress,
      taxId: taxId ?? this.taxId,
      website: website ?? this.website,
      currency: currency ?? this.currency,
      defaultHourlyRate: defaultHourlyRate ?? this.defaultHourlyRate,
      defaultPaymentTerms: defaultPaymentTerms ?? this.defaultPaymentTerms,
      defaultTaxRate: defaultTaxRate ?? this.defaultTaxRate,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      invoiceStartNumber: invoiceStartNumber ?? this.invoiceStartNumber,
      timeFormat: timeFormat ?? this.timeFormat,
      dateFormat: dateFormat ?? this.dateFormat,
      emailNotifications: emailNotifications ?? this.emailNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      reminderNotifications:
          reminderNotifications ?? this.reminderNotifications,
      theme: theme ?? this.theme,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory UserSettings.defaults(String userId) {
    return UserSettings(
      userId: userId,
      currency: 'USD',
      defaultPaymentTerms: 30,
      defaultTaxRate: 0,
      invoicePrefix: 'INV',
      invoiceStartNumber: 1,
      timeFormat: '12h',
      dateFormat: 'MM/dd/yyyy',
      emailNotifications: true,
      pushNotifications: true,
      reminderNotifications: true,
      theme: 'system',
    );
  }
}
