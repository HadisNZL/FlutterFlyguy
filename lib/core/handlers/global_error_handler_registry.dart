import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../exceptions/business_exceptions.dart';
import 'global_error_handler.dart';

/// 全局错误处理器注册表
class GlobalErrorHandlerRegistry {
  /// 处理器映射表
  static final _handlers = <Type, GlobalErrorHandler>{
    AccountConflictException: AccountConflictHandler(),
    // 未来新增特殊错误码，只需在此添加处理器
  };

  /// 处理全局错误
  static Future<void> handle(
    BuildContext context,
    WidgetRef ref,
    GlobalHandledException error,
  ) async {
    final handler = _handlers[error.runtimeType];
    if (handler != null) {
      await handler.handle(context, ref, error);
    }
  }
}
