/// 环境枚举
enum Environment { dev, beta, release }

/// API 环境配置
class ApiConfig {
  // 从编译时参数读取环境（--dart-define=ENV=xxx）
  static const _env = String.fromEnvironment('ENV', defaultValue: 'dev');

  /// 当前环境
  static Environment get environment {
    switch (_env) {
      case 'beta':
        return Environment.beta;
      case 'release':
        return Environment.release;
      default:
        return Environment.dev;
    }
  }

  /// 认证服务 Base URL
  static String get authBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://211.100.76.62/UserIdentity_v1';
      case Environment.beta:
        return 'http://iof-test.italkcs.com/UserIdentity_v1';
      case Environment.release:
        return 'https://webaccount.italkbb.com/UserIdentity_v1';
    }
  }

  /// 业务服务 Base URL
  static String get businessBaseUrl {
    switch (environment) {
      case Environment.dev:
        return 'http://211.100.76.62/Aijia/BusinessAPI/V3.4';
      case Environment.beta:
        return 'https://apitest.263nt.com/Aijia/BusinessAPI/V3.4';
      case Environment.release:
        return 'https://hsapi.italkdd.com/Aijia/BusinessAPI/V3.4';
    }
  }

  /// 连接超时
  static Duration get connectTimeout {
    switch (environment) {
      case Environment.dev:
        return const Duration(seconds: 20); // 开发环境长一点，方便调试
      case Environment.beta:
        return const Duration(seconds: 20);
      case Environment.release:
        return const Duration(seconds: 15); // 生产环境短一点
    }
  }

  /// 接收超时
  static Duration get receiveTimeout {
    switch (environment) {
      case Environment.dev:
        return const Duration(seconds: 20);
      case Environment.beta:
        return const Duration(seconds: 20);
      case Environment.release:
        return const Duration(seconds: 15);
    }
  }

  /// 发送超时
  static Duration get sendTimeout {
    switch (environment) {
      case Environment.dev:
        return const Duration(seconds: 20);
      case Environment.beta:
        return const Duration(seconds: 20);
      case Environment.release:
        return const Duration(seconds: 15);
    }
  }

  /// 是否启用日志
  static bool get enableLogger {
    return environment != Environment.release; // 生产环境关闭日志
  }
}
