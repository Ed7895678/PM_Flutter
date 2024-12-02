import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';

class ProductCard extends StatelessWidget {
  final ProductModel product;
  final VoidCallback onTap;

  const ProductCard({
    super.key,
    required this.product,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
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
                  child: Image.network(
                    product.imageUrl,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.phone_android, size: 50);
                    },
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product.name,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '€${product.price.toStringAsFixed(2)}',
                    style: const TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
