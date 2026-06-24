import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/storage/token_storage.dart';
import '../../models/auth/token_model.dart';
import '../../repositories/auth_repository.dart';

part 'global_auth_provider.g.dart';

/// 全局认证状态
/// 用于管理用户登录状态和令牌
@riverpod
class GlobalAuth extends _$GlobalAuth {
  @override
  Future<TokenModel?> build() async {
    // 从本地加载令牌
    return ref.read(tokenStorageProvider).getToken();
  }

  /// 用户登录
  Future<void> login({
    required String username,
    required String password,
    required String deviceUuid,
    required String deviceInfo,
  }) async {
    final token = await ref
        .read(authRepositoryProvider)
        .login(
          username: username,
          password: password,
          deviceUuid: deviceUuid,
          deviceInfo: deviceInfo,
        );

    // 更新状态
    state = AsyncValue.data(token);
  }

  /// 刷新令牌
  Future<void> refresh() async {
    final token = await ref.read(authRepositoryProvider).refreshToken();
    state = AsyncValue.data(token);
  }

  /// 登出
  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    state = const AsyncValue.data(null);
  }

  /// 检查并刷新令牌（启动页调用）
  Future<bool> checkAndRefresh() async {
    final success = await ref
        .read(authRepositoryProvider)
        .checkAndRefreshToken();
    if (success) {
      // 刷新成功，重新加载令牌
      ref.invalidateSelf();
    }
    return success;
  }
}
