import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/invoice.dart';
import '../../../services/printer_service.dart';
import '../../../viewmodels/invoices_view_model.dart';

Future<void> showInvoiceDetailsDialog(
  BuildContext context,
  Invoice invoice,
) async {
  final viewModel = context.read<InvoicesViewModel>();


  final items = await viewModel.getInvoiceItems(
    invoice.id!,
  );

  if (!context.mounted) return;

  final fullInvoice = Invoice(
    id: invoice.id,
    invoiceNumber: invoice.invoiceNumber,
    date: invoice.date,
    total: invoice.total,
    discount: invoice.discount,
    paidAmount: invoice.paidAmount,
    items: items,
  );


  await showDialog(
    context: context,
    builder: (_) => AlertDialog(
      title: Text(
        'فاتورة رقم ${fullInvoice.invoiceNumber}',
      ),

      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            Text(
              'التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(fullInvoice.date)}',
            ),

            const Divider(),

            ...fullInvoice.items.map(
              (item) => _InvoiceItemRow(
                item: item,
              ),
            ),

            const Divider(),


            if (fullInvoice.discount > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'الخصم',
                  ),
                  Text(
                    '${fullInvoice.discount.toStringAsFixed(2)} ج.م',
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'الإجمالي',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${fullInvoice.total.toStringAsFixed(2)} ج.م',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primaryDark,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),


            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'المدفوع',
                ),
                Text(
                  '${fullInvoice.paidAmount.toStringAsFixed(2)} ج.م',
                ),
              ],
            ),

            const SizedBox(height: 8),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  fullInvoice.paidAmount >= fullInvoice.total
                      ? 'الباقي'
                      : 'المتبقي',
                ),
                Text(
                  '${(fullInvoice.paidAmount - fullInvoice.total).abs().toStringAsFixed(2)} ج.م',
                ),
              ],
            ),
          ],
        ),
      ),


      actions: [

        ElevatedButton.icon(
          onPressed: () async {
            try {
              await PrinterService.instance.generateAndPrintInvoice(
                fullInvoice,
              );
            } catch (e) {
              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'حدث خطأ أثناء الطباعة: $e',
                  ),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          icon: const Icon(
            Icons.print_outlined,
          ),
          label: const Text(
            'طباعة',
          ),
        ),


        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'إغلاق',
          ),
        ),
      ],
    ),
  );
}


class _InvoiceItemRow extends StatelessWidget {
  final InvoiceItem item;

  const _InvoiceItemRow({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              '${item.productName} × ${item.quantity}',
            ),
          ),
          Text(
            '${item.subtotal.toStringAsFixed(2)} ج.م',
          ),
        ],
      ),
    );
  }
}
