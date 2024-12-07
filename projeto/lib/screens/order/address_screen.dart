import 'package:flutter/material.dart';
import '../../data/services/sp_addresses.dart';
import 'confirmation_screen.dart';
import 'package:projeto/widgets/header.dart';

// Ecrã para selecionar a morada
class AddressScreen extends StatefulWidget {
  final String paymentMethod; // Método de pagamento selecionado
  final String paymentDetail; // Detalhes do pagamento
  final double total; // Total da compra

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
  List<Map<String, String>> _addresses = []; // Lista de moradas
  String? _selectedAddressId; // ID da morada selecionada
  bool _isNavigating = false; // Indica se está a navegar para o próximo ecrã

  @override
  void initState() {
    super.initState();
    _loadAddresses(); // Carrega as moradas ao iniciar
  }

  // Função para carregar as moradas disponíveis
  Future<void> _loadAddresses() async {
    try {
      final addresses = await AddressService.getAddresses();
      setState(() {
        _addresses = addresses;
      });
    } catch (e) {
      debugPrint('Erro ao carregar endereços: $e');
    }
  }

  // Seleciona uma morada com base no ID
  void _selectAddress(String addressId) {
    setState(() {
      _selectedAddressId = addressId;
    });
  }

  // Navega para o ecrã de confirmação
  void _navigateToConfirmation() async {
    if (_isNavigating || _selectedAddressId == null) return;

    try {
      setState(() {
        _isNavigating = true;
      });

      // Obtém os detalhes da morada selecionada
      final selectedAddress = _addresses.firstWhere(
            (address) => address['id'] == _selectedAddressId,
      );

      final morada = selectedAddress['morada'] ?? '';
      final localizacao = selectedAddress['localizacao'] ?? '';

      // Navega para o ecrã de confirmação
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConfirmationScreen(
            paymentMethod: widget.paymentMethod,
            paymentDetail: widget.paymentDetail,
            address: morada,
            location: localizacao,
            total: widget.total,
          ),
        ),
      );
    } catch (e) {
      debugPrint('Erro durante a navegação: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao continuar: $e')),
      );
    } finally {
      setState(() {
        _isNavigating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Cabeçalho do ecrã
      appBar: const Header(
        title: "Escolher Morada",
      ),

      // Corpo do ecrã
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Mensagem caso não existam moradas disponíveis
            if (_addresses.isEmpty)
              const Center(
                child: Text(
                  "Nenhuma morada disponível. Adicione uma morada no seu Perfil.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),

            // Lista de moradas disponíveis
            if (_addresses.isNotEmpty)
              ..._addresses.map((address) {
                bool isSelected = _selectedAddressId == address['id'];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16), // Espaço entre os botões
                  child: ElevatedButton(
                    onPressed: () => _selectAddress(address['id']!),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: isSelected ? Colors.red : Colors.grey[300],
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Texto com a morada
                        Text(
                          address['morada'] ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 4), // Espaço entre textos

                        // Texto com a localização
                        Text(
                          address['localizacao'] ?? '',
                          style: const TextStyle(fontSize: 14, color: Colors.black54),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),

      // Barra inferior com o botão para continuar
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
            onPressed: _selectedAddressId != null ? _navigateToConfirmation : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),

            // Botão com indicador de carregamento
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
}
