import 'package:flutter/material.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Carrinho'),
      ),
      body: ListView.builder(
        itemCount: 0, // Temporário
        itemBuilder: (context, index) {
          return const CartItemWidget();
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {},
            child: const Text('Finalizar Compra'),
          ),
        ),
      ),
    );
  }
}
