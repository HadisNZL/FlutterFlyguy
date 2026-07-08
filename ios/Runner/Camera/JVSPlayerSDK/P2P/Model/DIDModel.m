//
//  DIDModel.m
//  P2PTester
//
//  Created by yc on 2021/2/2.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import "DIDModel.h"

static NSString *DID_Key        = @"DID_Key";
static NSString *License_Key    = @"License_Key";
static NSString *CRCKey_Key     = @"CRCKey_Key";
static NSString *InitString_Key = @"InitString_Key";
static NSString *WakeupKey_Key  = @"WakeupKey_Key";
static NSString *IP1_Key        = @"IP1_Key";
static NSString *IP2_Key        = @"IP2_Key";
static NSString *IP3_Key        = @"IP3_Key";

@implementation DIDModel

- (instancetype)initWithDID:(NSString *)did InitString:(NSString *)initString {
    
    self = [super init];
    if (self) {
        self.DID        = [NSString stringWithString:did];
        self.InitString = [NSString stringWithString:initString];
        self.APILicense = @"";
        self.CRCKey     = @"";
        self.WakeupKey  = @"";
        self.ServerIP1  = @"";
        self.ServerIP2  = @"";
        self.ServerIP3  = @"";
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)diction {
    self = [super init];
    if (self) {
        self.DID = diction[DID_Key];
        self.InitString = diction[InitString_Key];
        self.APILicense = diction[License_Key];;
        self.CRCKey     = diction[CRCKey_Key];;
        self.WakeupKey  = diction[WakeupKey_Key];;
        self.ServerIP1  = diction[IP1_Key];;
        self.ServerIP2  = diction[IP2_Key];;
        self.ServerIP3  = diction[IP3_Key];;
    }
    return self;
}

- (NSDictionary *)toDictionary {
    NSMutableDictionary *dic = [NSMutableDictionary dictionary];
    [dic setObject:self.DID        forKey:DID_Key];
    [dic setObject:self.InitString forKey:InitString_Key];
    [dic setObject:self.APILicense forKey:License_Key];
    [dic setObject:self.CRCKey     forKey:CRCKey_Key];
    [dic setObject:self.WakeupKey  forKey:WakeupKey_Key];
    [dic setObject:self.ServerIP1  forKey:IP1_Key];
    [dic setObject:self.ServerIP2  forKey:IP2_Key];
    [dic setObject:self.ServerIP3  forKey:IP3_Key];
    
    return [NSDictionary dictionaryWithDictionary:dic];
}

- (NSString *)toString {
    NSMutableString *str = [NSMutableString stringWithFormat:@"{DID:%@, Repeat:%d", self.DID, self.Repeat];
    if (self.InitString.length != 0) [str appendFormat:@", InitString:%@", self.InitString];
    if (self.APILicense.length != 0) [str appendFormat:@", APILicense:%@", self.APILicense];
    if (self.CRCKey.length != 0) [str appendFormat:@", CRCKey:%@", self.CRCKey];
    if (self.WakeupKey.length != 0) [str appendFormat:@", WakeupKey:%@", self.WakeupKey];
    if (self.ServerIP1.length != 0) [str appendFormat:@", ServerIP1:%@", self.ServerIP1];
    if (self.ServerIP2.length != 0) [str appendFormat:@", ServerIP2:%@", self.ServerIP2];
    if (self.ServerIP3.length != 0) [str appendFormat:@", ServerIP3:%@", self.ServerIP3];
    [str appendString:@"}"];
    
    return str;
}

+ (BOOL)isSame:(DIDModel *)model Sec:(DIDModel *)secModel {
    
    if (![model.DID isEqualToString:secModel.DID]) {
        return NO;
    }
    
    if (![model.APILicense isEqualToString:secModel.APILicense]) {
        return NO;
    }
    
    if (![model.CRCKey isEqualToString:secModel.CRCKey]) {
        return NO;
    }
    
    if (![model.InitString isEqualToString:secModel.InitString]) {
        return NO;
    }
    
    if (![model.WakeupKey isEqualToString:secModel.WakeupKey]) {
        return NO;
    }
    
    if (![model.ServerIP1 isEqualToString:secModel.ServerIP1]) {
        return NO;
    }
    
    if (![model.ServerIP2 isEqualToString:secModel.ServerIP2]) {
        return NO;
    }
    
    return [model.ServerIP3 isEqualToString:secModel.ServerIP3];
}

@end
