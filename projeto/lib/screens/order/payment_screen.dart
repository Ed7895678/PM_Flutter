import 'package:flutter/material.dart';
import 'address_screen.dart';
import 'package:projeto/widgets/header.dart';

class PaymentScreen extends StatefulWidget {
  final double total;

  const PaymentScreen({super.key, required this.total});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  String _selectedPaymentMethod = '';
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();

  final List<String> _paymentMethods = [
    "PayPal",
    "MBWay",
    "Transferência Bancária",
  ];

  void _selectPaymentMethod(String method) {
    setState(() {
      _selectedPaymentMethod = method == "Transferência Bancária" ? "BANK_TRANSFER" : method;
      _phoneController.clear();
      _cardNumberController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(
        title: "Informações de Pagamento",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ..._paymentMethods.map((method) {
              bool isSelected = method == "Transferência Bancária" ?
              _selectedPaymentMethod == "BANK_TRANSFER" :
              _selectedPaymentMethod == method;

              return Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: ElevatedButton(
                  onPressed: () => _selectPaymentMethod(method),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    backgroundColor: isSelected ? Colors.red : Colors.grey[300],
                    foregroundColor: isSelected ? Colors.white : Colors.black,
                  ),
                  child: Text(method),
                ),
              );
            }),

            const SizedBox(height: 16),
            if (_selectedPaymentMethod.isNotEmpty)
              Text(
                _selectedPaymentMethod == "BANK_TRANSFER" ?
                "Transferência Bancária" :
                _selectedPaymentMethod,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddressScreen(
                    paymentMethod: _selectedPaymentMethod,
                    paymentDetail: _selectedPaymentMethod == "PayPal" ||
                        _selectedPaymentMethod == "MBWay"
                        ? "Telefone: ${_phoneController.text}"
                        : _cardNumberController.text,
                    total: widget.total,
                  ),
                ),
              );
            }
                : null,
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