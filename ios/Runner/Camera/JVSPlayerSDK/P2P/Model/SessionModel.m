//
//  SessionModel.m
//  P2PTester
//
//  Created by yc on 2021/2/1.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import "SessionModel.h"
#import <arpa/inet.h>

@implementation SessionModel

+ (instancetype)SessionInfoWithSession:(int)session Info:(st_PPCS_Session)sInfo {
    
    SessionModel *info = [[SessionModel alloc] init];
    
    info.did = [NSString stringWithFormat:@"%s", sInfo.DID];
    
    char lan[20], wan[20], remote[20];
    strcpy(lan, inet_ntoa(sInfo.MyLocalAddr.sin_addr));
    strcpy(wan, inet_ntoa(sInfo.MyWanAddr.sin_addr));
    strcpy(remote, inet_ntoa(sInfo.RemoteAddr.sin_addr));
    
    info.remote_ip = [NSString stringWithFormat:@"%s", remote];
    info.my_lan_ip = [NSString stringWithFormat:@"%s", lan];
    info.my_wan_ip = [NSString stringWithFormat:@"%s", wan];
    
    info.supportPkt = YES;
    if (sInfo.bMode == 0) {
        if (isLANcmp([info.my_lan_ip UTF8String], [info.remote_ip UTF8String]) == 1) {
            info.mode = @"LAN";
        } else {
            info.mode = @"P2P";
        }
        if (getSocketType(sInfo.Skt) == 1) {
            info.mode = [NSString stringWithFormat:@"%@.", info.mode];
            info.supportPkt = NO;
        }
    } else if (sInfo.bMode == 1) {
        info.mode = @"RLY";
    } else if (sInfo.bMode == 2) {
        info.mode = @"TCP";
        info.supportPkt = NO;
    } else if (sInfo.bMode == 3) {
        info.mode = @"RP2P";
    }
    
    info.skt = sInfo.Skt;
    info.session = session;
    info.is_device = sInfo.bCorD == 1;
    info.connect_time = sInfo.ConnectTime;
    info.remote_port = ntohs(sInfo.RemoteAddr.sin_port);
    info.my_lan_port = ntohs(sInfo.MyLocalAddr.sin_port);
    info.my_wan_port = ntohs(sInfo.MyWanAddr.sin_port);
    
    return info;
}

- (NSString *)showSessionInfo {
    
    NSString *sInfoString = [NSString stringWithFormat:@"--------------- Session(%d) Info -------------\n", self.session];
    sInfoString = [sInfoString stringByAppendingFormat:@"Socket: %d\n", self.skt];
    sInfoString = [sInfoString stringByAppendingFormat:@"Remote Addr: %@:%d\n", self.remote_ip, self.remote_port];
    sInfoString = [sInfoString stringByAppendingFormat:@"My Lan Addr: %@:%d\n", self.my_lan_ip, self.my_lan_port];
    sInfoString = [sInfoString stringByAppendingFormat:@"My Wan Addr: %@:%d\n", self.my_wan_ip, self.my_wan_port];
    sInfoString = [sInfoString stringByAppendingFormat:@"Connection time: %d second before\n", self.connect_time];
    sInfoString = [sInfoString stringByAppendingFormat:@"DID: %@\n", self.did];
    sInfoString = [sInfoString stringByAppendingFormat:@"I am %s\n", self.is_device ? "Device" : "Client"];
    sInfoString = [sInfoString stringByAppendingFormat:@"Connection Mode: %@\n", self.mode];
    sInfoString = [sInfoString stringByAppendingFormat:@"----------------------------------------------\n"];
    return sInfoString;
}

@end
