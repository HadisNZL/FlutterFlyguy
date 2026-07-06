import '../../models/device/device_model.dart';
import 'camera_player.dart';
import 'impl/aspen_camera_player.dart';
import 'impl/ezviz_camera_player.dart';
import 'impl/hualai_camera_player.dart';

/// 摄像头播放器工厂
///
/// 根据设备的 OEM 字段创建对应厂商的播放器实例
class CameraPlayerFactory {
  CameraPlayerFactory._();

  /// 厂商标识常量
  static const String vendorAspen = 'aspen';
  static const String vendorEzviz = 'ezviz';
  static const String vendorHualai = 'hualai';

  /// 创建播放器实例
  ///
  /// [device] 设备信息，通过 device.oem 字段判断厂商
  ///
  /// 抛出 [UnsupportedError] 如果设备厂商不支持或为空
  static CameraPlayer createPlayer(DeviceModel device) {
    final oem = device.oem?.toLowerCase().trim();

    if (oem == null || oem.isEmpty) {
      throw UnsupportedError(
        '设备 ${device.location} 缺少厂商信息（OEM 字段为空）',
      );
    }

    switch (oem) {
      case vendorAspen:
        return AspenCameraPlayer();

      case vendorEzviz:
        return EzvizCameraPlayer();

      case vendorHualai:
        return HualaiCameraPlayer();

      default:
        throw UnsupportedError(
          '不支持的摄像头厂商: $oem（设备: ${device.location}）',
        );
    }
  }
}
