//
//  JVSDeviceNetConfigManager.h
//  JVSDeviceNetConfigComponent
//
//  Created by 李华 on 7/11/2024.
//

#import <UIKit/UIKit.h>
#import <JVSHttpRequstFrameWork/JVSNetworkDefines.h>
#import <JVSDeviceNetConfigComponent/JVSDeviceQRTypeModel.h>
#import <JVSDeviceNetConfigComponent/JVSLANDeviceModel.h>

NS_ASSUME_NONNULL_BEGIN

@interface JVSDeviceNetConfigManager : NSObject

+(instancetype) alloc __attribute__((unavailable("call shared instead")));
+(instancetype) new __attribute__((unavailable("call shared instead")));
-(instancetype) copy __attribute__((unavailable("call shared instead")));
-(instancetype) mutableCopy __attribute__((unavailable("call shared instead")));

/// @brief 单例
+ (instancetype)shared;



/**
 @brief 解析 二维码，获取二维码类型
 
 */
+(JVSDeviceQRTypeModel *)QRTypeForQRString:(NSString *)qrString;


/**
 @brief 生成一个 声波配网的二维码，
 支持声波配网的设备可以扫描这个二维码进行配网
 生成 imageSize * imageSize 的正方形二维码图片
 
 */
+(UIImage *)createSoundQRImageWith:(NSString *)wifiName
                      wifiPassword:(NSString *)wifiPassword
                         imageSize:(CGFloat)imageSize;

/**
 @brief 保存 wifi 名称和密码
 
 @param pwd WiFi密码，可以为空，为空时则删除已存在的WiFi Info
 @param key 保存WiFi 唯一的Key
 */
+(void)updateWifiPwd:(NSString * _Nullable)pwd forKey:(NSString *)key;
/**
 @brief 获取wifi密码
 
 @param key 获取WiFi密码 唯一的Key
 */
+(NSString *)wifiPwdForKey:(NSString *)key;


/**
 @brief 验证 WiFi密码是否可以连接
 
 @param wifiName wifi 名称
 @param wifiPassword wifi 密码
 @param callback WiFi是否正确正常回调
 */
+(void)validateWiFiWith:(NSString *)wifiName wifiPassword:(NSString *)wifiPassword callback:(void(^)(BOOL reachable))callback;



/**
 @brief 从 蓝牙获取 获取 WiFi列表
 
 @param success 接口调用成功回调
 @param fail 接口调用失败回调，error 表示失败原因
*/
+(void)getWifiListFromBLEWith:(RequestSuccessDataBlock)success
                         fail:(RequsetFailBlock)fail;


/**
@brief 从 AP获取 获取 WiFi列表

@param username 设备的用户名 非必填
@param password 设备的密码 非必填
@param success 接口调用成功回调
@param fail 接口调用失败回调，error 表示失败原因
*/
+(void)getWifiListFromAPWith:(NSString * _Nullable)username
                    password:(NSString * _Nullable)password
                     success:(RequestSuccessDataBlock)success
                        fail:(RequsetFailBlock)fail;


/**
 @brief 从局域获取 设备列表
 需要开启局域网 查询功能
 
 @param success 接口调用成功回调
 @param fail 接口调用失败回调，error 表示失败原因
 */
+(void)getDeviceListFromLocalNetwork:(void(^_Nullable)(NSArray<JVSLANDeviceModel *> * _Nullable data))success
                                fail:(RequsetFailBlock)fail;
    

/** 发送AP配网 WiFi和密码
 首先需要手机连接 到AP热点后，才能调用此方法；

 */
+(void)sendAPNetConfigurationWith:(NSString *)wifiName
                          wifiPwd:(NSString *)wifiPwd
                          success:(RequestSuccessBlock)success
                             fail:(RequsetFailBlock)fail;

/** 发送蓝牙BLE配网 WiFi和密码
 首先需要手机连接到蓝牙设备，才能调用此方法；

 */
+(void)sendBLENetConfigurationWith:(NSString *)wifiName
                           wifiPwd:(NSString *)wifiPwd
                           success:(RequestSuccessDataBlock)success
                              fail:(RequsetFailBlock)fail;

@end

NS_ASSUME_NONNULL_END
