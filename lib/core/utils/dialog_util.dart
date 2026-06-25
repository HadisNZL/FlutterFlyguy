import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// 对话框工具类
class DialogUtil {
  /// 显示确认对话框（平台自适应）
  static Future<bool?> showConfirm(
    BuildContext context, {
    required String title,
    required String content,
    String? confirmText,
    String? cancelText,
  }) {
    if (Platform.isIOS) {
      return showCupertinoDialog<bool>(
        context: context,
        builder: (context) => CupertinoAlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            CupertinoDialogAction(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText ?? '取消'),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText ?? '确定'),
            ),
          ],
        ),
      );
    } else {
      return showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(content),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(cancelText ?? '取消'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(confirmText ?? '确定'),
            ),
          ],
        ),
      );
    }
  }
}
