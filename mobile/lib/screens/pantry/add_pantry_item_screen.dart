import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../config/app_theme.dart';
import '../../models/product.dart';
import '../../models/storage_location.dart';
import '../../providers/providers.dart';
import '../../services/logger.dart';
import '../../widgets/error_snackbar.dart';

class AddPantryItemScreen extends ConsumerStatefulWidget {
  final String pantryId;
  final List<StorageLocation> storageLocations;

  const AddPantryItemScreen({
    super.key,
    required this.pantryId,
    required this.storageLocations,
  });

  @override
  ConsumerState<AddPantryItemScreen> createState() =>
      _AddPantryItemScreenState();
}

class _AddPantryItemScreenState extends ConsumerState<AddPantryItemScreen> {
  static const _tag = 'AddPantryItemScreen';

  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController(text: '1');
  final _unitController = TextEditingController();
  final _contentQuantityController = TextEditingController();
  final _contentUnitController = TextEditingController();
  final _categoryController = TextEditingController();
  final _notesController = TextEditingController();
  final _priceController = TextEditingController();

  String? _selectedLocationId;
  DateTime? _expirationDate;
  DateTime? _purchaseDate;
  bool _isLoading = false;

  // Scanned product info
  Product? _scannedProduct;
  String? _scannedBarcode;

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
        title: const Text('Add Pantry Item'),
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
            // ── Barcode scan section ──
            _buildScanSection(),
            const SizedBox(height: 20),

            // ── Product name ──
            _buildSectionLabel('Product Info'),
            const SizedBox(height: 8),
            TextFormField(
              controller: _nameController,
              autofocus: _scannedProduct == null,
              decoration: const InputDecoration(
                labelText: 'Item Name *',
                hintText: 'e.g. Milk',
                prefixIcon: Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (value) =>
                  (value == null || value.trim().isEmpty) ? 'Name is required' : null,
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

            // ── Content quantity + unit row (e.g. 500 g per piece) ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _contentQuantityController,
                    decoration: const InputDecoration(
                      labelText: 'Content',
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
                onPressed: _isLoading ? null : _addItem,
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
                    : const Icon(Icons.add),
                label: Text(_isLoading ? 'Adding...' : 'Add to Pantry'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // ── Scan section ──────────────────────────────────────────

  Widget _buildScanSection() {
    if (_scannedProduct != null) {
      return _buildScannedProductCard();
    }

    return InkWell(
      onTap: _openScanner,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.qr_code_scanner,
                color: AppTheme.primaryColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scan Barcode',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Scan a product barcode to auto-fill details',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondaryColor,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppTheme.primaryColor),
          ],
        ),
      ),
    );
  }

  Widget _buildScannedProductCard() {
    final product = _scannedProduct!;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.successColor.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.successColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // Product image or icon
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: SizedBox(
              width: 56,
              height: 56,
              child: product.imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: product.imageUrl!,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => Container(
                        color: AppTheme.dividerColor,
                        child: const Center(
                          child:
                              CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                      errorWidget: (_, __, ___) => Container(
                        color: AppTheme.dividerColor,
                        child: const Icon(Icons.image_not_supported,
                            size: 24, color: AppTheme.textSecondaryColor),
                      ),
                    )
                  : Container(
                      color: AppTheme.dividerColor,
                      child: const Icon(Icons.shopping_basket,
                          size: 24, color: AppTheme.textSecondaryColor),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.check_circle,
                        size: 16, color: AppTheme.successColor),
                    const SizedBox(width: 4),
                    Text(
                      'Product Found',
                      style:
                          Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.successColor,
                                fontWeight: FontWeight.w600,
                              ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  product.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_scannedBarcode != null)
                  Text(
                    'Barcode: $_scannedBarcode',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textTertiaryColor,
                        ),
                  ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: _clearScannedProduct,
            tooltip: 'Remove scanned product',
          ),
        ],
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

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

  // ── Actions ───────────────────────────────────────────────

  Future<void> _openScanner() async {
    Log.info(_tag, 'Opening barcode scanner for pantry');

    final result = await Navigator.of(context).push<_ScanResult>(
      MaterialPageRoute(
        builder: (context) => _PantryScannerPage(
          productServiceProvider: productServiceProvider,
        ),
      ),
    );

    if (result == null || !mounted) return;

    Log.info(_tag,
        'Scan result: product=${result.product?.name}, barcode=${result.barcode}');

    setState(() {
      _scannedProduct = result.product;
      _scannedBarcode = result.barcode;

      // Pre-fill fields from product
      if (result.product != null) {
        _nameController.text = result.product!.name;
        if (result.product!.category != null &&
            _categoryController.text.isEmpty) {
          _categoryController.text = result.product!.category!;
        }
      } else if (result.manualName != null) {
        _nameController.text = result.manualName!;
      }
    });
  }

  void _clearScannedProduct() {
    Log.debug(_tag, 'Clearing scanned product');
    setState(() {
      _scannedProduct = null;
      _scannedBarcode = null;
    });
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
    if (!_formKey.currentState!.validate()) return;

    final name = _nameController.text.trim();
    setState(() => _isLoading = true);

    final qty = double.tryParse(_quantityController.text) ?? 1;
    final price = double.tryParse(_priceController.text);
    final contentQty =
        double.tryParse(_contentQuantityController.text);

    Log.info(_tag, 'Adding item "$name" to pantry ${widget.pantryId}');

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
        expirationDate: _expirationDate?.toUtc().toIso8601String(),
        purchaseDate: _purchaseDate?.toUtc().toIso8601String(),
        price: price,
        barcode: _scannedBarcode,
        productId: _scannedProduct?.id,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        contentQuantity: contentQty,
        contentMaxQuantity: contentQty,
        contentUnit: _contentUnitController.text.trim().isEmpty
            ? null
            : _contentUnitController.text.trim(),
      );

      Log.info(_tag, 'Item "$name" added successfully');
      if (mounted) {
        showSuccessSnackBar(context, 'Added "$name"');
        Navigator.pop(context, true); // Return true to signal refresh needed
      }
    } catch (e) {
      Log.error(_tag, 'Add item failed', e);
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorSnackBar(context, e);
      }
    }
  }
}

// ── Inline scanner page ─────────────────────────────────────

class _ScanResult {
  final Product? product;
  final String barcode;
  final String? manualName;

  _ScanResult({this.product, required this.barcode, this.manualName});
}

class _PantryScannerPage extends ConsumerStatefulWidget {
  final Provider productServiceProvider;

  const _PantryScannerPage({required this.productServiceProvider});

  @override
  ConsumerState<_PantryScannerPage> createState() =>
      _PantryScannerPageState();
}

class _PantryScannerPageState extends ConsumerState<_PantryScannerPage> {
  static const _tag = 'PantryScanner';
  MobileScannerController? _controller;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    Log.info(_tag, 'Scanner opened for pantry item');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty || barcodes.first.rawValue == null) return;

    final barcode = barcodes.first.rawValue!;
    setState(() => _isProcessing = true);
    Log.info(_tag, 'Barcode detected: $barcode');

    try {
      final productService = ref.read(productServiceProvider);
      final product = await productService.getProductByBarcode(barcode);

      if (!mounted) return;

      if (product != null) {
        Log.info(_tag, 'Product found: "${product.name}"');
        // Return the product directly — user fills in pantry-specific fields on the form
        Navigator.pop(
            context, _ScanResult(product: product, barcode: barcode));
      } else {
        Log.info(_tag, 'Product not found, prompting for name');
        await _showNotFoundDialog(barcode);
      }
    } catch (e) {
      Log.error(_tag, 'Error processing barcode $barcode', e);
      if (mounted) {
        showErrorSnackBar(context, e);
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _showNotFoundDialog(String barcode) async {
    final nameController = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Barcode: $barcode',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Product Name',
                hintText: 'Enter the product name',
              ),
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, null),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, nameController.text),
            child: const Text('Use Name'),
          ),
        ],
      ),
    );

    if (!mounted) return;

    if (name != null && name.trim().isNotEmpty) {
      Navigator.pop(context,
          _ScanResult(barcode: barcode, manualName: name.trim()));
    } else {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onBarcodeDetected,
          ),
          if (_isProcessing)
            const Center(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Looking up product...'),
                    ],
                  ),
                ),
              ),
            ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.8),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.qr_code_scanner, size: 48, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Position barcode within the frame',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
