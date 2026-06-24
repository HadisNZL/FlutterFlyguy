import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../providers/global/global_auth_provider.dart';

class SplashPage extends ConsumerStatefulWidget {
  const SplashPage({super.key});

  @override
  ConsumerState<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends ConsumerState<SplashPage> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 检查并刷新令牌
      final isValid = await ref
          .read(globalAuthProvider.notifier)
          .checkAndRefresh();

      if (!mounted) return;

      if (isValid) {
        // 令牌有效，跳转首页
        context.go('/main');
      } else {
        // 令牌无效或不存在，跳转登录页
        context.go('/login');
      }
    } catch (e) {
      // 发生错误，跳转登录页
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo
            Image.asset(
              'assets/images/logo.png',
              width: 120,
              height: 120,
              errorBuilder: (_, _, _) => const Icon(
                Icons.account_circle,
                size: 120,
                color: AppColors.colorTheme,
              ),
            ),
            const SizedBox(height: 24),

            // 品牌名
            const Text(
              'Diviner',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.color333333,
              ),
            ),

            const SizedBox(height: 48),

            // 加载动画
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorTheme),
            ),
          ],
        ),
      ),
    );
  }
}
