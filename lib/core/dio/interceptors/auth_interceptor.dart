import 'dart:io';

import 'package:dio/dio.dart';

import '../../constants/api_endpoints.dart';
import '../../storage/token_storage.dart';
import '../../utils/device_info_util.dart';

/// 认证拦截器
/// 自动添加所有必要的 Header（设备信息、版本号、语言、Token）
class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._storage);
  final TokenStorage _storage;

  // 静态缓存，全局共享
  static String? _deviceIdCache;
  static String? _appVersionCache;
  static String? _languageCache;
  static Future<String>? _deviceIdFuture;
  static Future<String>? _appVersionFuture;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // 懒加载初始化（首次调用时初始化，后续使用缓存）
    await _ensureInitialized();

    // 添加全局应用 Header
    options.headers['X-App-Build'] = _appVersionCache;
    options.headers['X-App-Language'] = _languageCache;
    options.headers['X-App-Platform'] = Platform.isAndroid ? 'Android' : 'iOS';
    options.headers['X-App-Device-Id'] = _deviceIdCache;

    // 添加 Authorization Token（排除登录和刷新接口）
    if (!options.path.contains(ApiEndpoints.auth.token)) {
      final token = await _storage.getToken();
      if (token != null) {
        options.headers['Authorization'] =
            '${token.tokenType} ${token.accessToken}';
      }
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // 401 表示令牌失效，需要重新登录
    // 注意：这里只记录错误，不做跳转
    // 跳转逻辑应该在 UI 层处理，避免拦截器中依赖 Context
    if (err.response?.statusCode == 401) {
      // Token 失效，交给上层处理
    }

    handler.next(err);
  }

  /// 确保所有配置信息已初始化
  Future<void> _ensureInitialized() async {
    // 如果已经有缓存，直接返回
    if (_deviceIdCache != null &&
        _appVersionCache != null &&
        _languageCache != null) {
      return;
    }

    // 初始化设备ID（调用工具类，只创建一次 Future）
    _deviceIdFuture ??= DeviceInfoUtil.getDeviceId();
    _deviceIdCache ??= await _deviceIdFuture;

    // 初始化应用版本号（调用工具类，只创建一次 Future）
    _appVersionFuture ??= DeviceInfoUtil.getAppVersion();
    _appVersionCache ??= await _appVersionFuture;

    // 初始化系统语言（调用工具类，同步操作）
    _languageCache ??= DeviceInfoUtil.getSystemLanguage();
  }
}
