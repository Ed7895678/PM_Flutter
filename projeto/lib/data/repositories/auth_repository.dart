import '../services/api_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  final ApiService _apiService;

  AuthRepository(this._apiService);

  Future<String> login(String email, String password) async {
    final response = await _apiService.post('/auth/login', {
      'email': email,
      'password': password,
    });

    return response['token'];
  }

  Future<String> register(String name, String email, String password) async {
    final response = await _apiService.post('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });

    return response['token'];
  }
}
