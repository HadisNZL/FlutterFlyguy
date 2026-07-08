//
//  JVSRuntime.h
//  UserManagerExample
//
//  Created by 李华 on 2024/9/29.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <objc/runtime.h>

@interface NSObject (SXRuntime)



@property(nonatomic, strong) NSString *m_tag;

@property(nonatomic, copy, readonly) NSString *jvs_className;
@property(nonatomic, copy, readonly, class) NSString *jvs_className;



/**
 swizzle 类方法
 
 @param oriSel 原有的方法
 @param swiSel swizzle的方法
 */
+ (void)swizzleClassMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel;

/**
 swizzle 实例方法
 
 @param oriSel 原有的方法
 @param swiSel swizzle的方法
 */
+ (void)swizzleInstanceMethodWithOriginSel:(SEL)oriSel swizzledSel:(SEL)swiSel;

/**
 判断方法是否在子类里override了
 
 @param cls 传入要判断的Class
 @param sel 传入要判断的Selector
 @return 返回判断是否被重载的结果
 */
- (BOOL)isMethodOverride:(Class)cls selector:(SEL)sel;

/**
 判断当前类是否在主bundle里
 
 @param cls 出入类
 @return 返回判断结果
 */
+ (BOOL)isMainBundleClass:(Class)cls;

/**
 动态创建绑定selector的类
 tip：每当无法找到selectorcrash转发过来的所有selector都会追加到当前Class上
 
 @param aSelector 传入selector
 @return 返回创建的类
 */
+ (Class)addMethodToStubClass:(SEL)aSelector;


#pragma mark -
#pragma mark - 延迟调用
/**
 切换到主线程 执行代码
 @param _block block
 */
FOUNDATION_EXPORT void m_dispatch_on_main_thread(dispatch_block_t _block);

/**
 *  延迟调用  0.25 s
 *  @param block block
 */
FOUNDATION_EXPORT void m_dispatch_time_after(dispatch_block_t block);

FOUNDATION_EXPORT void m_dispatch_time_after_interval(NSTimeInterval interval, dispatch_block_t block);

FOUNDATION_EXPORT void m_dispatch_global_async(dispatch_block_t block);

FOUNDATION_EXPORT void m_dispatch_barrier_sync(dispatch_block_t block);

FOUNDATION_EXPORT void m_dispatch_main_async(dispatch_block_t block);

FOUNDATION_EXPORT void rhOpenURL(NSString *url);

@end
