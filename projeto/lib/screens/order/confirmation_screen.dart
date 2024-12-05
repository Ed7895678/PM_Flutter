import 'package:flutter/material.dart';
import 'package:projeto/widgets/header.dart';
import 'package:projeto/data/services/api_service.dart';
import '../home/home_screen.dart';

class ConfirmationScreen extends StatefulWidget {
  final String paymentMethod;
  final String paymentDetail;
  final String address;
  final String location;
  final double total;

  const ConfirmationScreen({
    super.key,
    required this.paymentMethod,
    required this.paymentDetail,
    required this.address,
    required this.location,
    required this.total,
  });

  @override
  State<ConfirmationScreen> createState() => _ConfirmationScreenState();
}

class _ConfirmationScreenState extends State<ConfirmationScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<dynamic>> _cartItems;
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    await _loadProducts();
    _cartItems = _loadCartItems();
  }

  Future<void> _loadProducts() async {
    try {
      final products = await _apiService.getProducts();
      setState(() {
        _products = List<Map<String, dynamic>>.from(products);
      });
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
    }
  }

  Future<List<dynamic>> _loadCartItems() async {
    final cart = await _apiService.getCart();
    return List<Map<String, dynamic>>.from(cart['items'] ?? []);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(title: "Confirmação"),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Carrinho",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<dynamic>>(
                future: _cartItems,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar os artigos: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  } else if (snapshot.hasData && snapshot.data!.isEmpty) {
                    return const Center(child: Text("Carrinho vazio."));
                  } else {
                    final items = snapshot.data!;
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: items.length,
                      itemBuilder: (context, index) {
                        final item = items[index];
                        final product = _findProduct(item['product_id']);
                        final quantity = item['quantity'] ?? 1;
                        final price = product?['price'] ?? 0.0;
                        final totalPrice = quantity * price;

                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
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
                                    product?['image_url'] ?? '',
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
                                        product?['name'] ?? 'Artigo Desconhecido',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        'Quantidade: $quantity',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Preço: €${price.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 14),
                                      ),
                                      Text(
                                        'Total: €${totalPrice.toStringAsFixed(2)}',
                                        style: const TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 32),
              Text(
                "Total: €${widget.total.toStringAsFixed(2)}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              buildPaymentDetails(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: buildConfirmButton(context),
    );
  }

  Widget buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildInfoRow("Método de Pagamento", widget.paymentMethod),
        const SizedBox(height: 8),
        buildInfoRow("Detalhes do Pagamento", widget.paymentDetail),
        const SizedBox(height: 8),
        buildInfoRow("Morada", widget.address),
        const SizedBox(height: 8),
        buildInfoRow("Localização", widget.location),
      ],
    );
  }

  Widget buildInfoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: "$label: ",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          TextSpan(
            text: value,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget buildConfirmButton(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () async {
            setState(() => _isLoading = true);
            try {
              final cart = await _apiService.getCart();
              final items = cart['items'] ?? [];

              final orderItems = (items as List<dynamic>).map((item) {
                final product = _findProduct(item['product_id']);
                return {
                  'product_id': item['product_id'],
                  'quantity': item['quantity'],
                  'product_name': product?['name'] ?? '',
                  'product_image_url': product?['image_url'] ?? '',
                  'product_price': product?['price'] ?? 0.0,
                };
              }).toList();

              final orderData = {
                "shipping_address": "${widget.address}, ${widget.location}",
                "payment_method": widget.paymentMethod.toUpperCase(),
                "items": orderItems,
                "total": widget.total,
                "status": "pending",
              };

              await _apiService.createOrder(orderData);
              await _apiService.updateCart([]);

              setState(() => _isLoading = false);

              if (context.mounted) {
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Sucesso'),
                    content: const Text('Obrigado/a pela sua encomenda'),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
                        },
                      ),
                    ],
                  ),
                );
              }
            } catch (e) {
              setState(() => _isLoading = false);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro ao criar encomenda: $e')),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: const Text("Confirmar Ordem"),
        ),
      ),
    );
  }
}