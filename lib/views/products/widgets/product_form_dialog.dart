import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/product.dart';
import '../../../viewmodels/products_view_model.dart';
import '../../shared/widgets/app_form_field.dart';
import '../../shared/widgets/app_icon_badge.dart';

Future<void> showProductFormDialog(BuildContext context, {Product? product}) {
  return showDialog(
    context: context,
    builder: (_) => ProductFormDialog(product: product),
  );
}

class ProductFormDialog extends StatefulWidget {
  final Product? product;

  const ProductFormDialog({super.key, this.product});

  @override
  State<ProductFormDialog> createState() => _ProductFormDialogState();
}

class _ProductFormDialogState extends State<ProductFormDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _barcodeController;
  late final TextEditingController _priceController;
  late final TextEditingController _costController;
  late final TextEditingController _quantityController;
  late final TextEditingController _categoryController;
  late final TextEditingController _minAlertController;

  final _formKey = GlobalKey<FormState>();

  Product? get _product => widget.product;
  bool get _isEditing => _product != null;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: _product?.name ?? '');
    _barcodeController = TextEditingController(text: _product?.barcode ?? '');
    _priceController = TextEditingController(text: _product?.price.toString() ?? '');
    _costController = TextEditingController(text: _product?.costPrice.toString() ?? '0');
    _quantityController = TextEditingController(text: _product?.quantity.toString() ?? '');
    _categoryController = TextEditingController(text: _product?.category ?? 'عام');
    _minAlertController = TextEditingController(text: _product?.minQuantityAlert.toString() ?? '5');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _barcodeController.dispose();
    _priceController.dispose();
    _costController.dispose();
    _quantityController.dispose();
    _categoryController.dispose();
    _minAlertController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final newProduct = Product(
      id: _product?.id,
      name: _nameController.text.trim(),
      barcode: _barcodeController.text.trim(),
      price: double.parse(_priceController.text),
      costPrice: double.tryParse(_costController.text) ?? 0,
      quantity: int.parse(_quantityController.text),
      category: _categoryController.text.trim().isEmpty ? 'عام' : _categoryController.text.trim(),
      minQuantityAlert: int.tryParse(_minAlertController.text) ?? 5,
    );

    final viewModel = context.read<ProductsViewModel>();
    final success = await viewModel.saveProduct(newProduct);

    if (!mounted) return;

    if (success) {
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.danger,
          content: Text(
            viewModel.errorMessage ?? 'حصل خطأ أثناء الحفظ',
            textAlign: TextAlign.right,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: AlertDialog(
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 10),
        contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        title: Row(
          children: [
            AppIconBadge(
              icon: _isEditing ? Icons.edit_outlined : Icons.add_box_outlined,
              size: 44,
            ),
            const SizedBox(width: 12),
            Text(
              _isEditing ? 'تعديل المنتج' : 'إضافة منتج جديد',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.textPrimary),
            ),
          ],
        ),
        content: SizedBox(
          width: 620,
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const AppFormSectionTitle(title: 'بيانات المنتج', icon: Icons.inventory_2_outlined),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: AppFormField(
                          controller: _nameController,
                          label: 'اسم المنتج',
                          icon: Icons.shopping_bag_outlined,
                          validator: Validators.productName,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppFormField(
                          controller: _categoryController,
                          label: 'الفئة',
                          icon: Icons.category_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  AppFormField(
                    controller: _barcodeController,
                    label: 'الباركود',
                    helperText: 'امسحه بالسكانر أو اكتبه يدويًا',
                    icon: Icons.qr_code_scanner_rounded,
                    validator: Validators.barcode,
                  ),
                  const SizedBox(height: 24),
                  const AppFormSectionTitle(title: 'الأسعار والمخزون', icon: Icons.storefront_outlined),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppFormField(
                          controller: _priceController,
                          label: 'سعر البيع',
                          icon: Icons.sell_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: Validators.price,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppFormField(
                          controller: _costController,
                          label: 'سعر الشراء',
                          helperText: 'اختياري',
                          icon: Icons.shopping_cart_outlined,
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          validator: Validators.optionalNumber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: AppFormField(
                          controller: _quantityController,
                          label: 'الكمية المتاحة',
                          icon: Icons.inventory_outlined,
                          keyboardType: TextInputType.number,
                          validator: Validators.quantity,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppFormField(
                          controller: _minAlertController,
                          label: 'حد تنبيه المخزون',
                          helperText: 'يظهر تنبيه عند الوصول له',
                          icon: Icons.warning_amber_outlined,
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(24, 10, 24, 20),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(foregroundColor: AppColors.textSecondary),
            child: const Text('إلغاء'),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _submit,
            icon: const Icon(Icons.check_rounded, size: 20),
            label: Text(_isEditing ? 'حفظ التعديلات' : 'إضافة المنتج'),
          ),
        ],
      ),
    );
  }
}
