//
//  WakeupQueryModel.h
//  P2PTester
//
//  Created by yc on 2021/2/7.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import <Foundation/Foundation.h>

#if Allow_WQ_DeBug == 1
#define WQLog(fmt, ...) NSLog((@"W: " fmt), ##__VA_ARGS__);
#else
#define WQLog(fmt, ...) ;
#endif

NS_ASSUME_NONNULL_BEGIN

@interface WakeupQueryModel : NSObject

@property (nonatomic, assign) BOOL stopQuery;

@property (nonatomic, assign) int  timeout;
@property (nonatomic, assign) int  repeatNumber;

@property (nonatomic, strong) NSMutableDictionary *lastLoginDiction;

/// Request the Wakeup Server for the last sleeplogin time of the device.
/// @param wakeupKey the Wakeup Server encryption and decryption key.
/// @param did DID of the target device.
/// @param ipArray the Wakeup Server ip array. 
- (int)queryWithWakeupKey:(NSString *)wakeupKey DID:(NSString *)did IPs:(NSArray *)ipArray;

@end

NS_ASSUME_NONNULL_END
