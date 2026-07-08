//
//  JVSDeviceQRTypeModel.h
//  JVSDeviceNetConfigComponent
//
//  Created by 李华 on 7/11/2024.
//

#import <Foundation/Foundation.h>
#import <JVSDeviceNetConfigComponent/JVSDeviceNetConfigDefines.h>

NS_ASSUME_NONNULL_BEGIN

/**
 二维码类型
 
 */

@interface JVSDeviceQRTypeModel : NSObject

@property(nonatomic, copy, readonly) NSString *qrString;


@property(nonatomic, assign, readonly) JVSDeviceQRType qrType;

/**
 @brief 二维码解析为 JVSDeviceQRTypeDeviceShare时
 会返回 deviceShareToken 值
 
 */
@property(nonatomic, copy, readonly) NSString *deviceShareToken;

/**
 @brief 二维码解析为 JVSDeviceQRTypeIPC 时
 会返回 vc, deviceSn, ct 等值
 
 */
@property(nonatomic, copy, readonly) NSString *vc;          // VC值
@property(nonatomic, copy, readonly) NSString *deviceSn;    // 设备id
/**
 ct值，指配网方式：
 0: Ap配网
 6，7： 二维码配网兼容声波配网
 8： 二维码声波配网 和 ap配网 切换配网
 9: 蓝牙配网
 */
@property(nonatomic, copy, readonly) NSString *ct;          // ct值

/**
 @brief 二维码解析为 JVSDeviceQRTypeVMS6100Login 时
 会返回 loginToken 值
 
 */
@property(nonatomic, copy, readonly) NSString *loginToken;

/**
 @brief 数据初始化
 */
+(instancetype)modelWithType:(JVSDeviceQRType)type
                      params:(NSDictionary * _Nullable)params
                    qrString:(NSString *)qrString;



@end

NS_ASSUME_NONNULL_END
