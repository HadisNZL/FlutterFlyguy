import '../camera_player.dart';

/// Ezviz（萤石）摄像头播放器实现
///
/// 暂未实现，预留接口
class EzvizCameraPlayer implements CameraPlayer {
  @override
  Future<void> initialize({
    required String deviceId,
    String? p2pId,
    String? p2pInitString,
    int channelNo = 0,
  }) async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<void> play() async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<void> pause() async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<void> dispose() async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<String?> takeSnapshot() async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<void> switchQuality(String quality) async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<String?> startRecording() async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<void> stopRecording() async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<void> startTalk() async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<void> stopTalk() async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }

  @override
  Future<void> ptzControl({
    required String direction,
    required String action,
  }) async {
    throw UnimplementedError('Ezviz 播放器暂未实现');
  }
}
