import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/api_endpoints.dart';
import '../core/dio/dio_client.dart';
import '../core/storage/token_storage.dart';

final authApiProvider = Provider<AuthApi>((ref) {
  final dio = DioClient.createAuth(
    tokenStorage: ref.watch(tokenStorageProvider),
  );
  return AuthApi(dio);
});

class AuthApi {
  AuthApi(this._dio);
  final Dio _dio;

  static const String _clientId = 'ahc_client';
  static const String _clientSecret = '3331e256-c21a-4624-90f6-3402725e027c';
  static const String _scopes = 'ahc_business_api';

  /// 用户登录
  /// 返回平铺的 JSON 对象（无包装层）
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
    required String deviceUuid,
    required String deviceInfo,
  }) async {
    final response = await _dio.post(
      ApiEndpoints.auth.token,
      data: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'user_login_in',
        'scopes': _scopes,
        'login_name': username,
        'password': password,
        'device_uuid': deviceUuid,
        'device_info': deviceInfo,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return response.data as Map<String, dynamic>;
  }

  /// 刷新令牌
  /// 返回平铺的 JSON 对象（无包装层）
  Future<Map<String, dynamic>> refreshToken(String refreshToken) async {
    final response = await _dio.post(
      ApiEndpoints.auth.token,
      data: {
        'client_id': _clientId,
        'client_secret': _clientSecret,
        'grant_type': 'refresh_token',
        'scopes': _scopes,
        'refresh_token': refreshToken,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );

    return response.data as Map<String, dynamic>;
  }

  /// 登出（预留接口，当前后端未提供）
  /// 注意：即使调用失败也不应阻塞登出流程
  Future<void> logout(String accessToken) async {
    // TODO: 等待后端提供登出接口
    // await _dio.post(ApiEndpoints.auth.logout, data: {'token': accessToken});
  }
}
