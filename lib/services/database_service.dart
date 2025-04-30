import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';

import '../models/product.dart';
import '../models/invoice.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final path = await getDatabasesPath();
    final dbPath = join(path, 'cashier.db');

    return await openDatabase(dbPath, version: 1, onCreate: _createDb);
  }

  Future<void> _createDb(Database db, int version) async {
    // Products table
    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        price REAL NOT NULL,
        gstRate REAL NOT NULL
      )
    ''');

    // Invoices table - store as JSON for simplicity
    await db.execute('''
      CREATE TABLE invoices (
        invoiceId TEXT PRIMARY KEY,
        data TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');
  }

  // Product operations
  Future<void> saveProduct(Product product) async {
    final db = await database;
    await db.insert(
      'products',
      product.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Product>> getProducts() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('products');

    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  Future<List<Product>> searchProducts(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'products',
      where: 'name LIKE ?',
      whereArgs: ['%$query%'],
    );

    return List.generate(maps.length, (i) {
      return Product.fromJson(maps[i]);
    });
  }

  // Invoice operations
  Future<void> saveInvoice(Invoice invoice) async {
    final db = await database;
    await db.insert('invoices', {
      'invoiceId': invoice.invoiceId,
      'data': jsonEncode(invoice.toJson()),
      'timestamp': invoice.timestamp.toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<Invoice>> getInvoices() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'invoices',
      orderBy: 'timestamp DESC',
    );

    return List.generate(maps.length, (i) {
      final data = jsonDecode(maps[i]['data']);
      return Invoice.fromJson(data);
    });
  }

  Future<Invoice?> getInvoice(String invoiceId) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'invoices',
      where: 'invoiceId = ?',
      whereArgs: [invoiceId],
    );

    if (maps.isEmpty) return null;

    final data = jsonDecode(maps.first['data']);
    return Invoice.fromJson(data);
  }
}
