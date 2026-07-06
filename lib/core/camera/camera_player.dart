/// 摄像头播放器统一抽象接口
///
/// 定义所有厂商摄像头播放器必须实现的通用方法
/// 通过工厂模式创建具体厂商的播放器实例
///
/// 支持的厂商：
/// - Aspen
/// - Ezviz（萤石）
/// - Hualai（华来）
abstract class CameraPlayer {
  /// 初始化播放器
  ///
  /// [deviceId] 设备 ID
  /// [p2pId] P2P 连接 ID（部分厂商需要）
  /// [p2pInitString] P2P 初始化字符串（部分厂商需要）
  /// [channelNo] 通道号（多通道设备需要，默认 0）
  Future<void> initialize({
    required String deviceId,
    String? p2pId,
    String? p2pInitString,
    int channelNo = 0,
  });

  /// 开始播放
  Future<void> play();

  /// 暂停播放
  Future<void> pause();

  /// 停止播放并释放资源
  Future<void> dispose();

  /// 截图
  ///
  /// 返回图片保存的本地路径，失败返回 null
  Future<String?> takeSnapshot();

  /// 切换清晰度
  ///
  /// [quality] 清晰度等级（'low' | 'medium' | 'high'）
  Future<void> switchQuality(String quality);

  // ==================== 以下功能预留，暂不实现 ====================

  /// 开始录像（预留）
  ///
  /// 返回录像文件保存路径
  Future<String?> startRecording() async {
    throw UnimplementedError('录像功能暂未实现');
  }

  /// 停止录像（预留）
  Future<void> stopRecording() async {
    throw UnimplementedError('录像功能暂未实现');
  }

  /// 开始对讲（预留）
  Future<void> startTalk() async {
    throw UnimplementedError('对讲功能暂未实现');
  }

  /// 停止对讲（预留）
  Future<void> stopTalk() async {
    throw UnimplementedError('对讲功能暂未实现');
  }

  /// 云台控制（预留）
  ///
  /// [direction] 方向（'up' | 'down' | 'left' | 'right'）
  /// [action] 动作（'start' | 'stop'）
  Future<void> ptzControl({
    required String direction,
    required String action,
  }) async {
    throw UnimplementedError('云台控制功能暂未实现');
  }
}
