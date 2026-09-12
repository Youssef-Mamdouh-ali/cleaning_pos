class InvoiceItem {
  final int? id;
  final int? invoiceId;
  final int productId;
  final String productName;
  final int quantity;
  final double unitPrice;
  final double subtotal;

  InvoiceItem({
    this.id,
    this.invoiceId,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  }) : subtotal = quantity * unitPrice;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'product_id': productId,
      'product_name': productName,
      'quantity': quantity,
      'unit_price': unitPrice,
      'subtotal': subtotal,
    };
  }

  factory InvoiceItem.fromMap(Map<String, dynamic> map) {
    return InvoiceItem(
      id: map['id'] as int?,
      invoiceId: map['invoice_id'] as int?,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      quantity: map['quantity'] as int,
      unitPrice: (map['unit_price'] as num).toDouble(),
    );
  }
}

class Invoice {
  final int? id;
  final String invoiceNumber;
  final DateTime date;
  final double total;
  final double discount;
  final double paidAmount;
  final List<InvoiceItem> items;

  Invoice({
    this.id,
    required this.invoiceNumber,
    required this.date,
    required this.total,
    this.discount = 0,
    required this.paidAmount,
    this.items = const [],
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_number': invoiceNumber,
      'date': date.toIso8601String(),
      'total': total,
      'discount': discount,
      'paid_amount': paidAmount,
    };
  }

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'] as int?,
      invoiceNumber: map['invoice_number'] as String,
      date: DateTime.parse(map['date'] as String),
      total: (map['total'] as num).toDouble(),
      discount: (map['discount'] as num?)?.toDouble() ?? 0,
      paidAmount: (map['paid_amount'] as num).toDouble(),
    );
  }
}
