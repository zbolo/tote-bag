import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/product.dart';
import 'api_client.dart';
import 'app_exception.dart';
import 'logger.dart';

const _tag = 'ProductService';

class ProductService {
  final ApiClient _apiClient;

  ProductService(this._apiClient);

  Future<Product?> getProductByBarcode(String barcode) async {
    Log.info(_tag, 'Looking up product by barcode: $barcode');
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.productsEndpoint}/barcode/$barcode',
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final product = Product.fromJson(
          response.data['data']['product'] as Map<String, dynamic>,
        );
        Log.info(_tag, 'Found product: "${product.name}" for barcode $barcode');
        return product;
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        Log.info(_tag, 'No product found for barcode $barcode');
        return null;
      }
      Log.error(_tag, 'Error looking up barcode $barcode', e);
      throw AppException.fromDio(e, context: 'Barcode lookup');
    } catch (e) {
      Log.error(_tag, 'Unexpected error looking up barcode', e);
      throw AppException.from(e, context: 'Barcode lookup');
    }
    return null;
  }

  Future<List<Product>> searchProducts(String query) async {
    Log.debug(_tag, 'Searching products: "$query"');
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.productsEndpoint}/search',
        queryParameters: {'query': query, 'limit': 20},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final products = (response.data['data']['products'] as List)
            .map((json) => Product.fromJson(json as Map<String, dynamic>))
            .toList();
        Log.info(_tag, 'Search "$query" returned ${products.length} results');
        return products;
      }
    } on DioException catch (e) {
      Log.error(_tag, 'Error searching products "$query"', e);
      throw AppException.fromDio(e, context: 'Product search');
    } catch (e) {
      Log.error(_tag, 'Unexpected error searching products', e);
      throw AppException.from(e, context: 'Product search');
    }
    return [];
  }
}
