//
//  DIDModel.h
//  P2PTester
//
//  Created by yc on 2021/2/2.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DIDModel : NSObject

@property (nonatomic, copy)     NSString *DID;

@property (nonatomic, copy)     NSString *InitString;
@property (nonatomic, copy)     NSString *APILicense;
@property (nonatomic, copy)     NSString *CRCKey;

@property (nonatomic, copy)     NSString *WakeupInfo;

@property (nonatomic, copy)     NSString *WakeupKey;
@property (nonatomic, copy)     NSString *ServerIP1;
@property (nonatomic, copy)     NSString *ServerIP2;
@property (nonatomic, copy)     NSString *ServerIP3;

@property (nonatomic, assign)   int Repeat;
@property (nonatomic, assign)   int DelaySec;
@property (nonatomic, assign)   int Timeout_0x7X;

@property (nonatomic, assign)   int Mode;
@property (nonatomic, assign)   int ThreadNum;
@property (nonatomic, assign)   int SizeOption;
@property (nonatomic, assign)   int Direction;

/// P2P / RLP/ Lan
@property (nonatomic, copy)     NSString *modeString;

- (instancetype)initWithDID:(NSString *)did InitString:(NSString *)initString;

- (instancetype)initWithDictionary:(NSDictionary *)diction;

- (NSDictionary *)toDictionary;
- (NSString *)toString;

+ (BOOL)isSame:(DIDModel *)model Sec:(DIDModel *)secModel;

@end

NS_ASSUME_NONNULL_END
