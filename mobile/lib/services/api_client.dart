import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import 'logger.dart';

const _tag = 'ApiClient';

class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        connectTimeout: ApiConfig.connectTimeout,
        receiveTimeout: ApiConfig.receiveTimeout,
        headers: {
          'Content-Type': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await getAccessToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          Log.debug(_tag,
              '→ ${options.method} ${options.path}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          Log.debug(_tag,
              '← ${response.statusCode} ${response.requestOptions.method} ${response.requestOptions.path}');
          return handler.next(response);
        },
        onError: (error, handler) async {
          Log.warn(_tag,
              '← ${error.response?.statusCode ?? 'ERR'} ${error.requestOptions.method} ${error.requestOptions.path}',
              error.message ?? '');

          if (error.response?.statusCode == 401) {
            Log.info(_tag, 'Token expired, attempting refresh');
            final refreshed = await _refreshToken();
            if (refreshed) {
              Log.info(_tag, 'Token refresh succeeded, retrying request');
              final opts = error.requestOptions;
              final token = await getAccessToken();
              opts.headers['Authorization'] = 'Bearer $token';
              try {
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                Log.error(_tag, 'Retry after refresh failed', e);
                return handler.next(error);
              }
            } else {
              Log.warn(_tag, 'Token refresh failed, returning 401');
            }
          }
          return handler.next(error);
        },
      ),
    );

    Log.info(_tag, 'Initialized with baseUrl=${ApiConfig.baseUrl}');
  }

  Dio get dio => _dio;

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<void> setAccessToken(String token) async {
    await _storage.write(key: _accessTokenKey, value: token);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<void> setRefreshToken(String token) async {
    await _storage.write(key: _refreshTokenKey, value: token);
  }

  Future<void> clearTokens() async {
    Log.info(_tag, 'Clearing stored tokens');
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
  }

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await getRefreshToken();
      if (refreshToken == null) {
        Log.warn(_tag, 'No refresh token available');
        return false;
      }

      final response = await _dio.post(
        '${ApiConfig.authEndpoint}/session/refresh',
        options: Options(
          headers: {'Authorization': 'Bearer $refreshToken'},
        ),
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.headers.value('st-access-token');
        final newRefreshToken = response.headers.value('st-refresh-token');

        if (newAccessToken != null) {
          await setAccessToken(newAccessToken);
        }
        if (newRefreshToken != null) {
          await setRefreshToken(newRefreshToken);
        }

        Log.info(_tag, 'Token refresh successful');
        return newAccessToken != null;
      }
    } catch (e) {
      Log.error(_tag, 'Token refresh error, clearing tokens', e);
      await clearTokens();
    }
    return false;
  }

  Future<bool> isAuthenticated() async {
    final token = await getAccessToken();
    return token != null;
  }
}
