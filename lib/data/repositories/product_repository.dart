import '../../core/utils/result.dart';
import '../database/database_helper.dart';
import '../models/product.dart';


class ProductRepository {
  final DatabaseHelper _db;

  ProductRepository({DatabaseHelper? database})
      : _db = database ?? DatabaseHelper.instance;

  Future<Result<List<Product>>> getAll() async {
    try {
      final products = await _db.getAllProducts();
      return Result.success(products);
    } catch (e) {
      return Result.failure('تعذر تحميل المنتجات: $e');
    }
  }

  Future<Result<List<Product>>> search(String query) async {
    try {
      final products = await _db.searchProducts(query);
      return Result.success(products);
    } catch (e) {
      return Result.failure('تعذر البحث عن المنتجات: $e');
    }
  }

  Future<Result<Product?>> getByBarcode(String barcode) async {
    try {
      final product = await _db.getProductByBarcode(barcode);
      return Result.success(product);
    } catch (e) {
      return Result.failure('تعذر البحث عن المنتج: $e');
    }
  }

  Future<Result<void>> add(Product product) async {
    try {
      await _db.insertProduct(product);
      return  Result.success(null);
    } catch (e) {
      return Result.failure('الباركود ده مستخدم قبل كده مع منتج تاني');
    }
  }

  Future<Result<void>> update(Product product) async {
    try {
      await _db.updateProduct(product);
      return  Result.success(null);
    } catch (e) {
      return Result.failure('الباركود ده مستخدم قبل كده مع منتج تاني');
    }
  }

  Future<Result<void>> delete(int id) async {
    try {
      await _db.deleteProduct(id);
      return  Result.success(null);
    } catch (e) {
      return Result.failure('تعذر حذف المنتج: $e');
    }
  }

  Future<Result<List<Product>>> getLowStock() async {
    try {
      final products = await _db.getLowStockProducts();
      return Result.success(products);
    } catch (e) {
      return Result.failure('تعذر تحميل تنبيهات المخزون: $e');
    }
  }
}
