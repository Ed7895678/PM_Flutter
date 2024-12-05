import 'package:flutter/material.dart';
import 'package:projeto/widgets/header.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = ''; // Metodo de pagamento selecionado
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();

  // Lista de métodos de pagamento
  final List<String> _paymentMethods = [
    "PayPal",
    "MBWay",
    "Transferência Bancária",
  ];

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method;
      _phoneController.clear();
      _cardNumberController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: const Header(
        title: "Método de pagamento",
      ),

      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Botões de metodo de pagamento
            ..._paymentMethods.map((method) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: () => _selectPaymentMethod(method),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: _selectedPaymentMethod == method
                        ? Colors.red
                        : Colors.grey[300],
                    foregroundColor: _selectedPaymentMethod == method
                        ? Colors.white
                        : Colors.black,
                  ),
                  child: Text(method),
                ),
              );
            }),

            // Mostrar metodo selecionado acima dos input's
            const SizedBox(height: 16),
            if (_selectedPaymentMethod.isNotEmpty)
              Text(
                _selectedPaymentMethod,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

            // Campos dinâmicos com base no metodo selecionado
            const SizedBox(height: 16),
            if (_selectedPaymentMethod == "PayPal" ||
                _selectedPaymentMethod == "MBWay") ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Número de Telefone",
                  border: OutlineInputBorder(),
                ),
              ),
            ] else if (_selectedPaymentMethod == "Transferência Bancária") ...[
              TextField(
                controller: _cardNumberController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Número do Cartão",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
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
            onPressed: _selectedPaymentMethod.isNotEmpty
                ? () {

              // Lógica de compra
              String details = "";
              if (_selectedPaymentMethod == "PayPal" ||
                  _selectedPaymentMethod == "MBWay") {
                details = "Telefone: ${_phoneController.text}";
              } else if (_selectedPaymentMethod == "Transferência Bancária") {
                details = "Número do Cartão: ${_cardNumberController.text}";
              }
            }
                : null, // Botão desativado se nenhum metodo for selecionado
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
