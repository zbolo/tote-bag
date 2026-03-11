import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/product.dart';
import 'app_exception.dart';
import 'logger.dart';

const _tag = 'FavoriteService';

class FavoriteService {
  final Dio _dio;

  FavoriteService({required Dio dio}) : _dio = dio;

  String get _basePath => ApiConfig.apiPrefix;

  /// Get all favorite products for the current user
  Future<List<Product>> getFavorites() async {
    Log.debug(_tag, 'Loading favorites');
    try {
      final response = await _dio.get('$_basePath/favorites');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        final favorites = data.map((json) => Product.fromJson(json)).toList();
        Log.info(_tag, 'Loaded ${favorites.length} favorites');
        return favorites;
      }

      throw const AppException('Could not load favorites. Please try again.');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Load favorites');
      Log.error(_tag, err.toString(), e);
      throw err;
    }
  }

  /// Add a product to favorites
  Future<void> addFavorite(String productId) async {
    Log.info(_tag, 'Adding favorite: $productId');
    try {
      final response = await _dio.post('$_basePath/favorites/$productId');

      if (response.statusCode != 201 || response.data['success'] != true) {
        throw const AppException('Could not add to favorites.');
      }
      Log.info(_tag, 'Added favorite $productId');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Add favorite');
      Log.error(_tag, err.toString(), e);
      throw err;
    }
  }

  /// Remove a product from favorites
  Future<void> removeFavorite(String productId) async {
    Log.info(_tag, 'Removing favorite: $productId');
    try {
      final response = await _dio.delete('$_basePath/favorites/$productId');

      if (response.statusCode != 200 || response.data['success'] != true) {
        throw const AppException('Could not remove from favorites.');
      }
      Log.info(_tag, 'Removed favorite $productId');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Remove favorite');
      Log.error(_tag, err.toString(), e);
      throw err;
    }
  }

  /// Toggle favorite status for a product
  Future<bool> toggleFavorite(String productId) async {
    Log.info(_tag, 'Toggling favorite: $productId');
    try {
      final response =
          await _dio.post('$_basePath/favorites/$productId/toggle');

      if (response.statusCode == 200 && response.data['success'] == true) {
        final isFav = response.data['data']['isFavorite'] as bool;
        Log.info(_tag, 'Toggled favorite $productId → $isFav');
        return isFav;
      }

      throw const AppException('Could not update favorite status.');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Toggle favorite');
      Log.error(_tag, err.toString(), e);
      throw err;
    }
  }

  /// Check if a product is favorited
  Future<bool> isFavorite(String productId) async {
    Log.debug(_tag, 'Checking favorite status: $productId');
    try {
      final response =
          await _dio.get('$_basePath/favorites/$productId/status');

      if (response.statusCode == 200 && response.data['success'] == true) {
        return response.data['data']['isFavorite'] as bool;
      }

      throw const AppException('Could not check favorite status.');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Check favorite');
      Log.error(_tag, err.toString(), e);
      throw err;
    }
  }
}
