import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// 全局日志工具类
///
/// 使用 logger 包封装，提供统一的日志输出接口
///
/// 特性：
/// - 自动美化输出（彩色、emoji）
/// - 支持多种日志级别（debug/info/warning/error）
/// - 支持 tag 标签，方便按模块筛选
/// - 生产环境自动禁用 debug 日志
/// - 支持错误和堆栈跟踪
///
/// 使用示例：
/// ```dart
/// // 简单使用（无 tag）
/// AppLogger.d('调试信息');
/// AppLogger.i('关键信息');
/// AppLogger.w('警告信息');
///
/// // 使用 tag（推荐）
/// AppLogger.d('开始预加载', tag: LogTag.preload);
/// AppLogger.d('读取缓存成功', tag: LogTag.storage);
/// AppLogger.e('网络请求失败', tag: LogTag.api, error: e, stackTrace: stackTrace);
///
/// // 灵活使用（跳过不需要的参数）
/// AppLogger.e('请求失败', error: error);  // 只传 error
/// AppLogger.e('请求失败', tag: LogTag.api);  // 只传 tag
/// ```
///
/// 筛选日志（在 IDE 或终端）：
/// - Android Studio: 在 Logcat 中搜索 "[PreLoad]"
/// - VS Code: 在 Debug Console 中搜索 "[PreLoad]"
/// - 终端: `flutter logs | grep "\[PreLoad\]"`
class AppLogger {
  // 私有构造函数，防止实例化
  AppLogger._();

  // 全局 Logger 实例
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // 不显示调用栈（除非是错误）
      errorMethodCount: 5, // 错误时显示 5 层调用栈
      lineLength: 80, // 每行宽度
      colors: true, // 彩色输出
      printEmojis: true, // 使用 emoji 图标
      dateTimeFormat: DateTimeFormat.none, // 不显示时间（Console 自带时间）
      excludeBox: {
        Level.debug: true, // debug 级别不显示边框
        Level.info: true, // info 级别不显示边框
      },
    ),
    filter: ProductionFilter(), // 生产环境自动禁用 debug/verbose
  );

  /// 格式化消息（添加 tag 和统一前缀）
  static String _formatMessage(String message, String? tag) {
    const prefix = 'nblog'; // 统一前缀，方便筛选所有 AppLogger 日志
    if (tag != null) {
      return '$prefix [$tag] $message';
    } else {
      return '$prefix $message';
    }
  }

  /// Debug 级别日志（开发调试用）
  ///
  /// 仅在 Debug 模式下输出，Release 模式自动禁用
  ///
  /// 参数：
  /// - message: 日志内容（必填）
  /// - tag: 标签，用于筛选同一模块的日志（可选，建议提供）
  /// - error: 错误对象（可选）
  /// - stackTrace: 堆栈跟踪（可选）
  ///
  /// 使用场景：
  /// - 调试信息
  /// - 函数调用跟踪
  /// - 变量值输出
  static void d(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      _logger.d(
        _formatMessage(message, tag),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Info 级别日志（关键信息）
  ///
  /// 在所有环境下都会输出
  ///
  /// 参数：
  /// - message: 日志内容（必填）
  /// - tag: 标签（可选，建议提供）
  /// - error: 错误对象（可选）
  /// - stackTrace: 堆栈跟踪（可选）
  ///
  /// 使用场景：
  /// - 应用启动/关闭
  /// - 用户登录/登出
  /// - 关键业务流程
  static void i(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.i(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Warning 级别日志（警告信息）
  ///
  /// 表示潜在问题，但不影响功能
  ///
  /// 参数：
  /// - message: 日志内容（必填）
  /// - tag: 标签（可选，建议提供）
  /// - error: 错误对象（可选）
  /// - stackTrace: 堆栈跟踪（可选）
  ///
  /// 使用场景：
  /// - 缓存未命中
  /// - 使用默认值
  /// - 过时的 API 调用
  static void w(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.w(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Error 级别日志（错误信息）
  ///
  /// 表示错误，但应用仍可继续运行
  ///
  /// 参数：
  /// - message: 日志内容（必填）
  /// - tag: 标签（可选，建议提供）
  /// - error: 错误对象（可选）
  /// - stackTrace: 堆栈跟踪（可选）
  ///
  /// 使用场景：
  /// - 网络请求失败
  /// - 数据解析错误
  /// - 业务逻辑错误
  static void e(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.e(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Verbose 级别日志（详细信息）
  ///
  /// 最详细的日志，通常不需要使用
  ///
  /// 参数：
  /// - message: 日志内容（必填）
  /// - tag: 标签（可选，建议提供）
  /// - error: 错误对象（可选）
  /// - stackTrace: 堆栈跟踪（可选）
  ///
  /// 使用场景：
  /// - 框架内部调试
  /// - 性能分析
  static void v(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    if (kDebugMode) {
      _logger.t(
        _formatMessage(message, tag),
        error: error,
        stackTrace: stackTrace,
      );
    }
  }

  /// Fatal 级别日志（致命错误）
  ///
  /// 表示致命错误，应用可能崩溃
  ///
  /// 参数：
  /// - message: 日志内容（必填）
  /// - tag: 标签（可选，建议提供）
  /// - error: 错误对象（可选）
  /// - stackTrace: 堆栈跟踪（可选）
  ///
  /// 使用场景：
  /// - 未捕获的异常
  /// - 关键资源初始化失败
  static void f(
    String message, {
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  }) {
    _logger.f(
      _formatMessage(message, tag),
      error: error,
      stackTrace: stackTrace,
    );
  }
}

/// 常用的 Tag 常量
///
/// 方便统一管理和避免拼写错误
class LogTag {
  LogTag._();

  // 核心模块
  static const String preload = 'PreLoadLog'; // 预加载
  static const String storage = 'StorageLog'; // 存储
  static const String api = 'APILog'; // 网络请求
  static const String auth = 'AuthLog'; // 认证
  static const String device = 'DeviceLog'; // 设备
  static const String ui = 'UILog'; // 界面

  // 业务模块
  static const String home = 'HomeLog'; // 首页
  static const String login = 'LoginLog'; // 登录
  static const String settings = 'SettingsLog'; // 设置

  // 系统模块
  static const String lifecycle = 'LifeCycleLog'; // 生命周期
  static const String navigation = 'NavigationLog'; // 导航
  static const String error = 'ErrorLog'; // 错误处理
}
