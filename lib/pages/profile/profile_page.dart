import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/colors.dart';
import '../../core/utils/dialog_util.dart';
import '../../core/utils/toast_util.dart';
import '../../providers/global/global_auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 16),
            _buildQuickCards(),
            const SizedBox(height: 16),
            _buildFamilySection(),
            const SizedBox(height: 16),
            _buildSettingsSection(),
            const SizedBox(height: 20),
            _buildLogoutButton(context, ref),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/header_gradient.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top + 30),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Hi!',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.color333333,
                        ),
                      ),
                      Text(
                        'diviner',
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: AppColors.color333333,
                        ),
                      ),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.grey[300],
                      ),
                      child: const Icon(
                        Icons.person,
                        size: 35,
                        color: Colors.grey,
                      ),
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: Container(
                        width: 24,
                        height: 24,
                        decoration: const BoxDecoration(
                          color: AppColors.colorTheme,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.home,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildQuickCards() {
    final cards = [
      {'image': 'assets/images/banner_guide.png'},
      {'image': 'assets/images/banner_guard.png'},
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: cards.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Container(
            width: 250,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.asset(
                cards[index]['image']!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(Icons.image, size: 40, color: Colors.grey),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFamilySection() {
    final families = [
      {'name': 'diviner', 'memberCount': 8},
      {'name': 'AijiaTest1', 'memberCount': 3},
      {'name': 'birt', 'memberCount': 8},
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的家庭组',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.color333333,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.colorTheme),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '查看全部',
                  style: TextStyle(color: AppColors.colorTheme, fontSize: 10),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...families.asMap().entries.map((entry) {
            final isLast = entry.key == families.length - 1;
            return Column(
              children: [
                _buildFamilyItem(
                  entry.value['name'] as String,
                  entry.value['memberCount'] as int,
                ),
                if (!isLast) const SizedBox(height: 8),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFamilyItem(String name, int memberCount) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.colorF6F6F9,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey[300],
            ),
            child: const Icon(Icons.person, size: 22, color: Colors.grey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.color333333,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.people,
                  size: 13,
                  color: AppColors.color666666,
                ),
                const SizedBox(width: 4),
                Text(
                  '$memberCount',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.color666666,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right,
            color: AppColors.color999999,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text(
              '通用设置',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.color333333,
              ),
            ),
          ),
          _buildSettingItem(Icons.send_outlined, '推送服务设置'),
          _buildDivider(),
          _buildSettingItem(Icons.settings_outlined, '系统设置'),
          _buildDivider(),
          _buildSettingItem(Icons.tv_outlined, '授权登录'),
          _buildDivider(),
          _buildSettingItem(
            Icons.headset_mic_outlined,
            '联系客服',
            trailing: '+1(877)482-5503',
          ),
          _buildDivider(),
          _buildSettingItem(Icons.help_outline, '使用帮助'),
          _buildDivider(),
          _buildSettingItem(Icons.message_outlined, '用户反馈'),
          _buildDivider(),
          _buildSettingItem(Icons.info_outline, '关于我们', trailing: 'v5.1.5'),
          _buildDivider(),
          _buildSettingItem(Icons.science_outlined, '内测功能'),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Divider(height: 1, color: Colors.grey[200]),
    );
  }

  Widget _buildSettingItem(IconData icon, String title, {String? trailing}) {
    return InkWell(
      onTap: () {},
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 22, color: AppColors.color666666),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.color333333,
                ),
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.color999999,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.color999999,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () async {
        // 显示确认对话框
        final confirm = await DialogUtil.showConfirm(
          context,
          title: '退出登录',
          content: '确定要退出登录吗？',
        );

        if (confirm != true) return;

        // 显示 Loading
        LoadingUtil.show();

        try {
          // 调用退出登录
          await ref.read(globalAuthProvider.notifier).logout();

          // 隐藏 Loading
          LoadingUtil.dismiss();

          // 清空路由栈并跳转到登录页
          if (context.mounted) {
            // 清空所有历史记录
            while (context.canPop()) {
              context.pop();
            }
            // 跳转到登录页（无法返回）
            context.pushReplacement(AppConstants.routeLogin);
          }
        } catch (e) {
          // 隐藏 Loading
          LoadingUtil.dismiss();

          // 显示错误提示
          ToastUtil.error(e.toString());
        }
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          '退出登录',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: AppColors.colorRed,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}
