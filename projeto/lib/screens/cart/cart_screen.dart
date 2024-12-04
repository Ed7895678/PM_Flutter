// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';
import '../../main.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? _cart;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = true;
  double _total = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadProducts();
    await _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final cart = await apiService.getCart();
      setState(() {
        _cart = cart;
        _isLoading = false;
        if (_products.isNotEmpty) {
          _calculateTotal();
        }
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar carrinho: $e')),
        );
      }
    }
  }

  Future<void> _loadProducts() async {
    try {
      final products = await apiService.getProducts();
      setState(() {
        _products = List<Map<String, dynamic>>.from(products);
        _calculateTotal();
      });
    } catch (e) {
      print('Erro ao carregar produtos: $e');
    }
  }

  void _calculateTotal() {
    if (_products.isEmpty) return;

    double total = 0;
    final items = _cart?['items'] ?? [];
    for (var item in items) {
      final product = _findProduct(item['product_id']);
      if (product != null && product['price'] != null) {
        total += (product['price'] * item['quantity']);
      }
    }
    setState(() {
      _total = total;
    });
  }

  Map<String, dynamic>? _findProduct(String productId) {
    try {
      return _products.firstWhere(
            (product) => product['_id'] == productId,
        orElse: () => {},
      );
    } catch (e) {
      return null;
    }
  }

  Future<void> _updateQuantity(String productId, int newQuantity) async {
    try {
      List<Map<String, dynamic>> currentItems = List<Map<String, dynamic>>.from(_cart?['items'] ?? []);

      if (newQuantity <= 0) {
        currentItems.removeWhere((item) => item['product_id'] == productId);
      } else {
        var itemIndex = currentItems.indexWhere((item) => item['product_id'] == productId);
        if (itemIndex != -1) {
          currentItems[itemIndex]['quantity'] = newQuantity;
        }
      }

      await apiService.updateCart(currentItems);
      await _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao atualizar carrinho: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final items = _cart?['items'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: items.isEmpty
          ? const Center(child: Text('Carrinho vazio'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final product = _findProduct(item['product_id']);

          if (product == null || product.isEmpty) {
            return const SizedBox();
          }

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.network(
                      product['image_url'] ?? '',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(Icons.image),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product['name'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '€${product['price']?.toString() ?? "0.00"}',
                          style: const TextStyle(
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove),
                              onPressed: () => _updateQuantity(
                                item['product_id'],
                                item['quantity'] - 1,
                              ),
                            ),
                            Text(item['quantity'].toString()),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () => _updateQuantity(
                                item['product_id'],
                                item['quantity'] + 1,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _updateQuantity(item['product_id'], 0),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: items.isEmpty
          ? null
          : Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total:',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '€${_total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () async {
                    try {
                      // Criar pedido com todos os campos obrigatórios
                      await apiService.createOrder({
                        'items': _cart?['items'] ?? [],
                        'shipping_address': 'Rua Exemplo 123, Lisboa',
                        'payment_method': 'MBWAY',
                        'total': _total,
                      });

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Pedido realizado com sucesso'),
                          ),
                        );
                        Navigator.pushReplacementNamed(context, '/home');
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Erro ao criar pedido: $e')),
                        );
                      }
                    }
                  },
                  child: const Text('Finalizar Compra'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}