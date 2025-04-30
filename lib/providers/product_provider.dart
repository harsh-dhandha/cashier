import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/product.dart';
import '../services/database_service.dart';

class ProductProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Product> _products = [];
  bool _isLoading = false;

  List<Product> get products => _products;
  bool get isLoading => _isLoading;

  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _databaseService.getProducts();
    } catch (e) {
      print('Error loading products: $e');
      _products = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addProduct(String name, double price, double gstRate) async {
    final product = Product(
      id: const Uuid().v4(),
      name: name,
      price: price,
      gstRate: gstRate,
    );

    await _databaseService.saveProduct(product);
    _products.add(product);
    notifyListeners();
  }

  Future<void> updateProduct(Product product) async {
    await _databaseService.saveProduct(product);

    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  Future<List<Product>> searchProducts(String query) async {
    if (query.isEmpty) return _products;

    return await _databaseService.searchProducts(query);
  }
}
