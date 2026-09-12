import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class AppIconBadge extends StatelessWidget {
  final IconData icon;
  final double size;
  final double iconSize;
  final Color background;
  final Color color;

  const AppIconBadge({
    super.key,
    required this.icon,
    this.size = 42,
    this.iconSize = 21,
    this.background = AppColors.primaryLight,
    this.color = AppColors.primaryDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(size * 0.24),
      ),
      child: Icon(icon, size: iconSize, color: color),
    );
  }
}
