import 'package:flutter/material.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static const TextStyle pageTitle = TextStyle(
    color: AppColors.textPrimary,
    fontSize: 28,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textPrimary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 14,
    color: AppColors.textSecondary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );

  static const TextStyle priceEmphasis = TextStyle(
    color: AppColors.primaryDark,
    fontSize: 15,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle amountLarge = TextStyle(
    color: AppColors.primaryDark,
    fontSize: 31,
    fontWeight: FontWeight.w800,
  );

  static const TextStyle errorText = TextStyle(
    color: AppColors.dangerDark,
    fontWeight: FontWeight.w500,
  );
}
