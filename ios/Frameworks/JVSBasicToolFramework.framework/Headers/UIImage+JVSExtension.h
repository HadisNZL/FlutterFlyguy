//
//  UIImage+JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/12.
//

#import <UIKit/UIKit.h>
#import <JVSBasicToolFramework/JVSBasicToolDefines.h>

#define mGetImage(key)               [UIImage jvs_imageNamed:(key)]

NS_ASSUME_NONNULL_BEGIN

@interface UIImage (JVSExtension)

/// 先获取Assets中图片，其次获取项目png图片
/// name 带后缀 .png .jpg 则优先从项目获取图片资源
+(UIImage *)jvs_imageNamed:(NSString *)name;

/// 给图片设置透明度，然后返回一张新的图片
-(UIImage *)jvs_imageWithApplyingAlpha:(CGFloat)alpha;

/// 给图片设置圆角
- (UIImage*)jvs_imageByRoundCornerRadius;


/// 给图片设置圆角
/// - Parameters:
///   - cornerRadius: 圆角大小
///   - corner: 四个角
///   - newSize: 新大小尺寸
- (UIImage *)jvs_imageWithCornerRadius:(CGFloat)cornerRadius
                               corners:(UIRectCorner)corner
                                  size:(CGSize)newSize;

- (UIImage *)jvs_imageWithCornerRadius:(CGFloat)cornerRadius
                               corners:(UIRectCorner)corner;

/// 更新图片的大小，会按照图片的比例缩小和放大
/// - Parameter newSize: 新的尺寸
- (UIImage *)jvs_imageResizedToSize:(CGSize)newSize;

/// 根据颜色生成图片 1 X 1大小 的图片
/// - Parameter color: 图片的颜色
+(UIImage *)jvs_imageWithColor:(UIColor *)color;

/// 根据颜色生成图片 size大小 的图片
/// - Parameter color: 图片的颜色
/// - Parameter size: 图片的颜色
+(UIImage *)jvs_imageWithColor:(UIColor *)color size:(CGSize)size;

/// 居中拉伸
-(UIImage *)jvs_imageScaled;


/// 创建 渐变色图片
+(UIImage *)jvs_gradientImageWith:(NSArray<UIColor *> *)colors
                     gradientType:(JVSGradientType)gradientType
                             size:(CGSize)imageSize
                            alpha:(CGFloat)alpha;

+(UIImage *)jvs_gradientImageWith:(NSArray<UIColor *> *)colors
                     gradientType:(JVSGradientType)gradientType
                             size:(CGSize)imageSize;
/// 默认 从左到 右
+(UIImage *)jvs_gradientImageWith:(NSArray<UIColor *> *)colors
                            frame:(CGRect)imageSize;



/// 修改 图片大小
- (void)jvs_imageChangedToSize:(CGSize)size
                    completion:(void(^)(UIImage *image))completion;


/// 转换成 base64
-(NSString *)jvs_base64EncodedString;

/// 字符串 创建二维码图片
///
/// @param urlString 字符串，不能为空
/// @param size 生成二维码的图片大小
+(UIImage *)jvs_qrImageWith:(NSString *)urlString size:(CGFloat)size;


/// 获取相册中 视频图像的缩略图
///
/// @param videoURL 视频地址
/// @param time 时间
+ (UIImage*)jvs_imageFromVideoUrl:(NSURL *)videoURL atTime:(NSTimeInterval)time;


/// 根据图片大小 智能压缩
-(NSData *)jvs_smartCompressedImage;
/// 缩略图
- (UIImage *)jvs_thumbnailImage;

/// JPEG 压缩
- (NSData *)JPEGRepresentationWith:(double)rate;

/// PNG 压缩
- (NSData *)PNGRepresentation;


/// 图片保存到相册
/// - 首先需要自己判断权限
///
/// @param complected 视频保存成功或者失败的回调
-(void)jvs_imageSavedToLibraryWith:(void(^)(BOOL success))complected;

@end

NS_ASSUME_NONNULL_END
