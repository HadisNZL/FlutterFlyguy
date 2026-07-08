#import <UIKit/UIKit.h>

@interface UILabel (HBExtension)
/**
 *  快速创建Label
 *  @param title         文字
 *  @param titleColor    文字颜色
 *  @param font          字体
 */
+ (instancetype)hb_labelWithTitle:(NSString *)title
                       titleColor:(UIColor *)titleColor
                             font:(UIFont *)font;

/**
 *  快速创建Label
 *
 *  @param frame         frame
 *  @param title         文字
 *  @param titleColor    文字颜色
 *  @param font          字体
 */
+ (instancetype)hb_labelWithFrame:(CGRect )frame
                            title:(NSString *)title
                       titleColor:(UIColor *)titleColor
                             font:(UIFont *)font;

/**
 *  快速创建Label
 *
 *  @param frame         frame
 *  @param title         文字
 *  @param titleColor    文字颜色
 *  @param textAlignment 对齐方式
 *  @param font          字体
 */
+ (instancetype)hb_labelWithFrame:(CGRect )frame
                            title:(NSString *)title
                       titleColor:(UIColor *)titleColor
                    textAlignment:(NSTextAlignment)textAlignment
                             font:(UIFont *)font;


/**
 *  封装UILable的字体不同颜色
 *
 *  @param frame         frame
 *  @param textStr         文字
 *  @param textColor    文字颜色
 *  @param font          字体
 *  @param textAlignment 对其方式
 *  @param valueColor 截取的颜色
 *  @param rangeStr 截取的文字
 *
 */


+ (UILabel *)hb_labelWithFrame:(CGRect)frame
                          text:(NSString *)textStr
                     textColor:(UIColor *)textColor
                      textFont:(UIFont *)font
                 textAlignment:(NSTextAlignment)textAlignment
                    valueColor:(UIColor *)valueColor
                 rangeOfString:(NSString *)rangeStr;



/**
 可以切圆角的UILable
 
 @param frame           位置
 @param title           文字
 @param titleColor      文字颜色
 @param backgroundColor 背景颜色
 @param rectCorner      切圆角的位置
 @param cornerRadii     切圆角半径
 @param textAlignment   文字显示位置
 @param font            文字大小
 
 @return instancetype
 */
+ (instancetype)hb_labelWithFrame:(CGRect )frame
                            title:(NSString *)title
                       titleColor:(UIColor *)titleColor
                  backgroundColor:(UIColor *)backgroundColor
      bezierPathByRoundingCorners:(UIRectCorner)rectCorner
                      cornerRadii:(CGSize)cornerRadii
                    textAlignment:(NSTextAlignment)textAlignment
                             font:(UIFont *)font;

/// 设置行间距
/// @param spacing 行间距
- (void)hb_lineSpaceWithSpacing:(CGFloat)spacing;
@end
