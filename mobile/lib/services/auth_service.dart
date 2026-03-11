import 'package:dio/dio.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import 'api_client.dart';
import 'app_exception.dart';
import 'logger.dart';

const _tag = 'AuthService';

class AuthService {
  final ApiClient _apiClient;

  AuthService(this._apiClient);

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String displayName,
  }) async {
    Log.info(_tag, 'Signing up user: $email');
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

        final accessToken = response.headers.value('st-access-token');
        final refreshToken = response.headers.value('st-refresh-token');

        if (accessToken != null) {
          await _apiClient.setAccessToken(accessToken);
        }
        if (refreshToken != null) {
          await _apiClient.setRefreshToken(refreshToken);
        }

        Log.info(_tag, 'Sign up successful for $email');
        return {
          'success': true,
          'user': user,
        };
      }

      final message = response.data['message'] ?? 'Sign up failed';
      Log.warn(_tag, 'Sign up rejected: $message');
      return {
        'success': false,
        'message': message,
      };
    } on DioException catch (e) {
      final appErr = AppException.fromDio(e, context: 'Sign up');
      Log.error(_tag, appErr.toString(), e);
      return {
        'success': false,
        'message': appErr.userMessage,
      };
    }
  }

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    Log.info(_tag, 'Signing in user: $email');
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
        final accessToken = response.headers.value('st-access-token');
        final refreshToken = response.headers.value('st-refresh-token');

        if (accessToken != null) {
          await _apiClient.setAccessToken(accessToken);
        }
        if (refreshToken != null) {
          await _apiClient.setRefreshToken(refreshToken);
        }

        Log.info(_tag, 'Sign in successful for $email');
        return {
          'success': true,
          'user': response.data['user'],
        };
      }

      final message = response.data['message'] ?? 'Sign in failed';
      Log.warn(_tag, 'Sign in rejected: $message');
      return {
        'success': false,
        'message': message,
      };
    } on DioException catch (e) {
      final appErr = AppException.fromDio(e, context: 'Sign in');
      Log.error(_tag, appErr.toString(), e);
      return {
        'success': false,
        'message': appErr.userMessage,
      };
    }
  }

  Future<void> signOut() async {
    Log.info(_tag, 'Signing out');
    try {
      await _apiClient.dio.post('${ApiConfig.authEndpoint}/signout');
      Log.info(_tag, 'Sign out API call successful');
    } catch (e) {
      Log.warn(_tag, 'Sign out API call failed (continuing)', e);
    } finally {
      await _apiClient.clearTokens();
    }
  }

  Future<User?> getCurrentUser() async {
    Log.debug(_tag, 'Fetching current user');
    try {
      final response = await _apiClient.dio.get('${ApiConfig.usersEndpoint}/me');

      if (response.statusCode == 200 && response.data['status'] == 'success') {
        final user = User.fromJson(response.data['data']['user'] as Map<String, dynamic>);
        Log.info(_tag, 'Current user loaded: ${user.displayName}');
        return user;
      }
      Log.warn(_tag, 'Unexpected response fetching current user: ${response.statusCode}');
    } catch (e) {
      Log.error(_tag, 'Failed to fetch current user', e);
      return null;
    }
    return null;
  }

  Future<bool> isAuthenticated() async {
    return await _apiClient.isAuthenticated();
  }
}
