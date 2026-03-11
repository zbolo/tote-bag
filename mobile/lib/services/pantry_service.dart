import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/pantry.dart';
import '../models/pantry_item.dart';
import '../models/storage_location.dart';
import 'api_client.dart';
import 'app_exception.dart';
import 'logger.dart';

const _tag = 'PantryService';

class PantryService {
  final ApiClient _apiClient;

  PantryService(this._apiClient);

  // ── Pantry CRUD ────────────────────────────────────────────

  Future<List<Pantry>> getPantries() async {
    Log.debug(_tag, 'Loading pantries');
    try {
      final response = await _apiClient.dio.get(ApiConfig.pantriesEndpoint);

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final pantries = (response.data['data']['pantries'] as List)
            .map((json) => Pantry.fromJson(json as Map<String, dynamic>))
            .toList();
        Log.info(_tag, 'Loaded ${pantries.length} pantries');
        return pantries;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Load pantries');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error loading pantries', e);
      throw AppException.from(e, context: 'Load pantries');
    }
    return [];
  }

  Future<Pantry> getPantryById(String pantryId) async {
    Log.debug(_tag, 'Loading pantry $pantryId');
    try {
      final response = await _apiClient.dio
          .get('${ApiConfig.pantriesEndpoint}/$pantryId');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final pantry = Pantry.fromJson(
          response.data['data']['pantry'] as Map<String, dynamic>,
        );
        Log.info(
            _tag, 'Loaded pantry "${pantry.name}" (${pantry.items.length} items)');
        return pantry;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Load pantry');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error loading pantry $pantryId', e);
      throw AppException.from(e, context: 'Load pantry');
    }
    throw const AppException('Could not load this pantry. Please try again.');
  }

  Future<Pantry> createPantry({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    Log.info(_tag, 'Creating pantry "$name"');
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.pantriesEndpoint,
        data: {
          'name': name,
          'description': description,
          'color': color,
          'icon': icon,
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 'success') {
        final pantry = Pantry.fromJson(
          response.data['data']['pantry'] as Map<String, dynamic>,
        );
        Log.info(_tag, 'Created pantry "${pantry.name}" (${pantry.id})');
        return pantry;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Create pantry');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error creating pantry', e);
      throw AppException.from(e, context: 'Create pantry');
    }
    throw const AppException('Could not create the pantry. Please try again.');
  }

  Future<Pantry> updatePantry({
    required String pantryId,
    String? name,
    String? description,
    String? color,
    String? icon,
  }) async {
    Log.info(_tag, 'Updating pantry $pantryId');
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (color != null) data['color'] = color;
      if (icon != null) data['icon'] = icon;

      final response = await _apiClient.dio.patch(
        '${ApiConfig.pantriesEndpoint}/$pantryId',
        data: data,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final pantry = Pantry.fromJson(
          response.data['data']['pantry'] as Map<String, dynamic>,
        );
        Log.info(_tag, 'Updated pantry "${pantry.name}"');
        return pantry;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Update pantry');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error updating pantry', e);
      throw AppException.from(e, context: 'Update pantry');
    }
    throw const AppException('Could not update the pantry. Please try again.');
  }

  Future<void> deletePantry(String pantryId) async {
    Log.info(_tag, 'Deleting pantry $pantryId');
    try {
      final response = await _apiClient.dio
          .delete('${ApiConfig.pantriesEndpoint}/$pantryId');

      if (response.statusCode != 204) {
        throw const AppException(
            'Could not delete the pantry. Please try again.');
      }
      Log.info(_tag, 'Deleted pantry $pantryId');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Delete pantry');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error deleting pantry', e);
      throw AppException.from(e, context: 'Delete pantry');
    }
  }

  // ── Item CRUD ──────────────────────────────────────────────

  Future<PantryItem> addItem({
    required String pantryId,
    required String name,
    double? quantity,
    double? maxQuantity,
    String? unit,
    String? category,
    String? storageLocationId,
    String? expirationDate,
    String? purchaseDate,
    double? price,
    String? barcode,
    String? productId,
    String? notes,
    double? lowStockThreshold,
  }) async {
    Log.info(_tag, 'Adding item "$name" to pantry $pantryId');
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.pantriesEndpoint}/$pantryId/items',
        data: {
          'name': name,
          'quantity': quantity,
          'maxQuantity': maxQuantity,
          'unit': unit,
          'category': category,
          'storageLocationId': storageLocationId,
          'expirationDate': expirationDate,
          'purchaseDate': purchaseDate,
          'price': price,
          'barcode': barcode,
          'productId': productId,
          'notes': notes,
          'lowStockThreshold': lowStockThreshold,
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 'success') {
        final item = PantryItem.fromJson(
          response.data['data']['item'] as Map<String, dynamic>,
        );
        Log.info(_tag, 'Added item "${item.name}" (${item.id})');
        return item;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Add pantry item');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error adding item', e);
      throw AppException.from(e, context: 'Add pantry item');
    }
    throw const AppException('Could not add the item. Please try again.');
  }

  Future<PantryItem> updateItem({
    required String pantryId,
    required String itemId,
    String? name,
    double? quantity,
    double? maxQuantity,
    String? unit,
    String? category,
    String? storageLocationId,
    String? expirationDate,
    String? purchaseDate,
    double? price,
    String? notes,
    double? lowStockThreshold,
    int? order,
  }) async {
    Log.debug(_tag, 'Updating item $itemId in pantry $pantryId');
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (quantity != null) data['quantity'] = quantity;
      if (maxQuantity != null) data['maxQuantity'] = maxQuantity;
      if (unit != null) data['unit'] = unit;
      if (category != null) data['category'] = category;
      if (storageLocationId != null) {
        data['storageLocationId'] = storageLocationId;
      }
      if (expirationDate != null) data['expirationDate'] = expirationDate;
      if (purchaseDate != null) data['purchaseDate'] = purchaseDate;
      if (price != null) data['price'] = price;
      if (notes != null) data['notes'] = notes;
      if (lowStockThreshold != null) {
        data['lowStockThreshold'] = lowStockThreshold;
      }
      if (order != null) data['order'] = order;

      final response = await _apiClient.dio.patch(
        '${ApiConfig.pantriesEndpoint}/$pantryId/items/$itemId',
        data: data,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final item = PantryItem.fromJson(
          response.data['data']['item'] as Map<String, dynamic>,
        );
        Log.debug(_tag, 'Updated item "${item.name}"');
        return item;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Update pantry item');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error updating item', e);
      throw AppException.from(e, context: 'Update pantry item');
    }
    throw const AppException('Could not update the item. Please try again.');
  }

  Future<void> deleteItem({
    required String pantryId,
    required String itemId,
  }) async {
    Log.info(_tag, 'Deleting item $itemId from pantry $pantryId');
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConfig.pantriesEndpoint}/$pantryId/items/$itemId',
      );

      if (response.statusCode != 204) {
        throw const AppException(
            'Could not delete the item. Please try again.');
      }
      Log.info(_tag, 'Deleted item $itemId');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Delete pantry item');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error deleting item', e);
      throw AppException.from(e, context: 'Delete pantry item');
    }
  }

  // ── Storage Locations ──────────────────────────────────────

  Future<StorageLocation> addStorageLocation({
    required String pantryId,
    required String name,
    String? icon,
  }) async {
    Log.info(_tag, 'Adding storage location "$name" to pantry $pantryId');
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.pantriesEndpoint}/$pantryId/locations',
        data: {'name': name, 'icon': icon},
      );

      if (response.statusCode == 201 && response.data['status'] == 'success') {
        final location = StorageLocation.fromJson(
          response.data['data']['location'] as Map<String, dynamic>,
        );
        Log.info(_tag, 'Added storage location "${location.name}"');
        return location;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Add storage location');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error adding storage location', e);
      throw AppException.from(e, context: 'Add storage location');
    }
    throw const AppException(
        'Could not add storage location. Please try again.');
  }

  Future<void> deleteStorageLocation({
    required String pantryId,
    required String locationId,
  }) async {
    Log.info(_tag, 'Deleting storage location $locationId');
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConfig.pantriesEndpoint}/$pantryId/locations/$locationId',
      );

      if (response.statusCode != 204) {
        throw const AppException(
            'Could not delete storage location. Please try again.');
      }
      Log.info(_tag, 'Deleted storage location $locationId');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Delete storage location');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error deleting storage location', e);
      throw AppException.from(e, context: 'Delete storage location');
    }
  }

  // ── Smart Features ─────────────────────────────────────────

  Future<List<PantryItem>> getExpiringItems(
    String pantryId, {
    int days = 7,
  }) async {
    Log.debug(_tag, 'Loading expiring items (${days}d) for pantry $pantryId');
    try {
      final response = await _apiClient.dio.get(
        '${ApiConfig.pantriesEndpoint}/$pantryId/expiring',
        queryParameters: {'days': days},
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final items = (response.data['data']['items'] as List)
            .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
            .toList();
        Log.info(_tag, 'Found ${items.length} expiring items');
        return items;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Load expiring items');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error loading expiring items', e);
      throw AppException.from(e, context: 'Load expiring items');
    }
    return [];
  }

  Future<List<PantryItem>> getLowStockItems(String pantryId) async {
    Log.debug(_tag, 'Loading low-stock items for pantry $pantryId');
    try {
      final response = await _apiClient.dio
          .get('${ApiConfig.pantriesEndpoint}/$pantryId/low-stock');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final items = (response.data['data']['items'] as List)
            .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
            .toList();
        Log.info(_tag, 'Found ${items.length} low-stock items');
        return items;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Load low-stock items');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error loading low-stock items', e);
      throw AppException.from(e, context: 'Load low-stock items');
    }
    return [];
  }

  Future<List<PantryItem>> moveFromShoppingList({
    required String pantryId,
    required String shoppingListId,
    required List<String> itemIds,
    String? storageLocationId,
    bool removeFromList = false,
  }) async {
    Log.info(_tag,
        'Moving ${itemIds.length} items from list $shoppingListId to pantry $pantryId');
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.pantriesEndpoint}/$pantryId/items/from-shopping-list',
        data: {
          'shoppingListId': shoppingListId,
          'itemIds': itemIds,
          'storageLocationId': storageLocationId,
          'removeFromList': removeFromList,
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 'success') {
        final items = (response.data['data']['items'] as List)
            .map((json) => PantryItem.fromJson(json as Map<String, dynamic>))
            .toList();
        Log.info(_tag, 'Moved ${items.length} items to pantry');
        return items;
      }
    } on DioException catch (e) {
      final err =
          AppException.fromDio(e, context: 'Move items to pantry');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error moving items to pantry', e);
      throw AppException.from(e, context: 'Move items to pantry');
    }
    throw const AppException(
        'Could not move items to pantry. Please try again.');
  }
}
