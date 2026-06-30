import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/colors.dart';
import '../../models/login_init/defense_area_model.dart';
import '../../providers/global/global_auth_provider.dart';
import '../../widgets/defense_area_drawer.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // 获取完整的登录初始化数据（包含所有防区）
    final loginInitData = ref.watch(globalAuthProvider);

    // 监听当前选中的防区 ID（响应式更新）
    final currentAreaId = ref.watch(currentAreaIdProvider);

    // 从数据中查找当前防区
    DefenseArea? currentArea;
    if (loginInitData != null && loginInitData.defenseAreaList.isNotEmpty) {
      try {
        currentArea = loginInitData.defenseAreaList.firstWhere(
          (area) => area.areaId == currentAreaId,
        );
      } catch (e) {
        // 如果找不到，使用第一个
        currentArea = loginInitData.defenseAreaList.first;
      }
    }

    final areaName = currentArea?.areaName ?? '';
    final defenseAreas = loginInitData?.defenseAreaList ?? <DefenseArea>[];

    return _buildHomePage(context, ref, areaName, defenseAreas, currentAreaId);
  }

  /// 构建首页正常内容
  Widget _buildHomePage(
    BuildContext context,
    WidgetRef ref,
    String areaName,
    List<DefenseArea> defenseAreas,
    int currentAreaId,
  ) {
    return Scaffold(
      backgroundColor: AppColors.colorWhite,
      // 添加侧滑抽屉
      drawer: DefenseAreaDrawer(
        defenseAreas: defenseAreas,
        currentAreaId: currentAreaId,
        onAreaSelected: (areaId) {
          // 切换防区
          ref.read(globalAuthProvider.notifier).switchDefenseArea(areaId);
        },
      ),
      body: Builder(
        builder: (scaffoldContext) => Column(
          children: [
            _buildHeaderWithModeSelector(scaffoldContext, areaName),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    _buildDeviceList(),
                    const SizedBox(height: 16),
                    _buildCameraPreview(),
                    const SizedBox(height: 16),
                    _buildAddDevice(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderWithModeSelector(BuildContext context, String areaName) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/header_gradient.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          SizedBox(
            height: 56,
            child: Stack(
              children: [
                // 左侧菜单按钮
                Positioned(
                  left: 0,
                  top: 0,
                  bottom: 0,
                  child: IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: () {
                      // 打开侧滑抽屉
                      Scaffold.of(context).openDrawer();
                    },
                  ),
                ),
                // 中间标题（绝对居中）
                Center(
                  child: Text(
                    areaName,
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                // 右侧 911 按钮
                Positioned(
                  right: 15,
                  top: 0,
                  bottom: 0,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {},
                      child: Image.asset('assets/images/btn_911.png'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          _buildModeSelector(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
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
      child: Row(
        children: [
          Expanded(child: _buildModeButton('离家', 'away', false)),
          const SizedBox(width: 8),
          Expanded(child: _buildModeButton('在家', 'home', false)),
          const SizedBox(width: 8),
          Expanded(child: _buildModeButton('撤防', 'disarmed', true)),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, String mode, bool isActive) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: isActive ? AppColors.colorTheme : AppColors.colorF5F5F5,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            'assets/images/icon_mode_${mode}_${isActive ? 'press' : 'normal'}.png',
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isActive ? Colors.white : AppColors.color666666,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeviceList() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 15),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              _buildDeviceCard('Justice', Icons.sensor_door, null),
              const SizedBox(width: 12),
              _buildDeviceCard('前门', Icons.sensor_door, 'CLOSED'),
              const SizedBox(width: 12),
              _buildDeviceCard('pingan08', Icons.wifi, null),
              const SizedBox(width: 12),
              _buildDeviceCard('平安通0...', Icons.wifi, null),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDeviceCard(String name, IconData icon, String? status) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: const BoxDecoration(
            color: AppColors.colorF5F5F5,
            shape: BoxShape.circle,
          ),
          child: Stack(
            children: [
              Center(child: Icon(icon, color: AppColors.color666666, size: 28)),
              if (status != null)
                Positioned(
                  bottom: 4,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 8,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          width: 60,
          child: Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.color333333,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
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
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Stack(
              children: [
                Center(
                  child: Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const Positioned(
                  left: 12,
                  top: 12,
                  child: Text(
                    'Aijia',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ),
                const Positioned(
                  left: 12,
                  bottom: 12,
                  child: Text(
                    '2020-05-25 Mon. 06:50:23',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      shadows: [Shadow(color: Colors.black, blurRadius: 4)],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '三代009',
                    style: TextStyle(
                      color: AppColors.color333333,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.colorF5F5F5,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '24H',
                    style: TextStyle(
                      color: AppColors.color666666,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.colorF5F5F5,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.cloud_outlined,
                    color: AppColors.color666666,
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddDevice() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(40),
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
      child: Center(
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: AppColors.colorF5F5F5,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.add,
                color: AppColors.color999999,
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              '添加设备',
              style: TextStyle(color: AppColors.color999999, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
