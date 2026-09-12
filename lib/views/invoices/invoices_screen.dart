import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/invoices_view_model.dart';
import '../shared/widgets/app_empty_state.dart';
import 'widgets/invoice_details_dialog.dart';
import 'widgets/invoice_row.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'ar_EG',
      symbol: 'ج.م',
      decimalDigits: 2,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FA),

      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        centerTitle: false,
        title: const Text(
          'منظفات الأمير',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Consumer<InvoicesViewModel>(
          builder: (context, viewModel, _) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [

                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFFEFF3FF),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.receipt_long_outlined,
                        color: Color(0xFF3F51B5),
                        size: 25,
                      ),
                    ),

                    const SizedBox(width: 12),

                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'سجل الفواتير',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            '${viewModel.invoices.length} فاتورة',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),


                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<InvoiceFilter>(
                      value: viewModel.currentFilter,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                      ),
                      icon: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: InvoiceFilter.all,
                          child: Text('كل الفواتير'),
                        ),
                        DropdownMenuItem(
                          value: InvoiceFilter.today,
                          child: Text('اليوم'),
                        ),
                        DropdownMenuItem(
                          value: InvoiceFilter.yesterday,
                          child: Text('أمس'),
                        ),
                        DropdownMenuItem(
                          value: InvoiceFilter.thisWeek,
                          child: Text('هذا الأسبوع'),
                        ),
                        DropdownMenuItem(
                          value: InvoiceFilter.thisMonth,
                          child: Text('هذا الشهر'),
                        ),
                      ],
                      onChanged: (filter) {
                        if (filter == null) return;

                        context
                            .read<InvoicesViewModel>()
                            .setFilter(filter);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.payments_outlined,
                          color: Color(0xFF2E7D32),
                          size: 26,
                        ),
                      ),

                      const SizedBox(width: 14),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إجمالي المبيعات',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 14,
                              ),
                            ),

                            const SizedBox(height: 5),

                            Text(
                              currencyFormat.format(viewModel.total),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          viewModel.filterTitle,
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                Expanded(
                  child: viewModel.isLoading
                      ? const Center(
                    child: CircularProgressIndicator(),
                  )
                      : viewModel.errorMessage != null
                      ? Center(
                    child: Text(
                      viewModel.errorMessage!,
                      style: const TextStyle(
                        color: Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                      : viewModel.invoices.isEmpty
                      ? const AppEmptyState(
                    icon: Icons.receipt_long_outlined,
                    title: 'مفيش فواتير',
                    message:
                    'مفيش فواتير في الفترة المحددة',
                  )
                      : Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: ListView.separated(
                      itemCount: viewModel.invoices.length,
                      separatorBuilder: (_, __) =>
                      const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final invoice =
                        viewModel.invoices[index];

                        return InvoiceRow(
                          invoice: invoice,
                          onTap: () =>
                              showInvoiceDetailsDialog(
                                context,
                                invoice,
                              ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}