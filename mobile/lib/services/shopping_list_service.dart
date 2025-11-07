import '../config/api_config.dart';
import '../models/shopping_list.dart';
import '../models/shopping_list_item.dart';
import 'api_client.dart';

class ShoppingListService {
  final ApiClient _apiClient;

  ShoppingListService(this._apiClient);

  Future<List<ShoppingList>> getLists() async {
    try {
      final response = await _apiClient.dio.get(ApiConfig.listsEndpoint);

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final lists = (response.data['data']['lists'] as List)
            .map((json) => ShoppingList.fromJson(json as Map<String, dynamic>))
            .toList();
        return lists;
      }
    } catch (e) {
      throw Exception('Failed to load lists: $e');
    }
    return [];
  }

  Future<ShoppingList> getListById(String listId) async {
    try {
      final response =
          await _apiClient.dio.get('${ApiConfig.listsEndpoint}/$listId');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return ShoppingList.fromJson(
          response.data['data']['list'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      throw Exception('Failed to load list: $e');
    }
    throw Exception('Failed to load list');
  }

  Future<ShoppingList> createList({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
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
        return ShoppingList.fromJson(
          response.data['data']['list'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      throw Exception('Failed to create list: $e');
    }
    throw Exception('Failed to create list');
  }

  Future<ShoppingList> updateList({
    required String listId,
    String? name,
    String? description,
    String? color,
    String? icon,
  }) async {
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
        return ShoppingList.fromJson(
          response.data['data']['list'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      throw Exception('Failed to update list: $e');
    }
    throw Exception('Failed to update list');
  }

  Future<void> deleteList(String listId) async {
    try {
      final response =
          await _apiClient.dio.delete('${ApiConfig.listsEndpoint}/$listId');

      if (response.statusCode != 204) {
        throw Exception('Failed to delete list');
      }
    } catch (e) {
      throw Exception('Failed to delete list: $e');
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
        return ShoppingListItem.fromJson(
          response.data['data']['item'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      throw Exception('Failed to add item: $e');
    }
    throw Exception('Failed to add item');
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
        return ShoppingListItem.fromJson(
          response.data['data']['item'] as Map<String, dynamic>,
        );
      }
    } catch (e) {
      throw Exception('Failed to update item: $e');
    }
    throw Exception('Failed to update item');
  }

  Future<void> deleteItem({
    required String listId,
    required String itemId,
  }) async {
    try {
      final response = await _apiClient.dio.delete(
        '${ApiConfig.listsEndpoint}/$listId/items/$itemId',
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete item');
      }
    } catch (e) {
      throw Exception('Failed to delete item: $e');
    }
  }

  Future<void> shareList({
    required String listId,
    required String email,
    required String permission,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.listsEndpoint}/$listId/share',
        data: {
          'email': email,
          'permission': permission,
        },
      );

      if (response.statusCode != 201) {
        throw Exception('Failed to share list');
      }
    } catch (e) {
      throw Exception('Failed to share list: $e');
    }
  }
}
