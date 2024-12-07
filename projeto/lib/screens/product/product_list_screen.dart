import 'package:flutter/material.dart';
import '../../main.dart';
import '../../widgets/header.dart';
import 'product_detail_screen.dart';

// Ecrã de listagem de produtos
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State {
  List _products = []; // Lista completa de produtos
  List _filteredProducts = []; // Lista filtrada de produtos
  List _categories = []; // Lista de categorias disponíveis
  String _selectedCategory = 'Todos'; // Categoria selecionada
  bool _isLoading = true; // Indicador de carregamento de produtos
  bool _isCategoriesLoading = true; // Indicador de carregamento de categorias
  final TextEditingController _searchController = TextEditingController(); // Controlador para pesquisa
  String _searchQuery = ''; // Texto de pesquisa atual

  @override
  void initState() {
    super.initState();
    _loadCategories(); // Carrega as categorias ao iniciar
    _loadProducts(); // Carrega os produtos ao iniciar

    // Atualiza a lista de produtos conforme o usuário digita na pesquisa
    _searchController.addListener(() {
      _filterProductsBySearch(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose(); // Libera o controlador ao fechar o widget
    super.dispose();
  }

  // Carrega as categorias a partir da API
  Future<void> _loadCategories() async {
    try {
      final categories = await apiService.getCategories();

      setState(() {
        _categories = [
          {'_id': 'Todos', 'name': 'Todos'}
        ];

        _categories.addAll(
          categories.map((category) => Map.from(category)),
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

  // Carrega os produtos, podendo ser filtrados por categoria
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

  // Filtra os produtos com base na pesquisa
  void _filterProductsBySearch(String searchQuery) {
    setState(() {
      _searchQuery = searchQuery;
      if (searchQuery.isEmpty) {
        _filteredProducts = _products;
      } else {
        _filteredProducts = _products.where((product) {
          return product['name']
              .toString()
              .toLowerCase()
              .contains(searchQuery.toLowerCase());
        }).toList();
      }
    });
  }

  // Filtra os produtos por categoria
  void _filterByCategory(String categoryId) async {
    setState(() => _selectedCategory = categoryId);

    // Recarrega os produtos se a categoria mudar
    await _loadProducts(categoryId);

    // Aplica o filtro de pesquisa, se houver
    if (_searchQuery.isNotEmpty) {
      _filterProductsBySearch(_searchQuery);
    }
  }

  // Exibe o modal para seleção de categoria
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
                  _filterByCategory(category['_id']);
                },
              );
            }).toList(),
          ],
        ),
      ),
    );
  }

  // Adiciona um produto ao carrinho
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
          // Campo de pesquisa e botão de categorias
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Campo de pesquisa
                Expanded(
                  flex: 2,
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Pesquisar produtos...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: BorderSide(color: Colors.grey[300]!),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30.0),
                        borderSide: const BorderSide(color: Colors.blue),
                      ),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Botão de filtro por categorias
                Expanded(
                  flex: 1,
                  child: ElevatedButton.icon(
                    onPressed: _showFilterModal,
                    label: const Text('Categorias'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Lista de produtos
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
                        // Imagem do produto
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
                        // Nome, preço e botão de adicionar ao carrinho
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
                                  style: ElevatedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                  ),
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
