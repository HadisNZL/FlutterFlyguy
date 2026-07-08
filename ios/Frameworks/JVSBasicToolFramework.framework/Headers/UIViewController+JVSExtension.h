//
//  UIViewController+JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/10.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIViewController (JVSNavBarItem_)


/// 快速获取一个 实例，或者 从 xib获取一个实例
+(instancetype)jvs_instance;

/// 获取当前 顶层 controller
+(UIViewController *)jvs_getCurrentController;

#pragma mark Navigation Bar Item
/**
 设置导航栏右侧按钮
 @param image 图片
 @param target target
 @param action 方法
 */
-(UIButton *)rightBarItemWithImage:(UIImage *)image rightSpace:(CGFloat)space target:(id _Nullable)target action:(SEL _Nullable)action;
-(UIButton *)rightBarItemWithTitle:(NSString *)title rightSpace:(CGFloat)space target:(id _Nullable)target action:(SEL _Nullable)action;

-(UIButton *)rightBarItemWithImage:(UIImage *)image target:(id _Nullable)target action:(SEL _Nullable)action;
-(UIButton *)rightBarItemWithTitle:(NSString *)title target:(id _Nullable)target action:(SEL _Nullable)action;

-(UIButton *)rightBarItemWithImage:(UIImage *)image rightSpace:(CGFloat)space clickCallback:(void (^  _Nullable)(void))callback;
-(UIButton *)rightBarItemWithTitle:(NSString *)title rightSpace:(CGFloat)space clickCallback:(void (^ _Nullable)(void))callback;


-(UIButton *)rightBarItemWithImage:(UIImage *)image clickCallback:(void (^  _Nullable)(void))callback;
-(UIButton *)rightBarItemWithTitle:(NSString *)title clickCallback:(void (^ _Nullable)(void))callback;

-(NSArray<UIButton *> *)rightBarItemWithFirstTitle:(NSString *)firstTitle secondTitle:(NSString *)secondTitle target:(id _Nullable)target firstAction:(SEL _Nullable)firstAction secondAction:(SEL _Nullable)secondAction;

/**
 设置导航栏左侧侧按钮
 @param image 图片
 @param target target
 @param action 方法
 */
- (UIButton *)leftBarItemWithImage:(UIImage *)image target:(id _Nullable)target action:(SEL _Nullable)action;
- (UIButton *)leftBarItemWithTitle:(NSString *)title target:(id _Nullable)target action:(SEL _Nullable)action;

-(UIButton *)leftBarItemWithImage:(UIImage *)image clickCallback:(void (^  _Nullable)(void))callback;
-(UIButton *)leftBarItemWithTitle:(NSString *)title clickCallback:(void (^ _Nullable)(void))callback;
-(UIButton *)leftBarItemWithTitle:(NSString *)title leftSpace:(CGFloat)leftSpace clickCallback:(void (^ _Nullable)(void))callback;

@end

NS_ASSUME_NONNULL_END
