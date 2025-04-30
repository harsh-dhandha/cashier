import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/invoice_provider.dart';
import '../models/invoice.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  final dateFormat = DateFormat('dd-MM-yyyy HH:mm');

  @override
  void initState() {
    super.initState();
    // Load invoices
    Future.microtask(
      () => Provider.of<InvoiceProvider>(context, listen: false).loadInvoices(),
    );
  }

  void _showInvoiceDetails(Invoice invoice) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (context) => DraggableScrollableSheet(
            initialChildSize: 0.9,
            minChildSize: 0.5,
            maxChildSize: 0.9,
            expand: false,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Invoice #${invoice.invoiceId}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    Text(
                      'Date: ${dateFormat.format(invoice.timestamp)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Items',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: ListView.builder(
                        controller: scrollController,
                        itemCount: invoice.items.length,
                        itemBuilder: (context, index) {
                          final item = invoice.items[index];
                          return ListTile(
                            title: Text(item.product.name),
                            subtitle: Text(
                              'Qty: ${item.quantity} × ₹${item.product.price.toStringAsFixed(2)}',
                            ),
                            trailing: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  '₹${item.totalItemPrice.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  'GST: ${item.product.gstRate.toStringAsFixed(1)}%',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('CGST:'),
                        Text('₹${invoice.totalCgst.toStringAsFixed(2)}'),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('SGST:'),
                        Text('₹${invoice.totalSgst.toStringAsFixed(2)}'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Grand Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          '₹${invoice.grandTotal.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          // TODO: Share or print invoice functionality
                          Navigator.pop(context);
                        },
                        child: const Text('Print Receipt'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Invoice History')),
      body: Consumer<InvoiceProvider>(
        builder: (context, invoiceProvider, child) {
          if (invoiceProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (invoiceProvider.invoices.isEmpty) {
            return const Center(child: Text('No invoices found'));
          }

          return ListView.separated(
            itemCount: invoiceProvider.invoices.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final invoice = invoiceProvider.invoices[index];
              return ListTile(
                title: Text('Invoice #${invoice.invoiceId}'),
                subtitle: Text(dateFormat.format(invoice.timestamp)),
                trailing: Text(
                  '₹${invoice.grandTotal.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                onTap: () => _showInvoiceDetails(invoice),
              );
            },
          );
        },
      ),
    );
  }
}
