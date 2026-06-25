import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/storage/login_init_storage.dart';
import '../../core/storage/token_storage.dart';
import '../../models/login_init/login_init_model.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/login_init_repository.dart';

part 'global_auth_provider.g.dart';

/// 全局认证状态
/// 管理用户登录状态和 LoginInit 数据
@riverpod
class GlobalAuth extends _$GlobalAuth {
  @override
  Future<LoginInitModel?> build() async {
    // 只读取本地缓存，不发起请求
    final token = await ref.read(tokenStorageProvider).getToken();
    if (token == null || token.accountId == null) {
      return null;
    }

    return ref
        .read(loginInitRepositoryProvider)
        .getCachedLoginInit(token.accountId!);
  }

  /// 用户登录
  Future<void> login({
    required String username,
    required String password,
    required String deviceUuid,
    required String deviceInfo,
  }) async {
    await ref.read(authRepositoryProvider).login(
          username: username,
          password: password,
          deviceUuid: deviceUuid,
          deviceInfo: deviceInfo,
        );
  }

  /// 登录成功后初始化数据（不使用缓存）
  Future<LoginInitModel> initAfterLogin() async {
    final data = await checkAndInitialize(useCache: false);
    if (data == null) {
      throw Exception('LoginInit failed');
    }
    return data;
  }

  /// 检查并初始化
  Future<LoginInitModel?> checkAndInitialize({required bool useCache}) async {
    // 1. 检查 Token
    final token = await ref.read(tokenStorageProvider).getToken();
    if (token == null) {
      return null;
    }

    // 2. 如果允许使用缓存 && Token 有 accountId
    if (useCache && token.accountId != null) {
      final cachedData = await ref
          .read(loginInitRepositoryProvider)
          .getCachedLoginInit(token.accountId!);

      if (cachedData != null) {
        // 有缓存：立即返回，后台更新
        _backgroundRefresh(token.accountId!);
        return cachedData;
      }
    }

    // 3. 无缓存或不使用缓存：必须请求
    try {
      final data = await ref.read(loginInitRepositoryProvider).getLoginInit();

      // 更新 Token（关联 AccountId）
      if (token.accountId == null) {
        final updatedToken = token.copyWith(accountId: data.accountInfo.accountId);
        await ref.read(tokenStorageProvider).saveToken(updatedToken);
      }

      // 更新状态
      state = AsyncValue.data(data);
      return data;
    } catch (e) {
      // 请求失败：清除 Token
      await logout();
      return null;
    }
  }

  /// 后台刷新（不阻塞 UI）
  void _backgroundRefresh(int accountId) async {
    try {
      final data = await ref.read(loginInitRepositoryProvider).getLoginInit();
      // 更新状态
      state = AsyncValue.data(data);
    } catch (e) {
      // 静默失败，继续使用缓存
    }
  }

  /// 退出登录
  Future<void> logout() async {
    // 清除所有缓存
    await ref.read(loginInitStorageProvider).clearAll();

    // 清除 Token
    await ref.read(authRepositoryProvider).logout();

    // 更新状态
    state = const AsyncValue.data(null);
  }
}
