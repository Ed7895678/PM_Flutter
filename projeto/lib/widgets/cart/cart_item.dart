import 'package:flutter/material.dart';
import '../../main.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  Map<String, dynamic>? _cart;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCart();
  }

  Future<void> _loadCart() async {
    try {
      final cart = await apiService.getCart();
      setState(() {
        _cart = cart;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  Future<void> _updateQuantity(String productId, int quantity) async {
    try {
      final items = _cart?['items'].map((item) {
        if (item['product_id'] == productId) {
          return {'product_id': productId, 'quantity': quantity};
        }
        return item;
      }).toList();

      await apiService.updateCart(List<Map<String, dynamic>>.from(items));
      _loadCart();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final items = _cart?['items'] ?? [];
    final total = _cart?['total'] ?? 0.0;

    return Scaffold(
      appBar: AppBar(title: const Text('Carrinho')),
      body: items.isEmpty
          ? const Center(child: Text('Carrinho vazio'))
          : ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Card(
            margin: const EdgeInsets.all(8),
            child: ListTile(
              leading: Image.network(
                item['image_url'] ?? '',
                width: 50,
                errorBuilder: (_, __, ___) => const Icon(Icons.image),
              ),
              title: Text(item['name'] ?? ''),
              subtitle: Text('€${item['price']?.toString() ?? "0.00"}'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => _updateQuantity(
                      item['product_id'],
                      item['quantity'] - 1,
                    ),
                  ),
                  Text('${item['quantity']}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => _updateQuantity(
                      item['product_id'],
                      item['quantity'] + 1,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: items.isEmpty
          ? null
          : SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
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
                    '€${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    try {
                      await apiService.createOrder({
                        'items': items,
                        'total': total,
                        'shipping_address': 'Endereço de exemplo',
                        'payment_method': 'MBWAY',
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
                          SnackBar(content: Text(e.toString())),
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
