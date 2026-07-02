import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../core/exceptions/business_exceptions.dart';
import '../../core/storage/login_init_storage.dart';
import '../../core/storage/token_storage.dart';
import '../../core/utils/app_logger.dart';
import '../../models/login_init/defense_area_model.dart';
import '../../models/login_init/login_init_model.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/login_init_repository.dart';
import 'global_devices_provider.dart';
import 'global_error_provider.dart';

part 'global_auth_provider.g.dart';

/// 当前选中的防区 ID（仅存在于内存，不持久化）
final currentAreaIdStateProvider = StateProvider<int?>((ref) => null);

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
    // 保留预设的 currentAreaId，不重置
    // 这样可以避免覆盖 main() 中预设的值
  }

  /// 获取当前防区 ID（默认第一个防区）
  int get currentAreaId {
    final selectedId = ref.read(currentAreaIdStateProvider);

    // 如果已选择，返回选中的
    if (selectedId != null) return selectedId;

    // 否则返回第一个防区的 ID
    if (state?.defenseAreaList.isNotEmpty ?? false) {
      return state!.defenseAreaList.first.areaId;
    }

    // 无防区数据，返回 0
    return 0;
  }

  /// 获取当前防区对象
  DefenseArea? get currentDefenseArea {
    if (state == null || state!.defenseAreaList.isEmpty) return null;

    try {
      // 根据 currentAreaId 查找对应的防区
      return state!.defenseAreaList.firstWhere(
        (area) => area.areaId == currentAreaId,
      );
    } catch (e) {
      // 如果找不到（理论上不应该发生），返回第一个
      return state!.defenseAreaList.first;
    }
  }

  /// 切换防区
  /// 参数：areaId - 要切换到的防区 ID
  void switchDefenseArea(int areaId) {
    // 校验防区是否存在
    if (state == null) return;

    final exists = state!.defenseAreaList.any((area) => area.areaId == areaId);
    if (!exists) return;

    AppLogger.d('🔄 [switchDefenseArea] 切换到防区 $areaId', tag: LogTag.auth);

    // 1. 检查目标防区是否有缓存
    final allDevices = ref.read(inMemoryDevicesProvider);
    final cachedDevices = allDevices[areaId];

    AppLogger.d('📦 [switchDefenseArea] 内存缓存状态:', tag: LogTag.auth);
    AppLogger.d('   - 所有防区: ${allDevices.keys.toList()}', tag: LogTag.auth);
    AppLogger.d('   - 防区 $areaId: ${cachedDevices?.length ?? 0} 个设备', tag: LogTag.auth);

    if (cachedDevices == null || cachedDevices.isEmpty) {
      AppLogger.w('❌ [switchDefenseArea] 无内存缓存，设置空数组触发占位符', tag: LogTag.auth);
      // 无缓存：设置空数组，触发占位符显示（加载中状态）
      ref.read(inMemoryDevicesProvider.notifier).update((state) => {
            ...state,
            areaId: [],
          });
    } else {
      AppLogger.d('✅ [switchDefenseArea] 有内存缓存，直接使用（瞬间显示）', tag: LogTag.auth);
    }
    // 如果有缓存，不需要修改，切换 areaId 后会自动显示缓存数据

    // 2. 更新 currentAreaId（触发 deviceProvider 重新构建和 HomePage 重新渲染）
    ref.read(currentAreaIdStateProvider.notifier).state = areaId;
    AppLogger.d('✅ [switchDefenseArea] currentAreaId 已更新为 $areaId', tag: LogTag.auth);

    // 3. deviceProvider 会自动处理后续的数据加载和更新
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

    // 重置防区选择
    ref.read(currentAreaIdStateProvider.notifier).state = null;
  }
}

/// 当前防区 ID Provider（响应式）
/// 用于其他页面监听当前选中的防区 ID
@riverpod
int currentAreaId(CurrentAreaIdRef ref) {
  // 监听 currentAreaIdStateProvider 和 globalAuthProvider
  ref.watch(currentAreaIdStateProvider);
  ref.watch(globalAuthProvider);
  // 返回当前防区 ID
  return ref.read(globalAuthProvider.notifier).currentAreaId;
}

/// 当前防区对象 Provider（响应式）
/// 用于其他页面监听当前选中的防区对象
@riverpod
DefenseArea? currentDefenseArea(CurrentDefenseAreaRef ref) {
  // 监听 currentAreaIdStateProvider 和 globalAuthProvider
  ref.watch(currentAreaIdStateProvider);
  ref.watch(globalAuthProvider);
  // 返回当前防区对象
  return ref.read(globalAuthProvider.notifier).currentDefenseArea;
}
