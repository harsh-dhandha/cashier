import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/product.dart';
import '../providers/product_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/invoice_provider.dart';
import '../widgets/product_tile.dart';
import '../widgets/invoice_summary.dart';
import 'product_screen.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({Key? key}) : super(key: key);

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  final _searchController = TextEditingController();
  List<Product> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    // Load products when screen initializes
    Future.microtask(
      () => Provider.of<ProductProvider>(context, listen: false).loadProducts(),
    );
  }

  Future<void> _searchProducts(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    final results = await Provider.of<ProductProvider>(
      context,
      listen: false,
    ).searchProducts(query);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  void _addToCart(Product product) {
    Provider.of<CartProvider>(context, listen: false).addProduct(product, 1);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${product.name} added to bill')));
  }

  Future<void> _generateInvoice() async {
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    if (cartProvider.items.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add items to generate invoice')),
      );
      return;
    }

    try {
      final invoice = await Provider.of<InvoiceProvider>(
        context,
        listen: false,
      ).createInvoice(cartProvider.items);

      cartProvider.clearCart();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Invoice #${invoice.invoiceId} generated successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to generate invoice: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cashier'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => Navigator.pushNamed(context, '/history'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search section
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Search products...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                    onChanged: (value) => _searchProducts(value),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton.icon(
                  onPressed:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProductScreen(),
                        ),
                      ),
                  icon: const Icon(Icons.add),
                  label: const Text('New'),
                ),
              ],
            ),
          ),

          // Search results
          if (_isSearching)
            const Center(child: CircularProgressIndicator())
          else if (_searchResults.isNotEmpty)
            Expanded(
              flex: 1,
              child: ListView.builder(
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final product = _searchResults[index];
                  return ProductTile(
                    product: product,
                    onTap: () => _addToCart(product),
                  );
                },
              ),
            ),

          // Current bill
          Consumer<CartProvider>(
            builder: (context, cart, child) {
              return Expanded(
                flex: 2,
                child:
                    cart.items.isEmpty
                        ? const Center(
                          child: Text('No items added to bill yet'),
                        )
                        : Column(
                          children: [
                            const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Current Bill',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: cart.items.length,
                                itemBuilder: (context, index) {
                                  final item = cart.items[index];
                                  return ListTile(
                                    title: Text(item.product.name),
                                    subtitle: Text(
                                      'Qty: ${item.quantity} × ₹${item.product.price.toStringAsFixed(2)}',
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          '₹${item.totalItemPrice.toStringAsFixed(2)}',
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => cart.removeItem(
                                                item.product.id,
                                              ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            ),
                            InvoiceSummary(
                              totalCgst: cart.totalCgst,
                              totalSgst: cart.totalSgst,
                              grandTotal: cart.grandTotal,
                            ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: ElevatedButton(
                                onPressed: _generateInvoice,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Theme.of(context).primaryColor,
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 15,
                                  ),
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: const Text(
                                  'Generate Invoice',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
