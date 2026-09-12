import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../models/product.dart';
import '../models/invoice.dart';

class DatabaseHelper {
  DatabaseHelper._internal();

  static final DatabaseHelper instance = DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();

    return _database!;
  }

  Future<Database> _initDatabase() async {
    // مهم: sqflite_common_ffi على ويندوز محتاج التهيئة دي قبل أي استخدام
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final directory = await getApplicationDocumentsDirectory();
    final path = join(directory.path, 'cleaning_pos.db');

    final db = await databaseFactory.openDatabase(
      path,
      options: OpenDatabaseOptions(
        version: 1,
        onCreate: _onCreate,
      ),
    );

    // تنظيف الفواتير القديمة تلقائيًا
    await _cleanupOldInvoicesIfNeeded(db);

    return db;
  }


  Future<void> _onCreate(Database db, int version) async {
    // ---------------- المنتجات ----------------

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        barcode TEXT NOT NULL UNIQUE,
        price REAL NOT NULL,
        cost_price REAL DEFAULT 0,
        quantity INTEGER NOT NULL DEFAULT 0,
        category TEXT DEFAULT 'عام',
        min_quantity_alert INTEGER DEFAULT 5
      )
    ''');

    // ---------------- الفواتير ----------------

    await db.execute('''
      CREATE TABLE invoices (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_number TEXT NOT NULL,
        date TEXT NOT NULL,
        total REAL NOT NULL,
        discount REAL DEFAULT 0,
        paid_amount REAL NOT NULL
      )
    ''');

    // ---------------- عناصر الفواتير ----------------

    await db.execute('''
      CREATE TABLE invoice_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        invoice_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        unit_price REAL NOT NULL,
        subtotal REAL NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices (id)
      )
    ''');
  }


  Future<int> insertProduct(Product product) async {
    final db = await database;

    return await db.insert(
      'products',
      product.toMap()..remove('id'),
    );
  }

  Future<int> updateProduct(Product product) async {
    final db = await database;

    return await db.update(
      'products',
      product.toMap(),
      where: 'id = ?',
      whereArgs: [product.id],
    );
  }

  Future<int> deleteProduct(int id) async {
    final db = await database;

    return await db.delete(
      'products',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Product>> getAllProducts() async {
    final db = await database;

    final maps = await db.query(
      'products',
      orderBy: 'name ASC',
    );

    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final db = await database;

    final maps = await db.query(
      'products',
      where: 'barcode = ?',
      whereArgs: [barcode],
      limit: 1,
    );

    if (maps.isEmpty) {
      return null;
    }

    return Product.fromMap(maps.first);
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;

    final maps = await db.query(
      'products',
      where: 'name LIKE ? OR barcode LIKE ?',
      whereArgs: [
        '%$query%',
        '%$query%',
      ],
      orderBy: 'name ASC',
    );

    return maps.map((m) => Product.fromMap(m)).toList();
  }

  Future<List<Product>> getLowStockProducts() async {
    final db = await database;

    final maps = await db.rawQuery(
      '''
      SELECT *
      FROM products
      WHERE quantity <= min_quantity_alert
      ORDER BY quantity ASC
      ''',
    );

    return maps.map((m) => Product.fromMap(m)).toList();
  }


  Future<int> createInvoice(Invoice invoice) async {
    final db = await database;

    return await db.transaction((txn) async {
      // إنشاء الفاتورة
      final invoiceId = await txn.insert(
        'invoices',
        invoice.toMap()..remove('id'),
      );

      // إضافة عناصر الفاتورة وتحديث المخزون
      for (final item in invoice.items) {
        await txn.insert(
          'invoice_items',
          {
            'invoice_id': invoiceId,
            'product_id': item.productId,
            'product_name': item.productName,
            'quantity': item.quantity,
            'unit_price': item.unitPrice,
            'subtotal': item.subtotal,
          },
        );

        // تحديث المخزون
        await txn.rawUpdate(
          '''
          UPDATE products
          SET quantity = quantity - ?
          WHERE id = ?
          ''',
          [
            item.quantity,
            item.productId,
          ],
        );
      }

      return invoiceId;
    });
  }

  Future<List<Invoice>> getAllInvoices({
    DateTime? from,
    DateTime? to,
  }) async {
    final db = await database;

    String? where;
    List<Object?>? whereArgs;

    if (from != null && to != null) {
      where = 'date >= ? AND date < ?';

      whereArgs = [
        from.toIso8601String(),
        to.toIso8601String(),
      ];
    }

    else if (from != null) {
      where = 'date >= ?';

      whereArgs = [
        from.toIso8601String(),
      ];
    }

    else if (to != null) {
      where = 'date < ?';

      whereArgs = [
        to.toIso8601String(),
      ];
    }

    final maps = await db.query(
      'invoices',
      where: where,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return maps.map((m) => Invoice.fromMap(m)).toList();
  }

  Future<List<InvoiceItem>> getInvoiceItems(int invoiceId) async {
    final db = await database;

    final maps = await db.query(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );

    return maps.map((m) => InvoiceItem.fromMap(m)).toList();
  }

  Future<double> getTodaySalesTotal() async {
    final db = await database;

    final today = DateTime.now();

    // بداية اليوم
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    );

    // بداية اليوم التالي
    final startOfNextDay = startOfDay.add(
      const Duration(days: 1),
    );

    final result = await db.rawQuery(
      '''
      SELECT COALESCE(SUM(total), 0) AS total
      FROM invoices
      WHERE date >= ? AND date < ?
      ''',
      [
        startOfDay.toIso8601String(),
        startOfNextDay.toIso8601String(),
      ],
    );

    return (result.first['total'] as num).toDouble();
  }


  Future<void> _cleanupOldInvoicesIfNeeded(Database db) async {
    // إنشاء جدول صغير لتخزين آخر مرة حصل فيها تنظيف.
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT NOT NULL
      )
    ''');

    final result = await db.query(
      'app_settings',
      where: 'key = ?',
      whereArgs: ['last_invoice_cleanup'],
      limit: 1,
    );

    final now = DateTime.now();

    // لو حصل تنظيف قبل كده
    if (result.isNotEmpty) {
      final lastCleanupString = result.first['value'] as String;

      final lastCleanup = DateTime.tryParse(lastCleanupString);

      if (lastCleanup != null &&
          lastCleanup.year == now.year &&
          lastCleanup.month == now.month) {
        // التنظيف اتعمل بالفعل خلال الشهر الحالي
        return;
      }
    }

    // تنفيذ التنظيف
    await _deleteInvoicesOlderThanThreeMonths(db);

    // تسجيل تاريخ آخر عملية تنظيف
    await db.insert(
      'app_settings',
      {
        'key': 'last_invoice_cleanup',
        'value': now.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<void> _deleteInvoicesOlderThanThreeMonths(
      Database db,
      ) async {
    final now = DateTime.now();

    final startOfCurrentMonth = DateTime(
      now.year,
      now.month,
      1,
    );

    final deleteBefore = DateTime(
      startOfCurrentMonth.year,
      startOfCurrentMonth.month - 2,
      1,
    );

    final deleteBeforeString = deleteBefore.toIso8601String();

    await db.transaction((txn) async {
      // أولًا: حذف عناصر الفواتير القديمة
      await txn.rawDelete(
        '''
        DELETE FROM invoice_items
        WHERE invoice_id IN (
          SELECT id
          FROM invoices
          WHERE date < ?
        )
        ''',
        [deleteBeforeString],
      );

      // ثانيًا: حذف الفواتير القديمة
      await txn.delete(
        'invoices',
        where: 'date < ?',
        whereArgs: [deleteBeforeString],
      );
    });
  }
}