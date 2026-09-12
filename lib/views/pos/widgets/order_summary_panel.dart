import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../shared/widgets/app_card.dart';
import '../../shared/widgets/app_icon_badge.dart';

class OrderSummaryPanel extends StatelessWidget {
  final int itemCount;
  final int totalQuantity;
  final double total;
  final NumberFormat currencyFormat;
  final bool isCartEmpty;
  final VoidCallback onCheckout;

  const OrderSummaryPanel({
    super.key,
    required this.itemCount,
    required this.totalQuantity,
    required this.total,
    required this.currencyFormat,
    required this.isCartEmpty,
    required this.onCheckout,
  });

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(22),
      withShadow: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Row(
            children: [
               AppIconBadge(icon: Icons.receipt_long_outlined),
               SizedBox(width: 12),
               Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('ملخص الفاتورة', style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  )),
                  SizedBox(height: 3),
                  Text('تفاصيل عملية البيع', style: AppTextStyles.caption),
                ],
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SummaryRow(
            title: 'عدد الأصناف',
            value: '$itemCount',
            icon: Icons.inventory_2_outlined,
          ),
          const SizedBox(height: 14),
          _SummaryRow(
            title: 'عدد الوحدات',
            value: '$totalQuantity',
            icon: Icons.shopping_basket_outlined,
          ),
          const SizedBox(height: 20),
          const Divider(color: AppColors.divider),
          const SizedBox(height: 20),
          const Text('الإجمالي', textAlign: TextAlign.right, style: AppTextStyles.body),
          const SizedBox(height: 8),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: Text(
              currencyFormat.format(total),
              key: ValueKey(total),
              textAlign: TextAlign.right,
              style: AppTextStyles.amountLarge,
            ),
          ),
          const SizedBox(height: 4),
          const Text('جنيه مصري', textAlign: TextAlign.right, style: AppTextStyles.caption),
          const Spacer(),
          SizedBox(
            height: 58,
            child: ElevatedButton.icon(
              onPressed: isCartEmpty ? null : onCheckout,
              icon: const Icon(Icons.point_of_sale_rounded, size: 23),
              label: const Text('إتمام البيع', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(
                disabledBackgroundColor: AppColors.divider,
                disabledForegroundColor: AppColors.disabledText,
              ),
            ),
          ),
          const SizedBox(height: 10),
          if (!isCartEmpty)
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.keyboard_return_rounded, size: 15, color: AppColors.textSecondary),
                SizedBox(width: 5),
                Text('جاهز لإتمام عملية البيع', style: AppTextStyles.caption),
              ],
            ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const _SummaryRow({required this.title, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        const SizedBox(width: 10),
        Text(title, style: AppTextStyles.body),
        const Spacer(),
        Text(value, style: const TextStyle(
          color: AppColors.textPrimary,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        )),
      ],
    );
  }
}
