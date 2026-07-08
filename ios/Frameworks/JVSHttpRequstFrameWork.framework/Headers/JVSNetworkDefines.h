//
//  JVSDefines.h
//  JVSHttpRequstFrameWork
//
//  Created by 张晓东 on 2024/9/9.
//

#import <Foundation/Foundation.h>

#ifndef JVSDefines_h
#define JVSDefines_h

/// 网络状态
typedef NS_ENUM(NSInteger, JVSNetworkReachStatus) {
    JVSNetworkReachStatusUnknown               = -1,
    JVSNetworkReachStatusNotReachable,
    JVSNetworkReachStatusWWAN,
    JVSNetworkReachStatusWifi,
};

//请求成功回调
typedef void(^IRequestSuccessBlock) (NSURLSessionDataTask*_Nonnull task, id _Nullable responseObject);
//请求失败回调
typedef void(^IRequsetFailBlock) (NSURLSessionDataTask *_Nullable task, NSError *_Nonnull error);
//进度回调
typedef void (^IRequsetProgress)(NSProgress *_Nonnull progress);

typedef void(^RequestSuccessDataBlock)(id _Nullable data);
typedef void(^RequsetFailBlock)(NSError * _Nonnull error);
typedef void(^RequestSuccessBlock)(void);

/// 用户相关的域名
FOUNDATION_EXPORT NSString * _Nonnull JVSGetBaseUrl(void);
/// 设备相关的域名
FOUNDATION_EXPORT NSString * _Nonnull JVSGetDeviceBaseUrl(void);
/// H5 域名
FOUNDATION_EXPORT NSString * _Nonnull JVSGetH5BaseUrl(void);
/// 2.0穿透域名
FOUNDATION_EXPORT NSString * _Nonnull JVSGetSecondServerUrl(void);

/// 网络是否可达
FOUNDATION_EXPORT BOOL JVSNetworkIsReachable(void);
/// 网络状态
FOUNDATION_EXPORT JVSNetworkReachStatus JVSGetNetworkReachStatus(void);


// token无效
#define AccountTokenInvalid         2301
// token过期
#define AccountTokenOverdue         2302
// 账号被踢退token过期
#define AccountOutTokenOver         1006
// 用户踢退
#define AccountUserLoginOut         2206
// tiken错误
#define AccountTikenError           2205
// ip锁定
#define AccountIpLock               2237

// 成功的返回码
#define SuccessCode                 1000
// token失效返回码
#define TokenInvalid                1006
// tiken失效返回码
#define TikenInvalid                4007
// tiken失效返回码
#define AccountInvalid              4008
// 设备不属于用户
#define NoBelongToUser              3007
// 请求错误
#define RequestError                2029
//需要获取服务token
#define ServerClientIDError         401


#define JVSAssertFailed(msg)         NSAssert(NO, (msg))



#ifndef __OPTIMIZE__
#define NSLog(FORMAT, ...) {NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
                            [dateFormatter setDateFormat:@"yyyy.MM.dd HH:mm:ss:SSS"]; \
                            NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
                            fprintf(stderr, "\n----🍺开始🍺\n%s %s:%d\t%s\n%s\n----🍺结束🍺\n", [str UTF8String], [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, __FUNCTION__, [[NSString stringWithFormat: FORMAT, ## __VA_ARGS__] UTF8String]);}

#else
#define NSLog(...){}
#endif


#endif /* JVSDefines_h */
