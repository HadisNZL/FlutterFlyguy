//
//  JVSLANDeviceModel.h
//  JVSDeviceNetConfigComponent
//
//  Created by 李华 on 7/11/2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
//port = 18320,
//device_name = "          ",
//protocol = "CLOUDSEE2",
//active_status = 0,
//channel_count = 1,
//sn = "12221S2HA1R2",
//device_type = 1,
//ip = "192.168.71.179",


@interface JVSLANDeviceModel : NSObject


@property (nonatomic, copy) NSString *port;
@property (nonatomic, copy) NSString *device_name;
@property (nonatomic, assign) NSInteger channel_count;
@property (nonatomic, copy) NSString *sn;
/** verification_code */
@property (nonatomic, copy) NSString *verification_code;
/** ONLINE 在线 */
@property (nonatomic, copy) NSString *deviceState;
/** 设备类型  */
@property (nonatomic, copy) NSString *deviceType;
/** 设备接入协议
枚举: PUBLICCLOUD:公有云设备,CLOUDSEE1:云视通1.0设备,CLOUDSEE2:云视通2.0设备 */
@property (nonatomic, copy) NSString *protocol;
@property (nonatomic, copy) NSString *ip;
/** active_status 1已激活 2 未激活 0无需操作 */
@property (nonatomic, assign) NSInteger active_status;
/** 是否选中状态  */
@property (nonatomic, assign) BOOL isSelected;
/** hasAdd */
@property (nonatomic, assign) BOOL hasAdd;
/** 是否在线  */
@property (nonatomic, assign) BOOL isOnLine;

@end

NS_ASSUME_NONNULL_END
