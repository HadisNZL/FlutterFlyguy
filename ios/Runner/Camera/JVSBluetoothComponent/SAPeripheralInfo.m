//
//  SABlePeripheralInfo.m
//  SAASTest
//
//  Created by 李华 on 2024/1/19.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import "SAPeripheralInfo.h"
#import <JVSBasicToolFramework/NSObject+JSONFormat.h>

@implementation SAPeripheralInfo

+(instancetype)modelWithPeripheral:(CBPeripheral *)peripheral adData:(NSDictionary *)adData RSSI:(NSNumber *)RSSI {
    SAPeripheralInfo *info = SAPeripheralInfo.new;
    info.peripheral = peripheral;
    info.advertisementData = adData;
    info.RSSI = RSSI;
    return info;
}
+(instancetype)modelWithPeripheral:(CBPeripheral *)peripheral adData:(NSDictionary *)adData {
    return [self modelWithPeripheral:peripheral adData:adData RSSI:@(0)];
}

-(void)setAdvertisementData:(NSDictionary *)advertisementData {
    _advertisementData = advertisementData;
    _nameFromAdverisementData = advertisementData[@"kCBAdvDataLocalName"];
    
    NSData *manufactureData = advertisementData[@"kCBAdvDataManufacturerData"];
    if (manufactureData) {
        NSString *mData = @"";
        if ([manufactureData isKindOfClass:NSData.class]) {
            mData = [[NSString alloc] initWithData:manufactureData encoding:4];
        }
        _isJovisionManufacturer = [mData containsString:@"JOVISION"];
    }
    
}

-(BOOL)isEqual:(SAPeripheralInfo *)object {
    if (!object || ![object isKindOfClass:SAPeripheralInfo.class]) return NO;
    return [object.peripheral.identifier isEqual:self.peripheral.identifier];
}

-(NSUUID *)identifier {
    return _peripheral.identifier;
}

-(NSString *)deviceSn { return _peripheral.name; }

-(BOOL)isConnected {
    return _peripheral.state==CBPeripheralStateConnected;
}

-(NSString *)peripheralDetailInfo {
    return [NSString stringWithFormat:@"\nstate=%ld\tRSSI=%@\tname=%@\tperipheralUUID=%@\nSerivce=%@\nAd=%@", _peripheral.state, _peripheral.RSSI?:@"0",
            _peripheral.name?:@"", [self identifier].UUIDString?:@"", _peripheral.services.m_JSONString?:@"", _advertisementData?:@""];
}

@end
