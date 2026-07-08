//
//  DCSModel.m
//  P2PTester
//
//  Created by yc on 2022/3/28.
//

#import "DCSModel.h"
#import <arpa/inet.h>
#import <netdb.h>

#include <sys/select.h>
#include <sys/time.h>
#include <unistd.h>


@implementation DCSModel

+ (instancetype)dcsModelWithPacket:(char *)packet Size:(int)size Index:(int)index Addr:(struct sockaddr_in)addr {
    
    DCSModel *model = [[DCSModel alloc] init];
    model.getRespAck = NO;
    model.respSendCount = 0;
    model.lastRespTime = 0;
    
    model.addr = addr;
    model.cmdIndex = index;
    
    model.packet = [NSString stringWithUTF8String:packet];
    model.DCSTRID = [[NSString alloc] initWithBytes:packet length:32 encoding:NSUTF8StringEncoding];
    model.DCmd = [[NSString alloc] initWithBytes:packet+32 length:size-32 encoding:NSUTF8StringEncoding];
    
    return model;
}

- (NSString *)toString {
    return [NSString stringWithFormat:@"{DCmdIndex=%d, TRID=%@, DCmd=%@, getRespAck=%s}",
            self.cmdIndex, self.DCSTRID, self.DCmd, self.getRespAck ? "Yes":"No"];
}

@end
