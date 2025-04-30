import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/invoice.dart';

class InvoiceDetailView extends StatelessWidget {
  final Invoice invoice;

  const InvoiceDetailView({Key? key, required this.invoice}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'INVOICE',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Invoice #${invoice.invoiceId}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Date: ${dateFormat.format(invoice.timestamp)}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const Divider(thickness: 2),
          const SizedBox(height: 10),

          // Table header
          Row(
            children: const [
              Expanded(
                flex: 3,
                child: Text(
                  'Item',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'Qty',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Price',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 1,
                child: Text(
                  'GST',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Expanded(
                flex: 2,
                child: Text(
                  'Total',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const Divider(),

          // Invoice items
          ...invoice.items
              .map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Expanded(flex: 3, child: Text(item.product.name)),
                      Expanded(flex: 1, child: Text('${item.quantity}')),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${item.product.price.toStringAsFixed(2)}',
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Text('${item.product.gstRate}%'),
                      ),
                      Expanded(
                        flex: 2,
                        child: Text(
                          '₹${item.totalItemPrice.toStringAsFixed(2)}',
                        ),
                      ),
                    ],
                  ),
                ),
              )
              .toList(),

          const Divider(),
          const SizedBox(height: 20),

          // Summary
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('CGST: '),
              const SizedBox(width: 10),
              Text('₹${invoice.totalCgst.toStringAsFixed(2)}'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text('SGST: '),
              const SizedBox(width: 10),
              Text('₹${invoice.totalSgst.toStringAsFixed(2)}'),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              const Text(
                'Grand Total: ',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 10),
              Text(
                '₹${invoice.grandTotal.toStringAsFixed(2)}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 40),
          const Center(
            child: Text(
              'Thank you for your business!',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
    );
  }
}
