//
//  UDPRecvEchoModel.h
//  P2PTester
//
//
//  Created by yc on 2021/2/1.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import <Foundation/Foundation.h>

#if Allow_RE_DeBug == 1
#define RELog(fmt, ...) NSLog((@"UDP_RECV_ECHO(%d): " fmt), __LINE__, ##__VA_ARGS__)
#else
#define RELog(fmt, ...)
#endif

NS_ASSUME_NONNULL_BEGIN

@interface UDPRecvEchoModel : NSObject

@property (nonatomic, assign) BOOL stopRun;
@property (nonatomic, assign) int  binPort;

@property (nonatomic, copy) NSString *myIP;

+ (instancetype)shareInstance;

- (void)startWithIP:(NSString *)ip Port:(int)port;

@end

NS_ASSUME_NONNULL_END
