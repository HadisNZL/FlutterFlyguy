import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/storage/token_storage.dart';
import '../../models/login_init/login_init_model.dart';
import '../../providers/global/global_auth_provider.dart';
import '../devices/devices_page.dart';
import '../guard/guard_page.dart';
import '../home/home_page.dart';
import '../profile/profile_page.dart';
import '../records/records_page.dart';

class MainPage extends ConsumerStatefulWidget {
  /// 路由携带的额外参数
  /// 用于接收页面跳转时的上下文信息，例如：
  /// - fromLogin: 是否来自登录页面（用于判断是否需要刷新数据）
  /// - 未来可扩展其他参数
  final Map<String, dynamic>? extra;

  const MainPage({super.key, this.extra});

  @override
  ConsumerState<MainPage> createState() => _MainPageState();
}

class _MainPageState extends ConsumerState<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    HomePage(),
    RecordsPage(),
    GuardPage(),
    DevicesPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();

    // 判断是否来自登录页面
    // 如果是登录跳转，登录流程已经请求过数据，无需再次刷新
    final fromLogin = widget.extra?[AppConstants.extraFromLogin] == true;
    _initialize(skipRefresh: fromLogin);
  }

  /// 应用初始化
  /// 职责：
  /// 1. 快速检查 token 存在性
  /// 2. 同步读取 LoginInit 缓存并设置到 provider
  /// 3. 根据来源决定是否触发后台刷新
  ///
  /// 参数：
  /// - skipRefresh: 是否跳过刷新
  ///   - true: 跳过刷新（登录跳转场景，数据已是最新）
  ///   - false: 触发刷新（冷启动、其他跳转场景）
  Future<void> _initialize({bool skipRefresh = false}) async {
    // 1. 快速检查 token 是否存在（5-10ms）
    final token = await ref.read(tokenStorageProvider).getToken();

    if (!mounted) return;

    if (token == null) {
      // 未登录，跳转登录页
      context.go(AppConstants.routeLogin);
      return;
    }

    // 2. 同步读取 LoginInit 缓存（Hive box 已在 main() 打开）
    if (token.accountId != null) {
      final box = Hive.box<LoginInitModel>(AppConstants.boxLoginInit);
      final cachedData = box.get(AppConstants.loginInitKey(token.accountId!));

      if (cachedData != null) {
        // 有缓存，立即设置（同步）
        ref.read(globalAuthProvider.notifier).setState(cachedData);
      }
    }

    // 3. 根据来源决定是否触发后台刷新
    if (!skipRefresh) {
      // 非登录跳转：触发后台刷新（冷启动、其他场景）
      // ignore: unawaited_futures
      ref.read(globalAuthProvider.notifier).checkAndInitialize(useCache: true);
    }
    // 登录跳转：跳过刷新（登录流程已请求过数据）
  }

  Widget _buildNavItem(String name, int index) {
    final isSelected = _currentIndex == index;
    return Image.asset(
      'assets/images/tabbar_${name}_${isSelected ? 'press' : 'normal'}.png',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppColors.colorTheme,
        unselectedItemColor: AppColors.color999999,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        items: [
          BottomNavigationBarItem(
            icon: _buildNavItem('homepage', 0),
            label: '首页',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem('records', 1),
            label: '记录',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem('guard', 2),
            label: '守护模式',
          ),
          BottomNavigationBarItem(
            icon: Stack(
              clipBehavior: Clip.none,
              children: [
                _buildNavItem('devices', 3),
                if (_currentIndex != 3)
                  Positioned(
                    right: -4,
                    top: -4,
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
            label: '设备',
          ),
          BottomNavigationBarItem(
            icon: _buildNavItem('profile', 4),
            label: '我的',
          ),
        ],
      ),
    );
  }
}
