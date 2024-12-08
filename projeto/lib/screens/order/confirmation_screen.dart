import 'package:flutter/material.dart';
import 'package:projeto/widgets/header.dart';
import 'package:projeto/data/services/api_service.dart';
import '../home/home_screen.dart';

// Informações provenientes das paginas anteriores
class ConfirmationScreen extends StatefulWidget {
  final String paymentMethod; // Metodo de Pagamento
  final String paymentDetail; // Detalhes
  final String address; // Morada
  final String location; // Localização
  final double total; // Total

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
  final ApiService _apiService = ApiService(); // Serviço para interagir com a API
  late Future<List<dynamic>> _cartItems; // Itens do carrinho
  List<Map<String, dynamic>> _products = []; // Lista de produtos
  bool _isLoading = false; // Indicador de carregamento do pedido
  bool _isInitialized = false; // Verifica se os dados foram carregados

  @override
  void initState() {
    super.initState();
    debugPrint('ConfirmationScreen - initState');
    _initializeScreen(); // Inicializa os dados do ecrã
  }

  // Carrega os dados necessários
  Future<void> _initializeScreen() async {
    try {
      debugPrint('Iniciando carregamento dos dados');
      await _loadProducts();
      _cartItems = _loadCartItems();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
      debugPrint('Dados carregados com sucesso');
    } catch (e) {
      debugPrint('Erro ao inicializar tela: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar dados: $e')),
        );
      }
    }
  }

  // Carrega os produtos disponíveis
  Future<void> _loadProducts() async {
    try {
      debugPrint('Carregando produtos');
      final products = await _apiService.getProducts();
      if (mounted) {
        setState(() {
          _products = List<Map<String, dynamic>>.from(products);
        });
      }
      debugPrint('Produtos carregados: ${_products.length}');
    } catch (e) {
      debugPrint('Erro ao carregar produtos: $e');
      rethrow;
    }
  }

  // Carrega os itens do carrinho
  Future<List<dynamic>> _loadCartItems() async {
    try {
      debugPrint('Carregando itens do carrinho');
      final cart = await _apiService.getCart();
      final items = List<Map<String, dynamic>>.from(cart['items'] ?? []);
      debugPrint('Itens do carrinho carregados: ${items.length}');
      return items;
    } catch (e) {
      debugPrint('Erro ao carregar itens do carrinho: $e');
      rethrow;
    }
  }

  // Encontra os produtos pelo ID
  Map<String, dynamic>? _findProduct(String productId) {
    try {
      return _products.firstWhere(
            (product) => product['_id'] == productId,
        orElse: () => {},
      );
    } catch (e) {
      debugPrint('Erro ao encontrar produto: $e');
      return null;
    }
  }

  // Exibe os detalhes do pagamento, morada e localização
  Widget _buildPaymentDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow("Método de Pagamento", widget.paymentMethod),
        const SizedBox(height: 8),
        _buildInfoRow("", widget.paymentDetail),
        const SizedBox(height: 8),
        _buildInfoRow("Morada", widget.address),
        const SizedBox(height: 8),
        _buildInfoRow("Localização", widget.location),
      ],
    );
  }

  // Cria uma linha de informações com título e valor
  Widget _buildInfoRow(String label, String value) {
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

  // Botão para confirmar o pedido
  Widget _buildConfirmButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: _isLoading ? null : _confirmOrder,
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          child: _isLoading
              ? const SizedBox(
            height: 20,
            width: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Confirmar"),
        ),
      ),
    );
  }

  // Confirma o pedido e guarda os dados
  Future<void> _confirmOrder() async {
    setState(() => _isLoading = true);
    try {
      // Construção da Ordem
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

      // Criação da Ordem
      await _apiService.createOrder(orderData);
      await _apiService.updateCart([]);

      setState(() => _isLoading = false);

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao criar pedido: $e')),
        );
      }
    }
  }

  // Feedback ao utilizador
  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Sucesso'),
        content: const Text('Obrigado pela sua compra!'),
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

  // Estrutura da Pagina
  @override
  Widget build(BuildContext context) {
    if (!_isInitialized) {
      return const Scaffold(
        appBar: Header(title: "Confirmação"),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(

      appBar: const Header(title: "Confirmação do Pedido"),

      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                "Itens",
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

                  // Enquanto os itens não voltam, loading
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Erro ao retornar lista de itens
                  if (snapshot.hasError) {
                    return Center(
                      child: Text(
                        'Erro ao carregar os itens: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  }

                  // Verifica o estado do carrinho
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Carrinho vazio"));
                  }

                  // Usamos o Listview para mostrar cada item no carrinho
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
                                      product?['name'] ?? 'Produto Desconhecido',
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
                },
              ),
              // Total da ordem
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
              // Detalhes da compra
              const SizedBox(height: 32),
              _buildPaymentDetails(),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
      bottomNavigationBar: _buildConfirmButton(),
    );
  }
}
