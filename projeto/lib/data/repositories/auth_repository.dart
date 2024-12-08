import '../services/api_service.dart';
import '../../core/constants/api_constants.dart';

// Serviços de Login e Registo
class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<String> login(String email, String password) async {
    try {
      final response = await _apiService.login(email, password);
      return response['token'];
    } catch (e) {
      throw Exception('Falha no login: $e');
    }
  }

  Future<String> register(String name, String email, String password) async {
    try {
      final response = await _apiService.register(name, email, password);
      return response['token'];
    } catch (e) {
      throw Exception('Falha no registro: $e');
    }
  }
}