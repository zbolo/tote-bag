import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/shopping_list_service.dart';
import '../services/product_service.dart';
import '../services/favorite_service.dart';
import '../services/app_exception.dart';
import '../services/logger.dart';
import '../models/user.dart';
import '../models/shopping_list.dart';
import '../models/product.dart';

/// View mode for shopping list items display.
enum ListViewMode { list, grid }

/// Provider for the current list view mode (list vs card/grid).
/// Persisted per session; defaults to list view.
final listViewModeProvider = StateProvider<ListViewMode>(
  (ref) => ListViewMode.list,
);

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

final favoriteServiceProvider = Provider<FavoriteService>(
  (ref) => FavoriteService(dio: ref.watch(apiClientProvider).dio),
);

// Auth State Providers
final currentUserProvider =
    StateNotifierProvider<CurrentUserNotifier, AsyncValue<User?>>(
  (ref) => CurrentUserNotifier(ref.watch(authServiceProvider)),
);

class CurrentUserNotifier extends StateNotifier<AsyncValue<User?>> {
  final AuthService _authService;
  static const _tag = 'CurrentUserNotifier';

  CurrentUserNotifier(this._authService) : super(const AsyncValue.loading()) {
    _loadUser();
  }

  Future<void> _loadUser() async {
    state = const AsyncValue.loading();
    try {
      final user = await _authService.getCurrentUser();
      Log.info(_tag, 'User state → ${user?.displayName ?? 'not signed in'}');
      state = AsyncValue.data(user);
    } catch (error, stackTrace) {
      Log.error(_tag, 'Failed to load user', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> signIn(String email, String password) async {
    Log.info(_tag, 'Sign in flow started for $email');
    final result = await _authService.signIn(email: email, password: password);
    if (result['success'] == true) {
      await _loadUser();
    } else {
      final message = result['message'] ?? 'Sign in failed';
      throw AppException(message);
    }
  }

  Future<void> signUp(String email, String password, String displayName) async {
    Log.info(_tag, 'Sign up flow started for $email');
    final result = await _authService.signUp(
      email: email,
      password: password,
      displayName: displayName,
    );
    if (result['success'] == true) {
      await _loadUser();
    } else {
      final message = result['message'] ?? 'Sign up failed';
      throw AppException(message);
    }
  }

  Future<void> signOut() async {
    Log.info(_tag, 'Sign out flow started');
    await _authService.signOut();
    state = const AsyncValue.data(null);
    Log.info(_tag, 'User signed out');
  }

  Future<void> refresh() async {
    await _loadUser();
  }
}

// Shopping Lists Provider
final shoppingListsProvider = StateNotifierProvider<ShoppingListsNotifier,
    AsyncValue<List<ShoppingList>>>(
  (ref) => ShoppingListsNotifier(ref.watch(shoppingListServiceProvider)),
);

class ShoppingListsNotifier
    extends StateNotifier<AsyncValue<List<ShoppingList>>> {
  final ShoppingListService _service;
  static const _tag = 'ShoppingListsNotifier';

  ShoppingListsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadLists();
  }

  Future<void> loadLists() async {
    state = const AsyncValue.loading();
    try {
      final lists = await _service.getLists();
      Log.info(_tag, 'State updated: ${lists.length} lists');
      state = AsyncValue.data(lists);
    } catch (error, stackTrace) {
      Log.error(_tag, 'Failed to load lists', error, stackTrace);
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

// Favorite Products Provider
final favoriteProductsProvider =
    StateNotifierProvider<FavoriteProductsNotifier, AsyncValue<List<Product>>>(
  (ref) => FavoriteProductsNotifier(ref.watch(favoriteServiceProvider)),
);

class FavoriteProductsNotifier
    extends StateNotifier<AsyncValue<List<Product>>> {
  final FavoriteService _service;
  static const _tag = 'FavoriteProductsNotifier';

  FavoriteProductsNotifier(this._service) : super(const AsyncValue.loading()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    state = const AsyncValue.loading();
    try {
      final favorites = await _service.getFavorites();
      Log.info(_tag, 'State updated: ${favorites.length} favorites');
      state = AsyncValue.data(favorites);
    } catch (error, stackTrace) {
      Log.error(_tag, 'Failed to load favorites', error, stackTrace);
      state = AsyncValue.error(error, stackTrace);
    }
  }

  Future<void> toggleFavorite(Product product) async {
    try {
      await _service.toggleFavorite(product.id);
      await loadFavorites();
    } catch (error) {
      rethrow;
    }
  }

  bool isFavorite(String productId) {
    return state.whenData((products) {
          return products.any((p) => p.id == productId);
        }).value ??
        false;
  }
}
