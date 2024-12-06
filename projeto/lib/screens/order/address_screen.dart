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
  bool _isNavigating = false;

  void _navigateToConfirmation() async {
    // Evita múltiplos cliques durante a navegação
    if (_isNavigating) return;

    try {
      setState(() {
        _isNavigating = true;
      });

      // Validar campos
      if (_addressController.text.trim().isEmpty || _locationController.text.trim().isEmpty) {
        throw 'Por favor, preencha todos os campos do endereço';
      }

      debugPrint('Iniciando navegação para ConfirmationScreen');
      debugPrint('Método de Pagamento: ${widget.paymentMethod}');
      debugPrint('Detalhes do Pagamento: ${widget.paymentDetail}');
      debugPrint('Endereço: ${_addressController.text}');
      debugPrint('Localização: ${_locationController.text}');
      debugPrint('Total: ${widget.total}');

      if (!mounted) return;

      // Navegar para a próxima tela
      await Navigator.push(
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

      debugPrint('Navegação para ConfirmationScreen concluída com sucesso');
    } catch (e) {
      debugPrint('Erro durante a navegação: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString())),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isNavigating = false;
        });
      }
    }
  }

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
            TextField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: "Morada",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
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
            onPressed: _isNavigating ? null : _navigateToConfirmation,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isNavigating
                ? const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
                SizedBox(width: 10),
                Text("Processando..."),
              ],
            )
                : const Text("Continuar"),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    _locationController.dispose();
    super.dispose();
  }
}