import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/list_item_card.dart';
import '../../widgets/add_item_dialog.dart';
import '../../widgets/product_grid_item.dart';
import '../../models/product.dart';

class ListDetailScreen extends ConsumerWidget {
  final String listId;

  const ListDetailScreen({
    super.key,
    required this.listId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final listAsync = ref.watch(shoppingListProvider(listId));

    return Scaffold(
      appBar: AppBar(
        title: listAsync.when(
          data: (list) => Text(list.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () => context.push('/scanner/$listId'),
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Implement share functionality
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('Share functionality coming soon')),
              );
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
                // Product Grid Section (Bring! style)
                Container(
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quick Add',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
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
                      SizedBox(
                        height: 180,
                        child: favoritesAsync.when(
                          data: (favorites) {
                            if (favorites.isEmpty) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Text(
                                    'Star products to see them here for quick add',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(
                                          color: AppTheme.textSecondaryColor,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              );
                            }

                            // Get product IDs that are already in the list
                            final productsInList = list.items
                                .where((item) => item.product != null)
                                .map((item) => item.product!.id)
                                .toSet();

                            return GridView.builder(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              scrollDirection: Axis.horizontal,
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 1,
                                mainAxisSpacing: 12,
                                childAspectRatio: 1.2,
                              ),
                              itemCount: favorites.length,
                              itemBuilder: (context, index) {
                                final product = favorites[index];
                                final isInList =
                                    productsInList.contains(product.id);

                                return ProductGridItem(
                                  product: product,
                                  isInList: isInList,
                                  onTap: () => _quickAddProduct(
                                      context, ref, product, isInList),
                                );
                              },
                            );
                          },
                          loading: () =>
                              const Center(child: CircularProgressIndicator()),
                          error: (_, __) => Center(
                            child: Text(
                              'Failed to load favorites',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.errorColor,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

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

                // Shopping List Section
                Expanded(
                  child: list.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.shopping_cart_outlined,
                                size: 64,
                                color: AppTheme.textTertiaryColor,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'No items in this list',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: AppTheme.textSecondaryColor,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap products above or use the + button',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color: AppTheme.textTertiaryColor,
                                    ),
                              ),
                            ],
                          ),
                        )
                      : ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            if (uncheckedItems.isNotEmpty) ...[
                              ...uncheckedItems.map((item) => Padding(
                                    padding: const EdgeInsets.only(bottom: 12),
                                    child: ListItemCard(
                                      item: item,
                                      listId: listId,
                                      onRefresh: () {
                                        ref.invalidate(
                                            shoppingListProvider(listId));
                                      },
                                    ),
                                  )),
                            ],
                            if (checkedItems.isNotEmpty) ...[
                              if (uncheckedItems.isNotEmpty)
                                const SizedBox(height: 16),
                              Text(
                                'Checked Items',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
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
                                        ref.invalidate(
                                            shoppingListProvider(listId));
                                      },
                                    ),
                                  )),
                            ],
                          ],
                        ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: AppTheme.errorColor,
              ),
              const SizedBox(height: 16),
              Text(
                'Error loading list',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
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

  Future<void> _quickAddProduct(
    BuildContext context,
    WidgetRef ref,
    Product product,
    bool isInList,
  ) async {
    try {
      final service = ref.read(shoppingListServiceProvider);

      if (isInList) {
        // Show snackbar that item is already in list
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${product.name} is already in your list'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppTheme.textSecondaryColor,
          ),
        );
        return;
      }

      // Add the product to the list
      await service.addItem(
        listId: listId,
        name: product.name,
        quantity: 1,
        unit: 'pcs',
        productId: product.id,
        category: product.category,
      );

      // Refresh the list
      ref.invalidate(shoppingListProvider(listId));

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Added ${product.name} to list'),
            duration: const Duration(seconds: 1),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }
}
