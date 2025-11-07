import 'dart:io';
import 'package:url_launcher/url_launcher.dart';
import '../models/invoice.dart';

class EmailService {
  /// Send invoice via email
  Future<bool> sendInvoiceEmail({
    required String recipientEmail,
    required Invoice invoice,
    File? pdfAttachment,
    String? customMessage,
  }) async {
    final subject = Uri.encodeComponent(
      'Invoice ${invoice.invoiceNumber} from Your Business',
    );

    final body = Uri.encodeComponent(
      customMessage ??
          '''
Hello,

Please find attached invoice ${invoice.invoiceNumber} for \$${invoice.total.toStringAsFixed(2)}.

Invoice Details:
- Invoice Number: ${invoice.invoiceNumber}
- Amount: \$${invoice.total.toStringAsFixed(2)}
- Due Date: ${invoice.dueDate.toString().split(' ')[0]}

${invoice.notes ?? ''}

Thank you for your business!

Best regards
''',
    );

    // For mobile/desktop, open default email client
    final emailUri = Uri.parse(
      'mailto:$recipientEmail?subject=$subject&body=$body',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return true;
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      throw Exception('Failed to send email: ${e.toString()}');
    }
  }

  /// Send payment reminder
  Future<bool> sendPaymentReminder({
    required String recipientEmail,
    required Invoice invoice,
  }) async {
    final subject = Uri.encodeComponent(
      'Payment Reminder: Invoice ${invoice.invoiceNumber}',
    );

    final daysOverdue = invoice.daysOverdue;
    final body = Uri.encodeComponent('''
Hello,

This is a friendly reminder that invoice ${invoice.invoiceNumber} is ${daysOverdue > 0 ? '$daysOverdue days overdue' : 'due soon'}.

Invoice Details:
- Invoice Number: ${invoice.invoiceNumber}
- Amount: \$${invoice.total.toStringAsFixed(2)}
- Due Date: ${invoice.dueDate.toString().split(' ')[0]}
- Status: ${invoice.isOverdue ? 'OVERDUE' : 'Due'}

Please process payment at your earliest convenience.

Thank you!

Best regards
''');

    final emailUri = Uri.parse(
      'mailto:$recipientEmail?subject=$subject&body=$body',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return true;
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      throw Exception('Failed to send reminder: ${e.toString()}');
    }
  }

  /// Send thank you email after payment
  Future<bool> sendThankYouEmail({
    required String recipientEmail,
    required Invoice invoice,
  }) async {
    final subject = Uri.encodeComponent(
      'Payment Received: Invoice ${invoice.invoiceNumber}',
    );

    final body = Uri.encodeComponent('''
Hello,

Thank you for your payment!

We have received your payment of \$${invoice.total.toStringAsFixed(2)} for invoice ${invoice.invoiceNumber}.

Payment Details:
- Invoice Number: ${invoice.invoiceNumber}
- Amount Paid: \$${invoice.total.toStringAsFixed(2)}
- Payment Date: ${invoice.paidDate?.toString().split(' ')[0] ?? 'Today'}

We appreciate your business and look forward to working with you again!

Best regards
''');

    final emailUri = Uri.parse(
      'mailto:$recipientEmail?subject=$subject&body=$body',
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
        return true;
      } else {
        throw Exception('Could not launch email client');
      }
    } catch (e) {
      throw Exception('Failed to send thank you email: ${e.toString()}');
    }
  }
}
