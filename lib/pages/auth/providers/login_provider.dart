import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../providers/global/global_auth_provider.dart';

part 'login_provider.g.dart';

@riverpod
class Login extends _$Login {
  @override
  FutureOr<void> build() {
    // 初始状态为空
  }

  /// 提交登录
  Future<void> submit({
    required String username,
    required String password,
    required String deviceUuid,
    required String deviceInfo,
  }) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // 1. 登录获取 Token
      await ref.read(globalAuthProvider.notifier).login(
            username: username,
            password: password,
            deviceUuid: deviceUuid,
            deviceInfo: deviceInfo,
          );

      // 2. 初始化数据（不使用缓存）
      await ref.read(globalAuthProvider.notifier).initAfterLogin();
    });
  }
}
