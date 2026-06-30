import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flyguy/core/utils/toast_util.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_constants.dart';
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
    ToastUtil.error(message);
  }

  @override
  Widget build(BuildContext context) {
    final loginState = ref.watch(loginProvider);
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();
    final canSubmit =
        username.isNotEmpty && password.isNotEmpty && !loginState.isLoading;

    // 监听登录状态
    ref.listen<AsyncValue<void>>(loginProvider, (_, state) {
      state.whenOrNull(
        data: (_) {
          context.go(
            AppConstants.routeMain,
            extra: {AppConstants.extraFromLogin: true},
          );
        },
        error: (error, _) {
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
            children: [
              const SizedBox(height: 100),

              // Logo 占位
              Container(
                width: 160,
                height: 100,
                color: AppColors.colorTheme.withValues(alpha: 0.1),
                child: const Center(
                  child: Text(
                    'LOGO',
                    style: TextStyle(
                      color: AppColors.colorTheme,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // 账号输入框
              TextField(
                controller: _usernameController,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '',
                  suffixIcon: username.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.cancel,
                            color: AppColors.color999999,
                            size: 20,
                          ),
                          onPressed: () {
                            _usernameController.clear();
                            setState(() {});
                          },
                        )
                      : null,
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.colorTheme,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.colorTheme,
                      width: 1.5,
                    ),
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
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: '密码',
                  hintStyle: const TextStyle(color: AppColors.colorCCCCCC),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.color999999,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.colorEEEEEE,
                      width: 1,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: AppColors.colorTheme,
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 底部链接行
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      _showError('注册功能待开发');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '立即注册',
                      style: TextStyle(
                        color: AppColors.colorTheme,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _showError('忘记密码功能待开发');
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      '忘记密码',
                      style: TextStyle(
                        color: AppColors.color333333,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 登录按钮
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: canSubmit ? _handleLogin : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.colorTheme,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    disabledBackgroundColor: AppColors.colorCCCCCC,
                    elevation: 0,
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
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send, size: 18),
                            SizedBox(width: 8),
                            Text(
                              '登录',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              SizedBox(height: MediaQuery.of(context).size.height * 0.15),

              const SizedBox(height: 60),
            ],
          ),
        ),
      ),
    );
  }
}
