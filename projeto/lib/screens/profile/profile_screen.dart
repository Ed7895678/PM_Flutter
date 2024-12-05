// lib/screens/profile/profile_screen.dart
import 'package:flutter/material.dart';
import '../../main.dart';
import '../../widgets/header.dart';
import '../order/order_list_screen.dart';
import 'addresses_list_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      // Header
      appBar: const Header(
        title: "Perfil",
      ),

      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Nome de User
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),

          // Pedidos Realizados
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Meus Pedidos'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OrderListScreen(),
                ),
              );
            },
          ),

          // Endereços
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Endereços'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddressesListScreen(),
                ),
              );
            },
          ),

          // Sair da Conta
          const Divider(),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
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
