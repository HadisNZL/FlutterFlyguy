import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/device/device_model.dart';

/// 全局设备数据内存状态
/// 按防区 ID 存储设备列表，常驻内存，供 UI 同步读取
///
/// 职责：
/// - 存储当前所有已加载防区的设备数据
/// - 提供同步访问，无延迟
/// - 由 MainPage 启动时预加载、切换防区时更新
final inMemoryDevicesProvider =
    StateProvider<Map<int, List<DeviceModel>>>((ref) => {});
