import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/database_service.dart';

class InvoiceProvider with ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  List<Invoice> _invoices = [];
  bool _isLoading = false;

  List<Invoice> get invoices => _invoices;
  bool get isLoading => _isLoading;

  Future<void> loadInvoices() async {
    _isLoading = true;
    notifyListeners();

    try {
      _invoices = await _databaseService.getInvoices();
    } catch (e) {
      print('Error loading invoices: $e');
      _invoices = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Invoice> createInvoice(List<InvoiceItem> items) async {
    // Calculate totals
    final totalCgst = items.fold(0.0, (sum, item) => sum + item.cgst);
    final totalSgst = items.fold(0.0, (sum, item) => sum + item.sgst);
    final grandTotal = items.fold(
      0.0,
      (sum, item) => sum + item.totalItemPrice,
    );

    // Create new invoice
    final invoice = Invoice(
      invoiceId: const Uuid().v4(),
      timestamp: DateTime.now(),
      items: items,
      totalCgst: totalCgst,
      totalSgst: totalSgst,
      grandTotal: grandTotal,
    );

    // Save invoice to database
    await _databaseService.saveInvoice(invoice);

    // Update local list
    _invoices.insert(0, invoice);
    notifyListeners();

    return invoice;
  }

  Future<Invoice?> getInvoiceDetails(String invoiceId) async {
    return await _databaseService.getInvoice(invoiceId);
  }
}
