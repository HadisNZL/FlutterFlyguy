import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/device_info_util.dart';
import 'providers/login_provider.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty) {
      _showError('请输入账号');
      return;
    }

    if (password.isEmpty) {
      _showError('请输入密码');
      return;
    }

    // 获取设备信息
    final deviceUuid = await DeviceInfoUtil.getDeviceId();
    final deviceModel = await DeviceInfoUtil.getDeviceModel();

    await ref
        .read(loginProvider.notifier)
        .submit(
          username: username,
          password: password,
          deviceUuid: deviceUuid,
          deviceInfo: deviceModel,
        );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);

    // 监听登录状态
    ref.listen<AsyncValue<void>>(loginProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          // 登录成功，跳转首页
          context.go('/main');
        },
        error: (error, _) {
          // 登录失败，显示错误
          _showError(error.toString());
        },
      );
    });

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 80),

              // Logo
              Center(
                child: Image.asset(
                  'assets/images/logo.png',
                  width: 100,
                  height: 100,
                  errorBuilder: (_, _, _) => const Icon(
                    Icons.account_circle,
                    size: 100,
                    color: AppColors.colorTheme,
                  ),
                ),
              ),

              const SizedBox(height: 60),

              // 账号输入框
              TextField(
                controller: _usernameController,
                decoration: InputDecoration(
                  hintText: '请输入手机号/邮箱',
                  hintStyle: const TextStyle(color: AppColors.color999999),
                  prefixIcon: const Icon(
                    Icons.person_outline,
                    color: AppColors.color666666,
                  ),
                  filled: true,
                  fillColor: AppColors.colorF5F5F5,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ),

              const SizedBox(height: 16),

              // 密码输入框
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: '请输入密码',
                  hintStyle: const TextStyle(color: AppColors.color999999),
                  prefixIcon: const Icon(
                    Icons.lock_outline,
                    color: AppColors.color666666,
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                      color: AppColors.color666666,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  filled: true,
                  fillColor: AppColors.colorF5F5F5,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // 忘记密码
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () {
                    // TODO: 跳转忘记密码页面
                    _showError('忘记密码功能待开发');
                  },
                  child: const Text(
                    '忘记密码？',
                    style: TextStyle(
                      color: AppColors.color666666,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // 登录按钮
              SizedBox(
                height: 48,
                child: ElevatedButton(
                  onPressed: loginState.isLoading ? null : _handleLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorTheme,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    disabledBackgroundColor: AppColors.color999999,
                  ),
                  child: loginState.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text(
                          '登录',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 24),

              // 立即注册
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '还没有账号？',
                    style: TextStyle(
                      color: AppColors.color666666,
                      fontSize: 14,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: 跳转注册页面
                      _showError('注册功能待开发');
                    },
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                    ),
                    child: const Text(
                      '立即注册',
                      style: TextStyle(
                        color: AppColors.colorTheme,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
