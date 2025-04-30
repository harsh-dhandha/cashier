import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import '../models/invoice.dart';

class ExportService {
  // Generate PDF from invoice data and share it
  Future<void> generateAndSharePDF(
    BuildContext context,
    Invoice invoice,
  ) async {
    try {
      // Create a PDF document
      final pdf = pw.Document();

      // Add a page to the PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  'INVOICE',
                  style: pw.TextStyle(
                    fontSize: 24,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 10),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('Invoice #: ${invoice.invoiceId}'),
                    pw.Text(
                      'Date: ${DateFormat('dd-MM-yyyy HH:mm').format(invoice.timestamp)}',
                    ),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 20),

                // Table header
                pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 3,
                      child: pw.Text(
                        'Item',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 1,
                      child: pw.Text(
                        'Qty',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Price',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'GST',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        'Total',
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                pw.Divider(),

                // Invoice items
                pw.Column(
                  children:
                      invoice.items.map((item) {
                        return pw.Row(
                          children: [
                            pw.Expanded(
                              flex: 3,
                              child: pw.Text(item.product.name),
                            ),
                            pw.Expanded(
                              flex: 1,
                              child: pw.Text('${item.quantity}'),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                '₹${item.product.price.toStringAsFixed(2)}',
                              ),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text('${item.product.gstRate}%'),
                            ),
                            pw.Expanded(
                              flex: 2,
                              child: pw.Text(
                                '₹${item.totalItemPrice.toStringAsFixed(2)}',
                              ),
                            ),
                          ],
                        );
                      }).toList(),
                ),

                pw.Divider(),
                pw.SizedBox(height: 20),

                // Summary
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('CGST: '),
                    pw.SizedBox(width: 10),
                    pw.Text('₹${invoice.totalCgst.toStringAsFixed(2)}'),
                  ],
                ),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text('SGST: '),
                    pw.SizedBox(width: 10),
                    pw.Text('₹${invoice.totalSgst.toStringAsFixed(2)}'),
                  ],
                ),
                pw.SizedBox(height: 5),
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Text(
                      'Grand Total: ',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                    pw.SizedBox(width: 10),
                    pw.Text(
                      '₹${invoice.grandTotal.toStringAsFixed(2)}',
                      style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                    ),
                  ],
                ),

                pw.SizedBox(height: 40),
                pw.Center(
                  child: pw.Text(
                    'Thank you for your business!',
                    style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
                  ),
                ),
              ],
            );
          },
        ),
      );

      // Save the PDF to a file
      final directory = await getTemporaryDirectory();
      final dateFormat = DateFormat('yyyyMMdd_HHmmss');
      final timestamp = dateFormat.format(DateTime.now());
      final fileName = 'Invoice_${invoice.invoiceId}_$timestamp.pdf';
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      // Share the PDF
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Invoice #${invoice.invoiceId}',
        text:
            'Invoice generated on ${DateFormat('dd-MM-yyyy HH:mm').format(invoice.timestamp)}',
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate PDF: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
