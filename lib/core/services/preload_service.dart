import 'package:hive_flutter/hive_flutter.dart';

import '../../models/auth/token_model.dart';
import '../../models/device/device_model.dart';
import '../../models/login_init/login_init_model.dart';
import '../constants/app_constants.dart';
import '../storage/device_storage.dart';
import '../utils/app_logger.dart';

/// 预加载服务
///
/// 负责在应用启动时同步读取核心数据到内存
///
/// 职责：
/// 1. 读取 token 判断登录状态
/// 2. 读取 LoginInit 获取当前防区 ID
/// 3. 读取当前防区的设备缓存
/// 4. 返回预加载数据结构
///
/// 使用场景：
/// - 在 main() 函数中调用，UI 渲染前完成
/// - 保证首页打开时数据已在内存，实现 0ms 显示
class PreloadService {
  // 私有构造函数，防止实例化
  PreloadService._();

  /// 执行预加载（同步）
  ///
  /// 注意：必须在 Hive boxes 打开后调用
  ///
  /// 返回：
  /// - 有缓存：包含 currentAreaId 和设备数据
  /// - 无缓存/未登录：返回空数据
  static PreloadData executeSync() {
    AppLogger.d('🚀 开始预加载数据', tag: LogTag.preload);

    try {
      // 1. 读取 token
      final token = _readToken();
      if (token?.accountId == null) {
        AppLogger.e('❌ 未登录或无 accountId，返回空数据', tag: LogTag.preload);
        return PreloadData.empty();
      }

      AppLogger.d('🔑 accountId = ${token!.accountId}', tag: LogTag.preload);

      // 2. 读取 LoginInit
      final loginData = _readLoginInit(token.accountId!);
      if (loginData == null || loginData.defenseAreaList.isEmpty) {
        AppLogger.e('❌ 无 LoginInit 或防区列表为空，返回空数据', tag: LogTag.preload);
        return PreloadData.empty();
      }

      AppLogger.d(
        '📋 LoginInit = 存在, 防区数量 = ${loginData.defenseAreaList.length}',
        tag: LogTag.preload,
      );

      // 3. 获取当前（第一个）防区的 ID
      final currentAreaId = loginData.defenseAreaList.first.areaId;
      AppLogger.d('🏢 当前防区 ID = $currentAreaId', tag: LogTag.preload);

      // 4. 读取设备缓存
      final devices = _readDevices(currentAreaId);

      if (devices == null || devices.isEmpty) {
        AppLogger.w('⚠️  无设备缓存，但返回 currentAreaId', tag: LogTag.preload);
        return PreloadData(currentAreaId: currentAreaId, allDevices: {});
      }

      AppLogger.d('✅ 成功加载 ${devices.length} 个设备', tag: LogTag.preload);

      // 5. 返回预加载数据
      return PreloadData(
        currentAreaId: currentAreaId,
        allDevices: {currentAreaId: devices},
      );
    } catch (e, stackTrace) {
      // 预加载失败不影响应用启动，返回空数据
      // HomePage 会显示占位内容，后续由 deviceProvider 异步加载
      AppLogger.e(
        '❌ 预加载失败: $e',
        tag: LogTag.preload,
        error: e,
        stackTrace: stackTrace,
      );
      return PreloadData.empty();
    }
  }

  /// 读取 token
  static TokenModel? _readToken() {
    try {
      final tokenBox = Hive.box<TokenModel>(AppConstants.boxAuthToken);
      final token = tokenBox.get(AppConstants.keyToken);
      AppLogger.d(
        '🔑 token = ${token != null ? "存在" : "null"}',
        tag: LogTag.preload,
      );
      return token;
    } catch (e) {
      AppLogger.e('❌ 读取 token 失败: $e', tag: LogTag.preload);
      return null;
    }
  }

  /// 读取 LoginInit 数据
  static LoginInitModel? _readLoginInit(int accountId) {
    try {
      final loginBox = Hive.box<LoginInitModel>(AppConstants.boxLoginInit);
      final loginData = loginBox.get(AppConstants.loginInitKey(accountId));
      return loginData;
    } catch (e) {
      AppLogger.e('❌ 读取 LoginInit 失败: $e', tag: LogTag.preload);
      return null;
    }
  }

  /// 读取设备缓存
  static List<DeviceModel>? _readDevices(int areaId) {
    try {
      final deviceStorage = DeviceStorage();
      return deviceStorage.getDevicesSync(areaId);
    } catch (e) {
      AppLogger.e('❌ 读取设备缓存失败: $e', tag: LogTag.preload);
      return null;
    }
  }
}

/// 预加载数据结构
class PreloadData {
  PreloadData({
    required this.currentAreaId,
    required this.allDevices,
  });

  /// 创建空数据
  factory PreloadData.empty() {
    return PreloadData(currentAreaId: 0, allDevices: {});
  }

  /// 当前防区 ID
  final int currentAreaId;

  /// 所有防区的设备数据
  /// Key: 防区 ID
  /// Value: 该防区的设备列表
  final Map<int, List<DeviceModel>> allDevices;

  /// 是否为空数据
  bool get isEmpty => currentAreaId == 0;

  /// 是否有数据
  bool get isNotEmpty => !isEmpty;
}
