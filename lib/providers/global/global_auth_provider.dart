import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/exceptions/business_exceptions.dart';
import '../../core/storage/login_init_storage.dart';
import '../../core/storage/token_storage.dart';
import '../../models/login_init/login_init_model.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/login_init_repository.dart';
import 'global_error_provider.dart';

part 'global_auth_provider.g.dart';

/// 全局认证状态
/// 管理用户登录状态和 LoginInit 数据
@riverpod
class GlobalAuth extends _$GlobalAuth {
  @override
  LoginInitModel? build() {
    // 同步初始化，返回 null
    // 实际数据由 MainPage 同步设置（从缓存读取）
    return null;
  }

  /// 同步设置数据（供 MainPage 调用）
  void setState(LoginInitModel data) {
    state = data;
  }

  /// 用户登录
  Future<void> login({
    required String username,
    required String password,
    required String deviceUuid,
    required String deviceInfo,
  }) async {
    await ref
        .read(authRepositoryProvider)
        .login(
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
  /// useCache: 是否优先使用缓存
  ///
  /// 返回值：
  /// - LoginInitModel: 成功获取数据
  /// - null: 未登录或 token 过期
  ///
  /// 异常：
  /// - 网络错误、超时等会抛出异常，由调用方处理
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
        final updatedToken = token.copyWith(
          accountId: data.accountInfo.accountId,
        );
        await ref.read(tokenStorageProvider).saveToken(updatedToken);
      }

      // 更新状态
      state = data;
      return data;
    } on DioException catch (e) {
      // 网络请求异常：细分处理
      if (e.response?.statusCode == 401) {
        // 401 Token 过期：清除登录状态
        await logout();
        state = null;
        return null;
      }

      // 其他网络错误：静默失败，保持当前状态
      rethrow;
    } catch (e) {
      // 未知错误：静默失败
      rethrow;
    }
  }

  /// 后台刷新（不阻塞 UI）
  void _backgroundRefresh(int accountId) async {
    try {
      final data = await ref.read(loginInitRepositoryProvider).getLoginInit();
      // 更新状态
      state = data;
    } catch (e) {
      // 判断是否为特殊错误码（如 74015 账号冲突）
      if (e is DioException && e.error is AccountConflictException) {
        // 74015：清理本地数据并弹窗，不调用 logout 接口
        await ref.read(loginInitStorageProvider).clearAll();
        await ref.read(tokenStorageProvider).clearToken();
        state = null;
        ref
            .read(globalErrorProvider.notifier)
            .notify(e.error as AccountConflictException);
        return;
      }
      // 其他错误（网络超时、500 等）：静默失败，继续使用缓存
    }
  }

  /// 退出登录
  Future<void> logout() async {
    // 清除所有缓存
    await ref.read(loginInitStorageProvider).clearAll();

    // 清除 Token
    await ref.read(authRepositoryProvider).logout();

    // 更新状态
    state = null;
  }
}
