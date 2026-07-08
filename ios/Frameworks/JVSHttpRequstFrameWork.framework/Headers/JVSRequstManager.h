//
//  JVSRequstManager.h
//  JVSHttpRequstFrameWork
//
//  Created by 张晓东 on 2024/9/6.
//

#import <Foundation/Foundation.h>
#import <JVSHttpRequstFrameWork/NSError+JVSErrorData.h>

NS_ASSUME_NONNULL_BEGIN

/// failedFlag=YES 则回调 fail Block， 否则非空，继续执行代码
FOUNDATION_EXPORT BOOL JVSCheckParameterEmpty(BOOL failedFlag, NSString *paramterName, id failBlock);

#define WriteNetLogToLocalFileWith(logStr)  [JVSRequstManager outLogToLocalDiskWith:(logStr)]

#define JVSCheckParamString(param, failBlock)     if (JVSCheckParameterEmpty(param.length==0, @#param, failBlock)) return;
#define JVSCheckParamArray(array, failBlock)      if (JVSCheckParameterEmpty(array.count==0, @#array, failBlock)) return;
#define JVSCheckParamInt(number, failBlock)       if (JVSCheckParameterEmpty(number==0, @#number, failBlock)) return;

#define JVSCheckParamEmptyRet(flag, msg, failBlock) if (JVSCheckParameterEmpty(flag, (msg), failBlock)) return;



@interface JVSRequstManager : NSObject

/**
 @brief 是否开启打印日志，默认 NO
 @param logEnabled YES: 开启打印日志， NO：关闭打印日志
 */

+(void)setLogEnabled:(BOOL)logEnabled;

/// 移除字典 或者 数组中的 Null 空串
/// @param JSONObject 字典 或者 数组
//id JVSJSONObjectByRemovingKeysWithNullValues(id JSONObject);

//+ (void)setTenantId:(NSString *)tenantId realmID:(NSString *)realmID;


/**
 @brief 根据 base url 获取一个 JVSRequstManager 对象， base url 和 JVSRequstManager 对象一一对应
 @param baseUrl base url 支持 https 和 http 俩种格式
 */
+ (instancetype)managerWith:(NSString *_Nonnull)baseUrl;

/**
 * @brief 释放 JVSRequstManager 对象
 * @param baseUrl 创建时传入的 base url
 */
+ (BOOL)destoryManagerFor:(NSString *_Nonnull)baseUrl;

/// @brief 取消 JVSRequstManager 的所有请求, manager为空 则取消所有请求
/// @param manager JVSRequstManager 对象
+ (void)cancelAllRequestsFor:(JVSRequstManager * _Nullable )manager;

/**
 * @brief 普通GET方法请求网络数据
 * @param aipName URI接口地址
 * @param params 请求参数
 * @param headers 请求头参数
 * @param success 请求成功回调
 * @param fail 请求失败回调
 */

- (void)GET:(NSString *_Nonnull)aipName params:(id)params headers:(NSDictionary *)headers success:(IRequestSuccessBlock)success fail:(IRequsetFailBlock)fail;
/**
 * @brief 普通POST方法请求网络数据
 * @param aipName URI接口地址
 * @param params 请求参数
 * @param headers 请求头参数
 * @param success 请求成功回调
 * @param fail 请求失败回调
 */
- (void)POST:(NSString *_Nonnull)aipName params:(id)params headers:(NSDictionary *)headers success:(IRequestSuccessBlock)success fail:(IRequsetFailBlock)fail;

/**
 * @brief 普通PUT方法请求网络数据
 * @param aipName URI接口地址
 * @param params 请求参数
 * @param headers 请求头参数
 * @param success 请求成功回调
 * @param fail 请求失败回调
 */
- (void)PUT:(NSString *_Nonnull)aipName params:(id)params headers:(NSDictionary *)headers success:(IRequestSuccessBlock)success fail:(IRequsetFailBlock)fail;
/**
 * @brief 普通DELETE方法请求网络数据
 * @param aipName URI接口地址
 * @param params 请求参数
 * @param headers 请求头参数
 * @param success 请求成功回调
 * @param fail 请求失败回调
 */
- (void)DELETE:(NSString *_Nonnull)aipName params:(id)params headers:(NSDictionary *)headers success:(IRequestSuccessBlock)success fail:(IRequsetFailBlock)fail;


#pragma mark --------------------------  续约
/// 添加需要 自动续约 Token的 接口地址
/// @param apiNames 需要 自动续约Token的接口地址
+ (void)addRenewTokenApiNames:(NSArray<NSString *> *)apiNames;

/// @brief TOKEN续约 接口地址
/// @param url 续约接口地址 - 全路径
+ (void)setRenewTokenURL:(NSString *)url;

/// 把日志写入 本地 - 开启 logEnabled = YES 或者 Debug 模式
+(void)outLogToLocalDiskWith:(NSString *)logStr;



#pragma mark --------------------------  快捷方法
/// 基础发送 请求的接口
+(void)DeviceURL_post:(NSString *)url params:(id)params success:(RequestSuccessDataBlock)success fail:(RequsetFailBlock)fail;
+(void)DeviceURL_get:(NSString *)url params:(id)params success:(RequestSuccessDataBlock)success fail:(RequsetFailBlock)fail;
+(void)DeviceURL_put:(NSString *)url params:(id)params success:(RequestSuccessDataBlock)success fail:(RequsetFailBlock)fail;

+(void)BaseURL_post:(NSString *)url params:(id)params success:(RequestSuccessDataBlock)success fail:(RequsetFailBlock)fail;
+(void)BaseURL_put:(NSString *)url params:(id)params success:(RequestSuccessDataBlock)success fail:(RequsetFailBlock)fail;
+(void)BaseURL_get:(NSString *)url params:(id)params success:(RequestSuccessDataBlock)success fail:(RequsetFailBlock)fail;


// 2.0 穿透 发送请求
+(void)SecondServerURL_postWith:(id)params success:(RequestSuccessDataBlock)success fail:(RequsetFailBlock)fail withOldParame:(NSDictionary *)oldParame;


// 接口回调前 处理数据
+(void)handleResponse:(NSDictionary *)dataDict success:(RequestSuccessBlock _Nullable)success
                 fail:(RequsetFailBlock)fail;

// 有数据返回的 回调
+(void)handleResponse:(NSDictionary *)dataDict successDataRet:(RequestSuccessDataBlock _Nullable)success
                 fail:(RequsetFailBlock)fail;

@end

NS_ASSUME_NONNULL_END
