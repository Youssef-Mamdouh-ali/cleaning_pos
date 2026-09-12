import 'package:cleaning_pos/services/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import '../../../data/models/invoice.dart';

class InvoicePdfPreviewScreen extends StatelessWidget {
  final Invoice invoice;

  const InvoicePdfPreviewScreen({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'معاينة الفاتورة',
        ),
        centerTitle: true,
      ),

      body: PdfPreview(
        build: (format) async {
          return PrinterService.instance.generateInvoicePdf(
            invoice,
          );
        },

        initialPageFormat:
        PrinterService.instance.pageFormat,

        allowPrinting: true,
        allowSharing: false,

        canChangePageFormat: false,
        canChangeOrientation: false,

        pdfFileName:
        'invoice_${invoice.invoiceNumber}.pdf',
      ),
    );
  }
}