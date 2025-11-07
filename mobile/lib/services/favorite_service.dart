import 'package:dio/dio.dart';
import '../models/product.dart';

class FavoriteService {
  final Dio _dio;
  final String baseUrl;

  FavoriteService({
    required Dio dio,
    String? baseUrl,
  })  : _dio = dio,
        baseUrl = baseUrl ?? 'http://localhost:3000/api/v1';

  /// Get all favorite products for the current user
  Future<List<Product>> getFavorites() async {
    try {
      final response = await _dio.get('$baseUrl/favorites');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Product.fromJson(json)).toList();
      }

      throw Exception('Failed to fetch favorites');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Add a product to favorites
  Future<void> addFavorite(String productId) async {
    try {
      final response = await _dio.post('$baseUrl/favorites/$productId');

      if (response.statusCode != 201 || response.data['success'] != true) {
        throw Exception('Failed to add favorite');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Remove a product from favorites
  Future<void> removeFavorite(String productId) async {
    try {
      final response = await _dio.delete('$baseUrl/favorites/$productId');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw Exception('Failed to remove favorite');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Favorite not found');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Toggle favorite status for a product
  Future<bool> toggleFavorite(String productId) async {
    try {
      final response = await _dio.post('$baseUrl/favorites/$productId/toggle');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['isFavorite'] as bool;
      }

      throw Exception('Failed to toggle favorite');
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw Exception('Product not found');
      }
      throw Exception('Network error: ${e.message}');
    }
  }

  /// Check if a product is favorited
  Future<bool> isFavorite(String productId) async {
    try {
      final response = await _dio.get('$baseUrl/favorites/$productId/status');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['isFavorite'] as bool;
      }

      throw Exception('Failed to check favorite status');
    } on DioException catch (e) {
      throw Exception('Network error: ${e.message}');
    }
  }
}
