import 'package:flutter/material.dart';
import 'package:flyguy/core/constants/colors.dart';

/// 从中心向两边扩散的 Loading 条
///
/// 动画效果：
/// 1. 从中心点开始
/// 2. 向两边扩散
/// 3. 到达两端后消失
/// 4. 循环重复
class CenterExpandLoadingBar extends StatefulWidget {
  const CenterExpandLoadingBar({
    super.key,
    this.height = 2.5,
    this.color = AppColors.colorTheme,
    this.duration = const Duration(milliseconds: 800),
  });

  /// Loading 条高度
  final double height;

  /// Loading 条颜色
  final Color color;

  /// 一次扩散动画时长
  final Duration duration;

  @override
  State<CenterExpandLoadingBar> createState() => _CenterExpandLoadingBarState();
}

class _CenterExpandLoadingBarState extends State<CenterExpandLoadingBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    // 创建动画控制器
    _controller = AnimationController(vsync: this, duration: widget.duration)
      ..repeat(); // 无限循环
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _ExpandLinePainter(
              progress: _controller.value, // 0.0 - 1.0
              color: widget.color,
            ),
          );
        },
      ),
    );
  }
}

/// 绘制扩散线条
class _ExpandLinePainter extends CustomPainter {
  _ExpandLinePainter({required this.progress, required this.color});

  /// 动画进度 (0.0 - 1.0)
  final double progress;

  /// 线条颜色
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    // 中心点 X 坐标
    final centerX = size.width * 0.5;

    // 扩散宽度（从中心向两边）
    final expandWidth = size.width * 0.5 * progress;

    // 计算左右边界
    final leftX = centerX - expandWidth;
    final rightX = centerX + expandWidth;

    // 绘制矩形
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawRect(Rect.fromLTRB(leftX, 0, rightX, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant _ExpandLinePainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
