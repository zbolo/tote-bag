import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  static String get baseUrl =>
      dotenv.env['API_BASE_URL'] ?? 'http://10.0.2.2:3000';

  static const String apiVersion = 'v1';
  static const String apiPrefix = '/api/$apiVersion';

  // Endpoints
  static const String authEndpoint = '/api/auth';
  static const String listsEndpoint = '$apiPrefix/lists';
  static const String productsEndpoint = '$apiPrefix/products';
  static const String usersEndpoint = '$apiPrefix/users';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 10);
  static const Duration receiveTimeout = Duration(seconds: 10);
}
