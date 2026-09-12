import 'package:cleaning_pos/views/invoices/invoice_pdf_preview_screen.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../viewmodels/pos_view_model.dart';
import '../shared/widgets/app_empty_state.dart';
import 'widgets/barcode_scan_field.dart';
import 'widgets/cart_error_banner.dart';
import 'widgets/cart_header.dart';
import 'widgets/cart_item_tile.dart';
import 'widgets/order_summary_panel.dart';

class PosScreen extends StatefulWidget {
  const PosScreen({super.key});

  @override
  State<PosScreen> createState() => _PosScreenState();
}

class _PosScreenState extends State<PosScreen> {
  final TextEditingController _barcodeController =
  TextEditingController();

  final FocusNode _barcodeFocusNode = FocusNode();

  final _currencyFormat = NumberFormat.currency(
    locale: 'ar_EG',
    symbol: 'ج.م',
    decimalDigits: 2,
  );

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _barcodeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _barcodeController.dispose();
    _barcodeFocusNode.dispose();

    super.dispose();
  }

  Future<void> _onBarcodeSubmitted(
      BuildContext context,
      String value,
      ) async {
    final viewModel = context.read<PosViewModel>();

    _barcodeController.clear();

    await viewModel.handleBarcodeScanned(value);

    _barcodeFocusNode.requestFocus();
  }


  Future<void> _onCheckout(
      BuildContext context,
      ) async {
    final viewModel = context.read<PosViewModel>();

    final invoice = await viewModel.checkout();

    if (!context.mounted) return;


    if (invoice == null) {
      _barcodeFocusNode.requestFocus();
      return;
    }


    await _showCheckoutSuccessDialog(
      context,
      invoice,
    );

    if (!context.mounted) return;

    _barcodeFocusNode.requestFocus();
  }

  Future<void> _showCheckoutSuccessDialog(
      BuildContext context,
      invoice,
      ) async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.green.withValues(
                    alpha: 0.12,
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'تم إتمام البيع',
              ),
            ],
          ),

          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'تم تسجيل الفاتورة بنجاح.',
              ),

              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  'رقم الفاتورة: ${invoice.invoiceNumber}',
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          actions: [

            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'بيع جديد',
              ),
            ),


            ElevatedButton.icon(
              onPressed: () {
                Navigator.of(dialogContext).pop();

                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => InvoicePdfPreviewScreen(
                      invoice: invoice,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.print_outlined),
              label: const Text('معاينة وطباعة الفاتورة'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        title: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withValues(
                  alpha: 0.15,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.storefront_rounded,
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 12),

            const Text(
              'منظفات الأمير',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          20,
          4,
          20,
          20,
        ),

        child: Consumer<PosViewModel>(
          builder: (
              context,
              viewModel,
              _,
              ) {
            return Row(
              crossAxisAlignment:
              CrossAxisAlignment.stretch,

              children: [

                Expanded(
                  flex: 3,
                  child: Column(
                    children: [
                      BarcodeScanField(
                        controller: _barcodeController,
                        focusNode: _barcodeFocusNode,
                        onSubmitted: (value) =>
                            _onBarcodeSubmitted(
                              context,
                              value,
                            ),
                      ),

                      const SizedBox(height: 12),

                      if (viewModel.errorMessage != null)
                        CartErrorBanner(
                          message: viewModel.errorMessage!,
                        ),

                      const SizedBox(height: 16),

                      CartHeader(
                        itemCount:
                        viewModel.cartItems.length,
                        onClear: () {
                          viewModel.clearCart();

                          _barcodeFocusNode
                              .requestFocus();
                        },
                      ),

                      const SizedBox(height: 10),

                      Expanded(
                        child: viewModel.cartItems.isEmpty
                            ? const AppEmptyState(
                          icon: Icons
                              .shopping_cart_outlined,
                          title: 'السلة فارغة',
                          message:
                          'امسح باركود المنتج لإضافته إلى الفاتورة',
                        )
                            : ListView.separated(
                          padding:
                          const EdgeInsets.only(
                            bottom: 10,
                          ),
                          itemCount:
                          viewModel
                              .cartItems
                              .length,
                          separatorBuilder:
                              (_, __) =>
                          const SizedBox(
                            height: 8,
                          ),
                          itemBuilder:
                              (context, index) {
                            final item =
                            viewModel
                                .cartItems[index];

                            return CartItemTile(
                              item: item,
                              currencyFormat:
                              _currencyFormat,
                              onIncrement: () =>
                                  viewModel
                                      .updateQuantity(
                                    index,
                                    item.quantity + 1,
                                  ),
                              onDecrement: () =>
                                  viewModel
                                      .updateQuantity(
                                    index,
                                    item.quantity - 1,
                                  ),
                              onRemove: () =>
                                  viewModel
                                      .removeItem(
                                    index,
                                  ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),


                Expanded(
                  flex: 2,
                  child: OrderSummaryPanel(
                    itemCount:
                    viewModel.cartItems.length,
                    totalQuantity:
                    viewModel.totalQuantity,
                    total:
                    viewModel.total,
                    currencyFormat:
                    _currencyFormat,
                    isCartEmpty:
                    viewModel.isCartEmpty,
                    onCheckout: () =>
                        _onCheckout(context),
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