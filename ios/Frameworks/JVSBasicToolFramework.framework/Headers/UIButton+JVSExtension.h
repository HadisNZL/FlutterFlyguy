//
//  XYButton.h
//  UserManagerExample
//
//  Created by 李华 on 2024/9/29.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JVSBasicToolFramework/JVSBasicToolDefines.h>

@interface UIView (Grandient)

#pragma mark --------------------------  添加渐变色
/// 设置背景渐变颜色，默认从左到右
-(void)setGradientBackgroundWith:(NSArray<UIColor *> *)colors;
-(void)setGradientBackgroundWith:(NSArray<UIColor *> *)colors
                           alpha:(CGFloat)alpha;
/// 设置 UIButton 背景 渐变色
-(void)setGradientBackgroundWith:(NSArray<UIColor *> *)colors
                    gradientType:(JVSGradientType)gradientType;

-(void)setGradientBackgroundWith:(NSArray<UIColor *> *)colors
                    gradientType:(JVSGradientType)gradientType
                           alpha:(CGFloat)alpha;

@end

@interface UIButton (JVSExtension)


#pragma mark --------------------------  便捷的点击事件
@property(nonatomic ,copy)void(^block)(UIButton*);

-(void)addTapBlock:(void(^)(UIButton*btn))block;

/**  扩大 button 点击范围  >0 表示扩大  <0 缩小范围 */
- (void)jvs_enlargeEdgeWith:(UIEdgeInsets)edgeInsets;
- (void)jvs_enlargeEdgeWithTop:(CGFloat)top right:(CGFloat)right bottom:(CGFloat)bottom left:(CGFloat)left;

/// 使用YY，只有一个点击事件 - UIControlEventTouchUpInside
-(void)setClickEventsBlock:(void (^)(id sender))block;

-(void)addTarget:(id)target clickAction:(SEL)action;


/** 是否禁用 防重复点击功能 - 默认 NO： 启用防重复点击功能 */
@property (nonatomic, assign) BOOL shouldDisableUnrepeatClick;


/// 颜色转图片，设置按钮背景图片
-(void)jvs_setBackgroundColor:(UIColor *)color forState:(UIControlState)state;


@end



typedef void(^TapButtonActionBlock) (UIButton *button);

@interface UIButton (JVSCreate)
/**
 *  快速创建文字Button
 *
 *  @param frame           frame
 *  @param title           title
 *  @param font           font
 *  @param backgroundColor 背景颜色
 *  @param titleColor      文字颜色
 *  @param tapAction       回调
 */
+ (instancetype)hb_buttonWithFrame:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont*)font
                   backgroundColor:(UIColor *)backgroundColor
                        titleColor:(UIColor *)titleColor
                         tapAction:(TapButtonActionBlock)tapAction;



/**
 *   快速创建图片Button
 *
 *  @param frame       frame
 *  @param imageString 按钮的背景图片
 *  @param tapAction   回调
 */
+ (instancetype)hb_buttonWithFrame:(CGRect)frame
       NormalBackgroundImageString:(NSString *)imageString
                         tapAction:(TapButtonActionBlock)tapAction;

/**
 *  指定角切圆角
 *
 *  @param frame           frame
 *  @param title           title
 *  @param font           font
 *  @param backgroundColor 背景颜色
 *  @param titleColor      文字颜色
 *  @param rectCorner      指定角UIRectCorner
 *  @param cornerRadii     圆角大小
 *  @param tapAction       回调
 */

+ (instancetype)hb_buttonWithFrame:(CGRect)frame
                             title:(NSString *)title
                         titleFont:(UIFont*)font
                   backgroundColor:(UIColor *)backgroundColor
                        titleColor:(UIColor *)titleColor
       bezierPathByRoundingCorners:(UIRectCorner)rectCorner
                       cornerRadii:(CGSize)cornerRadii
                         tapAction:(TapButtonActionBlock)tapAction;

/// 设置图片的button
/// @param imageString 图片名称
/// @param tapAction 点击效果
+(instancetype)hb_buttonWithImage:(NSString *)imageString tapAction:(TapButtonActionBlock)tapAction;




+ (instancetype)jvs_buttonWithTitle:(NSString *)title
                          titleFont:(UIFont*)titleFont
                         titleColor:(UIColor *)titleColor;

+ (instancetype)jvs_buttonWithTitle:(NSString *)title
                          titleFont:(UIFont*)titleFont
                         titleColor:(UIColor *)titleColor
                          tapBlock:(TapButtonActionBlock)tapAction;

+ (instancetype)jvs_buttonWithImage:(UIImage *)normalImage
                           tapBlock:(TapButtonActionBlock)tapAction;

+ (instancetype)jvs_buttonWithImage:(UIImage *)normalImage
                      selectedImage:(UIImage*)selectedImage;

+ (instancetype)jvs_buttonWithImage:(UIImage *)normalImage
                      selectedImage:(UIImage*)selectedImage
                           tapBlock:(TapButtonActionBlock)tapAction;


@end
