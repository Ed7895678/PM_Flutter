import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final String name;
  final double price;
  final String? imageUrl;
  final VoidCallback onAddToCart;

  const ProductCard({
    super.key,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
              ),
              child: Center(
                child: imageUrl != null && imageUrl!.isNotEmpty
                    ? Image.network(
                  imageUrl!,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(Icons.phone_android, size: 50);
                  },
                )
                    : const Icon(Icons.phone_android, size: 50),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  '€${price.toStringAsFixed(2)}',
                  style: const TextStyle(color: Colors.green),
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onAddToCart,
                    child: const Text('Adicionar'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}