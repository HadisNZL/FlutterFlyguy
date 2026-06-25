import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../api/auth_api.dart';
import '../api/business_api.dart';
import '../core/storage/token_storage.dart';
import '../models/auth/token_model.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(
    ref.watch(authApiProvider),
    ref.watch(businessApiProvider),
    ref.watch(tokenStorageProvider),
  );
});

class AuthRepository {
  AuthRepository(this._authApi, this._businessApi, this._storage);
  final AuthApi _authApi;
  final BusinessApi _businessApi;
  final TokenStorage _storage;

  /// 用户登录
  /// 登录成功后自动保存令牌到本地
  Future<TokenModel> login({
    required String username,
    required String password,
    required String deviceUuid,
    required String deviceInfo,
  }) async {
    final json = await _authApi.login(
      username: username,
      password: password,
      deviceUuid: deviceUuid,
      deviceInfo: deviceInfo,
    );

    // 构造 TokenModel（添加登录时间戳）
    final token = TokenModel(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String,
      loginTime: DateTime.now().millisecondsSinceEpoch,
    );

    // 保存到本地
    await _storage.saveToken(token);

    return token;
  }

  /// 刷新令牌
  /// 刷新成功后自动更新本地令牌
  Future<TokenModel> refreshToken() async {
    final currentToken = await _storage.getToken();
    if (currentToken == null) {
      throw Exception('本地无令牌，无法刷新');
    }

    final json = await _authApi.refreshToken(currentToken.refreshToken);

    // 构造新的 TokenModel
    final newToken = TokenModel(
      accessToken: json['access_token'] as String,
      expiresIn: json['expires_in'] as int,
      tokenType: json['token_type'] as String,
      refreshToken: json['refresh_token'] as String,
      loginTime: DateTime.now().millisecondsSinceEpoch,
    );

    // 更新本地令牌
    await _storage.saveToken(newToken);

    return newToken;
  }

  /// 退出登录
  /// 调用业务接口退出 + 清除本地 Token
  Future<void> logout() async {
    // 调用业务接口退出登录
    await _businessApi.logout();

    // 清除本地 Token
    await _storage.clearToken();
  }

  /// 检查并刷新令牌（启动页调用）
  /// 返回 true 表示令牌有效或刷新成功，false 表示需要重新登录
  Future<bool> checkAndRefreshToken() async {
    final token = await _storage.getToken();

    if (token == null) {
      // 无令牌，需要登录
      return false;
    }

    if (token.isExpired) {
      // 已过期，清空本地令牌
      await _storage.clearToken();
      return false;
    }

    if (token.needsRefresh) {
      // 距离过期不足24小时，自动刷新
      try {
        await refreshToken();
        return true;
      } catch (e) {
        // 刷新失败，清空本地令牌
        await _storage.clearToken();
        return false;
      }
    }

    // 令牌有效，无需刷新
    return true;
  }
}
