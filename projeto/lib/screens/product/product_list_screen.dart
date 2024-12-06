import 'package:flutter/material.dart';
import '../../main.dart';
import '../../widgets/header.dart';
import 'product_detail_screen.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State {
  List _products = [];
  List _filteredProducts = [];
  List _categories = [];
  String _selectedCategory = 'Todos';
  bool _isLoading = true;
  bool _isCategoriesLoading = true;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadCategories();
    _loadProducts();

    _searchController.addListener(() {
      _filterProducts(_selectedCategory, _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await apiService.getCategories();

      setState(() {
        _categories = [
          {'_id': 'Todos', 'name': 'Todos'}
        ];

        _categories.addAll(
          categories.map(
                (category) => Map.from(category),
          ),
        );

        _isCategoriesLoading = false;
      });
    } catch (e) {
      setState(() => _isCategoriesLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar categorias: $e')),
        );
      }
    }
  }

  Future<void> _loadProducts([String? categoryId]) async {
    try {
      setState(() => _isLoading = true);
      final products = await apiService.getProducts(categoryId: categoryId);

      setState(() {
        _products = products;
        _filteredProducts = products;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar produtos: $e')),
        );
      }
    }
  }

  void _filterProducts(String categoryId, [String? searchQuery]) {
    setState(() {
      _selectedCategory = categoryId;
      _searchQuery = searchQuery ?? _searchQuery;

      _loadProducts(categoryId).then((_) {
        if (_searchQuery.isNotEmpty) {
          _filteredProducts = _products.where((product) {
            return product['name']
                .toString()
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
          }).toList();
        }
      });
    });
  }

  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Selecionar Categoria',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ..._categories.map((category) {
              return ListTile(
                title: Text(category['name']),
                onTap: () {
                  Navigator.pop(context);
                  _filterProducts(category['_id'], _searchQuery);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  Future _addToCart(Map product) async {
    try {
      final currentCart = await apiService.getCart();
      List<Map<String, dynamic>> currentItems =
      List<Map<String, dynamic>>.from(currentCart['items'] ?? []);

      int existingIndex = currentItems
          .indexWhere((item) => item['product_id'] == product['_id']);

      if (existingIndex != -1) {
        currentItems[existingIndex]['quantity']++;
      } else {
        currentItems.add({
          'product_id': product['_id'],
          'quantity': 1,
        });
      }

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
    if (_isLoading || _isCategoriesLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: const Header(title: "Produtos"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Barra de pesquisa
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Pesquisar produtos...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Botão de Categorias
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: _showFilterModal,
                    label: const Text('Categorias'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: _filteredProducts.isEmpty
                ? const Center(
              child: Text(
                'Nenhum produto encontrado.',
                style: TextStyle(fontSize: 16),
              ),
            )
                : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.7,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _filteredProducts.length,
              itemBuilder: (context, index) {
                final product = _filteredProducts[index];
                return Card(
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            productId: product['_id'],
                          ),
                        ),
                      );
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[100],
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                            child: Center(
                              child: Image.network(
                                product['image_url'] ?? '',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                const Icon(Icons.image, size: 50),
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['name'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '€${product['price']?.toString() ?? "0.00"}',
                                style: const TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: () => _addToCart(product),
                                  child: const Text('Adicionar'),
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
            ),
          ),
        ],
      ),
    );
  }
}