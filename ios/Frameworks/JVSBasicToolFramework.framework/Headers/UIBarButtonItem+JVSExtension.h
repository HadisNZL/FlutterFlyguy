//
//  UIBarButtonItem+JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/10.
//

#import <UIKit/UIKit.h>


NS_ASSUME_NONNULL_BEGIN

/// 常用的 回调Block
typedef void (^MButtonClickBlock)(UIButton *sender);

@interface UIBarButtonItem (JVSExtension)

+(instancetype)itemWithView:(UIView *)view;

/**
 根据图片生成UIBarButtonItem
 
 @param target target对象
 @param action 响应方法
 @param image image
 @return 生成的UIBarButtonItem
 */
+(instancetype)itemWithTarget:(id _Nullable)target
                       action:(SEL _Nullable)action
                        image:(UIImage *_Nullable)image;
/**
 根据图片生成UIBarButtonItem
 
 @param target target对象
 @param action 响应方法
 @param image image
 @param imageEdgeInsets 图片偏移
 @return 生成的UIBarButtonItem
 */
+(instancetype)itemWithTarget:(id _Nullable)target
                       action:(SEL _Nullable)action
                        image:(UIImage *)image
              imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;

/**
 根据图片生成UIBarButtonItem

 @param target target对象
 @param action 响应方法
 @param nomalImage nomalImage
 @param higeLightedImage higeLightedImage
 @param imageEdgeInsets 图片偏移
 @return 生成的UIBarButtonItem
 */
+(instancetype)itemWithTarget:(id _Nullable)target
                       action:(SEL _Nullable)action
                   nomalImage:(UIImage * _Nullable)nomalImage
             higeLightedImage:(UIImage * _Nullable)higeLightedImage
              imageEdgeInsets:(UIEdgeInsets)imageEdgeInsets;


/**
 根据文字生成UIBarButtonItem
 @param target target对象
 @param action 响应方法
 @param title title
 */
+(instancetype)itemWithTarget:(id _Nullable)target
                       action:(SEL _Nullable)action
                        title:(NSString * _Nullable)title;
+(instancetype)itemWithTarget:(id _Nullable)target
                       action:(SEL _Nullable)action
                        title:(NSString *)title
                         font:(UIFont *)font
                   titleColor:(UIColor *)titleColor;

+(instancetype)itemWithTarget:(id _Nullable)target
                       action:(SEL _Nullable)action
                        title:(NSString * _Nullable)title
                         font:(UIFont * _Nullable)font
                   titleColor:(UIColor * _Nullable)titleColor
              titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets;

/**
 根据文字生成UIBarButtonItem
 
 @param target target对象
 @param action 响应方法
 @param title title
 @param titleEdgeInsets 文字偏移
 @return 生成的UIBarButtonItem
 */
+(instancetype)itemWithTarget:(id _Nullable)target
                       action:(SEL _Nullable)action
                        title:(NSString * _Nullable)title
              titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets;

/**
 根据文字生成UIBarButtonItem

 @param target target对象
 @param action 响应方法
 @param title title
 @param font font
 @param titleColor 字体颜色
 @param highlightedColor 高亮颜色
 @param titleEdgeInsets 文字偏移
 @return 生成的UIBarButtonItem
 */
+(instancetype)itemWithTarget:(id _Nullable)target
                       action:(SEL _Nullable)action
                        title:(NSString * _Nullable)title
                         font:(UIFont * _Nullable)font
                   titleColor:(UIColor * _Nullable)titleColor
             highlightedColor:(UIColor * _Nullable)highlightedColor
              titleEdgeInsets:(UIEdgeInsets)titleEdgeInsets;




+(instancetype)itemWithImage:(UIImage *)image touchCallback:(MButtonClickBlock)touchCallback;
+(instancetype)itemWithTitle:(NSString *)title touchCallback:(MButtonClickBlock)touchCallback;

/**
 用作修正位置的UIBarButtonItem

 @param width 修正宽度
 @return 修正位置的UIBarButtonItem
 */
+(instancetype)itemWithFixedWidth:(CGFloat)width;

@end



NS_ASSUME_NONNULL_END
