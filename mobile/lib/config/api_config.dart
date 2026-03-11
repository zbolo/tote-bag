class ApiConfig {
  static const String baseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://localhost:3333',
  );

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
