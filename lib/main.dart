import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'core/constants/colors.dart';
import 'core/exceptions/business_exceptions.dart';
import 'core/handlers/global_error_handler_registry.dart';
import 'core/router/app_router.dart';
import 'models/auth/token_model.dart';
import 'models/login_init/defense_area_model.dart';
import 'models/login_init/login_init_model.dart';
import 'providers/global/global_error_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();
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

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const ProviderScope(child: MyApp()));

  // 配置 EasyLoading 样式
  _configEasyLoading();
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
