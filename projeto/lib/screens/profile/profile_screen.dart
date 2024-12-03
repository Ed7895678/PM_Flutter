import 'package:flutter/material.dart';
import '../../main.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<dynamic> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadOrders();
  }

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
          SnackBar(content: Text(e.toString())),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
        children: [
          const ListTile(
            leading: CircleAvatar(child: Icon(Icons.person)),
            title: Text('Nome do Usuário'),
            subtitle: Text('user@example.com'),
          ),
          const Divider(),
          const ListTile(
            title: Text(
              'Pedidos',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          if (_orders.isEmpty)
            const Center(child: Text('Nenhum pedido encontrado'))
          else
            ...(_orders.map((order) => ListTile(
              title: Text('Pedido #${order['_id']}'),
              subtitle: Text(
                'Status: ${order['status']}\n'
                    'Total: €${order['total']?.toString() ?? "0.00"}',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                // Implementar detalhes do pedido
              },
            ))),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () {
              apiService.setToken('');
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}