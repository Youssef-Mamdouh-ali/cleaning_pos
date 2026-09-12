import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class TodaySalesBanner extends StatelessWidget {
  final String formattedTotal;

  const TodaySalesBanner({super.key, required this.formattedTotal});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        'إجمالي مبيعات اليوم: $formattedTotal',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppColors.primaryDark,
        ),
      ),
    );
  }
}
