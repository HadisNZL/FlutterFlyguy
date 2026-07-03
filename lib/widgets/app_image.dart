import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/colors.dart';
import '../core/storage/token_storage.dart';
import '../core/utils/app_logger.dart';

/// 图片类型枚举
enum _ImageType { network, asset }

/// 商业级图片加载组件
class AppImage extends ConsumerWidget {
  factory AppImage.camera({
    required String? imageUrl,
    Widget? placeholder,
    Widget? errorWidget,
    Key? key,
  }) {
    return AppImage._(
      imageUrl: imageUrl,
      imageType: _ImageType.network,
      aspectRatio: 16 / 9,
      fit: BoxFit.cover,
      placeholder: placeholder,
      errorWidget: errorWidget,
      memCacheWidth: 1920,
      needsToken: true,
      key: key,
    );
  }

  factory AppImage.asset(
    String assetPath, {
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Key? key,
  }) {
    return AppImage._(
      imageUrl: assetPath,
      imageType: _ImageType.asset,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      shape: shape,
      key: key,
    );
  }

  factory AppImage.networkWithoutToken({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Widget? placeholder,
    Widget? errorWidget,
    int? memCacheWidth,
    int? memCacheHeight,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    Key? key,
  }) {
    return AppImage._(
      imageUrl: imageUrl,
      imageType: _ImageType.network,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      shape: shape,
      placeholder: placeholder,
      errorWidget: errorWidget,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: fadeInDuration,
      needsToken: false,
      key: key,
    );
  }

  factory AppImage.network({
    required String? imageUrl,
    double? width,
    double? height,
    BoxFit fit = BoxFit.cover,
    BorderRadius? borderRadius,
    BoxShape shape = BoxShape.rectangle,
    Widget? placeholder,
    Widget? errorWidget,
    int? memCacheWidth,
    int? memCacheHeight,
    Duration fadeInDuration = const Duration(milliseconds: 300),
    Key? key,
  }) {
    return AppImage._(
      imageUrl: imageUrl,
      imageType: _ImageType.network,
      width: width,
      height: height,
      fit: fit,
      borderRadius: borderRadius,
      shape: shape,
      placeholder: placeholder,
      errorWidget: errorWidget,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: fadeInDuration,
      needsToken: true,
      key: key,
    );
  }
  const AppImage._({
    required this.imageUrl,
    required this.imageType,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.shape = BoxShape.rectangle,
    this.aspectRatio,
    this.placeholder,
    this.errorWidget,
    this.memCacheWidth,
    this.memCacheHeight,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.needsToken = false,
    super.key,
  });

  final String? imageUrl;
  final _ImageType imageType;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final BoxShape shape;
  final double? aspectRatio;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? memCacheWidth;
  final int? memCacheHeight;
  final Duration fadeInDuration;
  final bool needsToken;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget imageWidget;

    switch (imageType) {
      case _ImageType.network:
        imageWidget = _buildNetworkImage(ref);
        break;
      case _ImageType.asset:
        imageWidget = _buildAssetImage();
        break;
    }

    if (aspectRatio != null) {
      imageWidget = AspectRatio(aspectRatio: aspectRatio!, child: imageWidget);
    }

    if (borderRadius != null || shape == BoxShape.circle) {
      imageWidget = ClipRRect(
        borderRadius: shape == BoxShape.circle
            ? BorderRadius.circular(1000)
            : (borderRadius ?? BorderRadius.zero),
        child: imageWidget,
      );
    }

    if (width != null || height != null) {
      imageWidget = SizedBox(width: width, height: height, child: imageWidget);
    }

    return imageWidget;
  }

  Widget _buildNetworkImage(WidgetRef ref) {
    if (imageUrl == null || imageUrl!.isEmpty) {
      AppLogger.w('图片地址为空', tag: LogTag.ui);
      return errorWidget ?? _buildDefaultErrorWidget();
    }

    // 同步获取 headers（不再使用 FutureBuilder）
    final headers = _getHttpHeadersSync(ref);

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      httpHeaders: headers,
      fit: fit,
      width: width,
      height: height,
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: Duration.zero,  // 旧图消失无过渡，减少闪烁
      placeholder: (context, url) {
        // 使用灰色背景替代白色，视觉过渡更柔和
        return placeholder ??
            Container(
              color: Colors.grey[300],
              child: const Center(
                child: SizedBox(
                  width: 30,
                  height: 30,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.colorTheme,
                    ),
                  ),
                ),
              ),
            );
      },
      errorWidget: (context, url, error) {
        AppLogger.e('图片加载失败: $url', tag: LogTag.ui, error: error);
        return errorWidget ?? _buildDefaultErrorWidget();
      },
    );
  }

  Widget _buildAssetImage() {
    if (imageUrl == null || imageUrl!.isEmpty) {
      AppLogger.w('资源路径为空', tag: LogTag.ui);
      return errorWidget ?? _buildDefaultErrorWidget();
    }

    return Image.asset(
      imageUrl!,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        AppLogger.e('资源图片加载失败: $imageUrl', tag: LogTag.ui, error: error);
        return errorWidget ?? _buildDefaultErrorWidget();
      },
    );
  }

  /// 同步获取 HTTP headers（包含 token）
  ///
  /// 注意：token box 必须已在 main() 中打开
  Map<String, String> _getHttpHeadersSync(WidgetRef ref) {
    if (!needsToken) {
      return {};
    }

    try {
      final token = ref.read(tokenStorageProvider).getTokenSync();
      if (token == null || token.accessToken.isEmpty) {
        AppLogger.w('Token 为空，图片加载将不添加认证头', tag: LogTag.ui);
        return {};
      }

      return {
        'Authorization': 'Bearer ${token.accessToken}',
      };
    } catch (e) {
      AppLogger.e('同步获取 token 失败', tag: LogTag.ui, error: e);
      return {};
    }
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: SizedBox(
          width: 30,
          height: 30,
          child: CircularProgressIndicator(
            strokeWidth: 2.5,
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.colorTheme),
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: AppColors.color999999,
          size: 60,
        ),
      ),
    );
  }
}
