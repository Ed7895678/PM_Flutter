// lib/screens/product/product_detail_screen.dart
import 'package:flutter/material.dart';
import '../../main.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  Map<String, dynamic>? _product;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

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

  Future<void> _addToCart() async {
    try {
      // Obter carrinho atual
      final currentCart = await apiService.getCart();
      List<Map<String, dynamic>> currentItems =
      List<Map<String, dynamic>>.from(currentCart['items'] ?? []);

      // Verificar se produto já existe
      int existingIndex = currentItems.indexWhere(
              (item) => item['product_id'] == _product!['_id']
      );

      if (existingIndex != -1) {
        // Se existe, incrementar quantidade
        currentItems[existingIndex]['quantity']++;
      } else {
        // Se não existe, adicionar novo item
        currentItems.add({
          'product_id': _product!['_id'],
          'quantity': 1,
        });
      }

      // Atualizar carrinho
      await apiService.updateCart(currentItems);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Produto adicionado ao carrinho')),
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
      appBar: AppBar(
        title: Text(_product!['name']),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 300,
              width: double.infinity,
              color: Colors.grey[100],
              child: Image.network(
                _product!['image_url'] ?? '',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 100),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _product!['name'],
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '€${_product!['price']}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _product!['description'] ?? '',
                    style: const TextStyle(fontSize: 16),
                  ),
                  if (_product!['specs'] != null) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Especificações',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ..._buildSpecifications(_product!['specs']),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _addToCart,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Adicionar ao Carrinho'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

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