import 'product.dart';

class InvoiceItem {
  final Product product;
  final int quantity;
  final double cgst;
  final double sgst;
  final double totalItemPrice;

  const InvoiceItem({
    required this.product,
    required this.quantity,
    required this.cgst,
    required this.sgst,
    required this.totalItemPrice,
  });

  Map<String, dynamic> toJson() => {
    'product': product.toJson(),
    'quantity': quantity,
    'cgst': cgst,
    'sgst': sgst,
    'totalItemPrice': totalItemPrice,
  };

  factory InvoiceItem.fromJson(Map<String, dynamic> json) => InvoiceItem(
    product: Product.fromJson(json['product']),
    quantity: json['quantity'],
    cgst: json['cgst'],
    sgst: json['sgst'],
    totalItemPrice: json['totalItemPrice'],
  );
}
