import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// 设备信息工具类
class DeviceInfoUtil {
  /// 获取设备ID
  static Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return ''; //androidInfo.id
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return ''; //iosInfo.identifierForVendor ?? 'unknown'
      }
    } catch (e) {
      return 'unknown';
    }

    return 'unknown';
  }

  /// 获取设备型号
  static Future<String> getDeviceModel() async {
    final deviceInfo = DeviceInfoPlugin();

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfo.androidInfo;
        return '${androidInfo.manufacturer}${androidInfo.model}';
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfo.iosInfo;
        return '${iosInfo.name}${iosInfo.model}';
      }
    } catch (e) {
      return 'unknown';
    }

    return 'unknown';
  }

  /// 获取应用版本号
  static Future<String> getAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      return 'v${packageInfo.version}(${packageInfo.buildNumber})';
    } catch (e) {
      return 'v1.0.0(1)';
    }
  }

  /// 获取系统语言
  static String getSystemLanguage() {
    final locale = Platform.localeName; // 如：zh_CN, en_US
    // 转换为后端需要的格式：zh-chs
    if (locale.startsWith('zh')) {
      return 'zh-chs';
    } else if (locale.startsWith('en')) {
      return 'en';
    }
    return 'zh-chs'; // 默认中文
  }
}
