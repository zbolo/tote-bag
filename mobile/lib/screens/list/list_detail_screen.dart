import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/logger.dart';
import '../../widgets/list_item_card.dart';
import '../../widgets/list_item_grid_card.dart';
import '../../widgets/add_item_dialog.dart';
import '../../widgets/product_grid_item.dart';
import '../../widgets/error_snackbar.dart';
import '../../models/product.dart';
import '../../models/shopping_list.dart';
import '../../models/shopping_list_item.dart';

class ListDetailScreen extends ConsumerWidget {
  final String listId;

  const ListDetailScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(shoppingListProvider(listId));
    final viewMode = ref.watch(listViewModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: listAsync.when(
          data: (list) => Text(list.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: Icon(
              viewMode == ListViewMode.list
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
            ),
            tooltip: viewMode == ListViewMode.list
                ? 'Switch to card view'
                : 'Switch to list view',
            onPressed: () {
              final newMode = viewMode == ListViewMode.list
                  ? ListViewMode.grid
                  : ListViewMode.list;
              ref.read(listViewModeProvider.notifier).state = newMode;
              Log.debug('ListDetailScreen',
                  'View mode toggled → ${newMode.name}');
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/scanner/$listId'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showInfoSnackBar(context, 'Share functionality coming soon');
            },
          ),
        ],
      ),
      body: listAsync.when(
        data: (list) {
          final uncheckedItems =
              list.items.where((item) => !item.isChecked).toList();
          final checkedItems =
              list.items.where((item) => item.isChecked).toList();
          final favoritesAsync = ref.watch(favoriteProductsProvider);

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(shoppingListProvider(listId));
              ref.invalidate(favoriteProductsProvider);
            },
            child: Column(
              children: [
                // Progress Bar
                if (list.items.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: AppTheme.surfaceColor,
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${list.checkedItems} of ${list.totalItems} items',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            Text(
                              '${(list.progress * 100).toInt()}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    color: AppTheme.primaryColor,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: list.progress,
                          backgroundColor: AppTheme.dividerColor,
                          minHeight: 6,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ],
                    ),
                  ),

                // Shopping List + Favorites (scrollable)
                Expanded(
                  child: list.items.isEmpty
                      ? _buildEmptyWithFavorites(
                          context, ref, list, favoritesAsync)
                      : viewMode == ListViewMode.list
                          ? _buildListView(context, ref, uncheckedItems,
                              checkedItems, list, favoritesAsync)
                          : _buildGridView(context, ref, uncheckedItems,
                              checkedItems, list, favoritesAsync),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: AppTheme.textTertiaryColor,
                ),
                const SizedBox(height: 16),
                Text(
                  'Could not load this list',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  friendlyErrorMessage(error),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () => ref.invalidate(shoppingListProvider(listId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => AddItemDialog(listId: listId),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyWithFavorites(
    BuildContext context,
    WidgetRef ref,
    ShoppingList list,
    AsyncValue<List<Product>> favoritesAsync,
  ) {
    return ListView(
      children: [
        const SizedBox(height: 48),
        const Icon(
          Icons.shopping_cart_outlined,
          size: 64,
          color: AppTheme.textTertiaryColor,
        ),
        const SizedBox(height: 16),
        Text(
          'No items in this list',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textSecondaryColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap a favorite below or use the + button',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textTertiaryColor,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),
        ..._buildFavoritesSection(context, ref, list, favoritesAsync),
      ],
    );
  }

  Widget _buildListView(
    BuildContext context,
    WidgetRef ref,
    List<ShoppingListItem> uncheckedItems,
    List<ShoppingListItem> checkedItems,
    ShoppingList list,
    AsyncValue<List<Product>> favoritesAsync,
  ) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (uncheckedItems.isNotEmpty) ...[
          ...uncheckedItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListItemCard(
                  item: item,
                  listId: listId,
                  onRefresh: () {
                    ref.invalidate(shoppingListProvider(listId));
                  },
                ),
              )),
        ],
        if (checkedItems.isNotEmpty) ...[
          if (uncheckedItems.isNotEmpty) const SizedBox(height: 16),
          Text(
            'Checked Items',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.textSecondaryColor,
                ),
          ),
          const SizedBox(height: 12),
          ...checkedItems.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: ListItemCard(
                  item: item,
                  listId: listId,
                  onRefresh: () {
                    ref.invalidate(shoppingListProvider(listId));
                  },
                ),
              )),
        ],
        // Favorites section at the bottom
        ..._buildFavoritesSection(context, ref, list, favoritesAsync),
      ],
    );
  }

  Widget _buildGridView(
    BuildContext context,
    WidgetRef ref,
    List<ShoppingListItem> uncheckedItems,
    List<ShoppingListItem> checkedItems,
    ShoppingList list,
    AsyncValue<List<Product>> favoritesAsync,
  ) {
    final productsInList = list.items
        .where((item) => item.product != null)
        .map((item) => item.product!.id)
        .toSet();

    return CustomScrollView(
      slivers: [
        if (uncheckedItems.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListItemGridCard(
                  key: ValueKey(uncheckedItems[index].id),
                  item: uncheckedItems[index],
                  listId: listId,
                  onRefresh: () {
                    ref.invalidate(shoppingListProvider(listId));
                  },
                ),
                childCount: uncheckedItems.length,
              ),
            ),
          ),
        if (checkedItems.isNotEmpty) ...[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
                16, uncheckedItems.isNotEmpty ? 24 : 16, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Text(
                'Checked Items',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textSecondaryColor,
                    ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) => ListItemGridCard(
                  key: ValueKey(checkedItems[index].id),
                  item: checkedItems[index],
                  listId: listId,
                  onRefresh: () {
                    ref.invalidate(shoppingListProvider(listId));
                  },
                ),
                childCount: checkedItems.length,
              ),
            ),
          ),
        ],
        // Favorites section at the bottom
        ..._buildFavoritesSlivers(
            context, ref, list, favoritesAsync, productsInList),
      ],
    );
  }

  /// Builds the favorites section as regular widgets (for ListView).
  List<Widget> _buildFavoritesSection(
    BuildContext context,
    WidgetRef ref,
    ShoppingList list,
    AsyncValue<List<Product>> favoritesAsync,
  ) {
    return favoritesAsync.when(
      data: (favorites) {
        if (favorites.isEmpty) return [];

        final productsInList = list.items
            .where((item) => item.product != null)
            .map((item) => item.product!.id)
            .toSet();

        return [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quick Add',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                TextButton.icon(
                  onPressed: () => context.push('/scanner/$listId'),
                  icon: const Icon(Icons.qr_code_scanner, size: 18),
                  label: const Text('Scan'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppTheme.primaryColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 0.75,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final product = favorites[index];
              final isInList = productsInList.contains(product.id);

              return ProductGridItem(
                product: product,
                isInList: isInList,
                onTap: () =>
                    _quickAddProduct(context, ref, product, isInList),
              );
            },
          ),
          const SizedBox(height: 80), // space for FAB
        ];
      },
      loading: () => [
        const Padding(
          padding: EdgeInsets.all(32),
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (_, __) => [],
    );
  }

  /// Builds the favorites section as slivers (for CustomScrollView / grid view).
  List<Widget> _buildFavoritesSlivers(
    BuildContext context,
    WidgetRef ref,
    ShoppingList list,
    AsyncValue<List<Product>> favoritesAsync,
    Set<String> productsInList,
  ) {
    return favoritesAsync.when(
      data: (favorites) {
        if (favorites.isEmpty) return [];

        return [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
            sliver: SliverToBoxAdapter(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Quick Add',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  TextButton.icon(
                    onPressed: () => context.push('/scanner/$listId'),
                    icon: const Icon(Icons.qr_code_scanner, size: 18),
                    label: const Text('Scan'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 80),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.75,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final product = favorites[index];
                  final isInList = productsInList.contains(product.id);

                  return ProductGridItem(
                    product: product,
                    isInList: isInList,
                    onTap: () =>
                        _quickAddProduct(context, ref, product, isInList),
                  );
                },
                childCount: favorites.length,
              ),
            ),
          ),
        ];
      },
      loading: () => [
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        ),
      ],
      error: (_, __) => [],
    );
  }

  Future<void> _quickAddProduct(
    BuildContext context,
    WidgetRef ref,
    Product product,
    bool isInList,
  ) async {
    if (isInList) {
      showInfoSnackBar(context, '${product.name} is already in your list',
          duration: const Duration(seconds: 1));
      return;
    }

    Log.info('ListDetailScreen', 'Quick adding "${product.name}" to list $listId');
    try {
      final service = ref.read(shoppingListServiceProvider);
      await service.addItem(
        listId: listId,
        name: product.name,
        quantity: 1,
        unit: 'pcs',
        productId: product.id,
        category: product.category,
      );

      ref.invalidate(shoppingListProvider(listId));

      if (context.mounted) {
        showSuccessSnackBar(context, 'Added ${product.name} to list',
            duration: const Duration(seconds: 1));
      }
    } catch (e) {
      Log.error('ListDetailScreen', 'Quick add failed for "${product.name}"', e);
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }
}
