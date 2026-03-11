import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../config/app_theme.dart';
import '../../providers/providers.dart';
import '../../services/logger.dart';
import '../../widgets/pantry_card.dart';
import '../../widgets/create_pantry_dialog.dart';
import '../../widgets/error_snackbar.dart';

class PantryListScreen extends ConsumerWidget {
  const PantryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantriesAsync = ref.watch(pantriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Pantries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Log.debug('PantryListScreen', 'Manual refresh tapped');
              ref.read(pantriesProvider.notifier).loadPantries();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(pantriesProvider.notifier).loadPantries();
        },
        child: pantriesAsync.when(
          data: (pantries) {
            if (pantries.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.kitchen_outlined,
                      size: 64,
                      color: AppTheme.textTertiaryColor,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No pantries yet',
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge
                          ?.copyWith(color: AppTheme.textSecondaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Create your first pantry to track your food',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textTertiaryColor),
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: pantries.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final pantry = pantries[index];
                return PantryCard(
                  pantry: pantry,
                  onTap: () {
                    Log.debug('PantryListScreen',
                        'Navigating to pantry "${pantry.name}" (${pantry.id})');
                    context.push('/pantry/${pantry.id}');
                  },
                );
              },
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cloud_off_outlined,
                      size: 64, color: AppTheme.textTertiaryColor),
                  const SizedBox(height: 16),
                  Text('Could not load your pantries',
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 8),
                  Text(
                    friendlyErrorMessage(error),
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(color: AppTheme.textSecondaryColor),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () =>
                        ref.read(pantriesProvider.notifier).loadPantries(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await showDialog(
            context: context,
            builder: (context) => const CreatePantryDialog(),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('New Pantry'),
      ),
    );
  }
}
