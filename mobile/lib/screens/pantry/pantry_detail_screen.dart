import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../config/app_theme.dart';
import '../../models/pantry_item.dart';
import '../../models/storage_location.dart';
import '../../providers/providers.dart';
import '../../services/logger.dart';
import '../../widgets/pantry_item_card.dart';
import '../../widgets/error_snackbar.dart';
import 'add_pantry_item_screen.dart';

class PantryDetailScreen extends ConsumerWidget {
  final String pantryId;

  const PantryDetailScreen({
    super.key,
    required this.pantryId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pantryAsync = ref.watch(pantryProvider(pantryId));
    final searchQuery = ref.watch(pantrySearchQueryProvider);
    final locationFilter = ref.watch(pantryStorageFilterProvider);

    return Scaffold(
      appBar: AppBar(
        title: pantryAsync.when(
          data: (pantry) => Text(pantry.name),
          loading: () => const Text('Loading...'),
          error: (_, __) => const Text('Error'),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              showInfoSnackBar(context, 'Share functionality coming soon');
            },
          ),
          PopupMenuButton(
            itemBuilder: (context) => [
              PopupMenuItem(
                child: const Row(
                  children: [
                    Icon(Icons.edit_location_alt_outlined, size: 20),
                    SizedBox(width: 12),
                    Text('Manage Locations'),
                  ],
                ),
                onTap: () => _manageLocations(context, ref),
              ),
            ],
          ),
        ],
      ),
      body: pantryAsync.when(
        data: (pantry) {
          final expiredCount = pantry.expiredItemCount;
          final expiringCount = pantry.expiringItemCount;

          // Filter items
          var filteredItems = pantry.items.toList();
          if (searchQuery.isNotEmpty) {
            filteredItems = filteredItems
                .where((item) => item.name
                    .toLowerCase()
                    .contains(searchQuery.toLowerCase()))
                .toList();
          }
          if (locationFilter != null) {
            filteredItems = filteredItems
                .where((item) =>
                    item.storageLocation?.id == locationFilter)
                .toList();
          }

          // Group by storage location
          final grouped = <StorageLocation?, List<PantryItem>>{};
          for (final item in filteredItems) {
            grouped.putIfAbsent(item.storageLocation, () => []).add(item);
          }

          // Sort groups: locations by order, null last
          final sortedLocations = pantry.storageLocations.toList()
            ..sort((a, b) => a.order.compareTo(b.order));

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(pantryProvider(pantryId));
            },
            child: Column(
              children: [
                // Expiration warning banner
                if (expiredCount > 0 || expiringCount > 0)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    color: expiredCount > 0
                        ? AppTheme.errorColor.withValues(alpha: 0.1)
                        : AppTheme.warningColor.withValues(alpha: 0.1),
                    child: Row(
                      children: [
                        Icon(
                          expiredCount > 0
                              ? Icons.warning_amber_rounded
                              : Icons.schedule,
                          size: 20,
                          color: expiredCount > 0
                              ? AppTheme.errorColor
                              : AppTheme.warningColor,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          expiredCount > 0
                              ? '$expiredCount expired item${expiredCount > 1 ? 's' : ''}${expiringCount > 0 ? ', $expiringCount expiring soon' : ''}'
                              : '$expiringCount item${expiringCount > 1 ? 's' : ''} expiring soon',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                color: expiredCount > 0
                                    ? AppTheme.errorColor
                                    : AppTheme.warningColor,
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ],
                    ),
                  ),

                // Search bar
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search items...',
                      prefixIcon: const Icon(Icons.search, size: 20),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: searchQuery.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear, size: 18),
                              onPressed: () => ref
                                  .read(pantrySearchQueryProvider.notifier)
                                  .state = '',
                            )
                          : null,
                    ),
                    onChanged: (value) =>
                        ref.read(pantrySearchQueryProvider.notifier).state =
                            value,
                  ),
                ),

                // Location filter chips
                if (sortedLocations.isNotEmpty)
                  SizedBox(
                    height: 40,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        FilterChip(
                          label: Text(
                            'All',
                            style: TextStyle(
                              color: locationFilter == null
                                  ? AppTheme.primaryColor
                                  : AppTheme.textPrimaryColor,
                            ),
                          ),
                          selected: locationFilter == null,
                          onSelected: (_) => ref
                              .read(pantryStorageFilterProvider.notifier)
                              .state = null,
                        ),
                        const SizedBox(width: 8),
                        ...sortedLocations.map((loc) => Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                avatar: Icon(loc.iconData, size: 16),
                                label: Text(
                                  loc.name,
                                  style: TextStyle(
                                    color: locationFilter == loc.id
                                        ? AppTheme.primaryColor
                                        : AppTheme.textPrimaryColor,
                                  ),
                                ),
                                selected: locationFilter == loc.id,
                                onSelected: (_) => ref
                                    .read(
                                        pantryStorageFilterProvider.notifier)
                                    .state = locationFilter == loc.id
                                        ? null
                                        : loc.id,
                              ),
                            )),
                      ],
                    ),
                  ),

                const SizedBox(height: 8),

                // Items grouped by location
                Expanded(
                  child: filteredItems.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.inventory_2_outlined,
                                  size: 64,
                                  color: AppTheme.textTertiaryColor),
                              const SizedBox(height: 16),
                              Text(
                                pantry.items.isEmpty
                                    ? 'No items in this pantry'
                                    : 'No items match your search',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                        color: AppTheme.textSecondaryColor),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Tap + to add items',
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                        color: AppTheme.textTertiaryColor),
                              ),
                            ],
                          ),
                        )
                      : _buildGroupedList(context, ref, sortedLocations,
                          grouped, pantry.storageLocations),
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
                const Icon(Icons.cloud_off_outlined,
                    size: 64, color: AppTheme.textTertiaryColor),
                const SizedBox(height: 16),
                Text('Could not load this pantry',
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
                      ref.invalidate(pantryProvider(pantryId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'pantryDetailFab',
        onPressed: () async {
          final pantry = pantryAsync.valueOrNull;
          if (pantry == null) return;

          final added = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (_) => AddPantryItemScreen(
                pantryId: pantryId,
                storageLocations: pantry.storageLocations,
              ),
            ),
          );
          if (added == true) {
            ref.invalidate(pantryProvider(pantryId));
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildGroupedList(
    BuildContext context,
    WidgetRef ref,
    List<StorageLocation> sortedLocations,
    Map<StorageLocation?, List<PantryItem>> grouped,
    List<StorageLocation> allLocations,
  ) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 80),
      children: [
        // Items with a storage location (grouped)
        for (final loc in sortedLocations)
          if (grouped.containsKey(loc) ||
              grouped.keys.any(
                  (k) => k != null && k.id == loc.id))
            _buildLocationSection(context, ref, loc,
                _getItemsForLocation(grouped, loc), allLocations),

        // Items without a storage location
        if (grouped.containsKey(null) &&
            grouped[null]!.isNotEmpty)
          _buildLocationSection(
              context, ref, null, grouped[null]!, allLocations),
      ],
    );
  }

  List<PantryItem> _getItemsForLocation(
      Map<StorageLocation?, List<PantryItem>> grouped,
      StorageLocation loc) {
    for (final entry in grouped.entries) {
      if (entry.key != null && entry.key!.id == loc.id) {
        return entry.value;
      }
    }
    return [];
  }

  Widget _buildLocationSection(
    BuildContext context,
    WidgetRef ref,
    StorageLocation? location,
    List<PantryItem> items,
    List<StorageLocation> allLocations,
  ) {
    if (items.isEmpty) return const SizedBox.shrink();

    // Sort by expiration date (soonest first), then by name
    final sortedItems = items.toList()
      ..sort((a, b) {
        if (a.expirationDate != null && b.expirationDate != null) {
          return a.expirationDate!.compareTo(b.expirationDate!);
        }
        if (a.expirationDate != null) return -1;
        if (b.expirationDate != null) return 1;
        return a.name.compareTo(b.name);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Row(
            children: [
              Icon(
                location?.iconData ?? Icons.inventory_2,
                size: 20,
                color: AppTheme.primaryColor,
              ),
              const SizedBox(width: 8),
              Text(
                location?.name ?? 'Uncategorized',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryColor,
                    ),
              ),
              const SizedBox(width: 8),
              Text(
                '(${items.length})',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textTertiaryColor,
                    ),
              ),
            ],
          ),
        ),
        ...sortedItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: PantryItemCard(
                item: item,
                pantryId: pantryId,
                onRefresh: () => ref.invalidate(pantryProvider(pantryId)),
              ),
            )),
      ],
    );
  }

  void _manageLocations(BuildContext context, WidgetRef ref) {
    final pantry = ref.read(pantryProvider(pantryId)).valueOrNull;
    if (pantry == null) return;

    Log.info('PantryDetailScreen', 'Opening location manager');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _LocationManagerSheet(
        pantryId: pantryId,
        locations: pantry.storageLocations,
        onChanged: () => ref.invalidate(pantryProvider(pantryId)),
      ),
    );
  }
}

class _LocationManagerSheet extends ConsumerStatefulWidget {
  final String pantryId;
  final List<StorageLocation> locations;
  final VoidCallback onChanged;

  const _LocationManagerSheet({
    required this.pantryId,
    required this.locations,
    required this.onChanged,
  });

  @override
  ConsumerState<_LocationManagerSheet> createState() =>
      _LocationManagerSheetState();
}

class _LocationManagerSheetState
    extends ConsumerState<_LocationManagerSheet> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.5,
      minChildSize: 0.3,
      maxChildSize: 0.8,
      expand: false,
      builder: (context, scrollController) => Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Storage Locations',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),

            // Add new location
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      hintText: 'New location name',
                      isDense: true,
                    ),
                    textCapitalization: TextCapitalization.sentences,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.add_circle,
                      color: AppTheme.primaryColor),
                  onPressed: _addLocation,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Existing locations
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: widget.locations.length,
                itemBuilder: (context, index) {
                  final loc = widget.locations[index];
                  return ListTile(
                    leading: Icon(loc.iconData),
                    title: Text(loc.name),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete_outline,
                          color: AppTheme.errorColor, size: 20),
                      onPressed: () => _deleteLocation(loc),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addLocation() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    Log.info('LocationManager', 'Adding location "$name"');
    try {
      final service = ref.read(pantryServiceProvider);
      await service.addStorageLocation(
        pantryId: widget.pantryId,
        name: name,
      );
      _nameController.clear();
      widget.onChanged();
      if (mounted) {
        Navigator.pop(context);
        showSuccessSnackBar(context, 'Added "$name"');
      }
    } catch (e) {
      Log.error('LocationManager', 'Add location failed', e);
      if (mounted) showErrorSnackBar(context, e);
    }
  }

  Future<void> _deleteLocation(StorageLocation loc) async {
    Log.info('LocationManager', 'Deleting location "${loc.name}"');
    try {
      final service = ref.read(pantryServiceProvider);
      await service.deleteStorageLocation(
        pantryId: widget.pantryId,
        locationId: loc.id,
      );
      widget.onChanged();
      if (mounted) {
        Navigator.pop(context);
        showSuccessSnackBar(context, 'Deleted "${loc.name}"');
      }
    } catch (e) {
      Log.error('LocationManager', 'Delete location failed', e);
      if (mounted) showErrorSnackBar(context, e);
    }
  }
}
