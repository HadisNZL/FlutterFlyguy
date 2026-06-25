import 'package:flutter_easyloading/flutter_easyloading.dart';

/// Toast 工具类
class ToastUtil {
  /// 显示成功提示
  static void success(String message) {
    EasyLoading.showSuccess(message, duration: const Duration(seconds: 2));
  }

  /// 显示错误提示
  static void error(String message) {
    EasyLoading.showError(message, duration: const Duration(seconds: 2));
  }

  /// 显示普通提示
  static void info(String message) {
    EasyLoading.showInfo(message, duration: const Duration(seconds: 2));
  }
}

/// Loading 工具类
class LoadingUtil {
  /// 显示加载中
  static void show([String? message]) {
    EasyLoading.show(status: message ?? '加载中...');
  }

  /// 隐藏加载
  static void dismiss() {
    EasyLoading.dismiss();
  }
}
