import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../config/app_theme.dart';
import '../../models/pantry_item.dart';
import '../../models/storage_location.dart';
import '../../providers/providers.dart';
import '../../services/logger.dart';
import '../../widgets/error_snackbar.dart';

class EditPantryItemScreen extends ConsumerStatefulWidget {
  final String pantryId;
  final PantryItem item;
  final List<StorageLocation> storageLocations;

  const EditPantryItemScreen({
    super.key,
    required this.pantryId,
    required this.item,
    required this.storageLocations,
  });

  @override
  ConsumerState<EditPantryItemScreen> createState() =>
      _EditPantryItemScreenState();
}

class _EditPantryItemScreenState extends ConsumerState<EditPantryItemScreen> {
  static const _tag = 'EditPantryItemScreen';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _quantityController;
  late final TextEditingController _unitController;
  late final TextEditingController _contentQuantityController;
  late final TextEditingController _contentUnitController;
  late final TextEditingController _categoryController;
  late final TextEditingController _notesController;
  late final TextEditingController _priceController;

  late String? _selectedLocationId;
  late DateTime? _expirationDate;
  late DateTime? _purchaseDate;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final item = widget.item;
    _nameController = TextEditingController(text: item.name);
    _quantityController = TextEditingController(
        text: item.quantity % 1 == 0
            ? item.quantity.toInt().toString()
            : item.quantity.toString());
    _unitController = TextEditingController(text: item.unit ?? '');
    _contentQuantityController = TextEditingController(
        text: item.contentMaxQuantity != null
            ? (item.contentMaxQuantity! % 1 == 0
                ? item.contentMaxQuantity!.toInt().toString()
                : item.contentMaxQuantity.toString())
            : '');
    _contentUnitController =
        TextEditingController(text: item.contentUnit ?? '');
    _categoryController = TextEditingController(text: item.category ?? '');
    _notesController = TextEditingController(text: item.notes ?? '');
    _priceController = TextEditingController(
        text: item.price != null ? item.price.toString() : '');
    _selectedLocationId = item.storageLocation?.id;
    _expirationDate = item.expirationDate;
    _purchaseDate = item.purchaseDate;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _contentQuantityController.dispose();
    _contentUnitController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Item'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Product name ──
            _buildSectionLabel('Product Info'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Name is required'
                  : null,
            ),
            const SizedBox(height: 12),

            // ── Quantity + Unit row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(
                      labelText: 'Quantity',
                      prefixIcon: Icon(Icons.numbers),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'kg, L, pcs',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Content per unit row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _contentQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Content per unit',
                      hintText: '500',
                      prefixIcon: Icon(Icons.scale_outlined),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _contentUnitController,
                    decoration: const InputDecoration(
                      labelText: 'Content unit',
                      hintText: 'g, ml',
                      prefixIcon: Icon(Icons.straighten),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Dairy',
                prefixIcon: Icon(Icons.category_outlined),
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 24),

            // ── Storage ──
            _buildSectionLabel('Storage'),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: _selectedLocationId,
              decoration: const InputDecoration(
                labelText: 'Storage Location',
                prefixIcon: Icon(Icons.place_outlined),
              ),
              items: [
                const DropdownMenuItem(
                    value: null, child: Text('No location')),
                ...widget.storageLocations.map((loc) => DropdownMenuItem(
                      value: loc.id,
                      child: Row(
                        children: [
                          Icon(loc.iconData, size: 18),
                          const SizedBox(width: 8),
                          Text(loc.name),
                        ],
                      ),
                    )),
              ],
              onChanged: (value) =>
                  setState(() => _selectedLocationId = value),
            ),
            const SizedBox(height: 24),

            // ── Dates ──
            _buildSectionLabel('Dates'),
            const SizedBox(height: 8),
            _buildDateTile(
              icon: Icons.event,
              label: 'Expiration date',
              date: _expirationDate,
              onTap: () => _pickDate(isExpiration: true),
              onClear: () => setState(() => _expirationDate = null),
            ),
            const SizedBox(height: 8),
            _buildDateTile(
              icon: Icons.shopping_cart_outlined,
              label: 'Purchase date',
              date: _purchaseDate,
              onTap: () => _pickDate(isExpiration: false),
              onClear: () => setState(() => _purchaseDate = null),
            ),
            const SizedBox(height: 24),

            // ── Extra details ──
            _buildSectionLabel('Extra Details'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _priceController,
              decoration: const InputDecoration(
                labelText: 'Price',
                prefixIcon: Icon(Icons.euro),
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                prefixIcon: Icon(Icons.notes),
                alignLabelWithHint: true,
              ),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 3,
              minLines: 1,
            ),
            const SizedBox(height: 32),

            // ── Submit button ──
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _saveItem,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                ),
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.save),
                label: Text(_isLoading ? 'Saving...' : 'Save Changes'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textSecondaryColor,
          ),
    );
  }

  Widget _buildDateTile({
    required IconData icon,
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required VoidCallback onClear,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTheme.borderColor),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: AppTheme.textSecondaryColor),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                date != null
                    ? DateFormat('dd/MM/yyyy').format(date)
                    : label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: date != null
                          ? AppTheme.textPrimaryColor
                          : AppTheme.textTertiaryColor,
                    ),
              ),
            ),
            if (date != null)
              GestureDetector(
                onTap: onClear,
                child: const Icon(Icons.clear,
                    size: 18, color: AppTheme.textTertiaryColor),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate({required bool isExpiration}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiration
          ? (_expirationDate ?? now.add(const Duration(days: 7)))
          : (_purchaseDate ?? now),
      firstDate: isExpiration ? DateTime(2020) : DateTime(2020),
      lastDate: isExpiration
          ? now.add(const Duration(days: 365 * 3))
          : now,
    );
    if (picked != null) {
      setState(() {
        if (isExpiration) {
          _expirationDate = picked;
        } else {
          _purchaseDate = picked;
        }
      });
    }
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    setState(() => _isLoading = true);

    final qty = double.tryParse(_quantityController.text) ?? 1;
    final price = double.tryParse(_priceController.text);
    final contentPerUnit =
        double.tryParse(_contentQuantityController.text);

    // Recalculate contentQuantity proportionally if contentPerUnit changed
    final item = widget.item;
    double? newContentQuantity;
    if (contentPerUnit != null && contentPerUnit > 0) {
      final newTotalMax = qty * contentPerUnit;
      if (item.hasContentTracking && item.totalContentMax > 0) {
        // Scale proportionally
        final ratio = (item.contentQuantity ?? 0) / item.totalContentMax;
        newContentQuantity = (ratio * newTotalMax).clamp(0, newTotalMax);
      } else {
        // First time enabling content tracking — start full
        newContentQuantity = newTotalMax;
      }
    }

    Log.info(_tag, 'Saving item "${item.id}" → "$name"');

    try {
      final service = ref.read(pantryServiceProvider);
      await service.updateItem(
        pantryId: widget.pantryId,
        itemId: item.id,
        name: name,
        quantity: qty,
        maxQuantity: qty,
        unit: _unitController.text.trim().isEmpty
            ? null
            : _unitController.text.trim(),
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
        storageLocationId: _selectedLocationId,
        expirationDate: _expirationDate?.toUtc().toIso8601String(),
        purchaseDate: _purchaseDate?.toUtc().toIso8601String(),
        price: price,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        contentQuantity: newContentQuantity,
        contentMaxQuantity: contentPerUnit,
        contentUnit: _contentUnitController.text.trim().isEmpty
            ? null
            : _contentUnitController.text.trim(),
      );

      Log.info(_tag, 'Item "$name" saved successfully');
      if (mounted) {
        showSuccessSnackBar(context, 'Saved "$name"');
        Navigator.pop(context, true);
      }
    } catch (e) {
      Log.error(_tag, 'Save item failed', e);
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorSnackBar(context, e);
      }
    }
  }
}
