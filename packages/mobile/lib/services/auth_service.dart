import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_client.dart';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.authEndpoint}/signup',
        data: {
          'formFields': [
            {'id': 'email', 'value': email},
            {'id': 'password', 'value': password},
            {'id': 'displayName', 'value': displayName},
          ],
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        final user = response.data['user'] as Map<String, dynamic>;

        // Store tokens from headers
        final accessToken = response.headers.value('st-access-token');
        final refreshToken = response.headers.value('st-refresh-token');

        if (accessToken != null) {
          await _apiClient.setAccessToken(accessToken);
        }
        if (refreshToken != null) {
          await _apiClient.setRefreshToken(refreshToken);
        }

        return {
          'success': true,
          'user': user,
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Sign up failed',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _apiClient.dio.post(
        '${ApiConfig.authEndpoint}/signin',
        data: {
          'formFields': [
            {'id': 'email', 'value': email},
            {'id': 'password', 'value': password},
          ],
        },
      );

      if (response.statusCode == 200 && response.data['status'] == 'OK') {
        // Store tokens from headers
        final accessToken = response.headers.value('st-access-token');
        final refreshToken = response.headers.value('st-refresh-token');

        if (accessToken != null) {
          await _apiClient.setAccessToken(accessToken);
        }
        if (refreshToken != null) {
          await _apiClient.setRefreshToken(refreshToken);
        }

        return {
          'success': true,
          'user': response.data['user'],
        };
      }

      return {
        'success': false,
        'message': response.data['message'] ?? 'Sign in failed',
      };
    } on DioException catch (e) {
      return {
        'success': false,
        'message': e.response?.data['message'] ?? 'Network error',
      };
    }
  }

  Future<void> signOut() async {
    try {
      await _apiClient.dio.post('${ApiConfig.authEndpoint}/signout');
    } catch (e) {
      // Ignore errors during sign out
    } finally {
      await _apiClient.clearTokens();
    }
  }

  Future<User?> getCurrentUser() async {
    try {
      final response = await _apiClient.dio.get('${ApiConfig.usersEndpoint}/me');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        return User.fromJson(response.data['data']['user'] as Map<String, dynamic>);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }
}
