import 'package:flutter/material.dart';
import 'package:projeto/widgets/header.dart';
import 'package:projeto/data/services/api_service.dart';
import '../product/product_list_screen.dart';

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

  @override
  void initState() {
    super.initState();
    _cartItems = _loadCartItems();
  }

  // GET Cart
  Future<List<dynamic>> _loadCartItems() async {
    final cart = await _apiService.getCart();
    return List<Map<String, dynamic>>.from(cart['items'] ?? []);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(
        title: "Confirmação",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Resumo dos Itens no Carrinho
            const Text(
              "Carrinho",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.underline,
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
                  return const Center(
                    child: Text("Carrinho vazio."),
                  );
                } else {
                  final items = snapshot.data!;
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: items.map((item) {
                      final productName = item['name'] ?? 'Artigo Desconhecido';
                      final quantity = item['quantity'] ?? 1;
                      final price = item['price'] ?? 0.0;
                      return Text(
                        "$productName - Quantidade: $quantity - Preço: €${(quantity * price).toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 16),
                      );
                    }).toList(),
                  );
                }
              },
            ),
            const SizedBox(height: 32),

            // Total
            Text(
              "Total: €${widget.total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),

            // Pagamento
            const SizedBox(height: 32),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Método de Pagamento: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text: widget.paymentMethod,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Detalhes do Pagamento
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Detalhes do Pagamento: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text: widget.paymentDetail,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Morada
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Morada: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text: widget.address,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),

            // Localização
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: "Localização: ",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  TextSpan(
                    text: widget.location,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
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
          child: ElevatedButton(
            onPressed: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProductListScreen(),
                ),
                    (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("Confirmar Ordem"),
          ),
        ),
      ),
    );
  }
}
