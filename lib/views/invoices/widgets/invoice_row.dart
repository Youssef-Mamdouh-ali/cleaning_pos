import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/invoice.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon_badge.dart';

class InvoiceRow extends StatelessWidget {
  final Invoice invoice;
  final VoidCallback onTap;

  const InvoiceRow({super.key, required this.invoice, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            const AppIconBadge(icon: Icons.receipt_long_outlined, size: 42, iconSize: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'فاتورة رقم ${invoice.invoiceNumber}',
                    style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('yyyy-MM-dd HH:mm').format(invoice.date),
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
            Text(
              '${invoice.total.toStringAsFixed(2)} ج.م',
              style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.primaryDark),
            ),
          ],
        ),
      ),
    );
  }
}
