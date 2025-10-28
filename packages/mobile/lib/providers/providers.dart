import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/shopping_list_service.dart';
import '../services/product_service.dart';
import '../models/user.dart';
import '../models/shopping_list.dart';

// Service Providers
final apiClientProvider = Provider<ApiClient>((ref) => ApiClient());

final authServiceProvider = Provider<AuthService>(
  (ref) => AuthService(ref.watch(apiClientProvider)),
);

final shoppingListServiceProvider = Provider<ShoppingListService>(
  (ref) => ShoppingListService(ref.watch(apiClientProvider)),
);

final productServiceProvider = Provider<ProductService>(
  (ref) => ProductService(ref.watch(apiClientProvider)),
);

// Auth State Providers
final currentUserProvider = StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>(
  (ref) => CurrentUserNotifier(ref.watch(authServiceProvider)),
);

class CurrentUserNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;

  CurrentUserNotifier(this._authService) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.getCurrentUser();
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signIn(String email, String password) async {
    final result = await _authService.signIn(email: email, password: password);
    if (result['success'] == true) {
      await _loadUser();
    } else {
      throw Exception(result['message'] ?? 'Sign in failed');
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    final result = await _authService.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (result['success'] == true) {
      await _loadUser();
    } else {
      throw Exception(result['message'] ?? 'Sign up failed');
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
    state = const AsyncValue.data(null);
  }

  Future<void> refresh() async {
    await _loadUser();
  }
}

// Shopping Lists Provider
final shoppingListsProvider = StateNotifierProvider<ShoppingListsNotifier, AsyncValue<List<ShoppingList>>>(
  (ref) => ShoppingListsNotifier(ref.watch(shoppingListServiceProvider)),
);

class ShoppingListsNotifier extends StateNotifier<AsyncValue<List<ShoppingList>>> {
  final ShoppingListService _service;

  ShoppingListsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadLists();
  }

  Future<void> loadLists() async {
    state = const AsyncValue.loading();
    try {
      final lists = await _service.getLists();
      state = AsyncValue.data(lists);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> createList({
    required String name,
    String? description,
    String? color,
    String? icon,
  }) async {
    try {
      await _service.createList(
        name: name,
        description: description,
        color: color,
        icon: icon,
      );
      await loadLists();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> updateList({
    required String listId,
    String? name,
    String? description,
    String? color,
    String? icon,
  }) async {
    try {
      await _service.updateList(
        listId: listId,
        name: name,
        description: description,
        color: color,
        icon: icon,
      );
      await loadLists();
    } catch (error) {
      rethrow;
    }
  }

  Future<void> deleteList(String listId) async {
    try {
      await _service.deleteList(listId);
      await loadLists();
    } catch (error) {
      rethrow;
    }
  }
}

// Single Shopping List Provider
final shoppingListProvider = FutureProvider.family<ShoppingList, String>(
  (ref, listId) async {
    final service = ref.watch(shoppingListServiceProvider);
    return await service.getListById(listId);
  },
);
