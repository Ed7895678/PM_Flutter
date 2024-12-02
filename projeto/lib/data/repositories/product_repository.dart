import '../services/api_service.dart';
import '../models/product_model.dart';

class ProductRepository {
  final ApiService _apiService;

  ProductRepository(this._apiService);

  Future<List<ProductModel>> getProducts() async {
    final response = await _apiService.get('/products');
    return (response['products'] as List)
        .map((product) => ProductModel.fromJson(product))
        .toList();
  }

  Future<ProductModel> getProduct(String id) async {
    final response = await _apiService.get('/products/$id');
    return ProductModel.fromJson(response);
  }
}
