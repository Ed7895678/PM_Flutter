import 'package:http/http.dart' as http;
import 'dart:convert';
import '../core/constants/api_constants.dart';

class ApiService {
  final String baseUrl = ApiConstants.baseUrl;
  String? _token;

  void setToken(String token) {
    _token = token;
  }

  Map<String, String> get _headers {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  Future<Map<String, dynamic>> post(String endpoint, Map<String, dynamic> body) async {
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
      body: json.encode(body),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to post data');
    }
  }

  Future<Map<String, dynamic>> get(String endpoint) async {
    final response = await http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get data');
    }
  }
}
