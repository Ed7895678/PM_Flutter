import 'package:flutter/material.dart';
import 'address_screen.dart';
import 'package:projeto/widgets/header.dart';

// Ecrã para selecionar o método de pagamento
class PaymentScreen extends StatefulWidget {
  final double total; // Total do pedido

  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = ''; // Método de pagamento selecionado
  final TextEditingController _phoneController = TextEditingController(); // Controlador para MBWay ou PayPal
  final TextEditingController _cardNumberController = TextEditingController(); // Controlador para Transferência Bancária

  // Lista de métodos de pagamento disponíveis
  final List<String> _paymentMethods = [
    "PayPal",
    "MBWay",
    "Transferência Bancária",
  ];

  // Define o método de pagamento selecionado
  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method == "Transferência Bancária" ? "BANK_TRANSFER" : method;
      _phoneController.clear();
      _cardNumberController.clear();
    });
  }

  // Continua para o próximo ecrã após validação
  void _continuePayment() {

    // Validações para PayPal ou MBWay
    if (_selectedPaymentMethod == "PayPal" || _selectedPaymentMethod == "MBWay") {
      final phone = _phoneController.text.trim();

      if (phone.length != 9 || !RegExp(r'^\d{9}$').hasMatch(phone)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Insira um número de telemovél válido."),
          ),
        );
        return;
      }
    }

    // Validações para Transferência Bancária
    if (_selectedPaymentMethod == "BANK_TRANSFER") {
      final cardNumber = _cardNumberController.text.trim();

      if (cardNumber.length != 9 || !RegExp(r'^\d{9}$').hasMatch(cardNumber)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Insira um número de cartão válido."),
          ),
        );
        return;
      }
    }

    // Navega para o ecrã de seleção de morada
    // Passa os dados de metodo de pagamento e detalhes
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddressScreen(
          paymentMethod: _selectedPaymentMethod,
          paymentDetail: _selectedPaymentMethod == "PayPal" || _selectedPaymentMethod == "MBWay"
              ? "Numero de Telemovél: ${_phoneController.text}"
              : "Numero do Cartão: ${_cardNumberController.text}",
          total: widget.total,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cabeçalho do ecrã
      appBar: const Header(
        title: "Metodo de Pagamento",
      ),

      // Corpo do ecrã
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            // Selecionar Metodo de pagamento
            ..._paymentMethods.map((method) {
              bool isSelected = method == "Transferência Bancária"
                  ? _selectedPaymentMethod == "BANK_TRANSFER"
                  : _selectedPaymentMethod == method;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: () => _selectPaymentMethod(method),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    // Cores dos botões quando pressionados
                    backgroundColor: isSelected ? Colors.red : Colors.grey[300],
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                  ),
                  child: Text(method),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Mostra o método de pagamento selecionado
            if (_selectedPaymentMethod.isNotEmpty)
              Text(
                _selectedPaymentMethod == "BANK_TRANSFER"
                    ? "Transferência Bancária"
                    : _selectedPaymentMethod,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

            const SizedBox(height: 16),

            // Campos dependentes do método selecionado
            if (_selectedPaymentMethod == "PayPal" || _selectedPaymentMethod == "MBWay") ...[
              TextField(
                controller: _phoneController,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: "Número de Telefone",
                  border: OutlineInputBorder(),
                ),
              ),
            ] else if (_selectedPaymentMethod == "BANK_TRANSFER") ...[
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

      // Barra inferior com botão de continuação
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
            onPressed: _selectedPaymentMethod.isNotEmpty ? _continuePayment : null,
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
