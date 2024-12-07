import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../main.dart';
import '../../widgets/header.dart';

// Ecrã que exibe a lista de pedidos
class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  List<dynamic> _orders = []; // Lista de pedidos
  bool _isLoading = true; // Indica se os dados ainda estão a ser carregados

  @override
  void initState() {
    super.initState();
    _loadOrders(); // Carrega os pedidos ao inicializar o ecrã
  }

  // Carrega a lista de pedidos a partir da API
  Future<void> _loadOrders() async {
    try {
      final orders = await apiService.getOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao carregar pedidos: $e')),
        );
      }
    }
  }

  // Formata a data de um pedido
  String _formatDate(String dateStr) {
    try {
      final date = DateTime.parse(dateStr).toLocal();
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    } catch (e) {
      return 'Data indisponível';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // Exibe um indicador de carregamento enquanto os dados são carregados
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      // Cabeçalho do ecrã
      appBar: const Header(
        title: "Pedidos",
      ),

      // Corpo do ecrã com a lista de pedidos
      body: _orders.isEmpty
      // Mensagem caso não existam pedidos
          ? const Center(child: Text('Nenhum pedido encontrado'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];

          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),

              // Detalhes do pedido
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Pedido #${order['_id'].toString().substring(0, 8)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text('Data: ${_formatDate(order['created_at'] ?? '')}'),
                  Text(
                    'Status: ${order['status'] ?? "Indisponível"}',
                    style: TextStyle(
                      color: order['status'] == 'pending'
                          ? Colors.orange
                          : Colors.green,
                    ),
                  ),
                  Text(
                    'Total: €${order['total']?.toStringAsFixed(2) ?? "0.00"}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),

              // Ícone indicando que há mais detalhes disponíveis
              trailing: const Icon(Icons.chevron_right),

              // Ação ao clicar no pedido: exibe os detalhes em um modal
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) => OrderDetailsModal(order: order),
                  isScrollControlled: true,
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// Modal que exibe os detalhes de um pedido
class OrderDetailsModal extends StatelessWidget {
  final Map<String, dynamic> order;

  const OrderDetailsModal({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título do modal
            const Text(
              'Itens do Pedido:',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Lista de itens do pedido
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: order['items']?.length ?? 0,
              itemBuilder: (context, index) {
                final item = order['items'][index];
                final productName = item['product_name'] ?? 'Produto Indisponível';
                final productPrice = item['product_price'] ?? 0.0;
                final productImage = item['product_image_url'] ?? '';
                final quantity = item['quantity'] ?? 0;

                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: productImage.isNotEmpty
                  // Exibe a imagem do produto ou um ícone genérico
                      ? Image.network(
                    productImage,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image),
                  )
                      : const Icon(Icons.image),

                  // Nome do produto
                  title: Text(productName),

                  // Quantidade do produto
                  subtitle: Text('Quantidade: $quantity'),

                  // Preço total do item
                  trailing: Text(
                    '€${(productPrice * quantity).toStringAsFixed(2)}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                );
              },
            ),
            const Divider(),

            // Endereço de entrega
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Endereço de entrega'),
              subtitle: Text(order['shipping_address'] ?? 'Endereço não disponível'),
            ),

            // Método de pagamento
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Método de pagamento'),
              subtitle: Text(order['payment_method'] ?? 'Método não disponível'),
            ),
            const SizedBox(height: 16),

            // Total do pedido
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Total',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '€${order['total']?.toStringAsFixed(2) ?? "0.00"}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
