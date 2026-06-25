import 'package:dio/dio.dart';

import '../exceptions/business_exceptions.dart';
import 'toast_util.dart';

/// 页面级错误处理工具
class ErrorHandlerUtil {
  /// 统一处理错误
  /// - 特殊错误（GlobalHandledException）：静默处理（已由全局处理）
  /// - 普通错误：显示 Toast
  static void handleError(Object error) {
    // dismiss Loading
    LoadingUtil.dismiss();

    // 检查是否为全局处理的异常
    if (error is DioException && error.error is GlobalHandledException) {
      // 特殊错误已被全局处理，不显示 Toast
      return;
    }

    // 普通错误：显示 Toast
    ToastUtil.error(error.toString());
  }
}
