import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/app_theme.dart';
import '../providers/providers.dart';
import '../services/logger.dart';
import 'error_snackbar.dart';

class CreatePantryDialog extends ConsumerStatefulWidget {
  const CreatePantryDialog({super.key});

  @override
  ConsumerState<CreatePantryDialog> createState() => _CreatePantryDialogState();
}

class _CreatePantryDialogState extends ConsumerState<CreatePantryDialog> {
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New Pantry'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Pantry Name',
              hintText: 'e.g. Kitchen Pantry',
            ),
            textCapitalization: TextCapitalization.sentences,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description (optional)',
              hintText: 'e.g. Main household pantry',
            ),
            textCapitalization: TextCapitalization.sentences,
            maxLines: 2,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading ? null : _createPantry,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : const Text('Create'),
        ),
      ],
    );
  }

  Future<void> _createPantry() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    Log.info('CreatePantryDialog', 'Creating pantry "$name"');

    try {
      await ref.read(pantriesProvider.notifier).createPantry(
            name: name,
            description: _descriptionController.text.trim().isEmpty
                ? null
                : _descriptionController.text.trim(),
          );

      if (mounted) {
        Navigator.pop(context);
        showSuccessSnackBar(context, 'Pantry "$name" created');
      }
    } catch (e) {
      Log.error('CreatePantryDialog', 'Create pantry failed', e);
      if (mounted) {
        setState(() => _isLoading = false);
        showErrorSnackBar(context, e);
      }
    }
  }
}
