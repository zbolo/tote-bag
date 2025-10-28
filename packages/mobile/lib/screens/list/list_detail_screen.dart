import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/providers.dart';
import '../../widgets/list_item_card.dart';
import '../../widgets/add_item_dialog.dart';

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
                const SnackBar(content: Text('Share functionality coming soon')),
              );
            },
          ),
        ],
      ),
      body: listAsync.when(
        data: (list) {
          final uncheckedItems = list.items.where((item) => !item.isChecked).toList();
          final checkedItems = list.items.where((item) => item.isChecked).toList();

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(shoppingListProvider(listId));
            },
            child: Column(
              children: [
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
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
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
                Expanded(
                  child: list.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
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
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Add items to get started',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
}
