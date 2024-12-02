// lib/screens/cart/cart_screen.dart
import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
      ),
      body: const Center(
        child: Text('Tela do Carrinho'),
      ),
    );
  }
}