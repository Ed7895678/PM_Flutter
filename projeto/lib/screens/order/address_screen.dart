import 'package:flutter/material.dart';
import 'confirmation_screen.dart';

class AddressScreen extends StatefulWidget {
  const AddressScreen({super.key});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(
        title: const Text("Informações de Endereço"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Campo de Morada
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Morada",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Campo de Localização
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Localização",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 32),

            // Botão para confirmar
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ConfirmationScreen(),
                  ),
                );
              },

              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Continuar"),
            ),
          ],
        ),
      ),
    );
  }
}
