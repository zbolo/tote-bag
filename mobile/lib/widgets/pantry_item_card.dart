import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../config/app_theme.dart';
import '../models/pantry_item.dart';
import '../providers/providers.dart';
import '../services/logger.dart';
import 'edit_quantity_dialog.dart';
import 'error_snackbar.dart';

class PantryItemCard extends ConsumerStatefulWidget {
  final PantryItem item;
  final String pantryId;
  final VoidCallback onRefresh;
  final VoidCallback? onEdit;

  const PantryItemCard({
    super.key,
    required this.item,
    required this.pantryId,
    required this.onRefresh,
    this.onEdit,
  });

  @override
  ConsumerState<PantryItemCard> createState() => _PantryItemCardState();
}

class _PantryItemCardState extends ConsumerState<PantryItemCard> {
  late double _sliderValue;

  @override
  void initState() {
    super.initState();
    _sliderValue = widget.item.sliderValue;
  }

  @override
  void didUpdateWidget(PantryItemCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newVal = widget.item.sliderValue;
    final oldVal = oldWidget.item.sliderValue;
    if (oldVal != newVal) {
      _sliderValue = newVal;
    }
  }

  /// Compute percentage from the live slider value instead of the model.
  double get _livePct {
    final item = widget.item;
    final max = item.sliderMax;
    return max > 0 ? (_sliderValue / max).clamp(0.0, 1.0) : 0.0;
  }

  /// Compute content quantity display from the live slider value.
  String? get _liveContentDisplay {
    final item = widget.item;
    if (!item.hasContentTracking) return null;
    final qty = _sliderValue;
    final fmtQty =
        qty % 1 == 0 ? qty.toInt().toString() : qty.toStringAsFixed(1);
    final fmtMax = item.contentMaxQuantity! % 1 == 0
        ? item.contentMaxQuantity!.toInt().toString()
        : item.contentMaxQuantity!.toStringAsFixed(1);
    final u = item.contentUnit ?? '';
    return '$fmtQty / $fmtMax $u'.trim();
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;
    final pct = _livePct;

    return Card(
      child: InkWell(
        onTap: widget.onEdit,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product image thumbnail
              if (item.product?.imageUrl != null) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: CachedNetworkImage(
                      imageUrl: item.product!.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppTheme.dividerColor,
                        child: const Center(
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          ),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.dividerColor,
                        child: const Icon(Icons.inventory_2_outlined,
                            size: 24, color: AppTheme.textSecondaryColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
              ],

              // Main content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row: name, expiry badge, delete button
                    Row(
                      children: [
                        if (item.storageLocation != null) ...[
                          Icon(
                            item.storageLocation!.iconData,
                            size: 18,
                            color: AppTheme.textSecondaryColor,
                          ),
                          const SizedBox(width: 8),
                        ],
                        Expanded(
                          child: Text(
                            item.name,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ),
                        if (item.expirationDate != null)
                          _buildExpiryChip(context, item),
                        IconButton(
                          icon: const Icon(Icons.delete_outline, size: 20),
                          onPressed: () => _deleteItem(context),
                          color: AppTheme.errorColor,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Quantity info row
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => _editQuantity(context),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: AppTheme.dividerColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              item.displayQuantity,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: AppTheme.textSecondaryColor,
                                  ),
                            ),
                          ),
                        ),
                        if (_liveContentDisplay != null) ...[
                          const SizedBox(width: 6),
                          Text(
                            '·',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.textTertiaryColor,
                                ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _liveContentDisplay!,
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: _quantityColor(pct),
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                        if (item.category != null) ...[
                          const SizedBox(width: 8),
                          Flexible(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor
                                    .withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                item.category!,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(
                                      color: AppTheme.primaryColor,
                                      fontSize: 10,
                                    ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                        if (item.isLowStock) ...[
                          const SizedBox(width: 8),
                          const Icon(Icons.trending_down,
                              size: 14, color: AppTheme.secondaryColor),
                          const SizedBox(width: 2),
                          Text(
                            'Low',
                            style: Theme.of(context)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: AppTheme.secondaryColor,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ],
                      ],
                    ),

                    // Content quantity slider (only when content tracking is enabled)
                    if (item.hasContentTracking) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 6,
                                thumbShape:
                                    const RoundSliderThumbShape(
                                        enabledThumbRadius: 8),
                                activeTrackColor: _quantityColor(pct),
                                inactiveTrackColor:
                                    _quantityColor(pct)
                                        .withValues(alpha: 0.2),
                                thumbColor: _quantityColor(pct),
                                overlayColor:
                                    _quantityColor(pct)
                                        .withValues(alpha: 0.1),
                              ),
                              child: Slider(
                                value: _sliderValue.clamp(
                                    0, item.sliderMax),
                                min: 0,
                                max: item.sliderMax,
                                divisions:
                                    _sliderDivisions(item.sliderMax),
                                onChanged: (value) {
                                  setState(() => _sliderValue = value);
                                },
                                onChangeEnd: (value) =>
                                    _updateContentQuantity(value),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 48,
                            child: Text(
                              '${(pct * 100).toInt()}%',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(
                                    color: _quantityColor(pct),
                                    fontWeight: FontWeight.bold,
                                  ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ],
                      ),
                    ],

                    if (item.notes != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        item.notes!,
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textTertiaryColor,
                                ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _quantityColor(double pct) {
    if (pct > 0.5) return AppTheme.successColor;
    if (pct > 0.25) return AppTheme.warningColor;
    return AppTheme.errorColor;
  }

  int _sliderDivisions(double maxQuantity) {
    if (maxQuantity <= 5) return (maxQuantity * 10).toInt();
    if (maxQuantity <= 20) return maxQuantity.toInt();
    return 20;
  }

  Widget _buildExpiryChip(BuildContext context, PantryItem item) {
    final days = item.daysUntilExpiration!;
    final Color color;
    final String label;

    if (days < 0) {
      color = AppTheme.errorColor;
      label = 'Expired';
    } else if (days == 0) {
      color = AppTheme.errorColor;
      label = 'Today';
    } else if (days <= 3) {
      color = AppTheme.errorColor;
      label = '${days}d';
    } else if (days <= 7) {
      color = AppTheme.warningColor;
      label = '${days}d';
    } else {
      color = AppTheme.successColor;
      label = DateFormat('dd/MM/yy').format(item.expirationDate!);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
      ),
    );
  }

  Future<void> _editQuantity(BuildContext context) async {
    final item = widget.item;
    final newQuantity = await showDialog<int>(
      context: context,
      builder: (context) => EditQuantityDialog(
        itemName: item.name,
        quantity: item.quantity.toInt(),
        unit: item.unit,
      ),
    );

    if (newQuantity == null || newQuantity == item.quantity.toInt()) return;

    Log.info('PantryItemCard',
        'Updating piece quantity for "${item.name}" → $newQuantity');
    try {
      final service = ref.read(pantryServiceProvider);

      // When content tracking is on and quantity decreases,
      // clamp contentQuantity to the new total max.
      double? clampedContent;
      if (item.hasContentTracking) {
        final newTotalMax = newQuantity * item.contentPerUnit;
        final currentContent = item.contentQuantity ?? 0;
        if (currentContent > newTotalMax) {
          clampedContent = newTotalMax;
        }
      }

      await service.updateItem(
        pantryId: widget.pantryId,
        itemId: item.id,
        quantity: newQuantity.toDouble(),
        maxQuantity: newQuantity.toDouble(),
        contentQuantity: clampedContent,
      );
      widget.onRefresh();
    } catch (e) {
      Log.error('PantryItemCard', 'Quantity edit failed', e);
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _updateContentQuantity(double value) async {
    final item = widget.item;
    Log.debug('PantryItemCard',
        'Updating content quantity of "${item.name}" → $value');
    try {
      final service = ref.read(pantryServiceProvider);
      await service.updateItem(
        pantryId: widget.pantryId,
        itemId: item.id,
        contentQuantity: value,
      );
      widget.onRefresh();
    } catch (e) {
      Log.error('PantryItemCard', 'Content quantity update failed', e);
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _deleteItem(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Item'),
        content:
            Text('Are you sure you want to delete "${widget.item.name}"?'),
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

    Log.info('PantryItemCard',
        'Deleting item "${widget.item.name}" (${widget.item.id})');
    try {
      final service = ref.read(pantryServiceProvider);
      await service.deleteItem(
          pantryId: widget.pantryId, itemId: widget.item.id);
      widget.onRefresh();

      if (context.mounted) {
        showSuccessSnackBar(context, 'Item deleted');
      }
    } catch (e) {
      Log.error('PantryItemCard', 'Delete failed', e);
      if (context.mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }
}
