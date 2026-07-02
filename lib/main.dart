import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/colors.dart';
import 'core/exceptions/business_exceptions.dart';
import 'core/handlers/global_error_handler_registry.dart';
import 'core/router/app_router.dart';
import 'core/storage/device_storage.dart';
import 'core/utils/app_logger.dart';
import 'models/auth/token_model.dart';
import 'models/device/device_model.dart';
import 'models/login_init/defense_area_model.dart';
import 'models/login_init/login_init_model.dart';
import 'providers/global/global_auth_provider.dart';
import 'providers/global/global_devices_provider.dart';
import 'providers/global/global_error_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();
  // 注册强类型 Adapters（仅用于 Token 和 LoginInit）
  Hive.registerAdapter(TokenModelAdapter());
  Hive.registerAdapter(LoginInitModelAdapter());
  Hive.registerAdapter(APPAccountInfoAdapter());
  Hive.registerAdapter(SipInfoAdapter());
  Hive.registerAdapter(DefenseAreaAdapter());
  Hive.registerAdapter(AFAddressAdapter());
  Hive.registerAdapter(PSTNAdapter());
  Hive.registerAdapter(TimeZoneInfoAdapter());
  Hive.registerAdapter(OEMAccountAdapter());
  Hive.registerAdapter(AppSystemSettingAdapter());

  // 打开 Hive boxes（用于同步读取）
  await Hive.openBox<TokenModel>(AppConstants.boxAuthToken);
  await Hive.openBox<LoginInitModel>(AppConstants.boxLoginInit);
  // 设备列表使用 JSON 字符串存储，避免类型转换问题
  await Hive.openBox<String>(AppConstants.boxDevices);

  // 预加载核心数据到内存（在 UI 渲染前完成）
  final preloaded = _preloadData();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      overrides: [
        // 预设当前防区 ID（关键：解决第一帧 currentAreaId = 0 的问题）
        currentAreaIdStateProvider.overrideWith(
          (ref) => preloaded.isEmpty ? null : preloaded.currentAreaId,
        ),
        // 预设设备数据（支持多防区缓存）
        inMemoryDevicesProvider.overrideWith((ref) => preloaded.allDevices),
      ],
      child: const MyApp(),
    ),
  );

  // 配置 EasyLoading 样式
  _configEasyLoading();
}

/// 预加载数据结构
class _PreloadedData {
  _PreloadedData({required this.currentAreaId, required this.allDevices});

  factory _PreloadedData.empty() {
    return _PreloadedData(currentAreaId: 0, allDevices: {});
  }
  final int currentAreaId;
  final Map<int, List<DeviceModel>> allDevices;

  bool get isEmpty => currentAreaId == 0;
}

/// 预加载核心数据到内存
/// 在应用启动时同步读取缓存，确保首页渲染时数据已准备好
///
/// 职责：
/// 1. 读取 token 判断登录状态
/// 2. 读取 LoginInit 获取当前防区 ID
/// 3. 读取当前防区的设备缓存
/// 4. 返回预加载数据结构
///
/// 返回：
/// - 有缓存：返回包含 currentAreaId 和设备数据的结构
/// - 无缓存/未登录：返回空结构
_PreloadedData _preloadData() {
  AppLogger.d('🚀 开始预加载数据', tag: LogTag.preload);

  try {
    // 1. 读取 token（box 已在上面打开）
    final tokenBox = Hive.box<TokenModel>(AppConstants.boxAuthToken);
    final token = tokenBox.get(AppConstants.keyToken);

    AppLogger.d(
      '🔑 token = ${token != null ? "存在" : "null"}',
      tag: LogTag.preload,
    );
    AppLogger.d('🔑 accountId = ${token?.accountId}', tag: LogTag.preload);

    // 未登录，返回空
    if (token?.accountId == null) {
      AppLogger.e('❌ 未登录或无 accountId，返回空数据', tag: LogTag.preload);
      return _PreloadedData.empty();
    }

    // 2. 读取 LoginInit 数据
    final loginBox = Hive.box<LoginInitModel>(AppConstants.boxLoginInit);
    final loginData = loginBox.get(
      AppConstants.loginInitKey(token!.accountId!),
    );

    AppLogger.d(
      '📋 LoginInit = ${loginData != null ? "存在" : "null"}',
      tag: LogTag.preload,
    );
    AppLogger.d(
      '📋 防区数量 = ${loginData?.defenseAreaList.length ?? 0}',
      tag: LogTag.preload,
    );

    // 无 LoginInit 缓存，返回空
    if (loginData == null || loginData.defenseAreaList.isEmpty) {
      AppLogger.e('❌ 无 LoginInit 或防区列表为空，返回空数据', tag: LogTag.preload);
      return _PreloadedData.empty();
    }

    // 3. 获取当前（第一个）防区的 ID
    final currentAreaId = loginData.defenseAreaList.first.areaId;
    AppLogger.d('🏢 当前防区 ID = $currentAreaId', tag: LogTag.preload);

    // 4. 使用 DeviceStorage 同步读取设备缓存（Box 已打开）
    final deviceStorage = DeviceStorage();
    final devices = deviceStorage.getDevicesSync(currentAreaId);

    if (devices == null || devices.isEmpty) {
      AppLogger.w('⚠️  无设备缓存，但返回 currentAreaId', tag: LogTag.preload);
      return _PreloadedData(currentAreaId: currentAreaId, allDevices: {});
    }

    AppLogger.d('✅ 成功加载 ${devices.length} 个设备', tag: LogTag.preload);

    // 5. 返回预加载数据
    return _PreloadedData(
      currentAreaId: currentAreaId,
      allDevices: {currentAreaId: devices},
    );
  } catch (e, stackTrace) {
    // 预加载失败不影响应用启动，返回空数据
    // HomePage 会显示占位内容，后续由 deviceProvider 异步加载
    AppLogger.e('❌ 预加载失败: $e', tag: LogTag.preload, error: e, stackTrace: stackTrace);
    return _PreloadedData.empty();
  }
}

void _configEasyLoading() {
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.ring
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..maskType = EasyLoadingMaskType.black
    ..userInteractions = false
    ..dismissOnTap = false;
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // 全局监听业务错误
    ref.listen<Exception?>(globalErrorProvider, (prev, next) {
      if (next != null && next is GlobalHandledException) {
        GlobalErrorHandlerRegistry.handle(context, ref, next);
        ref.read(globalErrorProvider.notifier).clear();
      }
    });

    return MaterialApp.router(
      title: 'Diviner',
      debugShowCheckedModeBanner: false,
      routerConfig: router,
      builder: EasyLoading.init(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.colorTheme,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.colorF5F5F5,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppColors.color333333),
          titleTextStyle: TextStyle(
            color: AppColors.color333333,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        useMaterial3: true,
      ),
    );
  }
}
