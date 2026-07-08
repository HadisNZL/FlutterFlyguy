//
//  UIViewController+SAPushExt.h
//  SAASTest
//
//  Created by 李华 on 2024/3/1.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <UIKit/UIKit.h>
@interface UINavigationController (Navigator)


@property(nonatomic, strong, readonly) NSArray<UIViewController *> *jvs_viewControllers;
@property(nonatomic, strong, readonly) UIViewController *jvs_topViewController;

/// push 多个Controller 支持 instance 和 NSString
-(void)pushViewPages:(NSArray *)viewPages animation:(BOOL)animated;
-(void)pushViewPages:(NSArray *)viewPages;

@end


@interface UIViewController (Navigator)

/// 点击 返回按钮
-(void)onClickBackButton;

/// 获取nav Controller 的 所有viewControllers
@property(nonatomic, strong, readonly) NSArray<UIViewController *> *jvs_viewControllers;
@property(nonatomic, strong, readonly) UIViewController *jvs_topViewController;

/// 上一个Controller
/// 如果NavController 中 只有一个Controller时，则返回nil
@property(nonatomic, strong, readonly) UIViewController *jvs_previousViewController;
//@property(nonatomic, copy, readonly) NSString *jvs_className;


#pragma mark --------------------------  ToOverride
/// 使用 UIViewController+Navigator pop方法  , 子类覆盖
-(void)backViewWithParam:(NSDictionary *)params;

#pragma mark --------------------------  Push
-(void)pushViewController:(UIViewController *)viewPage animated:(BOOL)animated;

-(void)pushPageWithName:(NSString *)vcName animated:(BOOL)animated;
/**
 页面跳转(带参数)
 @param pageName   页面类名
 @param animated  是否开启动画
 @param pararmInfo 传参信息
 */
-(void)pushPageWithName:(NSString*)pageName animation:(BOOL)animated withParams:(NSDictionary*)pararmInfo;
/// 跳转带参数 animation: YES;
-(void)pushPageWithName:(NSString*)pageName withParams:(NSDictionary*)paramInfo;


#pragma mark --------------------------  Pop
/**
 返回上一页面
 @param animated 是否开启动画
 */
- (void)popViewPageAnimated:(BOOL)animated;
/// 调用 BaseViewController backViewWithParam
- (void)popViewPageAnimated:(BOOL)animated params:(NSDictionary *)params;


/**
 返回到指定页面，没找到 则不返回(带回参数)
 @param animated 是否开启动画
 @param paramInfo 传参信息
 */
- (BOOL)popViewPageTo:(NSString *)pageName animated:(BOOL)animated withParams:(NSDictionary*)paramInfo;
- (BOOL)popViewPageTo:(NSString *)pageName animated:(BOOL)animated;
- (BOOL)popViewPageTo:(NSString *)pageName withParams:(NSDictionary*)paramInfo;

/**
 返回指定页面(带回参数)
 @param viewPage 页面
 @param animated 是否开启动画
 @param paramInfo 传参信息
 */
- (void)popViewPageToPage:(UIViewController *)viewPage animated:(BOOL)animated withParams:(NSDictionary*)paramInfo;
- (void)popViewPageToPage:(UIViewController *)viewPage animated:(BOOL)animated;

/** 返回根页面
 @param animated 是否开启动画
 */
- (void)popToRootViewPage:(BOOL)animated;
- (void)popToRootViewPage:(BOOL)animated withParams:(NSDictionary*)paramInfo;

@end

