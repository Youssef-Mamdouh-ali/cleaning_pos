class Product {
  final int? id;
  final String name;
  final String barcode;
  final double price;
  final double costPrice;
  final int quantity;
  final String category;
  final int minQuantityAlert;
  Product({
    this.id,
    required this.name,
    required this.barcode,
    required this.price,
    this.costPrice = 0,
    required this.quantity,
    this.category = 'عام',
    this.minQuantityAlert = 5,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'price': price,
      'cost_price': costPrice,
      'quantity': quantity,
      'category': category,
      'min_quantity_alert': minQuantityAlert,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] as int?,
      name: map['name'] as String,
      barcode: map['barcode'] as String,
      price: (map['price'] as num).toDouble(),
      costPrice: (map['cost_price'] as num?)?.toDouble() ?? 0,
      quantity: map['quantity'] as int,
      category: map['category'] as String? ?? 'عام',
      minQuantityAlert: map['min_quantity_alert'] as int? ?? 5,
    );
  }

  Product copyWith({
    int? id,
    String? name,
    String? barcode,
    double? price,
    double? costPrice,
    int? quantity,
    String? category,
    int? minQuantityAlert,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      barcode: barcode ?? this.barcode,
      price: price ?? this.price,
      costPrice: costPrice ?? this.costPrice,
      quantity: quantity ?? this.quantity,
      category: category ?? this.category,
      minQuantityAlert: minQuantityAlert ?? this.minQuantityAlert,
    );
  }
}
