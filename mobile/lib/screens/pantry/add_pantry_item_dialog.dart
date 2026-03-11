import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../config/app_theme.dart';
import '../../models/storage_location.dart';
import '../../providers/providers.dart';
import '../../services/logger.dart';
import '../../widgets/error_snackbar.dart';

class AddPantryItemDialog extends ConsumerStatefulWidget {
  final String pantryId;
  final List<StorageLocation> storageLocations;

  const AddPantryItemDialog({
    super.key,
    required this.pantryId,
    required this.storageLocations,
  });

  @override
  ConsumerState<AddPantryItemDialog> createState() =>
      _AddPantryItemDialogState();
}

class _AddPantryItemDialogState extends ConsumerState<AddPantryItemDialog> {
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedLocationId;
  DateTime? _expirationDate;
  DateTime? _purchaseDate;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _unitController.dispose();
    _categoryController.dispose();
    _notesController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Pantry Item'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'e.g. Milk',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            // Quantity + Unit row
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Quantity'),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _unitController,
                    decoration: const InputDecoration(
                      labelText: 'Unit',
                      hintText: 'kg, L, pcs',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Storage location dropdown
            DropdownButtonFormField<String>(
              initialValue: _selectedLocationId,
              decoration: const InputDecoration(labelText: 'Storage Location'),
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
            const SizedBox(height: 12),

            // Expiration date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event, size: 20),
              title: Text(
                _expirationDate != null
                    ? 'Expires: ${DateFormat('dd/MM/yyyy').format(_expirationDate!)}'
                    : 'Set expiration date',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: _expirationDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () =>
                          setState(() => _expirationDate = null),
                    )
                  : null,
              onTap: () => _pickDate(isExpiration: true),
            ),

            // Purchase date
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.shopping_cart_outlined, size: 20),
              title: Text(
                _purchaseDate != null
                    ? 'Purchased: ${DateFormat('dd/MM/yyyy').format(_purchaseDate!)}'
                    : 'Set purchase date',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              trailing: _purchaseDate != null
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () =>
                          setState(() => _purchaseDate = null),
                    )
                  : null,
              onTap: () => _pickDate(isExpiration: false),
            ),

            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category',
                hintText: 'e.g. Dairy',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _priceController,
              decoration: const InputDecoration(labelText: 'Price'),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              textCapitalization: TextCapitalization.sentences,
              maxLines: 2,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _addItem,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : const Text('Add'),
        ),
      ],
    );
  }

  Future<void> _pickDate({required bool isExpiration}) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: isExpiration
          ? (_expirationDate ?? now.add(const Duration(days: 7)))
          : (_purchaseDate ?? now),
      firstDate: isExpiration ? now : DateTime(2020),
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

  Future<void> _addItem() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);

    final qty = double.tryParse(_quantityController.text) ?? 1;
    final price = double.tryParse(_priceController.text);

    Log.info('AddPantryItemDialog', 'Adding item "$name" to pantry');

    try {
      final service = ref.read(pantryServiceProvider);
      await service.addItem(
        pantryId: widget.pantryId,
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
        expirationDate: _expirationDate?.toIso8601String(),
        purchaseDate: _purchaseDate?.toIso8601String(),
        price: price,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
      );

      if (mounted) {
        Navigator.pop(context);
        showSuccessSnackBar(context, 'Added "$name"');
      }
    } catch (e) {
      Log.error('AddPantryItemDialog', 'Add item failed', e);
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorSnackBar(context, e);
      }
    }
  }
}
