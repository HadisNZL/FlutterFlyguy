//
//  JVSNetworkReachManager.h
//  JVSHttpRequstFrameWork
//  网络监听回调
//  Created by 李华 on 2024/9/20.
//

#import <Foundation/Foundation.h>
#import <JVSHttpRequstFrameWork/JVSNetworkDefines.h>

typedef void(^JVSNetworkStatusBlock) (JVSNetworkReachStatus status, JVSNetworkReachStatus oldStatus);

@interface JVSNetworkReachManager : NSObject

/// 单例对象
+(instancetype _Nonnull )shared;

/**
 * @brief 注册网络监听，target 为弱引用 使用 removeRegisterForTarget 移除，资源回收
 * @param target 注册
 * @param callback 网络变化回调
 */
+(void)registerForTarget:(id _Nonnull)target callback:(JVSNetworkStatusBlock _Nonnull)callback;

/// @brief 如果调用了registerForTarget:注册了对象, 则使用该方法取消注册
/// @param target 需要取消注册的对象
+(void)removeRegisterForTarget:(id _Nonnull)target;

/// 网络是否可以达
+(BOOL)isReachable;

/// 是不是 5G、4G、3G访问网络
+(BOOL)reachableViaWWAN;

/// 是不是 Wifi状态下
+(BOOL)reachableViaWiFi;

@end
