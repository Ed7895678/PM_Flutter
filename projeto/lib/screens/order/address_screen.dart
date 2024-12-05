import 'package:flutter/material.dart';
import 'confirmation_screen.dart';
import 'package:projeto/widgets/header.dart';

class AddressScreen extends StatefulWidget {
  final String paymentMethod;
  final String paymentDetail;
  final double total;

  const AddressScreen({
    super.key,
    required this.paymentMethod,
    required this.paymentDetail,
    required this.total,
  });

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(
        title: "Informações de Endereço",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Campo para "Morada"
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Morada",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            // Campo para "Localização"
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Localização",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: SafeArea(
          child: ElevatedButton(
            onPressed: () {
              // Navegar para a tela de confirmação com os detalhes
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConfirmationScreen(
                    paymentMethod: widget.paymentMethod,
                    paymentDetail: widget.paymentDetail,
                    address: _addressController.text,
                    location: _locationController.text,
                    total: widget.total,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text("Continuar"),
          ),
        ),
      ),
    );
  }
}
