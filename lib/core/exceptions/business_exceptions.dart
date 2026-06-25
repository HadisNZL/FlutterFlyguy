/// 全局处理的异常基类
/// 标记：此类异常已被全局处理，页面层不需要显示 Toast
abstract class GlobalHandledException implements Exception {}

/// 账号冲突异常（其他设备登录）
class AccountConflictException extends GlobalHandledException {
  AccountConflictException({
    required this.latestDevice,
    required this.latestLoginTime,
    required this.message,
  });

  final String latestDevice;
  final String latestLoginTime;
  final String message;

  @override
  String toString() => message;
}
