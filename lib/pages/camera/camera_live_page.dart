import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/app_logger.dart';
import '../../models/device/device_model.dart';
import '../../widgets/app_image.dart';
import '../../widgets/center_expand_loading_bar.dart';
import 'providers/camera_live_provider.dart';

/// 摄像头直播页面
///
/// 顶部 16:9 视频区域 + 底部控制按钮（录像、对讲、云台等暂时禁用）
class CameraLivePage extends ConsumerStatefulWidget {
  const CameraLivePage({required this.device, super.key});
  final DeviceModel device;

  @override
  ConsumerState<CameraLivePage> createState() => _CameraLivePageState();
}

class _CameraLivePageState extends ConsumerState<CameraLivePage>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // 验证设备信息
    if (widget.device.oem == null || widget.device.oem!.isEmpty) {
      AppLogger.e('设备缺少厂商信息（OEM 字段为空）', tag: LogTag.ui);
      return;
    }

    // 初始化播放器
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(cameraLiveProvider.notifier).initialize(widget.device);
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(const Duration(milliseconds: 350), () {
        ref.read(cameraLiveProvider.notifier).initialize(widget.device);
      });
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // 生命周期管理：后台暂停，前台恢复
    switch (state) {
      case AppLifecycleState.paused:
        AppLogger.d('App 进入后台，暂停播放', tag: LogTag.ui);
        ref.read(cameraLiveProvider.notifier).pause();
        break;
      case AppLifecycleState.resumed:
        AppLogger.d('App 恢复前台，继续播放', tag: LogTag.ui);
        ref.read(cameraLiveProvider.notifier).play();
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(cameraLiveProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.device.location),
        actions: [
          // 截图按钮
          IconButton(
            icon: const Icon(Icons.camera_alt),
            onPressed: state.isLoading ? null : _handleSnapshot,
          ),
          // 清晰度切换按钮
          PopupMenuButton<String>(
            enabled: !state.isLoading,
            icon: const Icon(Icons.settings),
            onSelected: _handleQualityChange,
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'low', child: Text('标清')),
              const PopupMenuItem(value: 'medium', child: Text('高清')),
              const PopupMenuItem(value: 'high', child: Text('超清')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // 16:9 视频区域
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Container(
              color: Colors.black,
              child: _buildVideoView(state),
            ),
          ),

          // 底部控制区域（暂时禁用）
          Expanded(child: _buildControlPanel()),
        ],
      ),
    );
  }

  /// 构建视频视图
  Widget _buildVideoView(AsyncValue<void> state) {
    // 检查设备厂商信息
    if (widget.device.oem == null || widget.device.oem!.isEmpty) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 48),
            SizedBox(height: 16),
            Text(
              '设备缺少厂商信息\n无法播放视频',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white),
            ),
          ],
        ),
      );
    }

    return state.when(
      data: (_) {
        // 播放中：显示原生视图 + 封面图遮罩
        final liveNotifier = ref.read(cameraLiveProvider.notifier);
        final isVideoReady = liveNotifier.isVideoReady;

        return Stack(
          fit: StackFit.expand,
          children: [
            // 底层：实时视频（原生视图）
            liveNotifier.buildPlatformView(context),

            // 顶层：封面图遮罩（带淡入淡出动画）
            AnimatedOpacity(
              opacity: isVideoReady ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 300),
              child: _buildCoverImage(),
            ),
          ],
        );
      },
      loading: () {
        // 加载中：显示封面图 + Loading
        return _buildCoverImage();
      },
      error: (error, stack) {
        // 错误状态
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text(
                '连接失败\n${error.toString()}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  ref
                      .read(cameraLiveProvider.notifier)
                      .initialize(widget.device);
                },
                child: const Text('重试'),
              ),
            ],
          ),
        );
      },
    );
  }

  /// 构建封面图
  Widget _buildCoverImage() {
    // 获取设备截图（使用 picName 构建 URL）
    final picInfo = widget.device.picInfoModel;
    final snapshotUrl = picInfo?.picName;

    return Stack(
      fit: StackFit.expand,
      children: [
        // 封面图（使用 AppImage 加载）
        AppImage.camera(
          imageUrl: snapshotUrl,
          placeholder: _buildPlaceholderImage(),
          errorWidget: _buildPlaceholderImage(),
        ),

        // 半透明遮罩
        Container(color: Colors.black.withValues(alpha: 0.3)),

        // 底部 Loading 条
        const Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: CenterExpandLoadingBar(),
        ),
      ],
    );
  }

  /// 构建占位图
  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.black87,
      child: const Center(
        child: Icon(Icons.videocam_off, size: 64, color: Colors.white54),
      ),
    );
  }

  /// 构建控制面板
  Widget _buildControlPanel() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Text(
            '控制面板',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // 录像、对讲按钮（暂时禁用）
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.videocam,
                label: '录像',
                enabled: false, // 暂时禁用
                onPressed: () {},
              ),
              _buildControlButton(
                icon: Icons.mic,
                label: '对讲',
                enabled: false, // 暂时禁用
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 24),

          // 云台控制（暂时禁用）
          const Text('云台控制（暂未开放）'),
          const SizedBox(height: 16),
          _buildPtzPanel(enabled: false),
        ],
      ),
    );
  }

  /// 构建控制按钮
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool enabled,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          iconSize: 48,
          icon: Icon(icon),
          onPressed: enabled ? onPressed : null,
          color: enabled ? Theme.of(context).primaryColor : Colors.grey,
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: enabled ? Colors.black87 : Colors.grey),
        ),
      ],
    );
  }

  /// 构建云台控制面板
  Widget _buildPtzPanel({required bool enabled}) {
    return Container(
      width: 200,
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // 上
          Positioned(
            top: 0,
            left: 75,
            child: IconButton(
              icon: const Icon(Icons.arrow_upward),
              onPressed: enabled ? () {} : null,
            ),
          ),
          // 下
          Positioned(
            bottom: 0,
            left: 75,
            child: IconButton(
              icon: const Icon(Icons.arrow_downward),
              onPressed: enabled ? () {} : null,
            ),
          ),
          // 左
          Positioned(
            left: 0,
            top: 75,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: enabled ? () {} : null,
            ),
          ),
          // 右
          Positioned(
            right: 0,
            top: 75,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward),
              onPressed: enabled ? () {} : null,
            ),
          ),
          // 中心
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.grey.shade300,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 处理截图
  Future<void> _handleSnapshot() async {
    final path = await ref.read(cameraLiveProvider.notifier).takeSnapshot();
    if (path != null && mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('截图已保存: $path')));
    } else if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('截图失败')));
    }
  }

  /// 处理清晰度切换
  Future<void> _handleQualityChange(String quality) async {
    await ref.read(cameraLiveProvider.notifier).switchQuality(quality);
    if (mounted) {
      final qualityText = {'low': '标清', 'medium': '高清', 'high': '超清'}[quality];
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('已切换至$qualityText')));
    }
  }
}
