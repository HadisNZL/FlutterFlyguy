import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/camera/camera_player.dart';
import '../../../core/camera/camera_player_factory.dart';
import '../../../core/utils/app_logger.dart';
import '../../../models/device/device_model.dart';

part 'camera_live_provider.g.dart';

/// 摄像头直播页面 Provider
///
/// 管理播放器生命周期、状态、错误处理
@riverpod
class CameraLive extends _$CameraLive {
  CameraPlayer? _player;
  DeviceModel? _device;

  @override
  FutureOr<void> build() async {
    // 监听 Provider 被销毁时释放资源
    ref.onDispose(() {
      AppLogger.i('CameraLive Provider 被销毁，释放播放器资源', tag: LogTag.api);
      _player?.dispose();
    });
  }

  /// 初始化播放器
  ///
  /// [device] 设备信息
  Future<void> initialize(DeviceModel device) async {
    try {
      state = const AsyncValue.loading();
      _device = device;

      AppLogger.i(
        '初始化摄像头播放器: ${device.location} (${device.oem}), P2P ID: ${device.p2pId ?? "NULL"}',
        tag: LogTag.api,
      );

      // 通过工厂创建对应厂商的播放器
      _player = CameraPlayerFactory.createPlayer(device);

      // 初始化播放器
      await _player!.initialize(
        deviceId: device.oemDeviceId,
        p2pId: device.p2pId,
        p2pInitString: device.p2pInitString,
        channelNo: device.channelNo ?? 0,
      );

      // 开始播放
      await _player!.play();

      state = const AsyncValue.data(null);
      AppLogger.i('摄像头播放器初始化成功', tag: LogTag.api);
    } catch (e, s) {
      AppLogger.e('摄像头播放器初始化失败', tag: LogTag.api, error: e);
      state = AsyncValue.error(e, s);
    }
  }

  /// 播放
  Future<void> play() async {
    try {
      await _player?.play();
    } catch (e) {
      AppLogger.e('播放失败', tag: LogTag.api, error: e);
    }
  }

  /// 暂停
  Future<void> pause() async {
    try {
      await _player?.pause();
    } catch (e) {
      AppLogger.e('暂停失败', tag: LogTag.api, error: e);
    }
  }

  /// 截图
  Future<String?> takeSnapshot() async {
    try {
      return await _player?.takeSnapshot();
    } catch (e) {
      AppLogger.e('截图失败', tag: LogTag.api, error: e);
      return null;
    }
  }

  /// 切换清晰度
  ///
  /// [quality] 清晰度等级（'low' | 'medium' | 'high'）
  Future<void> switchQuality(String quality) async {
    try {
      await _player?.switchQuality(quality);
    } catch (e) {
      AppLogger.e('切换清晰度失败', tag: LogTag.api, error: e);
    }
  }

  /// 获取当前设备信息
  DeviceModel? get device => _device;

  /// 获取原生视图类型（用于 PlatformView）
  String get platformViewType {
    if (_device == null) return '';

    final oem = _device!.oem?.toLowerCase().trim() ?? '';
    return 'camera_view_$oem';
  }

  /// 构建原生视图
  Widget buildPlatformView(BuildContext context) {
    if (_device == null) {
      return const Center(child: Text('设备信息为空'));
    }

    final viewType = platformViewType;

    if (Platform.isAndroid) {
      return AndroidView(
        viewType: viewType,
        creationParams: {
          'deviceId': _device!.oemDeviceId,
          'channelNo': _device!.channelNo ?? 0,
          'p2pId': _device!.p2pId,
          'p2pInitString': _device!.p2pInitString,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else if (Platform.isIOS) {
      return UiKitView(
        viewType: viewType,
        creationParams: {
          'deviceId': _device!.oemDeviceId,
          'channelNo': _device!.channelNo ?? 0,
          'p2pId': _device!.p2pId,
          'p2pInitString': _device!.p2pInitString,
        },
        creationParamsCodec: const StandardMessageCodec(),
      );
    } else {
      return const Center(child: Text('不支持的平台'));
    }
  }
}
