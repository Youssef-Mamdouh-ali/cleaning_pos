import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class CartHeader extends StatelessWidget {
  final int itemCount;
  final VoidCallback onClear;

  const CartHeader({super.key, required this.itemCount, required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Text('السلة', style: AppTextStyles.sectionTitle),
        const SizedBox(width: 10),
        if (itemCount > 0)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$itemCount أصناف',
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        const Spacer(),
        if (itemCount > 0)
          TextButton.icon(
            onPressed: onClear,
            icon: const Icon(Icons.delete_sweep_outlined, size: 19),
            label: const Text('مسح السلة'),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
          ),
      ],
    );
  }
}
