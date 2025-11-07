import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';
import '../models/invoice.dart';
import '../../settings/models/user_settings.dart';

class PdfService {
  /// Generate PDF for invoice with enhanced styling
  Future<pw.Document> generateInvoicePdf(
    Invoice invoice,
    List<InvoiceItem> items,
    UserSettings? settings,
    String? clientName,
  ) async {
    final pdf = pw.Document();

    // Load custom font for better typography (optional)
    final fontBold = await PdfGoogleFonts.robotoMedium();
    final fontRegular = await PdfGoogleFonts.robotoRegular();

    final theme = pw.ThemeData.withFont(
      base: fontRegular,
      bold: fontBold,
    );

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: theme,
        build: (context) => [
          _buildEnhancedHeader(settings),
          pw.SizedBox(height: 30),
          _buildInvoiceInfo(invoice, clientName),
          pw.SizedBox(height: 30),
          _buildEnhancedLineItems(items),
          pw.SizedBox(height: 25),
          _buildEnhancedTotals(invoice),
          pw.SizedBox(height: 30),
          if (invoice.notes != null && invoice.notes!.isNotEmpty)
            _buildNotes(invoice.notes!),
          if (invoice.paymentTerms != null && invoice.paymentTerms!.isNotEmpty)
            _buildPaymentTerms(invoice.paymentTerms!),
          pw.SizedBox(height: 20),
          _buildPaymentInstructions(settings),
        ],
        footer: (context) => _buildEnhancedFooter(settings, context),
      ),
    );

    return pdf;
  }

  /// Enhanced header with logo support and better layout
  pw.Widget _buildEnhancedHeader(UserSettings? settings) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border(
          bottom: pw.BorderSide(
            color: PdfColors.blue700,
            width: 3,
          ),
        ),
      ),
      padding: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  settings?.businessName ?? 'Your Business',
                  style: pw.TextStyle(
                    fontSize: 26,
                    fontWeight: pw.FontWeight.bold,
                    color: PdfColors.blue900,
                  ),
                ),
                pw.SizedBox(height: 8),
                if (settings?.businessEmail != null)
                  _buildInfoRow('Email', settings!.businessEmail!),
                if (settings?.businessPhone != null)
                  _buildInfoRow('Phone', settings!.businessPhone!),
                if (settings?.businessAddress != null) ...[
                  pw.SizedBox(height: 4),
                  pw.Text(
                    settings!.businessAddress!,
                    style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ],
              ],
            ),
          ),
          pw.Container(
            padding: const pw.EdgeInsets.all(15),
            decoration: pw.BoxDecoration(
              color: PdfColors.blue700,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Text(
              'INVOICE',
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildInfoRow(String label, String value) {
    return pw.Row(
      children: [
        pw.Text(
          '$label: ',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey800,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
        ),
      ],
    );
  }

  /// Enhanced invoice info with better status indicators
  pw.Widget _buildInvoiceInfo(Invoice invoice, String? clientName) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(8),
      ),
      padding: const pw.EdgeInsets.all(16),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Expanded(
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.blue700,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    'BILL TO',
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 10,
                      color: PdfColors.white,
                    ),
                  ),
                ),
                pw.SizedBox(height: 8),
                pw.Text(
                  clientName ?? 'Client',
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                'Invoice #${invoice.invoiceNumber}',
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              pw.SizedBox(height: 6),
              _buildDateRow(
                'Issue Date',
                DateFormat('MMM d, y').format(invoice.issueDate),
              ),
              _buildDateRow(
                'Due Date',
                DateFormat('MMM d, y').format(invoice.dueDate),
              ),
              if (invoice.isOverdue) ...[
                pw.SizedBox(height: 6),
                pw.Container(
                  padding: const pw.EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: pw.BoxDecoration(
                    color: PdfColors.red,
                    borderRadius: pw.BorderRadius.circular(4),
                  ),
                  child: pw.Text(
                    '⚠ OVERDUE',
                    style: pw.TextStyle(
                      color: PdfColors.white,
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  pw.Widget _buildDateRow(String label, String date) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 3),
      child: pw.Row(
        mainAxisSize: pw.MainAxisSize.min,
        children: [
          pw.Text(
            '$label: ',
            style: pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
          ),
          pw.Text(
            date,
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Enhanced line items table with better styling
  pw.Widget _buildEnhancedLineItems(List<InvoiceItem> items) {
    return pw.Table(
      border: pw.TableBorder.all(
        color: PdfColors.grey300,
        width: 1,
      ),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.5),
        3: const pw.FlexColumnWidth(1.5),
      },
      children: [
        // Header
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.blue700),
          children: [
            _buildTableCell('Description', isHeader: true, isWhite: true),
            _buildTableCell(
              'Qty',
              isHeader: true,
              align: pw.TextAlign.center,
              isWhite: true,
            ),
            _buildTableCell(
              'Rate',
              isHeader: true,
              align: pw.TextAlign.right,
              isWhite: true,
            ),
            _buildTableCell(
              'Amount',
              isHeader: true,
              align: pw.TextAlign.right,
              isWhite: true,
            ),
          ],
        ),
        // Items with alternating row colors
        ...items.asMap().entries.map(
              (entry) => pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: entry.key % 2 == 0
                      ? PdfColors.white
                      : PdfColors.grey50,
                ),
                children: [
                  _buildTableCell(entry.value.description),
                  _buildTableCell(
                    entry.value.quantity.toString(),
                    align: pw.TextAlign.center,
                  ),
                  _buildTableCell(
                    '\$${entry.value.rate.toStringAsFixed(2)}',
                    align: pw.TextAlign.right,
                  ),
                  _buildTableCell(
                    '\$${entry.value.amount.toStringAsFixed(2)}',
                    align: pw.TextAlign.right,
                  ),
                ],
              ),
            ),
      ],
    );
  }

  pw.Widget _buildTableCell(
    String text, {
    bool isHeader = false,
    bool isWhite = false,
    pw.TextAlign align = pw.TextAlign.left,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(10),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontWeight: isHeader ? pw.FontWeight.bold : pw.FontWeight.normal,
          fontSize: isHeader ? 11 : 10,
          color: isWhite ? PdfColors.white : PdfColors.black,
        ),
        textAlign: align,
      ),
    );
  }

  /// Enhanced totals with better visual hierarchy
  pw.Widget _buildEnhancedTotals(Invoice invoice) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 250,
          decoration: pw.BoxDecoration(
            border: pw.Border.all(color: PdfColors.grey300),
            borderRadius: pw.BorderRadius.circular(8),
          ),
          padding: const pw.EdgeInsets.all(15),
          child: pw.Column(
            children: [
              _buildTotalRow('Subtotal', invoice.subtotal),
              _buildTotalRow('Tax (${invoice.taxRate}%)', invoice.taxAmount),
              pw.Divider(thickness: 2, color: PdfColors.blue700),
              _buildTotalRow('Total', invoice.total, isTotal: true),
            ],
          ),
        ),
      ],
    );
  }

  pw.Widget _buildTotalRow(
    String label,
    double amount, {
    bool isTotal = false,
  }) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 5),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontWeight: isTotal ? pw.FontWeight.bold : pw.FontWeight.normal,
              fontSize: isTotal ? 16 : 12,
              color: isTotal ? PdfColors.blue900 : PdfColors.black,
            ),
          ),
          pw.Text(
            '\$${amount.toStringAsFixed(2)}',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: isTotal ? 18 : 12,
              color: isTotal ? PdfColors.blue900 : PdfColors.black,
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildNotes(String notes) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.yellow50,
        border: pw.Border.all(color: PdfColors.yellow200),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Notes:',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(notes, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  pw.Widget _buildPaymentTerms(String terms) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 12),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Payment Terms:',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 12,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(terms, style: const pw.TextStyle(fontSize: 10)),
        ],
      ),
    );
  }

  /// Payment instructions section
  pw.Widget _buildPaymentInstructions(UserSettings? settings) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Payment Instructions:',
            style: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              fontSize: 11,
            ),
          ),
          pw.SizedBox(height: 6),
          pw.Text(
            'Please make payment to the business address listed above or contact us for alternative payment methods.',
            style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
          ),
        ],
      ),
    );
  }

  /// Enhanced footer with page numbers
  pw.Widget _buildEnhancedFooter(
    UserSettings? settings,
    pw.Context context,
  ) {
    return pw.Container(
      alignment: pw.Alignment.center,
      margin: const pw.EdgeInsets.only(top: 20),
      child: pw.Column(
        children: [
          pw.Divider(color: PdfColors.blue700, thickness: 2),
          pw.SizedBox(height: 10),
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                'Thank you for your business!',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
              pw.Text(
                'Page ${context.pageNumber} of ${context.pagesCount}',
                style: const pw.TextStyle(fontSize: 9, color: PdfColors.grey700),
              ),
            ],
          ),
          if (settings?.website != null) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              settings!.website!,
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColors.blue700,
                decoration: pw.TextDecoration.underline,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Save PDF to file
  Future<File> savePdf(pw.Document pdf, String filename) async {
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$filename.pdf');
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  /// Print PDF
  Future<void> printPdf(pw.Document pdf) async {
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  }

  /// Share PDF
  Future<void> sharePdf(pw.Document pdf, String filename) async {
    await Printing.sharePdf(bytes: await pdf.save(), filename: '$filename.pdf');
  }

  /// Generate and save invoice PDF in one step
  Future<File> generateAndSaveInvoice(
    Invoice invoice,
    List<InvoiceItem> items,
    UserSettings? settings,
    String? clientName,
  ) async {
    final pdf = await generateInvoicePdf(invoice, items, settings, clientName);
    return await savePdf(pdf, 'invoice_${invoice.invoiceNumber}');
  }

  /// Preview PDF before saving/sharing
  Future<void> previewPdf(pw.Document pdf) async {
    await Printing.layoutPdf(
      onLayout: (format) async => pdf.save(),
      name: 'Invoice Preview',
    );
  }
}