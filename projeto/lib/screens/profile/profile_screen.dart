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
      // Cabeçalho do ecrã
      appBar: const Header(
        title: "Perfil",
      ),

      // Corpo do ecrã com as opções do perfil
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Avatar do usuário
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),

          const SizedBox(height: 32),

          // Pedidos realizados
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

          // Gerir endereços
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

          // Separador visual antes da opção de sair
          const Divider(),

          // Sair da conta
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sair'),
            onTap: () {
              // Remove o token de autenticação e redireciona para o login
              apiService.setToken('');
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
