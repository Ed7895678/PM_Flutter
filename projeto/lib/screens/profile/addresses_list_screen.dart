import 'package:flutter/material.dart';
import '../../data/services/sp_addresses.dart';
import '../../widgets/header.dart';

// Tela para gerenciar a lista de endereços
class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({super.key});

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  List<Map<String, String>> _addresses = []; // Lista de endereços

  final TextEditingController _streetController = TextEditingController(); // Controlador para a morada
  final TextEditingController _locationController = TextEditingController(); // Controlador para a localização

  @override
  void initState() {
    super.initState();
    _loadAddresses(); // Carrega os endereços ao iniciar
  }

  // Função para carregar endereços guardados
  Future<void> _loadAddresses() async {
    try {
      final storedAddresses = await AddressService.getAddresses();
      setState(() {
        _addresses = storedAddresses;
      });
    } catch (e) {
      print("Erro ao carregar endereços: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao carregar endereços. Tente novamente!')),
      );
    }
  }

  // Função para adicionar um novo endereço
  Future<void> _addAddress() async {
    if (_streetController.text.isNotEmpty && _locationController.text.isNotEmpty) {
      try {
        await AddressService.addAddress(
          _streetController.text,
          _locationController.text,
        );

        _streetController.clear();
        _locationController.clear();
        await _loadAddresses(); // Atualiza a lista de endereços
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Endereço salvo com sucesso!')),
        );
      } catch (e) {
        print("Erro ao adicionar endereço: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Erro ao salvar endereço. Tente novamente!')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preencha todos os campos!')),
      );
    }
  }

  // Função para remover um endereço por ID
  Future<void> _removeAddress(String id) async {
    try {
      await AddressService.removeAddressById(id);
      await _loadAddresses(); // Atualiza a lista após remoção
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço removido com sucesso!')),
      );
    } catch (e) {
      print("Erro ao remover endereço: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover o endereço.')),
      );
    }
  }

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
              "Endereços Guardados",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Lista de endereços
            Expanded(
              child: _addresses.isEmpty
                  ? const Center(child: Text("Nenhum endereço salvo."))
                  : ListView.builder(
                itemCount: _addresses.length,
                itemBuilder: (context, index) {
                  final address = _addresses[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    child: ListTile(
                      title: Text("Morada: ${address['morada']}"),
                      subtitle: Text("Localização: ${address['localizacao']}"),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Remove o endereço, passando o ID
                          _removeAddress(address['id']!);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Adicionar outro endereço
            const SizedBox(height: 16),
            const Text(
              "Adicionar Novo Endereço",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            // Campo de entrada para a morada
            TextField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: "Morada",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Campo de entrada para a Localidade
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Localidade",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),

            // Guardar endereço
            ElevatedButton(
              onPressed: _addAddress,
              child: const Text("Guardar Endereço"),
            ),
          ],
        ),
      ),
    );
  }
}
