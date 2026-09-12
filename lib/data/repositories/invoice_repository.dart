import '../../core/utils/result.dart';
import '../database/database_helper.dart';
import '../models/invoice.dart';

class InvoiceRepository {
  final DatabaseHelper _db;

  InvoiceRepository({DatabaseHelper? database})
      : _db = database ?? DatabaseHelper.instance;


  Future<Result<int>> create(Invoice invoice) async {
    try {
      final id = await _db.createInvoice(invoice);

      return Result.success(id);
    } catch (e) {
      return Result.failure(
        'تعذر تسجيل الفاتورة: $e',
      );
    }
  }


  Future<Result<List<Invoice>>> getAll({
    DateTime? from,
    DateTime? to,
  }) async {
    try {
      final invoices = await _db.getAllInvoices(
        from: from,
        to: to,
      );

      return Result.success(invoices);
    } catch (e) {
      return Result.failure(
        'تعذر تحميل الفواتير: $e',
      );
    }
  }

  Future<Result<List<InvoiceItem>>> getItems(
      int invoiceId,
      ) async {
    try {
      final items = await _db.getInvoiceItems(invoiceId);

      return Result.success(items);
    } catch (e) {
      return Result.failure(
        'تعذر تحميل تفاصيل الفاتورة: $e',
      );
    }
  }


  Future<Result<double>> getTodayTotal() async {
    try {
      final total = await _db.getTodaySalesTotal();

      return Result.success(total);
    } catch (e) {
      return Result.failure(
        'تعذر حساب مبيعات اليوم: $e',
      );
    }
  }
}