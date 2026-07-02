import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/device/device_model.dart';
import '../constants/app_constants.dart';
import '../utils/app_logger.dart';
import 'hive_json_storage.dart';

final deviceStorageProvider = Provider<DeviceStorage>((ref) {
  return DeviceStorage();
});

class DeviceStorage {
  static const String _boxName = AppConstants.boxDevices;

  // 使用通用的 HiveJsonStorage
  late final HiveJsonStorage<DeviceModel> _storage = HiveJsonStorage(
    boxName: _boxName,
    fromJson: DeviceModel.fromJson,
    toJson: (model) => model.toJson(),
  );

  /// 生成防区专属缓存 key
  String _areaKey(int areaId) => 'devices_$areaId';

  /// 保存设备列表（按防区）
  Future<void> saveDevices(List<DeviceModel> devices, int areaId) async {
    AppLogger.d('💾 [DeviceStorage.saveDevices] 保存防区 $areaId 的 ${devices.length} 个设备', tag: LogTag.storage);
    await _storage.saveList(_areaKey(areaId), devices);
  }

  /// 获取缓存的设备列表（按防区）
  Future<List<DeviceModel>?> getDevices(int areaId) async {
    AppLogger.d('📖 [DeviceStorage.getDevices] 读取防区 $areaId 的缓存', tag: LogTag.storage);
    return await _storage.getList(_areaKey(areaId));
  }

  /// 同步获取设备列表（用于 main() 预加载）
  ///
  /// 注意：Box 必须已经在外部打开
  List<DeviceModel>? getDevicesSync(int areaId) {
    AppLogger.d('📖 [DeviceStorage.getDevicesSync] 同步读取防区 $areaId 的缓存', tag: LogTag.storage);
    return _storage.getListSync(_areaKey(areaId));
  }

  /// 清除所有缓存
  Future<void> clearAll() async {
    await _storage.clearAll();
  }
}
