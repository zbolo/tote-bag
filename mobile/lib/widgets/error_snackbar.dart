import 'package:flutter/material.dart';
import '../config/app_theme.dart';
import '../services/app_exception.dart';

/// Show a user-friendly error SnackBar.
///
/// Extracts [AppException.userMessage] when available, otherwise
/// falls back to a generic message. Never shows raw stack traces.
void showErrorSnackBar(BuildContext context, Object error) {
  final message = _friendlyMessage(error);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.errorColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

/// Show a success SnackBar.
void showSuccessSnackBar(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2)}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.successColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

/// Show an info SnackBar.
void showInfoSnackBar(BuildContext context, String message,
    {Duration duration = const Duration(seconds: 2)}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppTheme.textSecondaryColor,
      duration: duration,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

/// Extract a user-friendly message from any error.
String friendlyErrorMessage(Object error) => _friendlyMessage(error);

String _friendlyMessage(Object error) {
  if (error is AppException) return error.userMessage;
  final s = error.toString();
  // Strip "Exception: " prefix that Dart adds
  if (s.startsWith('Exception: ')) return s.substring(11);
  return 'Something went wrong. Please try again.';
}
