import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

import '../data/models/invoice.dart';
import '../data/models/product.dart';
import '../data/repositories/invoice_repository.dart';
import '../data/repositories/product_repository.dart';


class PosViewModel extends ChangeNotifier {
  final ProductRepository _productRepository;
  final InvoiceRepository _invoiceRepository;

  PosViewModel({
    required ProductRepository productRepository,
    required InvoiceRepository invoiceRepository,
  })  : _productRepository = productRepository,
        _invoiceRepository = invoiceRepository;

  final List<InvoiceItem> _cartItems = [];

  List<InvoiceItem> get cartItems => List.unmodifiable(_cartItems);

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  bool get isCartEmpty => _cartItems.isEmpty;

  double get total =>
      _cartItems.fold(0, (sum, item) => sum + item.subtotal);

  int get totalQuantity =>
      _cartItems.fold(0, (sum, item) => sum + item.quantity);

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }


  Future<bool> handleBarcodeScanned(String barcode) async {
    final trimmed = barcode.trim();

    if (trimmed.isEmpty) {
      return false;
    }

    final result = await _productRepository.getByBarcode(trimmed);

    if (result.isFailure) {
      _errorMessage = result.errorOrNull;
      notifyListeners();
      return false;
    }

    final product = result.dataOrNull;

    if (product == null) {
      _errorMessage = 'مفيش منتج بالباركود ده: $trimmed';
      notifyListeners();
      return false;
    }

    if (product.quantity <= 0) {
      _errorMessage = 'المنتج "${product.name}" خلص من المخزون';
      notifyListeners();
      return false;
    }

    _addToCart(product);

    notifyListeners();

    return true;
  }


  void _addToCart(Product product) {
    final index = _cartItems.indexWhere(
          (item) => item.productId == product.id,
    );

    if (index != -1) {
      final existing = _cartItems[index];

      final newQty = existing.quantity + 1;

      if (newQty > product.quantity) {
        _errorMessage =
        'الكمية المطلوبة من "${product.name}" أكتر من المتاح بالمخزون';

        return;
      }

      _cartItems[index] = InvoiceItem(
        productId: existing.productId,
        productName: existing.productName,
        quantity: newQty,
        unitPrice: existing.unitPrice,
      );
    } else {
      _cartItems.add(
        InvoiceItem(
          productId: product.id!,
          productName: product.name,
          quantity: 1,
          unitPrice: product.price,
        ),
      );
    }

    _errorMessage = null;
  }


  void updateQuantity(
      int index,
      int newQuantity,
      ) {
    if (newQuantity <= 0) {
      _cartItems.removeAt(index);

      notifyListeners();

      return;
    }

    final item = _cartItems[index];

    _cartItems[index] = InvoiceItem(
      productId: item.productId,
      productName: item.productName,
      quantity: newQuantity,
      unitPrice: item.unitPrice,
    );

    notifyListeners();
  }


  void removeItem(int index) {
    _cartItems.removeAt(index);

    notifyListeners();
  }


  void clearCart() {
    _cartItems.clear();
    _errorMessage = null;

    notifyListeners();
  }


  Future<Invoice?> checkout() async {
    if (_cartItems.isEmpty) {
      return null;
    }

    final now = DateTime.now();

    final invoiceNumber = DateFormat(
      'yyyyMMdd-HHmmss',
    ).format(now);

    final invoice = Invoice(
      invoiceNumber: invoiceNumber,
      date: now,
      total: total,
      paidAmount: total,
      items: List.of(_cartItems),
    );

    final result = await _invoiceRepository.create(invoice);

    if (result.isFailure) {
      _errorMessage = result.errorOrNull;

      notifyListeners();

      return null;
    }

    _cartItems.clear();

    _errorMessage = null;

    notifyListeners();

    return invoice;
  }
}