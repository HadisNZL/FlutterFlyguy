import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/colors.dart';
import '../../core/utils/app_logger.dart';
import '../../models/login_init/defense_area_model.dart';
import '../../providers/global/global_auth_provider.dart';
import '../../providers/global/global_devices_provider.dart';
import '../../widgets/defense_area_drawer.dart';
import 'providers/device_provider.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  Widget build(BuildContext context) {
    // 获取完整的登录初始化数据（包含所有防区）
    final loginInitData = ref.watch(globalAuthProvider);

    // 等待 loginInitData 加载完成
    if (loginInitData == null) {
      return const Scaffold(
        backgroundColor: AppColors.colorWhite,
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorTheme),
          ),
        ),
      );
    }

    // 监听当前选中的防区 ID（响应式更新）
    final currentAreaId = ref.watch(currentAreaIdProvider);

    // 从数据中查找当前防区
    DefenseArea? currentArea;
    if (loginInitData.defenseAreaList.isNotEmpty) {
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
    final defenseAreas = loginInitData.defenseAreaList;

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
        builder: (scaffoldContext) {
          // 1. 获取当前防区 ID
          final currentAreaId = ref.watch(currentAreaIdProvider);

          // 2. 从 Map 中读取当前防区的设备数据
          final allDevices = ref.watch(inMemoryDevicesProvider);
          final devices = allDevices[currentAreaId] ?? [];

          AppLogger.d(
            '🏠 [HomePage.build] 防区 $currentAreaId, 内存中有 ${devices.length} 个设备',
            tag: LogTag.ui,
          );

          // 3. 触发后台刷新（异步，不阻塞 UI）
          ref.watch(deviceProvider);

          // 4. 根据数据状态渲染 UI
          if (devices.isNotEmpty) {
            AppLogger.d('✅ [HomePage.build] 显示完整内容', tag: LogTag.ui);
            return _buildFullContent(scaffoldContext, areaName);
          }

          // 无设备数据（包括加载中）：显示统一的占位符
          AppLogger.w('❌ [HomePage.build] 显示占位符', tag: LogTag.ui);
          return _buildPlaceholderContent(scaffoldContext, areaName);
        },
      ),
    );
  }

  /// 只显示占位的页面布局
  Widget _buildPlaceholderContent(BuildContext context, String areaName) {
    return Column(
      children: [
        _buildHeaderWithModeSelector(context, areaName),
        const SizedBox(height: 16),
        _buildAddDevicePlaceholder(title: '欢迎光临'),
        const Spacer(), // 占位卡片下方留空
      ],
    );
  }

  /// 完整的页面布局（有设备数据时）
  Widget _buildFullContent(BuildContext context, String areaName) {
    return Column(
      children: [
        _buildHeaderWithModeSelector(context, areaName),
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
    return Consumer(
      builder: (context, ref, child) {
        // 筛选传感器设备
        final sensorDevices = ref
            .read(deviceProvider.notifier)
            .getSensorDevices();

        if (sensorDevices.isEmpty) {
          return const SizedBox.shrink(); // 无传感器时不显示
        }

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
                children: sensorDevices
                    .map(
                      (device) => Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: _buildDeviceCard(
                          device.location,
                          _getDeviceIcon(device.deviceType),
                          device.status,
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getDeviceIcon(String deviceType) {
    switch (deviceType) {
      case 'motion':
        return Icons.sensors;
      case 'door':
        return Icons.sensor_door;
      case 'helpcall':
        return Icons.wifi;
      default:
        return Icons.devices;
    }
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
    return Consumer(
      builder: (context, ref, child) {
        final deviceAsync = ref.watch(deviceProvider);

        return deviceAsync.when(
          data: (devices) {
            // 筛选摄像头设备
            final cameraDevices = ref
                .read(deviceProvider.notifier)
                .getCameraDevices();

            // 无设备时显示默认占位
            if (cameraDevices.isEmpty) {
              return _buildAddDevicePlaceholder(title: '添加摄像头');
            }

            // 展示第一个摄像头
            final camera = cameraDevices.first;

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
                        Positioned(
                          left: 12,
                          top: 12,
                          child: Text(
                            camera.location,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              shadows: [
                                Shadow(color: Colors.black, blurRadius: 4),
                              ],
                            ),
                          ),
                        ),
                        Positioned(
                          right: 12,
                          top: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: camera.isOnline
                                  ? Colors.green
                                  : Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              camera.isOnline ? '在线' : '离线',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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
                        Expanded(
                          child: Text(
                            camera.location,
                            style: const TextStyle(
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
          },
          // loading 和 error 状态都显示默认占位
          loading: () => _buildAddDevicePlaceholder(title: '添加摄像头'),
          error: (error, stack) => _buildAddDevicePlaceholder(title: '添加摄像头'),
        );
      },
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

  /// 添加设备占位页面（类似摄像头卡片样式）
  Widget _buildAddDevicePlaceholder({required String title}) {
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
            decoration: const BoxDecoration(
              color: AppColors.colorF5F5F5,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Center(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.color999999,
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    '暂无设备',
                    style: TextStyle(
                      color: AppColors.color999999,
                      fontSize: 14,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.colorTheme,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    '立即添加',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
