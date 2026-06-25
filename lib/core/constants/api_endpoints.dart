/// API 接口路径
class ApiEndpoints {
  /// 认证接口
  static const auth = _AuthEndpoints();

  /// 业务接口
  static const business = _BusinessEndpoints();
}

/// 认证接口路径
class _AuthEndpoints {
  const _AuthEndpoints();

  /// 登录 / 刷新令牌
  String get token => '/connect/token';
}

/// 业务接口路径
class _BusinessEndpoints {
  const _BusinessEndpoints();

  /// 获取登录初始化信息
  String get loginInit => '/APP/GetAppLoginInitInfo';

  /// 退出登录
  String get logout => '/APP/LogOut';
}
