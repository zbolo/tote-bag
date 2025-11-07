import '../config/api_config.dart';
import '../models/product.dart';
import 'api_client.dart';

class ProductService {
  final ApiClient _apiClient;

  ProductService(this._apiClient);

  Future<Product?> getProductByBarcode(String barcode) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.productsEndpoint}/barcode/$barcode',
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return Product.fromJson(
          response.data['data']['product'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<List<Product>> searchProducts(String query) async {
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.productsEndpoint}/search',
        queryParameters: {'query': query, 'limit': 20},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return (response.data['data']['products'] as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      return [];
    }
    return [];
  }
}
