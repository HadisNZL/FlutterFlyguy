//
//  SessionModel.h
//  P2PTester
//
//  Created by yc on 2021/2/1.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import <Foundation/Foundation.h>
#include "PPCS_API.h"
#import "P2PUtil.h"

NS_ASSUME_NONNULL_BEGIN

@interface SessionModel : NSObject

@property (nonatomic, assign) int session;
@property (nonatomic, assign) int skt;
@property (nonatomic, assign) int remote_port;
@property (nonatomic, assign) int my_lan_port;
@property (nonatomic, assign) int my_wan_port;

@property (nonatomic, copy) NSString *remote_ip;
@property (nonatomic, copy) NSString *my_lan_ip;
@property (nonatomic, copy) NSString *my_wan_ip;

@property (nonatomic, copy) NSString *did;
@property (nonatomic, copy) NSString *mode;

@property (nonatomic, assign) unsigned int connect_time;

@property (nonatomic, assign) BOOL is_device;

@property (nonatomic, assign) BOOL supportPkt;

+ (instancetype)SessionInfoWithSession:(int)session Info:(st_PPCS_Session)sInfo;

- (NSString *)showSessionInfo;

@end

NS_ASSUME_NONNULL_END
