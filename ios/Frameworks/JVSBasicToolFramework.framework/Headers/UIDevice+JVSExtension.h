//
//  UIDevice+JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/12.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIDevice (JVSExtension)


/// 设备唯一ID
+(NSString *)jvs_deviceUUID;
+(NSString *)jvs_appVersion;
+(NSString *)jvs_appBuildVersion;


+ (double)jvs_folderSizeAtPath:(NSString *)path;
//计算文件的大小
+ (double)jvs_fileSizeAtPath:(NSString *)path;

// 根据路径删除文件
+ (void)jvs_cleanCachesAtPath:(NSString*)path;

/// 获取 App的缓存大小
+ (NSString*)jvs_getAPPCaches;
+ (void)jvs_clearAPPCaches;

//+(NSString *)jvs_deviceModel;
/**
 *  设备型号名称
 *  @return e.g. iPhone 5S
 */
+ (NSString*)jvs_deviceModelName;

/**
 *  获取系统版本号
 *  @return systemVersion e.g. iOS18.0
 */
+ (NSString *)jvs_systemVersion;

/// iOS13.0之后必须先打开定位权限，iOS14.0之后还要打开精准位置
/// 获取手机连接的 Wifi名字
+ (NSString *) jvs_connectedWiFiName;
+ (NSDictionary *) jvs_connectedWiFiInfo;

@end

NS_ASSUME_NONNULL_END
