import 'package:flutter/material.dart';
import '../../data/services/sp_addresses.dart';
import '../../widgets/header.dart';

class AddressesListScreen extends StatefulWidget {
  const AddressesListScreen({super.key});

  @override
  State<AddressesListScreen> createState() => _AddressesListScreenState();
}

class _AddressesListScreenState extends State<AddressesListScreen> {
  List<Map<String, String>> _addresses = [];

  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  // Carregar endereços do SharedPreferences
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

  // Adicionar um novo endereço
  Future<void> _addAddress() async {
    if (_streetController.text.isNotEmpty && _locationController.text.isNotEmpty) {
      try {
        await AddressService.addAddress(
          _streetController.text,
          _locationController.text,
        );
        _streetController.clear();
        _locationController.clear();
        await _loadAddresses(); // Atualiza a lista
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

  // Remover endereço por ID
  Future<void> _removeAddress(String id) async {
    try {
      await AddressService.removeAddressById(id);
      await _loadAddresses();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Endereço removido com sucesso!')),
      );
    } catch (e) {
      print("Erro ao remover endereço: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao remover endereço. Tente novamente!')),
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
                          _removeAddress(address['id']!);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            // Campos para adicionar novo endereço
            const SizedBox(height: 16),
            const Text(
              "Adicionar Novo Endereço",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _streetController,
              decoration: const InputDecoration(
                labelText: "Morada (Rua, Número)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: "Localização (Concelho, Distrito)",
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _addAddress,
              child: const Text("Salvar Endereço"),
            ),
          ],
        ),
      ),
    );
  }
}
