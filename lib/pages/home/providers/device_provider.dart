import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/app_logger.dart';
import '../../../models/device/device_model.dart';
import '../../../providers/global/global_auth_provider.dart';
import '../../../providers/global/global_devices_provider.dart';
import '../../../repositories/device_repository.dart';

part 'device_provider.g.dart';

@riverpod
class Device extends _$Device {
  @override
  Future<List<DeviceModel>> build() async {
    // 监听防区 ID 变化，自动重新构建
    final currentAreaId = ref.watch(currentAreaIdProvider);

    AppLogger.d('🔧 [deviceProvider.build] 开始构建，防区 $currentAreaId', tag: LogTag.device);

    // 防区 ID 无效时，返回空列表
    if (currentAreaId == 0) {
      AppLogger.w('⚠️  [deviceProvider.build] 防区 ID 无效 (0)，返回空列表', tag: LogTag.device);
      return [];
    }

    // 【优先级 1】先检查内存缓存（最快，0ms）
    // 二次冷启动时，main._preloadData 已预设数据到内存
    final inMemoryDevices = ref.read(inMemoryDevicesProvider)[currentAreaId];

    if (inMemoryDevices != null && inMemoryDevices.isNotEmpty) {
      AppLogger.d(
        '⚡️ [deviceProvider.build] 从内存缓存返回: ${inMemoryDevices.length} 个设备（瞬间显示）',
        tag: LogTag.device,
      );
      // 有内存数据：立即返回 + 后台静默刷新
      _refreshInBackground(currentAreaId);
      return inMemoryDevices;
    }

    AppLogger.d('💭 [deviceProvider.build] 内存无缓存，检查 Hive', tag: LogTag.device);

    // 【优先级 2】内存没有，读取 Hive 缓存（~50ms）
    // 首次启动或内存被清空时走这个分支
    final hiveCached =
        await ref.read(deviceRepositoryProvider).getCachedDevices(currentAreaId);

    if (hiveCached != null && hiveCached.isNotEmpty) {
      AppLogger.d(
        '✅ [deviceProvider.build] 从 Hive 缓存返回: ${hiveCached.length} 个设备',
        tag: LogTag.device,
      );
      // 有 Hive 缓存：更新内存 + 返回 + 后台刷新
      _updateMemoryState(currentAreaId, hiveCached);
      _refreshInBackground(currentAreaId);
      return hiveCached;
    }

    AppLogger.e('❌ [deviceProvider.build] 无任何缓存，请求接口（阻塞式）', tag: LogTag.device);

    // 【优先级 3】无任何缓存：阻塞式请求接口（~200ms）
    // 首次安装或缓存被清空时走这个分支
    final devices =
        await ref.read(deviceRepositoryProvider).refreshDevices(currentAreaId);

    AppLogger.d('📡 [deviceProvider.build] 接口返回: ${devices.length} 个设备', tag: LogTag.device);

    // 更新内存状态（自动保存到 Hive）
    _updateMemoryState(currentAreaId, devices);

    return devices;
  }

  /// 更新内存状态（inMemoryDevicesProvider）
  void _updateMemoryState(int areaId, List<DeviceModel> devices) {
    AppLogger.d('💾 [deviceProvider._updateMemoryState] 更新内存缓存: 防区 $areaId, ${devices.length} 个设备', tag: LogTag.device);
    ref.read(inMemoryDevicesProvider.notifier).update((state) => {
          ...state,
          areaId: devices,
        });
  }

  /// 后台刷新数据（不阻塞 UI）
  void _refreshInBackground(int areaId) {
    AppLogger.d('🔄 [deviceProvider._refreshInBackground] 启动后台刷新: 防区 $areaId', tag: LogTag.device);
    Future.microtask(() async {
      try {
        final latest =
            await ref.read(deviceRepositoryProvider).refreshDevices(areaId);

        AppLogger.d('📡 [deviceProvider._refreshInBackground] 后台刷新完成: ${latest.length} 个设备', tag: LogTag.device);

        // 只有当前防区还是这个 areaId 时，才更新
        if (ref.read(currentAreaIdProvider) == areaId) {
          AppLogger.d('✅ [deviceProvider._refreshInBackground] 当前防区匹配，更新数据', tag: LogTag.device);
          state = AsyncValue.data(latest);
          _updateMemoryState(areaId, latest);
        } else {
          AppLogger.w('⚠️  [deviceProvider._refreshInBackground] 当前防区已切换，丢弃刷新结果', tag: LogTag.device);
        }
      } catch (e) {
        AppLogger.e('❌ [deviceProvider._refreshInBackground] 后台刷新失败: $e', tag: LogTag.device);
        // 静默失败，不影响用户
      }
    });
  }

  /// 手动刷新
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final currentAreaId = ref.read(currentAreaIdProvider);
      final devices =
          await ref.read(deviceRepositoryProvider).refreshDevices(currentAreaId);
      _updateMemoryState(currentAreaId, devices);
      return devices;
    });
  }

  /// 获取摄像头设备
  List<DeviceModel> getCameraDevices() {
    final currentAreaId = ref.read(currentAreaIdProvider);
    final devices = ref.read(inMemoryDevicesProvider)[currentAreaId] ?? [];
    return devices.where((device) => device.isCamera).toList();
  }

  /// 获取传感器设备（红外探测器/门磁/平安通）
  List<DeviceModel> getSensorDevices() {
    final currentAreaId = ref.read(currentAreaIdProvider);
    final devices = ref.read(inMemoryDevicesProvider)[currentAreaId] ?? [];
    return devices.where((device) => device.isSensor).toList();
  }
}
