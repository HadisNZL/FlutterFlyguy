//
//  UIView+JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/12.
//

#import <UIKit/UIKit.h>

@interface UIView (JVSExtension)

/// 获取一个实例，如果有xib，则获取xib的一个实例
+ (instancetype) jvs_instance;

/// 移除所有的 子视图
- (void)m_removeAllSubviews;
/// 隐藏软键盘
- (void)m_endEditing;

/**  起点x坐标  */
@property (nonatomic, assign) CGFloat x;
/**  起点y坐标  */
@property (nonatomic, assign) CGFloat y;
/**  中心点x坐标  */
@property (nonatomic, assign) CGFloat centerX;
/**  中心点y坐标  */
@property (nonatomic, assign) CGFloat centerY;
/**  宽度  */
@property (nonatomic, assign) CGFloat width;
/**  高度  */
@property (nonatomic, assign) CGFloat height;
/**  顶部  */
@property (nonatomic, assign) CGFloat top;
/**  底部  */
@property (nonatomic, assign) CGFloat bottom;
/**  左边  */
@property (nonatomic, assign) CGFloat left;
/**  右边  */
@property (nonatomic, assign) CGFloat right;
/**  size  */
@property (nonatomic, assign) CGSize size;
/**  origin */
@property (nonatomic, assign) CGPoint origin;

FOUNDATION_EXPORT void ViewRadius(UIView *view, CGFloat cornerRadius);
FOUNDATION_EXPORT void ViewBorderRadius(UIView *view, CGFloat cornerRadius, CGFloat borderWidth, UIColor *borderColor);

#pragma mark --------------------------  UIView 设置圆角
@property(nonatomic, assign) CGFloat cornerRadius;
/**  设置圆角  */
- (void)rounded:(CGFloat)cornerRadius;
/**  设置圆角和边框  */
- (void)rounded:(CGFloat)cornerRadius width:(CGFloat)borderWidth color:(UIColor *)borderColor;
/**  设置边框  */
- (void)border:(CGFloat)borderWidth color:(UIColor *)borderColor;
/**   给哪几个角设置圆角  */
- (void)round:(CGFloat)cornerRadius RectCorners:(UIRectCorner)rectCorner;

- (UIViewController *)viewController;


/// 设置延迟点击
/// 点击后，延时再次点击
-(void)delayTimeToEnableTouch:(double)delaySeconds;
-(void)delayTimeToEnableTouch:(double)delaySeconds block:(dispatch_block_t)block;


#pragma mark --------------------------  设置阴影
/// 在self 底部添加一个 view 来做阴影 ,
/// 会设置 masksToBounds 和 cornerRadius
- (UIView *)setShadow:(UIColor*)color offset:(CGSize)offset shadowRadius:(CGFloat)radius cornerRadius:(CGFloat)cornerRadius;

/// 只是设置背景阴影
- (void)setShadow:(UIColor*)color offset:(CGSize)offset shadowRadius:(CGFloat)radius bgCorner:(CGFloat)bgCorner;
- (void)setShadow:(UIColor*)color offset:(CGSize)offset shadowRadius:(CGFloat)radius;

/// 子类超过父类的部分 还是会显示，
/// 解决办法，自己在父类中增加一个 view，并设置圆角，剪切子类
-(void)setLayerShadow:(UIColor*)color offset:(CGSize)offset shadowRadius:(CGFloat)radius;

/// 子类超过父类的部分 还是会显示，
/// 解决办法，自己在父类中增加一个 view，并设置圆角，剪切子类
- (void)setLayerShadow:(UIColor*)color offset:(CGSize)offset shadowRadius:(CGFloat)radius cornerRadius:(CGFloat)cornerRadius;


/// UIView 转换为 图片
- (UIImage *)jvs_snapshotImage;
- (UIImage *)jvs_snapshotImageAfterScreenUpdates:(BOOL)afterUpdates;

@end
