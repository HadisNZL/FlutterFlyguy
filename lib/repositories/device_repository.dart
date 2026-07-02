import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/device_api.dart';
import '../core/storage/device_storage.dart';
import '../core/utils/app_logger.dart';
import '../models/device/device_model.dart';

final deviceRepositoryProvider = Provider<DeviceRepository>((ref) {
  return DeviceRepository(
    ref.watch(deviceApiProvider),
    ref.watch(deviceStorageProvider),
  );
});

class DeviceRepository {
  DeviceRepository(this._deviceApi, this._storage);

  final DeviceApi _deviceApi;
  final DeviceStorage _storage;

  /// 获取缓存的设备列表（按防区）
  Future<List<DeviceModel>?> getCachedDevices(int areaId) async {
    return _storage.getDevices(areaId);
  }

  /// 请求接口并更新缓存（按防区）
  Future<List<DeviceModel>> refreshDevices(int areaId) async {
    final response = await _deviceApi.getDevices(areaId);

    // 提取嵌套的 Devices 数组：Data.Devices
    final data = response.data['Data'] as Map<String, dynamic>;
    final devicesList = data['Devices'] as List;

    final devices = <DeviceModel>[];
    for (var i = 0; i < devicesList.length; i++) {
      try {
        final json = devicesList[i] as Map<String, dynamic>;
        final device = DeviceModel.fromJson(json);
        devices.add(device);
      } catch (e) {
        AppLogger.w('⚠️ [DeviceRepository] 解析第 $i 个设备失败: $e', tag: LogTag.device);
      }
    }

    // 保存到对应防区的缓存
    await _storage.saveDevices(devices, areaId);
    return devices;
  }

  /// 清除缓存
  Future<void> clearCache() async {
    await _storage.clearAll();
  }
}
