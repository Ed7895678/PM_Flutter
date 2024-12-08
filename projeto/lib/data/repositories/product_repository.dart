import '../models/product_model.dart';
import '../services/api_service.dart';

// Serviços de contacto com as API's
class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  // Buscar TODOS os produtos
  Future<List<ProductModel>> getProducts() async {
    try {
      final response = await _apiService.get('/products');
      final List<dynamic> productList = response['products'] ?? [];
      return productList.map((json) => ProductModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Falha ao carregar produtos: $e');
    }
  }

  // Buscar UM produto através do ID
  Future<ProductModel> getProduct(String id) async {
    try {
      final response = await _apiService.get('/products/$id');
      return ProductModel.fromJson(response);
    } catch (e) {
      throw Exception('Falha ao carregar produto: $e');
    }
  }

  // Buscar TODAS as categorias
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _apiService.get('/categories');
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('Falha ao carregar categorias: $e');
    }
  }
}