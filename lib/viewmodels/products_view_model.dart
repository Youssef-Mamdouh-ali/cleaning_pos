import 'package:flutter/foundation.dart';

import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

class ProductsViewModel extends ChangeNotifier {
  final ProductRepository _repository;

  ProductsViewModel({required ProductRepository repository})
      : _repository = repository {
    loadProducts();
  }

  List<Product> _products = [];
  List<Product> get products => _products;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    final result = _searchQuery.isEmpty
        ? await _repository.getAll()
        : await _repository.search(_searchQuery);

    _isLoading = false;

    if (result.isSuccess) {
      _products = result.dataOrNull ?? [];
    } else {
      _errorMessage = result.errorOrNull;
    }

    notifyListeners();
  }

  void search(String query) {
    _searchQuery = query;
    loadProducts();
  }

  Future<bool> saveProduct(Product product) async {
    final result = product.id == null
        ? await _repository.add(product)
        : await _repository.update(product);

    if (result.isFailure) {
      _errorMessage = result.errorOrNull;
      notifyListeners();
      return false;
    }

    await loadProducts();
    return true;
  }

  Future<bool> deleteProduct(int id) async {
    final result = await _repository.delete(id);

    if (result.isFailure) {
      _errorMessage = result.errorOrNull;
      notifyListeners();
      return false;
    }

    await loadProducts();
    return true;
  }
}
