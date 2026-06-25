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
      final data = await ref
          .read(globalAuthProvider.notifier)
          .checkAndInitialize(useCache: true);

      if (!mounted) return;

      if (data == null) {
        context.go('/login');
      } else {
        context.go('/main');
      }
    } catch (e) {
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
