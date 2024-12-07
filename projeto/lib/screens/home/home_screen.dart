// lib/screens/home/home_screen.dart
import 'package:flutter/material.dart';
import '../cart/cart_screen.dart';
import '../product/product_list_screen.dart';
import '../profile/profile_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Índice do menu de navegação selecionado
  int _selectedIndex = 0;

  // Lista de ecrãs associados às opções do menu
  final List<Widget> _screens = [
    const ProductListScreen(),
    const CartScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Corpo do ecrã, exibindo o ecrã correspondente ao índice selecionado
      body: _screens[_selectedIndex],

      // Barra de navegação inferior
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,

        // Atualiza o índice selecionado
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },

        items: const [
          // Produtos
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Produtos',
          ),

          // Carrinho
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_cart),
            label: 'Carrinho',
          ),

          // Perfil
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
