import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/device/device_model.dart';
import '../../pages/auth/login_page.dart';
import '../../pages/camera/camera_live_page.dart';
import '../../pages/main/main_page.dart';
import '../constants/app_constants.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouterProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: AppConstants.routeMain,
    routes: [
      GoRoute(
        path: AppConstants.routeLogin,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppConstants.routeMain,
        builder: (context, state) {
          // 提取路由携带的 extra 参数
          // extra 用于传递页面跳转的上下文信息（如来源、状态等）
          final extra = state.extra as Map<String, dynamic>?;
          return MainPage(extra: extra);
        },
      ),
      GoRoute(
        path: AppConstants.routeCameraLive,
        builder: (context, state) {
          // 摄像头直播页面，从 extra 中获取设备信息
          final device = state.extra as DeviceModel;
          return CameraLivePage(device: device);
        },
      ),
    ],
  );
});
