import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

const TextStyle _headerStyle = TextStyle(
  fontSize: 12,
  fontWeight: FontWeight.w700,
  color: AppColors.primaryDark,
);

class ProductTableHeader extends StatelessWidget {
  const ProductTableHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('المنتج', style: _headerStyle)),
          Expanded(flex: 2, child: Text('الباركود', textAlign: TextAlign.center, style: _headerStyle)),
          Expanded(flex: 2, child: Text('الفئة', textAlign: TextAlign.center, style: _headerStyle)),
          Expanded(child: Text('الكمية', textAlign: TextAlign.center, style: _headerStyle)),
          Expanded(flex: 2, child: Text('السعر', textAlign: TextAlign.center, style: _headerStyle)),
          SizedBox(width: 105, child: Text('إجراءات', textAlign: TextAlign.center, style: _headerStyle)),
        ],
      ),
    );
  }
}
