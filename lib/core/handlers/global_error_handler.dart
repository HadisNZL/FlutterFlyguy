import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../exceptions/business_exceptions.dart';
import '../router/app_router.dart';
import '../utils/dialog_util.dart';

/// 全局错误处理器基类
abstract class GlobalErrorHandler<T extends GlobalHandledException> {
  Future<void> handle(BuildContext context, WidgetRef ref, T error);
}

/// 账号冲突处理器（74015）
class AccountConflictHandler
    extends GlobalErrorHandler<AccountConflictException> {
  @override
  Future<void> handle(
    BuildContext context,
    WidgetRef ref,
    AccountConflictException error,
  ) async {
    // 使用 rootNavigatorKey 的 context 弹窗
    final navContext = rootNavigatorKey.currentContext;
    if (navContext == null || !navContext.mounted) return;

    await DialogUtil.showAlert(
      navContext,
      title: '账号冲突',
      content:
          '您的账号已在 ${error.latestDevice} 设备登录\n'
          '登录时间：${error.latestLoginTime}\n\n'
          '请重新登录',
      buttonText: '重新登录',
    );

    // 跳转到登录页
    if (navContext.mounted) {
      while (navContext.canPop()) {
        navContext.pop();
      }
      navContext.pushReplacement('/login');
    }
  }
}
