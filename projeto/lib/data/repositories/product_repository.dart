// lib/data/repositories/product_repository.dart
import '../models/product_model.dart';
import '../services/api_service.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiService.get('/products');
      final List<dynamic> productList = response['products'] ?? [];
      return productList.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Falha ao carregar produtos: $e');
    }
  }

  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _apiService.get('/products/$id');
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Falha ao carregar produto: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _apiService.get('/categories');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Falha ao carregar categorias: $e');
    }
  }
}