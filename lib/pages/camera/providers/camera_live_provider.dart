import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/camera/camera_player.dart';
import '../../../core/camera/camera_player_factory.dart';
import '../../../core/camera/impl/aspen_camera_player.dart';
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

  // ═══════════════════════════════════════════════════════════════
  // EventChannel 相关
  // ═══════════════════════════════════════════════════════════════
  StreamSubscription<PlayerEvent>? _eventSubscription;

  /// 视频是否准备好（用于控制封面图显示）
  bool _isVideoReady = false;
  bool get isVideoReady => _isVideoReady;

  @override
  FutureOr<void> build() async {
    // 监听 Provider 被销毁时释放资源
    ref.onDispose(() {
      AppLogger.i('CameraLive Provider 被销毁，释放播放器资源', tag: LogTag.api);
      _eventSubscription?.cancel();  // 取消事件订阅
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
      _isVideoReady = false; // 重置状态

      AppLogger.i(
        '初始化摄像头播放器: ${device.location} (${device.oem}), P2P ID: ${device.p2pId ?? "NULL"}',
        tag: LogTag.api,
      );

      // 通过工厂创建对应厂商的播放器
      _player = CameraPlayerFactory.createPlayer(device);

      // ═══════════════════════════════════════════════════════════════
      // 开始监听播放器事件（EventChannel）
      // ═══════════════════════════════════════════════════════════════
      _startListeningToEvents();

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

  /// 开始监听播放器事件
  void _startListeningToEvents() {
    // 取消之前的订阅（如果有）
    _eventSubscription?.cancel();

    // 订阅事件流
    _eventSubscription = (_player as AspenCameraPlayer).events.listen(
      (event) {
        _handlePlayerEvent(event);
      },
      onError: (error) {
        _handlePlayerError(error);
      },
    );

    AppLogger.d('开始监听播放器事件', tag: LogTag.api);
  }

  /// 处理播放器事件
  void _handlePlayerEvent(PlayerEvent event) {
    AppLogger.d('收到播放器事件: $event', tag: LogTag.api);

    if (event.isP2PConnected) {
      // P2P 连接成功
      AppLogger.i('✅ P2P 已连接', tag: LogTag.api);

    } else if (event.isPlayerConnecting) {
      // 播放器连接中
      AppLogger.i('🔄 播放器连接中...', tag: LogTag.api);

    } else if (event.isPlayerConnected) {
      // 播放器连接成功
      AppLogger.i('✅ 播放器已连接', tag: LogTag.api);

    } else if (event.isVideoReady) {
      // 视频准备好了！可以隐藏封面图
      AppLogger.i('🎬 视频已准备好，可以显示画面', tag: LogTag.api);
      _isVideoReady = true;
      ref.notifyListeners(); // 通知 UI 更新
    }
  }

  /// 处理播放器错误
  void _handlePlayerError(dynamic error) {
    if (error is PlayerException) {
      AppLogger.e(
        '播放器错误: ${error.code} - ${error.message}',
        tag: LogTag.api,
      );

      // 根据错误类型处理
      switch (error.code) {
        case 'P2P_TIMEOUT':
          state = AsyncValue.error('P2P 连接超时，请检查网络', StackTrace.current);
          break;
        case 'CONNECT_FAILED':
          state = AsyncValue.error('连接设备失败，请重试', StackTrace.current);
          break;
        case 'P2P_INVALID_ID':
          state = AsyncValue.error('设备 ID 无效', StackTrace.current);
          break;
        default:
          state = AsyncValue.error(error.message, StackTrace.current);
      }
    } else {
      AppLogger.e('播放器未知错误', tag: LogTag.api, error: error);
      state = AsyncValue.error(error.toString(), StackTrace.current);
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
