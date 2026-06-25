import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/global/global_auth_provider.dart';
import '../exceptions/business_exceptions.dart';
import '../utils/dialog_util.dart';

/// 全局错误处理器基类
abstract class GlobalErrorHandler<T extends GlobalHandledException> {
  Future<void> handle(BuildContext context, WidgetRef ref, T error);
}

/// 账号冲突处理器（74015）
class AccountConflictHandler extends GlobalErrorHandler<AccountConflictException> {
  @override
  Future<void> handle(
    BuildContext context,
    WidgetRef ref,
    AccountConflictException error,
  ) async {
    await DialogUtil.showAlert(
      context,
      title: '账号冲突',
      content: '您的账号已在 ${error.latestDevice} 设备登录\n'
          '登录时间：${error.latestLoginTime}\n\n'
          '请重新登录',
      buttonText: '重新登录',
    );

    // 清除 Token
    await ref.read(globalAuthProvider.notifier).logout();

    // 跳转到登录页
    if (context.mounted) {
      while (context.canPop()) {
        context.pop();
      }
      context.pushReplacement('/login');
    }
  }
}
