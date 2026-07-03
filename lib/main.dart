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
import 'core/services/preload_service.dart';
import 'models/auth/token_model.dart';
import 'models/login_init/defense_area_model.dart';
import 'models/login_init/login_init_model.dart';
import 'providers/global/global_auth_provider.dart';
import 'providers/global/global_devices_provider.dart';
import 'providers/global/global_error_provider.dart';

void main() async {
  // 1. Flutter 初始化
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Hive 初始化
  await _initHive();

  // 3. 预加载核心数据到内存（在 UI 渲染前完成）
  final preloaded = PreloadService.executeSync();

  // 4. 配置系统 UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  // 5. 启动应用
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

  // 6. 配置 EasyLoading 样式
  _configEasyLoading();
}

/// 初始化 Hive
Future<void> _initHive() async {
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
}

/// 配置 EasyLoading 样式
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
