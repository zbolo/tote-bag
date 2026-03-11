import 'package:flutter/material.dart';
import '../config/app_theme.dart';

/// A compact dialog with −/+ buttons and a text field to edit item quantity.
class EditQuantityDialog extends StatefulWidget {
  final String itemName;
  final int quantity;
  final String? unit;

  const EditQuantityDialog({
    super.key,
    required this.itemName,
    required this.quantity,
    this.unit,
  });

  @override
  State<EditQuantityDialog> createState() => _EditQuantityDialogState();
}

class _EditQuantityDialogState extends State<EditQuantityDialog> {
  late int _quantity;
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _quantity = widget.quantity;
    _controller = TextEditingController(text: _quantity.toString());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _update(int delta) {
    setState(() {
      _quantity = (_quantity + delta).clamp(1, 999);
      _controller.text = _quantity.toString();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.itemName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton.filled(
            onPressed: _quantity > 1 ? () => _update(-1) : null,
            icon: const Icon(Icons.remove),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(width: 16),
          SizedBox(
            width: 60,
            child: TextField(
              controller: _controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              ),
              onChanged: (value) {
                final parsed = int.tryParse(value);
                if (parsed != null && parsed >= 1) {
                  setState(() => _quantity = parsed.clamp(1, 999));
                }
              },
            ),
          ),
          const SizedBox(width: 8),
          if (widget.unit != null)
            Text(
              widget.unit!,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.textSecondaryColor,
                  ),
            ),
          if (widget.unit != null) const SizedBox(width: 8),
          IconButton.filled(
            onPressed: _quantity < 999 ? () => _update(1) : null,
            icon: const Icon(Icons.add),
            style: IconButton.styleFrom(
              backgroundColor: AppTheme.primaryColor.withValues(alpha: 0.1),
              foregroundColor: AppTheme.primaryColor,
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, _quantity),
          child: const Text('Save'),
        ),
      ],
    );
  }
}
