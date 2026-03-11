import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:go_router/go_router.dart';
import '../../providers/providers.dart';
import '../../services/logger.dart';
import '../../widgets/error_snackbar.dart';
import '../../models/product.dart';

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
            if (product.imageUrl != null)
              Center(
                child: Image.network(
                  product.imageUrl!,
                  height: 100,
                  errorBuilder: (_, __, ___) =>
                      const Icon(Icons.image_not_supported),
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

    final shouldAdd = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Barcode: $barcode'),
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

    if (shouldAdd == true && nameController.text.isNotEmpty) {
      await _addManualItem(nameController.text, barcode);
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

  Future<void> _addManualItem(String name, String barcode) async {
    Log.info(_tag, 'Adding manual item "$name" (barcode: $barcode)');
    try {
      final service = ref.read(shoppingListServiceProvider);
      await service.addItem(
        listId: widget.listId,
        name: name,
        barcode: barcode,
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
