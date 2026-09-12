import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class BarcodeScanField extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  const BarcodeScanField({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: true,
        textAlign: TextAlign.right,
        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          labelText: 'امسح الباركود أو اكتب الكود',
          labelStyle: const TextStyle(color: AppColors.textSecondary),
          prefixIcon: const Icon(
            Icons.qr_code_scanner_rounded,
            color: AppColors.primaryDark,
            size: 28,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.keyboard_return_rounded,
                color: AppColors.primaryDark,
                size: 20,
              ),
            ),
          ),
          filled: true,
          fillColor: AppColors.card,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: const BorderSide(color: AppColors.primaryDark, width: 2),
          ),
        ),
        onSubmitted: onSubmitted,
        onTapOutside: (_) => focusNode.requestFocus(),
      ),
    );
  }
}
