import 'package:flutter/services.dart';

import '../../../core/utils/app_logger.dart';
import '../camera_player.dart';

/// Aspen 摄像头播放器实现
///
/// 通信方式：
/// 1. MethodChannel: Flutter 调用 Android 的控制方法
/// 2. EventChannel: 监听 Android 推送的播放器状态事件
class AspenCameraPlayer implements CameraPlayer {
  // ═══════════════════════════════════════════════════════════════
  // MethodChannel - Flutter 调用 Android
  // ═══════════════════════════════════════════════════════════════
  static const MethodChannel _methodChannel = MethodChannel('camera/aspen');

  // ═══════════════════════════════════════════════════════════════
  // EventChannel - Android 推送事件到 Flutter
  // ═══════════════════════════════════════════════════════════════
  static const EventChannel _eventChannel = EventChannel('camera/aspen/events');

  Stream<PlayerEvent>? _eventStream;

  // ═══════════════════════════════════════════════════════════════
  // EventChannel - 暴露事件流供外部监听
  // ═══════════════════════════════════════════════════════════════

  /// 播放器事件流
  ///
  /// 监听播放器状态变化：
  /// - P2P 连接状态
  /// - 播放器连接状态
  /// - 视频准备好
  /// - 错误通知
  Stream<PlayerEvent> get events {
    _eventStream ??= _eventChannel
        .receiveBroadcastStream()
        .map((data) {
          if (data is Map) {
            return PlayerEvent.fromMap(Map<String, dynamic>.from(data));
          }
          throw Exception('Invalid event data: $data');
        })
        .handleError((error) {
          // 处理 EventChannel 的错误
          if (error is PlatformException) {
            AppLogger.e(
              'EventChannel 错误: ${error.code} - ${error.message}',
              tag: LogTag.api,
            );
            throw PlayerException(
              code: error.code,
              message: error.message ?? '播放器错误',
              details: error.details,
            );
          }
          throw error;
        });

    return _eventStream!;
  }

  // ═══════════════════════════════════════════════════════════════
  // MethodChannel - 控制方法实现
  // ═══════════════════════════════════════════════════════════════

  @override
  Future<void> initialize({
    required String deviceId,
    String? p2pId,
    String? p2pInitString,
    int channelNo = 0,
  }) async {
    try {
      AppLogger.i(
        'Aspen 初始化播放器: deviceId=$deviceId, channelNo=$channelNo,p2pId=$p2pId',
        tag: LogTag.api,
      );

      await _methodChannel.invokeMethod('initialize', {
        'deviceId': deviceId,
        'p2pId': p2pId,
        'p2pInitString': p2pInitString,
        'channelNo': channelNo,
      });

      AppLogger.i('Aspen 初始化成功', tag: LogTag.api);
    } catch (e) {
      AppLogger.e('Aspen 初始化失败', tag: LogTag.api, error: e);
      rethrow;
    }
  }

  @override
  Future<void> play() async {
    try {
      AppLogger.d('Aspen 开始播放', tag: LogTag.api);
      await _methodChannel.invokeMethod('play');
    } catch (e) {
      AppLogger.e('Aspen 播放失败', tag: LogTag.api, error: e);
      rethrow;
    }
  }

  @override
  Future<void> pause() async {
    try {
      AppLogger.d('Aspen 暂停播放', tag: LogTag.api);
      await _methodChannel.invokeMethod('pause');
    } catch (e) {
      AppLogger.e('Aspen 暂停失败', tag: LogTag.api, error: e);
      rethrow;
    }
  }

  @override
  Future<void> dispose() async {
    try {
      AppLogger.i('Aspen 释放播放器资源', tag: LogTag.api);
      await _methodChannel.invokeMethod('dispose');
    } catch (e) {
      AppLogger.e('Aspen 释放资源失败', tag: LogTag.api, error: e);
      rethrow;
    }
  }

  @override
  Future<String?> takeSnapshot() async {
    try {
      AppLogger.d('Aspen 截图', tag: LogTag.api);
      final String? path = await _methodChannel.invokeMethod('takeSnapshot');
      if (path != null) {
        AppLogger.i('Aspen 截图成功: $path', tag: LogTag.api);
      }
      return path;
    } catch (e) {
      AppLogger.e('Aspen 截图失败', tag: LogTag.api, error: e);
      return null;
    }
  }

  @override
  Future<void> switchQuality(String quality) async {
    try {
      AppLogger.d('Aspen 切换清晰度: $quality', tag: LogTag.api);
      await _methodChannel.invokeMethod('switchQuality', {'quality': quality});
    } catch (e) {
      AppLogger.e('Aspen 切换清晰度失败', tag: LogTag.api, error: e);
      rethrow;
    }
  }

  // ==================== 预留功能（暂不实现）====================

  @override
  Future<String?> startRecording() async {
    throw UnimplementedError('Aspen 录像功能暂未实现');
  }

  @override
  Future<void> stopRecording() async {
    throw UnimplementedError('Aspen 录像功能暂未实现');
  }

  @override
  Future<void> startTalk() async {
    throw UnimplementedError('Aspen 对讲功能暂未实现');
  }

  @override
  Future<void> stopTalk() async {
    throw UnimplementedError('Aspen 对讲功能暂未实现');
  }

  @override
  Future<void> ptzControl({
    required String direction,
    required String action,
  }) async {
    throw UnimplementedError('Aspen 云台控制功能暂未实现');
  }
}

// ═══════════════════════════════════════════════════════════════
// 播放器事件模型
// ═══════════════════════════════════════════════════════════════

/// 播放器事件
class PlayerEvent {
  PlayerEvent({required this.type, required this.event, this.data});

  factory PlayerEvent.fromMap(Map<String, dynamic> map) {
    return PlayerEvent(
      type: map['type'] as String,
      event: map['event'] as String,
      data: map['data'] as Map<String, dynamic>?,
    );
  }

  /// 事件类型：'p2p' 或 'player'
  final String type;

  /// 事件名称：'connected', 'video_ready' 等
  final String event;

  /// 附加数据（可选）
  final Map<String, dynamic>? data;

  // ─────────────────────────────────────────────────────────
  // 便捷判断方法
  // ─────────────────────────────────────────────────────────

  /// P2P 连接成功
  bool get isP2PConnected => type == 'p2p' && event == 'connected';

  /// 播放器连接中
  bool get isPlayerConnecting => type == 'player' && event == 'connecting';

  /// 播放器连接成功
  bool get isPlayerConnected => type == 'player' && event == 'connected';

  /// 视频准备好（可以显示画面）
  bool get isVideoReady => type == 'player' && event == 'video_ready';

  @override
  String toString() => 'PlayerEvent(type: $type, event: $event, data: $data)';
}

/// 播放器异常
class PlayerException implements Exception {
  PlayerException({required this.code, required this.message, this.details});
  final String code;
  final String message;
  final dynamic details;

  @override
  String toString() => 'PlayerException($code: $message)';
}
