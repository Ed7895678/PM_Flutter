import 'package:flutter/material.dart';

class CartItemWidget extends StatelessWidget {
  const CartItemWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              color: Colors.grey[200],
              child: const Center(
                child: Icon(Icons.phone_android),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nome do Produto',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Text('€999.99'),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {},
                      ),
                      const Text('1'),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {},
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}