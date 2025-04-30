import '../models/product.dart';
import '../models/invoice_item.dart';

class GSTCalculator {
  // List of valid GST rates
  static const List<double> validGSTRates = [5.0, 12.0, 18.0, 28.0];

  // Calculate CGST and SGST for a single product
  static Map<String, double> calculateGST(Product product, int quantity) {
    if (!validGSTRates.contains(product.gstRate)) {
      throw ArgumentError('Invalid GST rate. Must be one of: $validGSTRates');
    }

    // Base price for the quantity
    final basePrice = product.price * quantity;

    // Calculate GST components
    final gstAmount = basePrice * (product.gstRate / 100);
    final cgst = gstAmount / 2;
    final sgst = gstAmount / 2;

    // Calculate total price with GST
    final totalPrice = basePrice + cgst + sgst;

    return {
      'basePrice': basePrice,
      'cgst': cgst,
      'sgst': sgst,
      'totalPrice': totalPrice,
    };
  }

  // Create InvoiceItem with calculated GST values
  static InvoiceItem createInvoiceItem(Product product, int quantity) {
    final gstValues = calculateGST(product, quantity);

    return InvoiceItem(
      product: product,
      quantity: quantity,
      cgst: gstValues['cgst']!,
      sgst: gstValues['sgst']!,
      totalItemPrice: gstValues['totalPrice']!,
    );
  }
}
