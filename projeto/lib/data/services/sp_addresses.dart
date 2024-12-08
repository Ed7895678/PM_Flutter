import 'dart:convert';
import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

// Serviços para conectar com Shared Preferences
class AddressService {
  static const String _keyAddresses = "flutter.addresses";

  // Gerar ID aleatório
  // Facilita o manuseamento de endereços
  static String _generateRandomId() {
    const characters = 'abcdefghijklmnopqrstuvwxyz0123456789';
    final random = Random();
    return List.generate(10, (index) => characters[random.nextInt(characters.length)]).join();
  }

  // Obter endereços guardados
  static Future<List<Map<String, String>>> getAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_keyAddresses) ?? '[]';

    try {
      final List<dynamic> decodedList = json.decode(jsonString);
      return decodedList.map((e) => Map<String, String>.from(e)).toList();
    } catch (e) {
      return [];
    }
  }

  // Guardar endereços
  static Future<void> saveAddresses(List<Map<String, String>> addresses) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = json.encode(addresses);
    await prefs.setString(_keyAddresses, jsonString);
    }

  // Adicionar endereço á SP
  static Future<void> addAddress(String morada, String localizacao) async {
    final addresses = await getAddresses();
    final newAddress = {
      'id': _generateRandomId(),
      'morada': morada,
      'localizacao': localizacao,
    };
    addresses.add(newAddress);
    await saveAddresses(addresses);
  }

  // Remover endereço através do id
  static Future<void> removeAddressById(String id) async {
    final addresses = await getAddresses();
    addresses.removeWhere((address) => address['id'] == id);
    await saveAddresses(addresses);
  }
}
