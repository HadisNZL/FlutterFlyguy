//
//  JVSBluetoothManager.h
//  SAASTest
//
//  Created by 李华 on 2024/1/19.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
#import <CoreLocation/CLLocationManager.h>
#import "SABleReadDataCoder.h"
#import "SABleWriteDataCoder.h"
#import "SAPeripheralInfo.h"


typedef void(^SAStateDidUpdateBlock)(NSInteger state);
typedef void(^SABLECompletedBlock)(NSDictionary *_Nullable result, NSError *_Nullable error);

@class JVSBluetoothManager;

@protocol JVSBluetoothManagerDelegate <NSObject>

@optional
/// 蓝牙状态改变了
- (void)bluetoothDidUpdateState:(CBManagerState)state;

/** 扫描到的设备回调，所有设备，有数据变化就会回调
 @param peripheralList 扫描到的蓝牙设备数组
 */
- (void)bluetoothDidScanPeripherals:(NSArray<SAPeripheralInfo *> *_Nonnull)peripheralList;

/** 连接外设成功，连接成功不一定能立马发消息，
 见 bluetoothBeReadyToWriteData，回调后可以发送消息了 */
- (void)bluetoothDidConnectPeripheral:(SAPeripheralInfo *_Nonnull)peripheral;

/** 连接外设失败 */
- (void)bluetoothDidConnectFailedPeripheral:(SAPeripheralInfo *_Nonnull)peripheral error:(NSError *_Nonnull)error;

/** 当前断开的设备
 @param peripheral 断开的peripheral信息
 */
- (void)bluetoothDidDisconnectPeripheral:(SAPeripheralInfo *_Nonnull)peripheral error:(NSError *_Nullable)error;


/// 连接蓝牙之后，这个方法回调之后，就可以立马发送消息了
- (void)bluetoothBeReadyToWriteData:(SAPeripheralInfo *_Nonnull)peripheralInfo;

/** 读取蓝牙数据, 处理过的数据
 @param valueDic 蓝牙设备主动发送过来的 处理过的数据(不是回包)
 */
- (void)bluetoothDidReadData:(NSDictionary *_Nonnull)valueDic forPeripheral:(SAPeripheralInfo *_Nonnull)peripheralInfo;

/// 过滤，默认读取全部外设
- (BOOL)bluetoothFilterOnDiscoverPeripheralName:(NSString *_Nullable)peripheralName advertisementData:(NSDictionary *_Nullable)advertisementData;


@end


typedef void(^MBluetoothScannedPeripheralsBlock)(NSArray<SAPeripheralInfo *> * _Nonnull peripheralInfos);

NS_ASSUME_NONNULL_BEGIN

@interface JVSBluetoothManager : NSObject

+(BOOL)hasSetupData;
+(BOOL)hasRequestAuthorization;
+ (JVSBluetoothManager *)shared;

/// 状态更新回调   @CBManagerState
-(void)updateBleStateWithBlock:(_Nullable SAStateDidUpdateBlock)bleStateDidUpdateBlock;
/// 定位服务  @CLAuthorizationStatus
-(void)updateLocationWithBlock:(_Nullable SAStateDidUpdateBlock)locationStateDidUpdateBlock;
@property(nonatomic, assign) CLAuthorizationStatus locationStatus;

/// 解码器 - 从服务端解析数据 - default SABleReadDataCoder
@property(nonatomic, strong) SABleReadDataCoder *readDataCoder;
/// 写码器 - 发送给服务端  default SABleWriteDataCoder
@property(nonatomic, strong) SABleWriteDataCoder *writeDataCoder;

@property (nonatomic, weak) id<JVSBluetoothManagerDelegate> delegate;

/// 默认为 -1，则未初始化，等蓝牙delegate 回调
@property(nonatomic, assign, readonly) CBManagerState bleState;

/// 获取当前连接成功的蓝牙设备数组
@property(nonatomic, strong, readonly) NSArray<SAPeripheralInfo *> *connectedPeripheralList;

/// 扫描到的设备信息
@property(nonatomic, strong, readonly) NSArray<SAPeripheralInfo *> *scannedPeripheralList;

//- (void)write:(NSData *)msgData forPeripheral:(SAPeripheralInfo *)peripheralInfo;
//- (void)write:(NSData *)msgData forPeripheral:(SAPeripheralInfo *)peripheralInfo withResponsed:(BOOL)responsed;

/// 给蓝牙设备发送消息， 发送消息后 直接以Block的方式回调 接口返回的数据
/// 发送后，等待超时这种情况暂未处理
/// - Parameters:
///   - dataDict: 参数字典
///   - peripheralInfo: 外设设备
///   - completion: 接口回包 回调
- (void)sendWithData:(NSDictionary *)dataDict forPeripheral:(SAPeripheralInfo *)peripheralInfo completion:(SABLECompletedBlock)completion;

/// 设置搜索 特定 服务和特征 获取设备的服务跟特征值
/// 不设置，则搜索所有的外设，建议在调用 startScanPeripheral 之前设置
/// - Parameters:
///   - peripheralWithServices: 只搜索对应的 Services 如 4A56
///   - characters: 只搜索对应的 特性
- (void)setupOptionsForScanPeripheralsWithServices:(NSArray<NSString *> *)peripheralWithServices
                              discoverWithServices:(NSArray<NSString *> *)discoverWithServices
                                withCaracteristics:(NSArray<NSString *> *)characters;

- (void)setupOptionsForScanPeripheralsWithServices:(NSArray<NSString *> *)peripheralWithServices;

/// 开始扫描周边蓝牙设备 同时 取消之前的所有的连接
- (void)startScanPeripheral;
/// 重新扫描周边蓝牙设备，不会取消之前的已经建立连接的蓝牙设备
//- (void)reScanPeripheral;


/// 停止扫描周边蓝牙设备
- (void)stopScanPeripheral;

/// 连接所选取的蓝牙外设
/// - Parameter peripheralInfo: 所选择蓝牙外设的Perioheral
-(void)connectPeripheral:(SAPeripheralInfo *)peripheralInfo;


/// 断开当前连接的所有蓝牙设备
/// 会删除所有 缓存数据
- (void)disconnectAllPeripherals;

/// 断开指定的蓝牙设备， 删除所有该设备相关的缓存数据
/// - Parameter peripheralInfo: 所选择蓝牙外设的Perioheral
- (void)disconnectWithPeripheral:(SAPeripheralInfo *)peripheralInfo;




@end



NS_ASSUME_NONNULL_END
