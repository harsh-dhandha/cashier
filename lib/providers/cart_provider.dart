import 'package:flutter/foundation.dart';

import '../models/product.dart';
import '../models/invoice_item.dart';
import '../services/gst_calculator.dart';

class CartProvider with ChangeNotifier {
  final List<InvoiceItem> _items = [];

  List<InvoiceItem> get items => _items;

  double get totalCgst => _items.fold(0, (sum, item) => sum + item.cgst);
  double get totalSgst => _items.fold(0, (sum, item) => sum + item.sgst);
  double get grandTotal =>
      _items.fold(0, (sum, item) => sum + item.totalItemPrice);

  void addProduct(Product product, int quantity) {
    // Check if product already in cart
    final existingItemIndex = _items.indexWhere(
      (item) => item.product.id == product.id,
    );

    if (existingItemIndex != -1) {
      // Update existing item quantity
      final existingItem = _items[existingItemIndex];
      final newQuantity = existingItem.quantity + quantity;

      final updatedItem = GSTCalculator.createInvoiceItem(product, newQuantity);
      _items[existingItemIndex] = updatedItem;
    } else {
      // Add new item
      final newItem = GSTCalculator.createInvoiceItem(product, quantity);
      _items.add(newItem);
    }

    notifyListeners();
  }

  void updateQuantity(String productId, int quantity) {
    final index = _items.indexWhere((item) => item.product.id == productId);

    if (index != -1) {
      if (quantity <= 0) {
        _items.removeAt(index);
      } else {
        final product = _items[index].product;
        final updatedItem = GSTCalculator.createInvoiceItem(product, quantity);
        _items[index] = updatedItem;
      }

      notifyListeners();
    }
  }

  void removeItem(String productId) {
    _items.removeWhere((item) => item.product.id == productId);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
