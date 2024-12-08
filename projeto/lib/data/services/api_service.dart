// lib/data/services/api_service.dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  final String baseUrl = 'http://pmonteiro.ovh:5000';
  String? _token;

  void setToken(String token) {
    _token = token;
    print('Token definido: $token');
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<dynamic> get(String endpoint) async {
    final url = '$baseUrl$endpoint';
    print('GET Request para: $url');

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: _headers,
      );

      print('Status code: ${response.statusCode}');
      print('Resposta: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha na requisição GET: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro na requisição GET: $e');
      rethrow;
    }
  }

  Future<dynamic> post(String endpoint, Map<String, dynamic> data) async {
    final url = '$baseUrl$endpoint';
    print('POST Request para: $url');
    print('Dados: $data');

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: _headers,
        body: json.encode(data),
      );

      print('Status code: ${response.statusCode}');
      print('Resposta: ${response.body}');

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        throw Exception('Falha na requisição POST: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erro na requisição POST: $e');
      rethrow;
    }
  }

  // Login de user
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await post('/auth/login', {
      'email': email,
      'password': password,
    });
    _token = response['token'];
    return response;
  }

  // Registo de um user
  Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final response = await post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
    _token = response['token'];
    return response;
  }

  // Buscar todos os produtos, podem ser filtrados por categoria
  Future<List<dynamic>> getProducts({String? categoryId}) async {
    String endpoint = '/products';
    if (categoryId != null && categoryId != 'Todos') {
      endpoint = '/products?category=$categoryId';
    }
    return await get(endpoint);
  }

  // Buscar um produto através de ID
  Future<Map<String, dynamic>> getProduct(String id) async {
    return await get('/products/$id');
  }

  // Buscar todas as categorias
  Future<List<dynamic>> getCategories() async {
    return await get('/categories');
  }

  // Buscar os itens presentes no Carrinho
  Future<Map<String, dynamic>> getCart() async {
    return await get('/cart');
  }

  // Inserir ou remover itens do carrinho
  Future<Map<String, dynamic>> updateCart(List<Map<String, dynamic>> items) async {
    return await post('/cart', {'items': items});
  }

  // Buscar todas as ordens
  Future<List<dynamic>> getOrders() async {
    return await get('/orders');
  }

  // Criar um ordem nova
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    return await post('/orders', orderData);
  }
}