import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'global_error_provider.g.dart';

/// 全局业务错误通知
/// 用于拦截器向 UI 层推送特殊错误
@riverpod
class GlobalError extends _$GlobalError {
  @override
  Exception? build() => null;

  Exception? _lastError;

  /// 通知错误（防重入）
  void notify(Exception error) {
    // 防重入：同类型错误只处理一次
    if (_lastError?.runtimeType == error.runtimeType) {
      return;
    }

    _lastError = error;
    state = error;
  }

  /// 清除错误
  void clear() {
    _lastError = null;
    state = null;
  }
}
