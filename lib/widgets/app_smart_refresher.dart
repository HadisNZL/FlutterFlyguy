import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../core/constants/colors.dart';

/// 通用的智能刷新组件
///
/// 封装 pull_to_refresh，提供统一的下拉刷新体验
///
/// 特性：
/// - 支持下拉刷新
/// - 支持上拉加载更多（可选）
/// - 统一的品牌样式
/// - 自动管理加载状态
///
/// 使用示例：
/// ```dart
/// AppSmartRefresher(
///   onRefresh: () async {
///     await loadData();
///   },
///   child: ListView(...),
/// )
/// ```
class AppSmartRefresher extends StatefulWidget {
  const AppSmartRefresher({
    required this.child,
    required this.onRefresh,
    this.onLoading,
    this.enablePullDown = true,
    this.enablePullUp = false,
    this.controller,
    super.key,
  });

  /// 子组件（必须是可滚动的 Widget，如 ListView、GridView）
  final Widget child;

  /// 下拉刷新回调（必填）
  final Future<void> Function() onRefresh;

  /// 上拉加载回调（可选，enablePullUp 为 true 时必填）
  final Future<void> Function()? onLoading;

  /// 是否启用下拉刷新（默认 true）
  final bool enablePullDown;

  /// 是否启用上拉加载（默认 false）
  final bool enablePullUp;

  /// 刷新控制器（可选，不传则自动创建）
  final RefreshController? controller;

  @override
  State<AppSmartRefresher> createState() => _AppSmartRefresherState();
}

class _AppSmartRefresherState extends State<AppSmartRefresher> {
  late RefreshController _controller;
  bool _isInternalController = false;

  @override
  void initState() {
    super.initState();
    // 如果外部没有传 controller，创建内部 controller
    if (widget.controller == null) {
      _controller = RefreshController();
      _isInternalController = true;
    } else {
      _controller = widget.controller!;
    }
  }

  @override
  void dispose() {
    // 只释放内部创建的 controller
    if (_isInternalController) {
      _controller.dispose();
    }
    super.dispose();
  }

  /// 处理下拉刷新
  Future<void> _onRefresh() async {
    try {
      await widget.onRefresh();
      _controller.refreshCompleted();
    } catch (e) {
      _controller.refreshFailed();
    }
  }

  /// 处理上拉加载
  Future<void> _onLoading() async {
    if (widget.onLoading == null) {
      _controller.loadComplete();
      return;
    }

    try {
      await widget.onLoading!();
      _controller.loadComplete();
    } catch (e) {
      _controller.loadFailed();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SmartRefresher(
      controller: _controller,
      enablePullDown: widget.enablePullDown,
      enablePullUp: widget.enablePullUp,
      onRefresh: widget.enablePullDown ? _onRefresh : null,
      onLoading: widget.enablePullUp ? _onLoading : null,
      // 自定义下拉刷新头部
      header: CustomHeader(
        height: 80,
        builder: (context, mode) {
          return _buildRefreshHeader(mode ?? RefreshStatus.idle);
        },
      ),
      // 上拉加载底部（统一品牌样式）
      footer: CustomFooter(
        builder: (context, mode) {
          Widget body;
          if (mode == LoadStatus.idle) {
            body = const Text(
              '上拉加载更多',
              style: TextStyle(color: AppColors.color999999, fontSize: 14),
            );
          } else if (mode == LoadStatus.loading) {
            body = const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.colorTheme,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  '加载中...',
                  style: TextStyle(color: AppColors.color999999, fontSize: 14),
                ),
              ],
            );
          } else if (mode == LoadStatus.failed) {
            body = const Text(
              '加载失败，点击重试',
              style: TextStyle(color: AppColors.color999999, fontSize: 14),
            );
          } else if (mode == LoadStatus.canLoading) {
            body = const Text(
              '松开加载更多',
              style: TextStyle(color: AppColors.color999999, fontSize: 14),
            );
          } else {
            body = const Text(
              '没有更多数据了',
              style: TextStyle(color: AppColors.color999999, fontSize: 14),
            );
          }
          return SizedBox(height: 55.0, child: Center(child: body));
        },
      ),
      child: widget.child,
    );
  }

  /// 构建自定义下拉刷新头部
  Widget _buildRefreshHeader(RefreshStatus mode) {
    String text;
    Widget icon;
    Color textColor = AppColors.colorTheme;

    switch (mode) {
      case RefreshStatus.idle:
        text = "下拉刷新设备列表";
        icon = const Icon(
          Icons.arrow_downward_rounded,
          color: AppColors.colorTheme,
          size: 20,
        );
        break;

      case RefreshStatus.canRefresh:
        text = "松开立即刷新";
        icon = const Icon(
          Icons.arrow_upward_rounded,
          color: AppColors.colorTheme,
          size: 20,
        );
        break;

      case RefreshStatus.refreshing:
        text = "正在刷新设备...";
        icon = const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorTheme),
          ),
        );
        break;

      case RefreshStatus.completed:
        text = "刷新成功";
        textColor = AppColors.colorTheme;
        icon = const Icon(
          Icons.check_circle_rounded,
          color: AppColors.colorTheme,
          size: 20,
        );
        break;

      case RefreshStatus.failed:
        text = "刷新失败，请重试";
        textColor = Colors.red;
        icon = const Icon(Icons.error_rounded, color: Colors.red, size: 20);
        break;

      default:
        text = "下拉刷新";
        icon = const Icon(
          Icons.refresh_rounded,
          color: AppColors.colorTheme,
          size: 20,
        );
    }

    return Container(
      height: 80,
      color: Colors.white,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 图标
          icon,
          const SizedBox(height: 8),
          // 文字提示
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
