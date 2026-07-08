//
//  SABlePeripheralInfo.h
//  SAASTest
//
//  Created by 李华 on 2024/1/19.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>


/// 从设备信息
NS_ASSUME_NONNULL_BEGIN

@interface SAPeripheralInfo : NSObject

+(instancetype)modelWithPeripheral:(CBPeripheral *)peripheral adData:(NSDictionary *)adData RSSI:(NSNumber *)RSSI;
+(instancetype)modelWithPeripheral:(CBPeripheral *)peripheral adData:(NSDictionary *)adData;


@property (nonatomic, copy) NSNumber *RSSI;
@property (nonatomic, strong) CBPeripheral *peripheral;
@property (nonatomic, copy) NSDictionary *advertisementData;

@property (nonatomic, copy, readonly) NSString *nameFromAdverisementData;
@property (nonatomic, assign, readonly) BOOL isJovisionManufacturer;
@property (nonatomic, copy, readonly) NSString *peripheralDetailInfo;

@property (readonly, nonatomic, strong) NSUUID *identifier;
@property (nonatomic, assign, readonly) BOOL isConnected;

/** is peripheral.name */
@property (nonatomic, copy, readonly) NSString *deviceSn;

/// 是否 已经配置了网络了
@property (nonatomic, assign) BOOL hasConfigWifi;
/// 之前有手动连接过
@property (nonatomic, assign) BOOL hasConnectBefore;


@property(nonatomic, strong) CBCharacteristic *writeCharacteristic;
@property(nonatomic, strong) CBCharacteristic *notifCharacteristic;

@end

NS_ASSUME_NONNULL_END
