import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('Teste de conexão com a API', () async {
    final url = Uri.parse('http://pmonteiro.ovh:5000/products');
    try {
      final response = await http.get(url);
      print('Status code: ${response.statusCode}');
      print('Resposta: ${response.body}');
      expect(response.statusCode, 200);
    } catch (e) {
      print('Erro: $e');
      fail('Erro na conexão com a API');
    }
  });
}