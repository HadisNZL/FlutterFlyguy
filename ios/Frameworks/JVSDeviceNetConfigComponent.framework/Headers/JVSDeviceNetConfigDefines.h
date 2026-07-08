//
//  JVSDeviceNetConfigDefines.h
//  JVSDeviceNetConfigComponent
//
//  Created by 李华 on 7/11/2024.
//


#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, JVSDeviceQRType) {
    JVSDeviceQRTypeNone = 0,                // 错误的二维码 - 不符合规则
    JVSDeviceQRTypeIPC,                     // 识别为 IPC
    JVSDeviceQRTypeDeviceShare,             // 识别为 设备分享
    JVSDeviceQRTypeVMS6100Login,            // 识别为 6100登录
    
    
    JVSDeviceQRTypeUnknown,                 // 找不到类型匹配 - 后台可以全量字符串查询
};


typedef NS_ENUM(NSInteger, JVSDeviceWIFIListType) {
    JVSDeviceWIFIListTypeFromAP,  // 从 AP获取WiFi列表
    JVSDeviceWIFIListTypeFromBLE, // 从 蓝牙BLE 获取WiFi列表
};
