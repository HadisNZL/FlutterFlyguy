//
//  JVSBluetoothManager.m
//  SAASTest
//
//  Created by 李华 on 2024/1/19.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import "JVSBluetoothManager.h"
#import "BabyBluetooth.h"
#import "SABleReadDataCoder.h"
#import "SABleWriteDataCoder.h"
#import <CoreLocation/CoreLocation.h>
//
#import <JVSBasicToolFramework/NSDate+JVSExtension.h>
#import <JVSBasicToolFramework/NSObject+JSONFormat.h>
#import <JVSBasicToolFramework/NSObject+JVSRuntime.h>
#import <JVSBasicToolFramework/JVSBasicToolDefines.h>
#import <JVSBasicToolFramework/JVSLogManager.h>

#define SABLERequestId              @"_reqId_"
#define SAServiceUUID               @"4A56"


@interface SABleResponseDelegate : NSObject<CLLocationManagerDelegate>
/// 请求 Id
@property(nonatomic, assign) NSInteger taskId;
/// 数据 回调
@property(nonatomic, copy) SABLECompletedBlock completedBlock;

@end
@implementation SABleResponseDelegate
-(void)dealloc {
    NSLog(@"---------- Dealloc SABleCompleteBlock %@", self);
}
@end

@interface SABlePeripheralTaskDelegate : NSObject

/// 请求id 和 回调
@property(nonatomic, strong) NSMutableDictionary<NSNumber *, SABleResponseDelegate *> *mutableReponseDelegateForRequestId;

@end
@implementation SABlePeripheralTaskDelegate
-(void)dealloc {
    NSLog(@"---------- Dealloc SABlePeripWrapInfo %@", self);
}
@end

@interface JVSBluetoothManager ()<CLLocationManagerDelegate> {
    BabyBluetooth *_baby;
    
    /// 搜索指定的 service  和 character 相关的
    NSArray<NSString *> *_serviceUUIDs;
    NSArray<NSString *> *_characterUUIDs;
    NSArray<NSString *> *_discoverWithServiceIds;
    
@private
    NSLock *_lock;
    int _increasedReqId;
    CBManagerState _bleState;
    
    CLLocationManager *_locationManager;
}

@property(nonatomic, strong) NSMutableArray<SAPeripheralInfo *> *scanPeripheralList;

/// 去重使用
@property(nonatomic, strong) NSMutableArray<NSString *> *peripheralsUUIDs;

@property(nonatomic, strong) NSMutableDictionary<NSString *, SAPeripheralInfo *> *periperalMapper;

/// 收到消息 - 回调信息
@property(nonatomic, strong) NSMutableDictionary<NSString *, SABlePeripheralTaskDelegate *> *mutableTaskDelegateForPeripheralId;

@property(nonatomic, copy) SAStateDidUpdateBlock locationStateDidUpdateBlock;
@property(nonatomic, copy) SAStateDidUpdateBlock bleStateDidUpdateBlock;

@end

#pragma mark --------------------------  JVSBluetoothManager
@implementation JVSBluetoothManager


+(BOOL)hasRequestAuthorization {
    return UNGetBool(@"SA_hasRequestAuthorization");
}
+(BOOL)hasSetupData {
    return instance!=nil;
}
static JVSBluetoothManager *instance = nil;
+ (JVSBluetoothManager *)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[JVSBluetoothManager alloc] init];
        [instance setupBaseData];
    });
    return instance;
}

-(void)setupBaseData {
    _lock = NSLock.new;
    _bleState = -1;
    _peripheralsUUIDs = NSMutableArray.new;
    _scanPeripheralList = NSMutableArray.new;
    _periperalMapper = NSMutableDictionary.new;
    
    [NSUserDefaults.standardUserDefaults setObject:@"1" forKey:@"BLE_AUTH_REQUESTED"];
    [NSUserDefaults.standardUserDefaults synchronize];
    
    _baby = [BabyBluetooth shareBabyBluetooth];
    // 设置蓝牙委托
    [self setupBabyBLEDelegate];
    UNSaveBool(YES, @"SA_hasRequestAuthorization");
}

#pragma mark --------------------------  向蓝牙设备发送数据
/** 向蓝牙设备发送数据
 @param msgData 数据data值
 */
- (void)write:(NSData *)msgData forPeripheral:(SAPeripheralInfo *)peripheralInfo {
    [self write:msgData forPeripheral:peripheralInfo withResponsed:YES];
}
- (void)write:(NSData *)msgData forPeripheral:(SAPeripheralInfo *)peripheralInfo withResponsed:(BOOL)responsed {
    if (!msgData) {
        NSLog(@"------ [ERROR] write[%@]: msgData is nil ", peripheralInfo.identifier.UUIDString);
        return;
    }
    if (!peripheralInfo.writeCharacteristic) {
        NSLog(@"------ [ERROR] write[%@] : peripheralInfo.writeCharacteristic is nil ", peripheralInfo.identifier.UUIDString);
        return;
    }
    [self _write:msgData forPeripheral:peripheralInfo withResponsed:responsed];
}
- (void)_write:(NSData *)msgData forPeripheral:(SAPeripheralInfo *)peripheralInfo withResponsed:(BOOL)responsed {
    NSLog(@"------ \n[%@] Did Send Data", peripheralInfo.identifier.UUIDString);
    CBCharacteristicWriteType type = responsed?CBCharacteristicWriteWithResponse:CBCharacteristicWriteWithoutResponse;
    [peripheralInfo.peripheral writeValue:msgData
                        forCharacteristic:peripheralInfo.writeCharacteristic type:type];
}

/// 发送消息后 直接以Block的方式回调 接口返回的数据
/// 发送后，等待超时这种情况暂未处理
/// - Parameters:
///   - dataDict: 参数字典
///   - peripheralInfo: 外设设备
///   - completion: 接口回调
- (void)sendWithData:(NSDictionary *)dataDict forPeripheral:(SAPeripheralInfo *)peripheralInfo completion:(SABLECompletedBlock)completion {
    if (![dataDict isKindOfClass:NSDictionary.class]) {
        NSLog(@"----- sendWithData dataDict 必须是 NSDictionary");
        return;
    }
    m_dispatch_on_main_thread(^{
        [self _sendWithData:dataDict forPeripheral:peripheralInfo completion:completion];
    });
}

- (void)_sendWithData:(NSDictionary *)dataDict forPeripheral:(SAPeripheralInfo *)peripheralInfo completion:(SABLECompletedBlock)completion {
//#if DEBUG
    if (!peripheralInfo.peripheral) {
        NSString *logStr = [NSString stringWithFormat:@"\n[%@][BLE To Send][peripheral is nil]\nDetail=%@", [NSDate jvs_currentDateString], peripheralInfo.peripheralDetailInfo];
        JVSWriteNetLogToLocalFileWith(logStr);
    }
//#endif
    
    NSMutableDictionary *dict = [(dataDict?:@{}) mutableCopy];
    /// 可加锁
    int reqId = [self getTaskRequestId];
    [dict setObject:@(reqId) forKey:SABLERequestId];
    
    [self addResponseDelegateFor:peripheralInfo requestId:reqId completeBlock:completion];
    
    NSArray *datas = [self.writeDataCoder encodeDataWith:dict.m_JSONData];
    [datas enumerateObjectsUsingBlock:^(NSData *toSendData, NSUInteger idx, BOOL *stop) {
        m_dispatch_time_after_interval(0.02, ^{
            NSLog(@"------ \ntoSendData [%@] len=%d(%lu-%lu) - \n%@", peripheralInfo.identifier.UUIDString,
                  (int)toSendData.length, idx+1, datas.count, toSendData);
            NSString *logStr = [NSString stringWithFormat:@"\n[%@][BLE To Send][ReqId=%d][%@] \n%@\nDetail=%@",[NSDate jvs_currentDateString], reqId, [NSDate jvs_currentDateString],[NSString stringWithFormat:@"%@ %@", dict[@"method"], dict], peripheralInfo.peripheralDetailInfo];
            JVSWriteNetLogToLocalFileWith(logStr);
            
            [self _write:toSendData forPeripheral:peripheralInfo withResponsed:YES];
        });
    }];
}

-(int)getTaskRequestId {
    [_lock lock];
    _increasedReqId ++;
    [_lock unlock];
    return _increasedReqId;
}

#pragma mark --------------------------  处理外设备 发回来的数据
-(void)handleReceivedResWith:(NSDictionary *)json forPeripheral:(CBPeripheral *)peripheral {
    /// json 结果返回结果格式：
    /* {"method": "ifconfig_notify_ble_config_result",
        "param" : { "result"：0 // -2:AP不存在；-1：密码错误；9：配网失败；1：配网成功｝， }
        "result": {}
        "error": { "errorcode" : 0 }
       }
     */
    int reqId = [json[SABLERequestId] intValue];
    NSLog(@"--------- handleReceivedResWith reqId=%d \nRes=%@", reqId, json);
    if (reqId) {
        SABleResponseDelegate *wrap = [self responseDelegateFor:peripheral requestId:reqId];
        NSDictionary *error = json[@"error"];
        int errorCode = [error[@"errorcode"] intValue];
        NSString *msg = [error[@"message"] description] ?:@"Failed to BLE Configure";
        if (errorCode!=0) {
            NSLog(@"--------handleReceivedResWith ERROR:  %@", error[@"message"]);
            if(wrap.completedBlock) {
                NSError *error = [NSError errorWithDomain:@"com.jevotech" code:errorCode userInfo:@{NSLocalizedDescriptionKey: msg}];
                wrap.completedBlock(nil, error);
            }
            SAPeripheralInfo *info = [self getPeripheralInfoWith:peripheral.identifier.UUIDString];
            NSString *logStr = [NSString stringWithFormat:@"\n[%@][BLE Got][ReqId=%d] \n%@\nDetail=%@",[NSDate jvs_currentDateString], reqId,[NSString stringWithFormat:@"%@ %@", json[@"method"], json], info.peripheralDetailInfo];
            JVSWriteNetLogToLocalFileWith(logStr);

            [self removePeripWrapInfoWith:peripheral];
            return;
        }
        if(wrap.completedBlock) {
            /// 有可能没有result，但 该位置代表该请求成功了
            wrap.completedBlock(json[@"result"]?:@{}, nil);
        }
        [self removePeripWrapInfoWith:peripheral];
        return;
    }
    SAPeripheralInfo *info = [self getPeripheralInfoWith:peripheral.identifier.UUIDString];
    NSString *logStr = [NSString stringWithFormat:@"\n[%@][BLE Got][Not ReqId] \n%@\nDetail=%@", [NSDate jvs_currentDateString],[NSString stringWithFormat:@"%@ %@", json[@"method"], json], info.peripheralDetailInfo];
    JVSWriteNetLogToLocalFileWith(logStr);
    
    /// 服务端，主动发过来的请求数据 (不是回包)
    if ([_delegate respondsToSelector:@selector(bluetoothDidReadData:forPeripheral:)]) {
        SAPeripheralInfo *info = [self getPeripheralInfoWith:peripheral.identifier.UUIDString];
        [_delegate bluetoothDidReadData:json forPeripheral:info];
    }
    [self removePeripWrapInfoWith:peripheral];
}

-(void)processDataWith:(NSData *)partData forPeripheral:(CBPeripheral *)peripheral {
    /// 数据不对头，以防闪退
    if (![self.readDataCoder canDecodeDataWith:partData]) {
        return;
    }
    m_dispatch_on_main_thread(^{
        NSError *error;
        NSDictionary *result = [self.readDataCoder resultDataByAddingPartData:partData
                                                                        error:&error];
        if (!error && result) {  // 收到完整数据了
            [self handleReceivedResWith:result forPeripheral:peripheral];
        }
    });
}

/// 开始扫描周边蓝牙设备
- (void)startScanPeripheral {
    _bleState = -1;
    //停止之前的连接
    [self disconnectAllPeripherals];
    [self stopScanPeripheral];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    _baby.scanForPeripherals().begin();
    
    [self ble_centralManagerDidUpdateState:_baby.centralManager];
}

-(void)reScanPeripheral {
    [self stopScanPeripheral];
    //设置委托后直接可以使用，无需等待CBCentralManagerStatePoweredOn状态。
    _baby.scanForPeripherals().begin();
    
    [self ble_centralManagerDidUpdateState:_baby.centralManager];
}

/**  停止扫描周边蓝牙设备 */
- (void)stopScanPeripheral {
    [_baby cancelScan];
}

/** 连接所选取的蓝牙外设
 @param peripheralInfo 所选择蓝牙外设的perioheral
 */
-(void)connectPeripheral:(SAPeripheralInfo *)peripheralInfo {
    _baby.having(peripheralInfo.peripheral).then
        .connectToPeripherals().discoverServices().discoverCharacteristics().begin();
}

- (void)setupOptionsForScanPeripheralsWithServices:(NSArray<NSString *> *)peripheralWithServices {
    [self setupOptionsForScanPeripheralsWithServices:peripheralWithServices
                                discoverWithServices:@[] withCaracteristics:@[]];
}

- (void)setupOptionsForScanPeripheralsWithServices:(NSArray<NSString *> *)peripheralWithServices
                              discoverWithServices:(NSArray<NSString *> *)discoverWithServices
                                withCaracteristics:(NSArray<NSString *> *)characters {
    _serviceUUIDs = peripheralWithServices;
    _characterUUIDs = characters;
    _discoverWithServiceIds = discoverWithServices;
    
    NSMutableArray *sericeIds = @[].mutableCopy;
    NSMutableArray *characterIds = @[].mutableCopy;
    NSMutableArray *discoverServiceIds = @[].mutableCopy;
    [peripheralWithServices enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [sericeIds addObject:[CBUUID UUIDWithString:obj]];
    }];
    [discoverWithServices enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [discoverServiceIds addObject:[CBUUID UUIDWithString:obj]];
    }];
    [characters enumerateObjectsUsingBlock:^(NSString *obj, NSUInteger idx, BOOL *stop) {
        [characterIds addObject:[CBUUID UUIDWithString:obj]];
    }];
    
    // 为YES，否则从设备断开重连后，无法回调
    NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};
    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                    CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                    CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    //连接设备->
    [_baby setBabyOptionsWithScanForPeripheralsWithOptions:scanOptions
                              connectPeripheralWithOptions:connectOptions
                            scanForPeripheralsWithServices:sericeIds
                                      discoverWithServices:discoverServiceIds
                               discoverWithCharacteristics:characterIds
    ];
}


/** 断开当前连接的所有蓝牙设备  */
- (void)disconnectAllPeripherals {
    [_baby cancelAllPeripheralsConnection];
    
    [_scanPeripheralList removeAllObjects];
    [_peripheralsUUIDs removeAllObjects];
    [_periperalMapper removeAllObjects];
    
    [_mutableTaskDelegateForPeripheralId removeAllObjects];
}

/** 断开指定的蓝牙设备
 @param peripheralInfo 所选择蓝牙外设的perioheral
 */
- (void)disconnectWithPeripheral:(SAPeripheralInfo *)peripheralInfo {
    NSString *peripheralUUID = peripheralInfo.peripheral.identifier.UUIDString;
    
    [_periperalMapper removeObjectForKey:peripheralUUID];
    [_peripheralsUUIDs removeObject:peripheralUUID];
    [_scanPeripheralList removeObject:peripheralInfo];
    [_mutableTaskDelegateForPeripheralId removeObjectForKey:peripheralUUID];
    
    [_baby cancelPeripheralConnection:peripheralInfo.peripheral];
}

#pragma mark --------------------------  蓝牙委托方法设置和回调处理
-(void)setupBabyBLEDelegate {
    __weak __typeof(self) weak_self = self;
    [_baby setBlockOnCentralManagerDidUpdateState:^(CBCentralManager *central) {
//        NSLog(@"--- setBlockOnCentralManagerDidUpdateState");
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            [weak_self ble_centralManagerDidUpdateState:central];
        });
    }];
    [_baby setBlockOnConnected:^(CBCentralManager *central, CBPeripheral *peripheral) {
//        NSLog(@"--- setBlockOnConnected");
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            [weak_self ble_didConnectPeripheral:peripheral];
        });
    }];
    [_baby setBlockOnFailToConnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//        NSLog(@"--- setBlockOnFailToConnect");
        SAPeripheralInfo *info = [weak_self getPeripheralInfoWith:peripheral.identifier.UUIDString ];
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            if ([weak_self.delegate
                 respondsToSelector:@selector(bluetoothDidConnectFailedPeripheral:error:)])
            [weak_self.delegate bluetoothDidConnectFailedPeripheral:info error:error];
        });
    }];
    //设置扫描到设备的委托
    [_baby setBlockOnDiscoverToPeripherals:^(CBCentralManager *central, CBPeripheral *peripheral, NSDictionary *advertisementData, NSNumber *RSSI) {
//        NSLog(@"--- setBlockOnDiscoverToPeripherals %@", peripheral);
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            [weak_self ble_discoverToPeripheral:peripheral advertisementData:advertisementData RSSI:RSSI];
        });
    }];
    //设置发现设service的Characteristics的委托
    [_baby setBlockOnDiscoverCharacteristics:^(CBPeripheral *peripheral, CBService *service, NSError *error) {
        NSLog(@"--- setBlockOnDiscoverCharacteristics %@", peripheral);
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            [weak_self ble_discoverCharacteristics:peripheral service:service error:error];
        });
    }];
    [_baby setBlockOnReadValueForCharacteristic:^(CBPeripheral *peripheral, CBCharacteristic *characteristic, NSError *error) {
        NSLog(@"--- setBlockOnReadValueForCharacteristic %@", peripheral);
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            [weak_self ble_onReadValueForCBPeripheral:peripheral character:characteristic error:error];
        });
    }];
    //设置查找设备的过滤器
    [_baby setFilterOnDiscoverPeripherals:^BOOL(NSString *peripheralName, NSDictionary *advertisementData, NSNumber *RSSI) {
//        NSLog(@"--- setFilterOnDiscoverPeripherals");
        if ([weak_self.delegate respondsToSelector:@selector(bluetoothFilterOnDiscoverPeripheralName:advertisementData:)]) {
            return [weak_self.delegate bluetoothFilterOnDiscoverPeripheralName:peripheralName advertisementData:advertisementData];
        }
        NSData *manufactureData = advertisementData[CBAdvertisementDataManufacturerDataKey]; // @"kCBAdvDataManufacturerData"
        if (!manufactureData || peripheralName.length<=8) {
            return NO;
        }
        NSString *mData = @"";
        if ([manufactureData isKindOfClass:NSData.class]) {
            mData = [[NSString alloc] initWithData:manufactureData encoding:4];
        }
        if (!mData.length) return NO;
        return [mData containsString:@"JOVISION"];
    }];
    /// 外设 断开连接了
    [_baby setBlockOnDisconnect:^(CBCentralManager *central, CBPeripheral *peripheral, NSError *error) {
//        NSLog(@"--- setBlockOnDisconnect");
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            [weak_self ble_disconnectPeripheral:peripheral error:error];
        });
    }];
    // 为YES，否则从设备断开重连后，无法回调
    NSDictionary *scanOptions = @{CBCentralManagerScanOptionAllowDuplicatesKey:@YES};

    NSDictionary *connectOptions = @{CBConnectPeripheralOptionNotifyOnConnectionKey:@YES,
                                    CBConnectPeripheralOptionNotifyOnDisconnectionKey:@YES,
                                    CBConnectPeripheralOptionNotifyOnNotificationKey:@YES};
    //设置 连接设备 选项
    [_baby setBabyOptionsWithScanForPeripheralsWithOptions:scanOptions
                              connectPeripheralWithOptions:connectOptions
                            scanForPeripheralsWithServices:nil
                                      discoverWithServices:nil
                               discoverWithCharacteristics:nil];
}

-(void)ble_centralManagerDidUpdateState:(CBCentralManager *)central {

    if ( central.state != _bleState ) {
        /// 变化了才回调
        if ([_delegate respondsToSelector:@selector(bluetoothDidUpdateState:)]) {
            [_delegate bluetoothDidUpdateState:central.state];
        }
        _bleState = central.state;
    }    
    _bleState = central.state;
    if (_bleStateDidUpdateBlock) {
        _bleStateDidUpdateBlock(central.state);
    }
}

//1 先发现设备
-(void)ble_discoverToPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary *)adData RSSI:(NSNumber *)RSSI {
    NSString *targetUUID = peripheral.identifier.UUIDString;
    if ([_peripheralsUUIDs containsObject:targetUUID]) {
        /// 相同了，直接过滤
//        NSLog(@"------ ble_discoverToPeripheral  相同了，直接过滤");
        return;
    }
    [_peripheralsUUIDs addObject:targetUUID];
    
    SAPeripheralInfo *info = [SAPeripheralInfo modelWithPeripheral:peripheral adData:adData RSSI:RSSI];
    [_scanPeripheralList addObject:info];
    [_periperalMapper setObject:info forKey:targetUUID];
    
    if ([_delegate respondsToSelector:@selector(bluetoothDidScanPeripherals:)]) {
        [_delegate bluetoothDidScanPeripherals:_scanPeripheralList.copy];
    }
}
/// 2.1 连接设备
-(void)ble_didConnectPeripheral:(CBPeripheral *)peripheral {
    NSString *peripheralUUID = peripheral.identifier.UUIDString;
    SAPeripheralInfo *info = [self getPeripheralInfoWith:peripheralUUID];
    info.hasConnectBefore = YES;
    if ([_delegate
         respondsToSelector:@selector(bluetoothDidConnectPeripheral:)]) {
        [_delegate bluetoothDidConnectPeripheral:info];
    }
}


// 2.2、 连接之后，发现 <指定>服务的 读,写,通知的特性 Characteristics
-(void)ble_discoverCharacteristics:(CBPeripheral *)peripheral service:(CBService *)service error:(NSError *)error {
    NSString *serviceUUID = service.UUID.UUIDString;
    NSString *peripheralUUID = peripheral.identifier.UUIDString;
    if (error) {
        NSLog(@"===ble_discoverCharacteristicsFailed : %@ - %@", peripheralUUID, error);
        return;
    }
    if (![serviceUUID isEqualToString:SAServiceUUID]) {
        return;
    }
//    if (_serviceUUIDs.count && ![_serviceUUIDs containsObject:uuid]) {
//        // 对方可能开了多个服务 ==  非指定的 SAServiceUUID 不要
//        return;
//    }
    SAPeripheralInfo *info = [self getPeripheralInfoWith:peripheralUUID];
    NSLog(@"------------- ble_discoverCharacteristics\nName: %@ \nperipheralUUID: %@ \nServiceUUID: %@\ninfo.writeCharacteristic=%@",
          service.peripheral.name, peripheralUUID, service.UUID.UUIDString, info.writeCharacteristic);
    if (info.writeCharacteristic && [_peripheralsUUIDs containsObject:peripheralUUID]) {
        // 列表已经存在了，不用再设置了
        return;
    }
    for (CBCharacteristic *character in service.characteristics) {
        CBCharacteristicProperties properties = character.properties;
        if (properties & CBCharacteristicPropertyRead) {
            [peripheral readValueForCharacteristic:character];
        }
        if (properties & CBCharacteristicPropertyWrite) {
            //如果具备写入值的特性，这个应该会有一些响应，需等待响应
            info.writeCharacteristic = character;
        }
        if (properties & CBCharacteristicPropertyNotify) {
            info.notifCharacteristic = character;
            [peripheral setNotifyValue:YES forCharacteristic:character];
        }
    }
    NSLog(@"------------- bluetoothBeReadyToWriteData \n[%@] ServiceId=%@", peripheral.identifier.UUIDString, service.UUID.UUIDString);
    m_dispatch_time_after_interval(0.02, ^{
        if ([self->_delegate respondsToSelector:@selector(bluetoothBeReadyToWriteData:)]) {
            [self->_delegate bluetoothBeReadyToWriteData:info];
        }
    });
}
//3 、 读和写 数据
-(void)ble_onReadValueForCBPeripheral:(CBPeripheral *)peripheral character:(CBCharacteristic *)character error:(NSError *)error {
    NSString *peripheralUUID = peripheral.identifier.UUIDString;
    if (error) {
        NSLog(@"------------- ble_onReadValueForCBPeripheral \n[%@] %@", peripheralUUID, error);
        if ([_peripheralsUUIDs containsObject:peripheralUUID]) {
            NSString *logStr = [NSString stringWithFormat:@"\n[%@][BLE ReadValue Error]\nperipheralUUID=%@\nError=%@", [NSDate jvs_currentDateString], peripheralUUID, error.localizedDescription ];
            JVSWriteNetLogToLocalFileWith(logStr);
        }
        return;
    }
    /// 读取到了外设的 返回值
    [self getPeripheralInfoWith:peripheralUUID];
    [self processDataWith:character.value forPeripheral:peripheral];
}

-(void)ble_disconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error {
    NSString *peripheralUUID = peripheral.identifier.UUIDString;
    SAPeripheralInfo *info = [self getPeripheralInfoWith:peripheralUUID];
    
    NSLog(@"------ [%@] ble_disconnectPeripheral\nError=%@", peripheralUUID, error);
    if (info.hasConnectBefore && info.isJovisionManufacturer) {  // 之前链接，然后断开连接了
        NSString *logStr = [NSString stringWithFormat:@"\n[%@][BLE Disconnect]\nperipheralUUID=%@\nError=%@", [NSDate jvs_currentDateString], peripheralUUID, error.localizedDescription ];
        JVSWriteNetLogToLocalFileWith(logStr);
    }
        
    if ([_delegate respondsToSelector:@selector(bluetoothDidDisconnectPeripheral:error:)]) {
        [_delegate bluetoothDidDisconnectPeripheral:info error:error];
    }
//    if (_delegate && info.isJovisionManufacturer && info.hasConnectBefore && !info.hasConfigWifi) {
//        SABluetoothDisconnectVC *vc = [SABluetoothDisconnectVC jvs_instance];
//        vc.deviceSn = info.peripheral.name;
//        UIViewController *top = [UIViewController jvs_getCurrentController];
//        [top.navigationController pushViewController:vc animated:YES];
//    }
}

-(void)dealloc {
    NSLog(@"---------- %@ Dealloc", self);
    [_baby cancelAllPeripheralsConnection];
    [_baby stop];
}

#pragma mark --------------------------  Setter & Getter
-(void)updateBleStateWithBlock:(SAStateDidUpdateBlock)bleStateDidUpdateBlock {
    _bleStateDidUpdateBlock = bleStateDidUpdateBlock;
    if (_bleState && _bleStateDidUpdateBlock) {
        _bleStateDidUpdateBlock(_bleState);
    }
}
/// 获取定位信息
-(void)updateLocationWithBlock:(SAStateDidUpdateBlock)locationStateDidUpdateBlock {
    _locationStateDidUpdateBlock = locationStateDidUpdateBlock;
    [self _updateLocationWithBlock:locationStateDidUpdateBlock];  // 需在主线程
}
-(void)_updateLocationWithBlock:(SAStateDidUpdateBlock)locationStateDidUpdateBlock {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    }
    if (locationStateDidUpdateBlock) {
        if (@available(iOS 14.0, *)) {
            _locationStatus = [_locationManager authorizationStatus];
        } else {
            _locationStatus = [CLLocationManager authorizationStatus];
        }
        if (_locationStatus>0) {
            m_dispatch_on_main_thread(^{
                locationStateDidUpdateBlock(self->_locationStatus);
            });
        }
    }
    [_locationManager requestWhenInUseAuthorization];
    [_locationManager requestAlwaysAuthorization];

}

-(CBManagerState)bleState {
    return _bleState;
}
-(NSArray<SAPeripheralInfo *> *)connectedPeripheralList {
    NSMutableArray *array = @[].mutableCopy;
    [_scanPeripheralList enumerateObjectsUsingBlock:^(SAPeripheralInfo *obj, NSUInteger idx, BOOL *stop) {
        if (obj.isConnected) {
            [array addObject:obj];
        }
    }];
    return array;
}

-(SAPeripheralInfo *)getPeripheralInfoWith:(NSString *)uuid {
    if (!uuid) return nil;
    if (!_periperalMapper) _periperalMapper = @{}.mutableCopy;
    return _periperalMapper[[uuid description]];
}

-(NSArray<SAPeripheralInfo *> *)scannedPeripheralList {
    return _scanPeripheralList.copy;
}

-(SABlePeripheralTaskDelegate *)peripheralTaskDelegateFor:(CBPeripheral *)info {
    if (!info) return nil;
    if (!_mutableTaskDelegateForPeripheralId) _mutableTaskDelegateForPeripheralId = @{}.mutableCopy;
    
    NSString *peripheralUUID = info.identifier.UUIDString;
    SABlePeripheralTaskDelegate *wrapInfo = _mutableTaskDelegateForPeripheralId[peripheralUUID];
    if (!wrapInfo) {
        wrapInfo = SABlePeripheralTaskDelegate.new;
        [_mutableTaskDelegateForPeripheralId setObject:wrapInfo forKey:peripheralUUID];
    }
    return wrapInfo;
}

-(void)removePeripWrapInfoWith:(CBPeripheral *)info {
    if (!info) return;
    
    NSString *peripheralUUID = info.identifier.UUIDString;
    SABlePeripheralTaskDelegate *wrapInfo = _mutableTaskDelegateForPeripheralId[peripheralUUID];
    [wrapInfo.mutableReponseDelegateForRequestId removeAllObjects];
}

-(SABleResponseDelegate *)responseDelegateFor:(CBPeripheral *)peripheral requestId:(int)requestId {
    SABlePeripheralTaskDelegate *wrapInfo = [self peripheralTaskDelegateFor:peripheral];
    SABleResponseDelegate *model = wrapInfo.mutableReponseDelegateForRequestId[@(requestId)];
    return model;
}

-(SABleResponseDelegate *) addResponseDelegateFor:(SAPeripheralInfo *)peripheral requestId:(int)requestId completeBlock:(SABLECompletedBlock)completeBlock {
    SABlePeripheralTaskDelegate *wrapInfo = [self peripheralTaskDelegateFor:peripheral.peripheral];
    if (!wrapInfo.mutableReponseDelegateForRequestId) wrapInfo.mutableReponseDelegateForRequestId=@{}.mutableCopy;
    SABleResponseDelegate *model = wrapInfo.mutableReponseDelegateForRequestId[@(requestId)];
    if (!model) {
        model = SABleResponseDelegate.new;
        [wrapInfo.mutableReponseDelegateForRequestId setObject:model forKey:@(requestId)];
    }
    model.taskId = requestId;
    model.completedBlock = completeBlock;
    return model;
}


-(SABleReadDataCoder *)readDataCoder {
    if (!_readDataCoder) {
        _readDataCoder = SABleReadDataCoder.new;
    }
    return _readDataCoder;
}
-(SABleWriteDataCoder *)writeDataCoder {
    if (!_writeDataCoder) {
        _writeDataCoder = SABleWriteDataCoder.new;
    }
    return _writeDataCoder;
}


#pragma mark -------------------------- CLLocationManagerDelegate
- (void)locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    [self _locationManagerDidChangeAuthorization:manager];
}
- (void)_locationManagerDidChangeAuthorization:(CLLocationManager *)manager {
    NSLog(@"-------------  locationManagerDidChangeAuthorization");
    m_dispatch_on_main_thread(^{
        if (_locationStateDidUpdateBlock) {
            if (@available(iOS 14.0, *)) {
                _locationStatus = manager.authorizationStatus;
            } else {
                _locationStatus = [CLLocationManager authorizationStatus];
            }
            _locationStateDidUpdateBlock(_locationStatus);
        }
    });
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status {
    [self _locationManagerDidChangeAuthorization:manager];
}



@end
