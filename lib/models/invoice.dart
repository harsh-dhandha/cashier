import 'invoice_item.dart';

class Invoice {
  final String invoiceId;
  final DateTime timestamp;
  final List<InvoiceItem> items;
  final double totalCgst;
  final double totalSgst;
  final double grandTotal;

  const Invoice({
    required this.invoiceId,
    required this.timestamp,
    required this.items,
    required this.totalCgst,
    required this.totalSgst,
    required this.grandTotal,
  });

  Map<String, dynamic> toJson() => {
    'invoiceId': invoiceId,
    'timestamp': timestamp.toIso8601String(),
    'items': items.map((item) => item.toJson()).toList(),
    'totalCgst': totalCgst,
    'totalSgst': totalSgst,
    'grandTotal': grandTotal,
  };

  factory Invoice.fromJson(Map<String, dynamic> json) => Invoice(
    invoiceId: json['invoiceId'],
    timestamp: DateTime.parse(json['timestamp']),
    items:
        (json['items'] as List)
            .map((item) => InvoiceItem.fromJson(item))
            .toList(),
    totalCgst: json['totalCgst'],
    totalSgst: json['totalSgst'],
    grandTotal: json['grandTotal'],
  );
}
