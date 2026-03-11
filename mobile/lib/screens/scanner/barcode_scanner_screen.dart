import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../config/app_theme.dart';
import '../../models/product.dart';
import '../../providers/providers.dart';
import '../../services/logger.dart';
import '../../widgets/error_snackbar.dart';

class BarcodeScannerScreen extends ConsumerStatefulWidget {
  final String listId;

  const BarcodeScannerScreen({
    super.key,
    required this.listId,
  });

  @override
  ConsumerState<BarcodeScannerScreen> createState() =>
      _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends ConsumerState<BarcodeScannerScreen> {
  MobileScannerController? _controller;
  bool _isProcessing = false;
  static const _tag = 'BarcodeScanner';

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
    );
    Log.info(_tag, 'Scanner opened for list ${widget.listId}');
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    setState(() => _isProcessing = true);
    Log.info(_tag, 'Barcode detected: ${barcode.rawValue}');

    try {
      final productService = ref.read(productServiceProvider);
      final product =
          await productService.getProductByBarcode(barcode.rawValue!);

      if (!mounted) return;

      if (product != null) {
        Log.info(_tag, 'Product found: "${product.name}"');
        await _showProductDialog(product);
      } else {
        Log.info(_tag, 'Product not found, showing manual entry');
        await _showManualEntryDialog(barcode.rawValue!);
      }
    } catch (e) {
      Log.error(_tag, 'Error processing barcode ${barcode.rawValue}', e);
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _showProductDialog(Product product) async {
    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product image
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 140,
                  height: 140,
                  child: product.imageUrl != null
                      ? CachedNetworkImage(
                          imageUrl: product.imageUrl!,
                          fit: BoxFit.cover,
                          placeholder: (_, __) => Container(
                            color: AppTheme.dividerColor,
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (_, __, ___) => Container(
                            color: AppTheme.dividerColor,
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 48,
                              color: AppTheme.textSecondaryColor,
                            ),
                          ),
                        )
                      : Container(
                          color: AppTheme.dividerColor,
                          child: const Icon(
                            Icons.shopping_basket,
                            size: 48,
                            color: AppTheme.textSecondaryColor,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.displayName,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (product.category != null) ...[
              const SizedBox(height: 8),
              Text('Category: ${product.category}'),
            ],
            if (product.quantity != null) ...[
              const SizedBox(height: 4),
              Text('Quantity: ${product.quantity}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Add to List'),
          ),
        ],
      ),
    );

    if (shouldAdd == true) {
      await _addProductToList(product);
    }
  }

  Future<void> _showManualEntryDialog(String barcode) async {
    final nameController = TextEditingController();
    final imagePicker = ImagePicker();
    String? selectedImagePath;

    final result = await showDialog<_ManualEntryResult>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Product Not Found'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Barcode: $barcode',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondaryColor,
                      ),
                ),
                const SizedBox(height: 16),

                // Image picker area
                GestureDetector(
                  onTap: () async {
                    Log.debug(_tag, 'Opening image source picker');
                    final source = await showModalBottomSheet<ImageSource>(
                      context: context,
                      builder: (ctx) => SafeArea(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Take Photo'),
                              onTap: () =>
                                  Navigator.pop(ctx, ImageSource.camera),
                            ),
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Choose from Gallery'),
                              onTap: () =>
                                  Navigator.pop(ctx, ImageSource.gallery),
                            ),
                          ],
                        ),
                      ),
                    );

                    if (source == null) return;

                    Log.debug(_tag, 'Picking image from ${source.name}');
                    final picked = await imagePicker.pickImage(
                      source: source,
                      maxWidth: 800,
                      maxHeight: 800,
                      imageQuality: 85,
                    );

                    if (picked != null) {
                      Log.info(
                          _tag, 'Image selected: ${picked.path}');
                      setDialogState(() {
                        selectedImagePath = picked.path;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.textTertiaryColor.withValues(alpha: 0.3),
                        width: 1.5,
                        strokeAlign: BorderSide.strokeAlignInside,
                      ),
                    ),
                    child: selectedImagePath != null
                        ? Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(11),
                                child: Image.file(
                                  File(selectedImagePath!),
                                  width: double.infinity,
                                  height: 150,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: Material(
                                  color: Colors.black54,
                                  borderRadius: BorderRadius.circular(16),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(16),
                                    onTap: () {
                                      Log.debug(_tag, 'Image removed');
                                      setDialogState(() {
                                        selectedImagePath = null;
                                      });
                                    },
                                    child: const Padding(
                                      padding: EdgeInsets.all(4),
                                      child: Icon(
                                        Icons.close,
                                        color: Colors.white,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 40,
                                color: AppTheme.textSecondaryColor,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Add product photo',
                                style: TextStyle(
                                  color: AppTheme.textSecondaryColor,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 16),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Product Name',
                    hintText: 'Enter product name',
                  ),
                  autofocus: true,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(
                context,
                _ManualEntryResult(
                  name: nameController.text,
                  imagePath: selectedImagePath,
                ),
              ),
              child: const Text('Add to List'),
            ),
          ],
        ),
      ),
    );

    if (result != null && result.name.isNotEmpty) {
      await _addManualItemWithImage(result.name, barcode, result.imagePath);
    }
  }

  Future<void> _addProductToList(Product product) async {
    Log.info(_tag, 'Adding scanned product "${product.name}" to list');
    try {
      final service = ref.read(shoppingListServiceProvider);
      await service.addItem(
        listId: widget.listId,
        name: product.name,
        barcode: product.barcode,
        productId: product.id,
        category: product.category,
      );

      if (mounted) {
        ref.invalidate(shoppingListProvider(widget.listId));
        showSuccessSnackBar(context, '${product.name} added to list');
      }
    } catch (e) {
      Log.error(_tag, 'Failed to add product "${product.name}"', e);
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  Future<void> _addManualItemWithImage(
    String name,
    String barcode,
    String? imagePath,
  ) async {
    Log.info(
        _tag, 'Adding manual item "$name" (barcode: $barcode, hasImage: ${imagePath != null})');
    try {
      final productService = ref.read(productServiceProvider);

      // Create the product on backend (with optional image)
      final product = await productService.createProduct(
        name: name,
        barcode: barcode,
        imagePath: imagePath,
      );

      Log.info(_tag, 'Product created: ${product.id}, adding to list');

      // Add to shopping list
      final listService = ref.read(shoppingListServiceProvider);
      await listService.addItem(
        listId: widget.listId,
        name: product.name,
        barcode: product.barcode,
        productId: product.id,
      );

      if (mounted) {
        ref.invalidate(shoppingListProvider(widget.listId));
        showSuccessSnackBar(context, '$name added to list');
      }
    } catch (e) {
      Log.error(_tag, 'Failed to add manual item "$name"', e);
      if (mounted) {
        showErrorSnackBar(context, e);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Barcode'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
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
                      Text('Processing...'),
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
                  Icon(
                    Icons.qr_code_scanner,
                    size: 48,
                    color: Colors.white,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Position barcode within the frame',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
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

/// Holds the result from the manual entry dialog.
class _ManualEntryResult {
  final String name;
  final String? imagePath;

  _ManualEntryResult({required this.name, this.imagePath});
}
