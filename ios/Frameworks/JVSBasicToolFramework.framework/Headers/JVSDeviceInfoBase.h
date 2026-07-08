//
//  JVSDeviceInfoBase.h
//  JVSDeviceSetInfoComponent
//
//  Created by 李华 on 2024/12/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JVSDeviceInfoBase : NSObject<NSCopying>

/// 我的设备列表外层没有，只有通道才会有，没有默认0
@property (nonatomic, copy) NSString *channelId;

/// 设备序列号
@property (nonatomic, copy) NSString *deviceSn;

/**
 设备接入协议
 PUBLICCLOUD:公有云设备,CLOUDSEE1:云视通1.0设备,CLOUDSEE2:云视通2.0设备
 */
@property (nonatomic, copy) NSString *accessProtocol;


/// 二次穿透的接口需要用的
/** 云视通设备Ip     */
@property (nonatomic, copy) NSString *deviceIp;
/** 云视通设备端口号 */
@property (nonatomic, copy) NSString *devicePort;
/** 云视通设备用户名 */
@property (nonatomic, copy) NSString *deviceUser;
/** 云视通设备密码 */
@property (nonatomic, copy) NSString *devicePwd;

/// 判断ap配网 无需传sn 以及port是int类型；
@property (nonatomic, assign) BOOL isApwifi;


@property (nonatomic, copy) NSString *key;


+(instancetype)modelWithSn:(NSString *)deviceSn channelId:(NSString *)channelId;
+(instancetype)modelWithSn:(NSString *)deviceSn channelId:(NSString *)channelId accessProtocol:(NSString *)accessProtocol;

@end

NS_ASSUME_NONNULL_END
