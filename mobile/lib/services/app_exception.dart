import 'package:dio/dio.dart';

/// Application-specific exception with a user-friendly message and
/// an optional raw error for terminal logging.
class AppException implements Exception {
  /// Short, user-friendly message safe to display in a SnackBar / dialog.
  final String userMessage;

  /// Technical detail for logs (not shown to users).
  final String? detail;

  /// Original error object (if any).
  final Object? cause;

  const AppException(this.userMessage, {this.detail, this.cause});

  @override
  String toString() => detail ?? userMessage;

  /// Build an [AppException] from a [DioException], mapping HTTP status
  /// codes and connection errors to readable messages.
  factory AppException.fromDio(DioException e, {String? context}) {
    final statusCode = e.response?.statusCode;
    final serverMessage = _extractServerMessage(e);

    final String userMsg;
    final String detailMsg;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      userMsg = 'Connection timed out. Check your internet connection.';
      detailMsg = '${context ?? 'Request'} timeout: ${e.type}';
    } else if (e.type == DioExceptionType.connectionError) {
      userMsg = 'Cannot reach the server. Check your connection.';
      detailMsg = '${context ?? 'Request'} connection error: ${e.message}';
    } else if (statusCode == null) {
      userMsg = 'Network error. Please try again.';
      detailMsg =
          '${context ?? 'Request'} failed: ${e.type} ${e.message ?? ''}';
    } else {
      userMsg = switch (statusCode) {
        400 => serverMessage ?? 'Invalid request. Please check your input.',
        401 => 'Session expired. Please sign in again.',
        403 => 'You don\'t have permission to do this.',
        404 => serverMessage ?? 'The requested item was not found.',
        409 => serverMessage ?? 'This conflicts with existing data.',
        422 => serverMessage ?? 'Invalid data. Please check your input.',
        429 => 'Too many requests. Please wait a moment.',
        >= 500 => 'Server error. Please try again later.',
        _ => serverMessage ?? 'Something went wrong (error $statusCode).',
      };
      detailMsg =
          '${context ?? 'Request'} HTTP $statusCode: ${serverMessage ?? e.message ?? ''}';
    }

    return AppException(userMsg, detail: detailMsg, cause: e);
  }

  /// Build an [AppException] from any error.
  factory AppException.from(Object error, {String? context}) {
    if (error is AppException) return error;
    if (error is DioException) {
      return AppException.fromDio(error, context: context);
    }
    return AppException(
      'Something went wrong. Please try again.',
      detail: '${context ?? 'Operation'} failed: $error',
      cause: error,
    );
  }

  static String? _extractServerMessage(DioException e) {
    try {
      final data = e.response?.data;
      if (data is Map) {
        return data['message'] as String? ??
            data['error'] as String? ??
            data['detail'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
