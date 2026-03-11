import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../models/shopping_list_item.dart';
import '../providers/providers.dart';
import '../services/logger.dart';
import 'error_snackbar.dart';

/// Card-style grid tile for a shopping list item, inspired by Bring! / KitchenOwl.
/// Shows product image, name, quantity, category badge, and action buttons.
class ListItemGridCard extends ConsumerWidget {
  final ShoppingListItem item;
  final String listId;
  final VoidCallback onRefresh;

  const ListItemGridCard({
    super.key,
    required this.item,
    required this.listId,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isChecked = item.isChecked;

    return Card(
      color: isChecked ? AppTheme.dividerColor : AppTheme.surfaceColor,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => _toggleChecked(context, ref),
        onLongPress: () => _deleteItem(context, ref),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Product image or placeholder
                Expanded(
                  flex: 3,
                  child: _buildImage(),
                ),

                // Item info
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 8, 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Name
                        Flexible(
                          child: Text(
                            item.name,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  decoration: isChecked
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: isChecked
                                      ? AppTheme.textSecondaryColor
                                      : AppTheme.textPrimaryColor,
                                ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(height: 1),

                        // Quantity + category
                        Row(
                          children: [
                            Text(
                              item.displayQuantity,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                    fontSize: 10,
                                  ),
                            ),
                            if (item.category != null) ...[
                              const SizedBox(width: 4),
                              Flexible(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(3),
                                  ),
                                  child: Text(
                                    item.category!,
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodySmall
                                        ?.copyWith(
                                          color: AppTheme.primaryColor,
                                          fontSize: 9,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Checked overlay
            if (isChecked)
              Positioned.fill(
                child: Container(
                  color: Colors.white.withValues(alpha: 0.4),
                  child: const Center(
                    child: Icon(
                      Icons.check_circle,
                      size: 36,
                      color: AppTheme.successColor,
                    ),
                  ),
                ),
              ),

            // Favorite star
            if (item.product != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => _toggleFavorite(context, ref),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.product!.isFavorite
                          ? Icons.star
                          : Icons.star_border,
                      size: 16,
                      color: item.product!.isFavorite
                          ? Colors.amber
                          : AppTheme.textSecondaryColor,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (item.product?.imageUrl != null) {
      return CachedNetworkImage(
        imageUrl: item.product!.imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _buildPlaceholder(
          child: const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
        errorWidget: (_, __, ___) => _buildPlaceholder(),
      );
    }
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder({Widget? child}) {
    return Container(
      color: AppTheme.dividerColor,
      child: Center(
        child: child ??
            const Icon(
              Icons.shopping_basket,
              size: 28,
              color: AppTheme.textSecondaryColor,
            ),
      ),
    );
  }

  Future<void> _toggleChecked(BuildContext context, WidgetRef ref) async {
    Log.debug('ListItemGridCard',
        'Toggling check on "${item.name}" → ${!item.isChecked}');
    try {
      final service = ref.read(shoppingListServiceProvider);
      await service.updateItem(
        listId: listId,
        itemId: item.id,
        isChecked: !item.isChecked,
      );
      onRefresh();
    } catch (e) {
      Log.error(
          'ListItemGridCard', 'Toggle check failed for "${item.name}"', e);
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _deleteItem(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content: Text('Are you sure you want to delete "${item.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    Log.info(
        'ListItemGridCard', 'Deleting item "${item.name}" (${item.id})');
    try {
      final service = ref.read(shoppingListServiceProvider);
      await service.deleteItem(listId: listId, itemId: item.id);
      onRefresh();

      if (context.mounted) {
        showSuccessSnackBar(context, 'Item deleted');
      }
    } catch (e) {
      Log.error('ListItemGridCard', 'Delete failed for "${item.name}"', e);
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _toggleFavorite(BuildContext context, WidgetRef ref) async {
    if (item.product == null) return;

    Log.info(
        'ListItemGridCard', 'Toggling favorite for "${item.product!.name}"');
    try {
      final favoritesNotifier = ref.read(favoriteProductsProvider.notifier);
      await favoritesNotifier.toggleFavorite(item.product!);
      onRefresh();

      if (context.mounted) {
        final isFavorite = favoritesNotifier.isFavorite(item.product!.id);
        showSuccessSnackBar(
          context,
          isFavorite ? 'Added to favorites' : 'Removed from favorites',
          duration: const Duration(seconds: 1),
        );
      }
    } catch (e) {
      Log.error('ListItemGridCard', 'Toggle favorite failed', e);
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }
}
