import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const CircleAvatar(
            radius: 50,
            child: Icon(Icons.person, size: 50),
          ),
          const SizedBox(height: 16),
          const Text(
            'Nome do Usuário',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 32),
          ListTile(
            leading: const Icon(Icons.shopping_bag),
            title: const Text('Meus Pedidos'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Endereços'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Configurações'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.exit_to_app),
            title: const Text('Sair'),
            onTap: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
    );
  }
}
