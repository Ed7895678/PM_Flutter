import 'package:flutter/material.dart';
import '../../main.dart';
import '../../widgets/header.dart';

// Ecrã de detalhes do produto
class ProductDetailScreen extends StatefulWidget {
  final String productId; // ID do produto

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _product; // Dados do produto
  bool _isLoading = true; // Indicador de carregamento
  int _quantity = 1; // Quantidade do produto selecionada

  @override
  void initState() {
    super.initState();
    _loadProduct(); // Carrega os dados do produto ao inicializar o ecrã
  }

  // Função para carregar os dados do produto
  Future<void> _loadProduct() async {
    try {
      final List<dynamic> products = await apiService.getProducts();
      final product = products.firstWhere(
            (p) => p['_id'] == widget.productId,
        orElse: () => null,
      );

      setState(() {
        _product = product;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar produto: $e')),
        );
      }
    }
  }

  // Incrementa a quantidade
  void _incrementQuantity() {
    if (_product != null && _quantity < _product!['stock']) {
      setState(() {
        _quantity++;
      });
    }
  }

  // Decrementa a quantidade
  void _decrementQuantity() {
    if (_quantity > 1) {
      setState(() {
        _quantity--;
      });
    }
  }

  // Adiciona o produto ao carrinho
  Future<void> _addToCart() async {
    try {
      final currentCart = await apiService.getCart();
      List<Map<String, dynamic>> currentItems =
      List<Map<String, dynamic>>.from(currentCart['items'] ?? []);

      int existingIndex = currentItems.indexWhere(
              (item) => item['product_id'] == _product!['_id']);

      if (existingIndex != -1) {
        currentItems[existingIndex]['quantity'] += _quantity;
      } else {
        currentItems.add({
          'product_id': _product!['_id'],
          'quantity': _quantity,
        });
      }

      await apiService.updateCart(currentItems);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${_quantity} unidade(s) adicionada(s) ao carrinho')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao adicionar ao carrinho: $e')),
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

    if (_product == null) {
      return const Scaffold(
        body: Center(child: Text('Produto não encontrado')),
      );
    }

    return Scaffold(
      // Cabeçalho com o nome do produto
      appBar: Header(
        title: _product!['name'],
      ),

      // Corpo do ecrã
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Imagem do produto
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[100],
              child: Image.network(
                _product!['image_url'] ?? '',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) =>
                const Icon(Icons.image, size: 100),
              ),
            ),

            // Detalhes do produto
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [

                  // Nome do produto
                  Text(
                    _product!['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Preço do produto
                  Text(
                    '€${_product!['price']}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Descrição do produto
                  Text(
                    _product!['description'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),

                  const SizedBox(height: 24),

                  // Especificações do produto
                  const Text(
                    'Especificações',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),

                  if (_product!['specs'] != null)
                    ..._buildSpecifications(_product!['specs']),

                  const SizedBox(height: 16),

                  // Informações de stock
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Stock: ',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_product!['stock'] ?? 'Indisponível'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Mudar quantidade
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: _quantity <= 1 ? null : _decrementQuantity,
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: _incrementQuantity,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),

      // Botão para adicionar ao carrinho
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Adicionar ao Carrinho'),
          ),
        ),
      ),
    );
  }

  // Constrói a lista de especificações do produto
  List<Widget> _buildSpecifications(Map<String, dynamic> specs) {
    return specs.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${entry.key}: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Expanded(
              child: Text(entry.value.toString()),
            ),
          ],
        ),
      );
    }).toList();
  }
}
