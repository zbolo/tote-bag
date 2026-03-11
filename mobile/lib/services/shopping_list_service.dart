import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import 'api_client.dart';
import 'app_exception.dart';
import 'logger.dart';

const _tag = 'ShoppingListService';

class ShoppingListService {
  final ApiClient _apiClient;

  ShoppingListService(this._apiClient);

  Future<List<ShoppingList>> getLists() async {
    Log.debug(_tag, 'Loading shopping lists');
    try {
      final response = await _apiClient.dio.get(ApiConfig.listsEndpoint);

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final lists = (response.data['data']['lists'] as List)
            .map((json) => ShoppingList.fromJson(json as Map<String, dynamic>))
            .toList();
        Log.info(_tag, 'Loaded ${lists.length} shopping lists');
        return lists;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Load lists');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error loading lists', e);
      throw AppException.from(e, context: 'Load lists');
    }
    return [];
  }

  Future<ShoppingList> getListById(String listId) async {
    Log.debug(_tag, 'Loading list $listId');
    try {
      final response =
          await _apiClient.dio.get('${ApiConfig.listsEndpoint}/$listId');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final list = ShoppingList.fromJson(
          response.data['data']['list'] as Map<String, dynamic>,
        );
        Log.info(_tag, 'Loaded list "${list.name}" (${list.items.length} items)');
        return list;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Load list');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error loading list $listId', e);
      throw AppException.from(e, context: 'Load list');
    }
    throw const AppException('Could not load this list. Please try again.');
  }

  Future<ShoppingList> createList({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    Log.info(_tag, 'Creating list "$name"');
    try {
      final response = await _apiClient.dio.post(
        ApiConfig.listsEndpoint,
        data: {
          'name': name,
          'description': description,
          'color': color,
          'icon': icon,
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 'success') {
        final list = ShoppingList.fromJson(
          response.data['data']['list'] as Map<String, dynamic>,
        );
        Log.info(_tag, 'Created list "${list.name}" (${list.id})');
        return list;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Create list');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error creating list', e);
      throw AppException.from(e, context: 'Create list');
    }
    throw const AppException('Could not create the list. Please try again.');
  }

  Future<ShoppingList> updateList({
    required String listId,
    String? name,
    String? description,
    String? color,
    String? icon,
  }) async {
    Log.info(_tag, 'Updating list $listId');
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (description != null) data['description'] = description;
      if (color != null) data['color'] = color;
      if (icon != null) data['icon'] = icon;

      final response = await _apiClient.dio.patch(
        '${ApiConfig.listsEndpoint}/$listId',
        data: data,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final list = ShoppingList.fromJson(
          response.data['data']['list'] as Map<String, dynamic>,
        );
        Log.info(_tag, 'Updated list "${list.name}"');
        return list;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Update list');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error updating list', e);
      throw AppException.from(e, context: 'Update list');
    }
    throw const AppException('Could not update the list. Please try again.');
  }

  Future<void> deleteList(String listId) async {
    Log.info(_tag, 'Deleting list $listId');
    try {
      final response =
          await _apiClient.dio.delete('${ApiConfig.listsEndpoint}/$listId');

      if (response.statusCode != 204) {
        throw const AppException('Could not delete the list. Please try again.');
      }
      Log.info(_tag, 'Deleted list $listId');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Delete list');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error deleting list', e);
      throw AppException.from(e, context: 'Delete list');
    }
  }

  Future<ShoppingListItem> addItem({
    required String listId,
    required String name,
    int quantity = 1,
    String? unit,
    String? notes,
    String? category,
    String? barcode,
    String? productId,
  }) async {
    Log.info(_tag, 'Adding item "$name" to list $listId');
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.listsEndpoint}/$listId/items',
        data: {
          'name': name,
          'quantity': quantity,
          'unit': unit,
          'notes': notes,
          'category': category,
          'barcode': barcode,
          'productId': productId,
        },
      );

      if (response.statusCode == 201 && response.data['status'] == 'success') {
        final item = ShoppingListItem.fromJson(
          response.data['data']['item'] as Map<String, dynamic>,
        );
        Log.info(_tag, 'Added item "${item.name}" (${item.id})');
        return item;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Add item');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error adding item', e);
      throw AppException.from(e, context: 'Add item');
    }
    throw const AppException('Could not add the item. Please try again.');
  }

  Future<ShoppingListItem> updateItem({
    required String listId,
    required String itemId,
    String? name,
    int? quantity,
    String? unit,
    String? notes,
    bool? isChecked,
    String? category,
    int? order,
  }) async {
    Log.debug(_tag, 'Updating item $itemId in list $listId');
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (quantity != null) data['quantity'] = quantity;
      if (unit != null) data['unit'] = unit;
      if (notes != null) data['notes'] = notes;
      if (isChecked != null) data['isChecked'] = isChecked;
      if (category != null) data['category'] = category;
      if (order != null) data['order'] = order;

      final response = await _apiClient.dio.patch(
        '${ApiConfig.listsEndpoint}/$listId/items/$itemId',
        data: data,
      );

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final item = ShoppingListItem.fromJson(
          response.data['data']['item'] as Map<String, dynamic>,
        );
        Log.debug(_tag, 'Updated item "${item.name}"');
        return item;
      }
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Update item');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error updating item', e);
      throw AppException.from(e, context: 'Update item');
    }
    throw const AppException('Could not update the item. Please try again.');
  }

  Future<void> deleteItem({
    required String listId,
    required String itemId,
  }) async {
    Log.info(_tag, 'Deleting item $itemId from list $listId');
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConfig.listsEndpoint}/$listId/items/$itemId',
      );

      if (response.statusCode != 204) {
        throw const AppException('Could not delete the item. Please try again.');
      }
      Log.info(_tag, 'Deleted item $itemId');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Delete item');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error deleting item', e);
      throw AppException.from(e, context: 'Delete item');
    }
  }

  Future<void> shareList({
    required String listId,
    required String email,
    required String permission,
  }) async {
    Log.info(_tag, 'Sharing list $listId with $email ($permission)');
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.listsEndpoint}/$listId/share',
        data: {
          'email': email,
          'permission': permission,
        },
      );

      if (response.statusCode != 201) {
        throw const AppException('Could not share the list. Please try again.');
      }
      Log.info(_tag, 'Shared list $listId with $email');
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      final err = AppException.fromDio(e, context: 'Share list');
      Log.error(_tag, err.toString(), e);
      throw err;
    } catch (e) {
      Log.error(_tag, 'Unexpected error sharing list', e);
      throw AppException.from(e, context: 'Share list');
    }
  }
}
