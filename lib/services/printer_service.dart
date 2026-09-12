import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import '../data/models/invoice.dart';

enum PrinterPaperSize {
  mm58,
  mm80,
}

class PrinterService {
  PrinterService._();

  static final PrinterService instance = PrinterService._();

  PrinterPaperSize paperSize = PrinterPaperSize.mm80;

  pw.Font? _regularFont;
  pw.Font? _boldFont;

  Future<void> _loadFonts() async {
    if (_regularFont != null && _boldFont != null) {
      return;
    }

    final regularData =
    await rootBundle.load('assets/fonts/Cairo-Regular.ttf');

    final boldData =
    await rootBundle.load('assets/fonts/Cairo-Bold.ttf');

    _regularFont = pw.Font.ttf(regularData);
    _boldFont = pw.Font.ttf(boldData);
  }

  PdfPageFormat get pageFormat {
    switch (paperSize) {
      case PrinterPaperSize.mm58:
        return PdfPageFormat(
          58 * PdfPageFormat.mm,
          250 * PdfPageFormat.mm,
          marginLeft: 5 * PdfPageFormat.mm,
          marginRight: 5 * PdfPageFormat.mm,
          marginTop: 5 * PdfPageFormat.mm,
          marginBottom: 5 * PdfPageFormat.mm,
        );

      case PrinterPaperSize.mm80:
        return PdfPageFormat(
          80 * PdfPageFormat.mm,
          250 * PdfPageFormat.mm,
          marginLeft: 6 * PdfPageFormat.mm,
          marginRight: 6 * PdfPageFormat.mm,
          marginTop: 5 * PdfPageFormat.mm,
          marginBottom: 5 * PdfPageFormat.mm,
        );
    }
  }

  Future<Uint8List> generateInvoicePdf(Invoice invoice) async {
    await _loadFonts();

    final regularFont = _regularFont!;
    final boldFont = _boldFont!;

    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: pageFormat,

        textDirection: pw.TextDirection.rtl,

        theme: pw.ThemeData.withFont(
          base: regularFont,
          bold: boldFont,
        ),


        build: (context) {
          return [
            _buildHeader(invoice, regularFont, boldFont),

            pw.SizedBox(height: 8),

            _buildInvoiceInfo(invoice, regularFont, boldFont),

            pw.SizedBox(height: 8),

            _buildItemsTable(
              invoice,
              regularFont,
              boldFont,
            ),

            pw.SizedBox(height: 10),

            _buildTotals(
              invoice,
              regularFont,
              boldFont,
            ),

            pw.SizedBox(height: 12),

            _buildFooter(
              regularFont,
              boldFont,
            ),
          ];
        },
      ),
    );

    return pdf.save();
  }


  pw.Widget _buildHeader(
      Invoice invoice,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 4),

        pw.Text(
          'منظفات الأمير',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 16,
          ),
        ),

        pw.SizedBox(height: 3),

        pw.Text(
          'فاتورة مبيعات',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 11,
          ),
        ),

        pw.SizedBox(height: 7),

        pw.Divider(
          thickness: 0.7,
        ),
      ],
    );
  }

  pw.Widget _buildInvoiceInfo(
      Invoice invoice,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 2,
      ),
      child: pw.Column(
        children: [
          _infoRow(
            'رقم الفاتورة',
            invoice.invoiceNumber,
            regularFont,
            boldFont,
          ),

          pw.SizedBox(height: 5),

          _infoRow(
            'التاريخ',
            _formatDate(invoice.date),
            regularFont,
            boldFont,
          ),
        ],
      ),
    );
  }

  pw.Widget _infoRow(
      String title,
      String value,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    return pw.Row(
      children: [
        pw.Expanded(
          flex: 2,
          child: pw.Text(
            title,
            textAlign: pw.TextAlign.right,
            style: pw.TextStyle(
              font: boldFont,
              fontSize: 9,
            ),
          ),
        ),

        pw.SizedBox(width: 8),

        pw.Expanded(
          flex: 3,
          child: pw.Text(
            value,
            textAlign: pw.TextAlign.left,
            style: pw.TextStyle(
              font: regularFont,
              fontSize: 9,
            ),
          ),
        ),
      ],
    );
  }

  pw.Widget _buildItemsTable(
      Invoice invoice,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    final headers = [
      'المنتج',
      'الكمية',
      'السعر',
      'الإجمالي',
    ];

    final data = invoice.items.map((item) {
      return [
        item.productName,
        item.quantity.toString(),
        _formatMoney(item.unitPrice),
        _formatMoney(item.subtotal),
      ];
    }).toList();

    return pw.TableHelper.fromTextArray(
      headers: headers,

      data: data,

      headerStyle: pw.TextStyle(
        font: boldFont,
        fontSize: 8,
      ),

      cellStyle: pw.TextStyle(
        font: regularFont,
        fontSize: 8,
      ),

      headerDecoration: const pw.BoxDecoration(
        color: PdfColors.grey300,
      ),

      cellAlignment: pw.Alignment.center,

      headerAlignment: pw.Alignment.center,

      border: pw.TableBorder.all(
        width: 0.5,
        color: PdfColors.black,
      ),

      cellPadding: const pw.EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 4,
      ),

      columnWidths: {
        0: const pw.FlexColumnWidth(2.5),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.3),
        3: const pw.FlexColumnWidth(1.5),
      },
    );
  }

  pw.Widget _buildTotals(
      Invoice invoice,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    final remaining =
        invoice.total - invoice.paidAmount;

    return pw.Column(
      children: [
        _totalRow(
          'الإجمالي',
          _formatMoney(invoice.total),
          regularFont,
          boldFont,
        ),

        if (invoice.discount > 0) ...[
          pw.SizedBox(height: 4),

          _totalRow(
            'الخصم',
            _formatMoney(invoice.discount),
            regularFont,
            boldFont,
          ),
        ],

        pw.SizedBox(height: 4),

        _totalRow(
          'المدفوع',
          _formatMoney(invoice.paidAmount),
          regularFont,
          boldFont,
        ),

        pw.SizedBox(height: 4),

        _totalRow(
          'المتبقي',
          _formatMoney(remaining),
          regularFont,
          boldFont,
        ),

        pw.SizedBox(height: 8),

        pw.Divider(
          thickness: 1,
        ),

        pw.SizedBox(height: 5),

        pw.Row(
          mainAxisAlignment:
          pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(
              'إجمالي الفاتورة',
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 12,
              ),
            ),

            pw.Text(
              _formatMoney(invoice.total),
              style: pw.TextStyle(
                font: boldFont,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _totalRow(
      String title,
      String value,
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    return pw.Row(
      mainAxisAlignment:
      pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 9,
          ),
        ),

        pw.Text(
          value,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 9,
          ),
        ),
      ],
    );
  }

  pw.Widget _buildFooter(
      pw.Font regularFont,
      pw.Font boldFont,
      ) {
    return pw.Column(
      children: [
        pw.Divider(
          thickness: 1,
        ),

        pw.SizedBox(height: 5),

        pw.Text(
          'شكراً لتعاملكم معنا',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: boldFont,
            fontSize: 10,
          ),
        ),

        pw.SizedBox(height: 3),

        pw.Text(
          'منظفات الأمير',
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            font: regularFont,
            fontSize: 8,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/$year $hour:$minute';
  }

  String _formatMoney(double value) {
    return value.toStringAsFixed(2);
  }

  Future<void> printInvoice(Invoice invoice) async {
    await Printing.layoutPdf(
      onLayout: (format) async {
        return generateInvoicePdf(invoice);
      },

      format: pageFormat,
    );
  }

  Future<void> generateAndPrintInvoice(
      Invoice invoice,
      ) async {
    await printInvoice(invoice);
  }
}