// lib/screens/address/addresses_list_screen.dart
import 'package:flutter/material.dart';
import '../../widgets/header.dart';

class AddressesListScreen extends StatelessWidget {
  const AddressesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const Header(
        title: "Lista de Endereços",
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              "Selecione um endereço ou adicione um novo:",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Lista de endereços (simulada)
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.home),
                    title: const Text("Rua das Flores, 123"),
                    subtitle: const Text("Lisboa, Portugal"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Lógica de seleção de endereço
                      },
                      child: const Text("Selecionar"),
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    leading: const Icon(Icons.work),
                    title: const Text("Avenida Principal, 456"),
                    subtitle: const Text("Porto, Portugal"),
                    trailing: ElevatedButton(
                      onPressed: () {
                        // Lógica de seleção de endereço
                      },
                      child: const Text("Selecionar"),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Lógica para adicionar um novo endereço
              },
              child: const Text("Adicionar Novo Endereço"),
            ),
          ],
        ),
      ),
    );
  }
}
