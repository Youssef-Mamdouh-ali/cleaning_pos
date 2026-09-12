import 'package:flutter/foundation.dart';

import '../data/models/invoice.dart';
import '../data/repositories/invoice_repository.dart';

enum InvoiceFilter {
  all,
  today,
  yesterday,
  thisWeek,
  thisMonth,
}

class InvoicesViewModel extends ChangeNotifier {
  final InvoiceRepository _repository;

  InvoicesViewModel({
    required InvoiceRepository repository,
  }) : _repository = repository {
    loadInvoices();
  }


  List<Invoice> _invoices = [];

  List<Invoice> get invoices => _invoices;

  double _total = 0;

  double get total => _total;


  bool _isLoading = false;

  bool get isLoading => _isLoading;

  String? _errorMessage;

  String? get errorMessage => _errorMessage;

  InvoiceFilter _currentFilter = InvoiceFilter.all;

  InvoiceFilter get currentFilter => _currentFilter;


  Future<void> loadInvoices() async {
    await _loadInvoicesForFilter(_currentFilter);
  }


  Future<void> setFilter(InvoiceFilter filter) async {
    if (_currentFilter == filter) {
      return;
    }

    _currentFilter = filter;

    await _loadInvoicesForFilter(filter);
  }

  Future<void> _loadInvoicesForFilter(
      InvoiceFilter filter,
      ) async {
    _isLoading = true;
    _errorMessage = null;

    notifyListeners();

    DateTime? from;
    DateTime? to;

    final now = DateTime.now();

    switch (filter) {

      case InvoiceFilter.all:
        from = null;
        to = null;
        break;


      case InvoiceFilter.today:
        from = DateTime(
          now.year,
          now.month,
          now.day,
        );

        to = from.add(
          const Duration(days: 1),
        );

        break;


      case InvoiceFilter.yesterday:
        to = DateTime(
          now.year,
          now.month,
          now.day,
        );

        from = to.subtract(
          const Duration(days: 1),
        );

        break;


      case InvoiceFilter.thisWeek:
        final today = DateTime(
          now.year,
          now.month,
          now.day,
        );

        from = today.subtract(
          Duration(days: today.weekday - 1),
        );

        to = from.add(
          const Duration(days: 7),
        );

        break;

      case InvoiceFilter.thisMonth:
        from = DateTime(
          now.year,
          now.month,
          1,
        );

        to = DateTime(
          now.year,
          now.month + 1,
          1,
        );

        break;
    }

    final result = await _repository.getAll(
      from: from,
      to: to,
    );

    _isLoading = false;

    if (result.isSuccess) {
      _invoices = result.dataOrNull ?? [];

      _total = _calculateTotal(_invoices);
    } else {
      _invoices = [];
      _total = 0;
      _errorMessage = result.errorOrNull;
    }

    notifyListeners();
  }

  double _calculateTotal(List<Invoice> invoices) {
    return invoices.fold(
      0.0,
          (sum, invoice) => sum + invoice.total,
    );
  }

  Future<List<InvoiceItem>> getInvoiceItems(
      int invoiceId,
      ) async {
    final result = await _repository.getItems(invoiceId);

    return result.dataOrNull ?? [];
  }

  String get filterTitle {
    switch (_currentFilter) {
      case InvoiceFilter.all:
        return 'كل الفواتير';

      case InvoiceFilter.today:
        return 'اليوم';

      case InvoiceFilter.yesterday:
        return 'أمس';

      case InvoiceFilter.thisWeek:
        return 'هذا الأسبوع';

      case InvoiceFilter.thisMonth:
        return 'هذا الشهر';
    }
  }
}