//
//  UDPRecvEchoModel.m
//  P2PTester
//
//  Created by yc on 2021/2/1.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import "UDPRecvEchoModel.h"
#import <arpa/inet.h>
#import <netdb.h>

#include <sys/select.h>
#include <sys/time.h>
#include <unistd.h>

static const int select_timeout = 500;

@implementation UDPRecvEchoModel

+ (instancetype)shareInstance {
    
    static UDPRecvEchoModel *model = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        model = [[UDPRecvEchoModel alloc] init];
        model.stopRun = YES;
    });
    return model;
}

- (void)startWithIP:(NSString *)ip Port:(int)port {
    
    self.binPort = port;
    self.myIP = ip;
    RELog(@"UDP_RECV_ECHO() start with %@:%d.", ip, port);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        RELog(@"Port=%d running.", port);
        int mSocket;
        self.stopRun = NO;
        
        if ((mSocket = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
            RELog(@"socket create fail error: %s", strerror(errno));
            return;
        }
        RELog(@"UDP_RECV_ECHO() create socket=%d.", mSocket);
        
        struct sockaddr_in localAddr = {0};
        localAddr.sin_len = sizeof(localAddr);
        localAddr.sin_family = AF_INET;
        localAddr.sin_addr.s_addr = inet_addr([ip UTF8String]);
        localAddr.sin_port = htons(port);
        
        if (bind(mSocket, (struct sockaddr *)&localAddr, sizeof(localAddr)) == -1) {
            RELog(@"socket bin error: %s", strerror(errno));
            close(mSocket);
            return;
        }
        
        struct timeval timeout = {0, select_timeout * 1000};
        fd_set readFd;
        
        char message[1024] = {0};
        struct sockaddr_in addr;
        unsigned int addr_size = sizeof(addr);
        ssize_t recv_size;
        
        RELog(@"start select timeout=%d", select_timeout);
        while (!self.stopRun) {
            
            memset(message, 0, sizeof(message));
            FD_ZERO(&readFd);
            FD_SET(mSocket, &readFd);
            
            int ret = select(mSocket + 1, &readFd, NULL, NULL, &timeout);
            
            switch (ret) {
                case 0:     // timeout
                    continue;
                break;
                case -1:    // errno
                    RELog(@"select error: %s", strerror(errno));
                    close(mSocket);
                    return;
                break;
                default:    // recv echo packet
                    if (FD_ISSET(mSocket, &readFd)) {
                        recv_size = recvfrom(mSocket, message, sizeof(message), 0, (struct sockaddr*)&addr, &addr_size);
                        if (recv_size == -1) {
                            RELog(@"recvfrom fail errno: %s", strerror(errno));
                            continue;
                        }
                        recv_size =  sendto(mSocket, message, sizeof(message), 0, (struct sockaddr*)&addr, addr_size);
                        if (recv_size == -1) {
                            RELog(@"sendto fail errno: %s", strerror(errno));
                            continue;
                        }
                        RELog(@"$$$ sendto success! Size=%zd", recv_size);
                    }
                    break;
            }
        }
        close(mSocket);
        RELog(@"UDP_RECV_ECHO() exit, socket close.");
        
        return;
    });
}

@end
