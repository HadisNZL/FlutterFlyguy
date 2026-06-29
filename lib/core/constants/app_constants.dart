/// 应用全局常量
/// 集中管理所有硬编码的字符串常量，便于维护和修改
class AppConstants {
  AppConstants._(); // 私有构造函数，防止实例化

  /// ==================== 路由路径 ====================

  /// 主页路由
  static const String routeMain = '/main';

  /// 登录页路由
  static const String routeLogin = '/login';

  /// ==================== 路由参数 ====================

  /// extra 参数：是否来自登录页面
  /// 用于 MainPage 判断是否需要刷新数据
  static const String extraFromLogin = 'fromLogin';

  /// ==================== 存储 Box 名称 ====================

  /// Token 存储 Box 名称
  static const String boxAuthToken = 'auth_token';

  /// LoginInit 数据存储 Box 名称
  static const String boxLoginInit = 'login_init';

  /// ==================== 存储 Key ====================

  /// Token 存储的 key
  static const String keyToken = 'token';

  /// LoginInit 数据存储的 key 前缀（后面跟 accountId）
  static const String keyLoginInitPrefix = 'account_';

  /// 生成 LoginInit 存储的完整 key
  static String loginInitKey(int accountId) => '$keyLoginInitPrefix$accountId';
}
