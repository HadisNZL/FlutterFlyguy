//
//  WakeupQueryModel.m
//  P2PTester
//
//  Created by yc on 2021/2/7.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import "WakeupQueryModel.h"
#import "P2PSDKHeader.h"

@interface WakeupQueryModel()

@property (nonatomic, strong) NSMutableDictionary *timeCountDiction;

@end

@implementation WakeupQueryModel

- (instancetype)init {
    self = [super init];
    if (self) {
        self.timeout = 3;
        self.repeatNumber = 5;
    }
    return self;
}

- (int)queryWithWakeupKey:(NSString *)wakeupKey DID:(NSString *)did IPs:(NSArray *)ipArray {
    
    WQLog(@"query() WakeupKey=%@, DID=%@, IPs=[%@, %@, %@]", wakeupKey, did, ipArray[0], ipArray[1], ipArray[2]);
    
    self.lastLoginDiction = [NSMutableDictionary dictionaryWithCapacity:0];
    self.timeCountDiction = [NSMutableDictionary dictionaryWithCapacity:0];
    struct sockaddr_in serverAddr[Wakeup_Server_Num];
    
    for (int item = 0; item < ipArray.count; item++) {
        if (ipArray[item] != nil && ![ipArray[item] isEqualToString:@""]) {
            [_lastLoginDiction setObject:@(ERROR_Wakeup_UnKnown) forKey:ipArray[item]];
            serverAddr[item].sin_addr.s_addr = inet_addr([ipArray[item] UTF8String]);
            serverAddr[item].sin_family = AF_INET;
            serverAddr[item].sin_port = htons(12305);
        }
    }
    if (_lastLoginDiction.count == 0) {
        WQLog(@"ERROR_Wakeup_InvalidParameter");
        return ERROR_Wakeup_InvalidParameter;
    }
    
    CHAR wakeupCMD[30];
    CHAR command[60];
    memset(wakeupCMD, 0, sizeof(wakeupCMD));
    memset(command, 0, sizeof(command));
    
    snprintf(wakeupCMD, sizeof(wakeupCMD), "DID=%s&", did.UTF8String);
    
    if (HS_iPN_StringEnc(wakeupKey.UTF8String, wakeupCMD, command, sizeof(command)) < 0) {
        WQLog(@"*** Wakeup Query Command StringEncode failed!!!");
        return -1;
    }
    WQLog(@"command enc: [%s] %lu byte -> [%s] %lu byte", wakeupCMD, strlen(wakeupCMD), command, strlen(command));
    
    int mSocket;
    if ((mSocket = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
        WQLog(@"socket create fail error: %s", strerror(errno));
        return ERROR_Wakeup_SocketCreateFailed;
    }
    WQLog(@"create socket=%d.", mSocket);
    
    int readDataflag[Wakeup_Server_Num];
    memset(&readDataflag, 0, sizeof(readDataflag));
    
    int ret;
    char dest[20], recvBuffer[256], message[128];
    ssize_t ret_size;
    struct sockaddr_in remote_addr;
    unsigned int remote_size = sizeof(struct sockaddr_in);
    
    fd_set readFd;
    struct timeval timeout = {self.timeout, 0};
    int queryTime = 0;
    
    int readDataCount;
    
    _stopQuery = NO;
    while (!_stopQuery && queryTime++ < _repeatNumber) {
        
        readDataCount = 0;
        for (int item = 0; item < _lastLoginDiction.count; item++) {
            
            if (readDataflag[item] == 0) {
                
                memset(dest, 0, sizeof(dest));
                if (inet_ntop(serverAddr[item].sin_family, (void *)&serverAddr[item].sin_addr.s_addr, dest, sizeof(dest)) == NULL) {
                    continue;
                }
                
                double nt = GetNowTime;
                if ([self.timeCountDiction objectForKey:[NSString stringWithUTF8String:dest]]) {
                    double qt = [[self.timeCountDiction objectForKey:[NSString stringWithUTF8String:dest]] doubleValue];
                    if (nt - qt < 1) {
                        WQLog(@"ip(%s): time=%.3f(%.3f)。", dest, qt, nt);
                        continue;
                    }
                }
                
                [self.timeCountDiction setObject:@(nt) forKey:[NSString stringWithUTF8String:dest]];
                WQLog(@"dest: %s, time=%.3f", dest, nt);
                
                ret_size = sendto(mSocket, command, sizeof(command), 0, (struct sockaddr *)&serverAddr[item], sizeof(struct sockaddr_in));
                if (ret_size == -1) {
                    WQLog(@"sendto fail error: %s", strerror(errno));
                    _stopQuery = YES;
                    break;
                }
                WQLog(@"%0d-Send command(%lu byte) to WakeupServer: %s:%d", queryTime, strlen(command), dest, ntohs(serverAddr[item].sin_port));
            } else readDataCount++;
        }
        if (readDataCount == _lastLoginDiction.count || _stopQuery) break;
        
        FD_ZERO(&readFd);
        FD_SET(mSocket, &readFd);
        
        WQLog(@"start select, timeout=%ld.", timeout.tv_sec);
        ret = select(mSocket + 1, &readFd, NULL, NULL, &timeout);
        
        switch (ret) {
            case 0:WQLog(@"socket receive timeout!");break;
            case -1: {
                WQLog(@"select error: %s", strerror(errno));
                _stopQuery = YES;
            } break;
            default: {
                if (FD_ISSET(mSocket, &readFd)) {
                    
                    memset(recvBuffer, 0, sizeof(recvBuffer));
                    memset(message, 0, sizeof(message));
                    
                    WQLog(@"start recvfrom.");
                    ret_size = recvfrom(mSocket, recvBuffer, sizeof(recvBuffer), 0, (struct sockaddr *)&remote_addr, &remote_size);
                    if (ret_size == -1) {
                        WQLog(@"recvfrom fail errno: %s", strerror(errno));
                        _stopQuery = YES;
                        break;
                    } else {
                        recvBuffer[ret_size] = '\0';
                        
                        if (HS_iPN_StringDnc(wakeupKey.UTF8String, recvBuffer, message, sizeof(message)) < 0) {
                            WQLog(@"iPN_StringDnc failed.");
                            break;
                        }
                        for (int jum = 0; jum < _lastLoginDiction.count; jum++) {
                            
                            if (remote_addr.sin_addr.s_addr == serverAddr[jum].sin_addr.s_addr &&
                                remote_addr.sin_port == serverAddr[jum].sin_port) {
                                
                                NSString *ip = [NSString stringWithFormat:@"%s", inet_ntop(remote_addr.sin_family, (char *)&remote_addr.sin_addr.s_addr, dest, sizeof(dest))];
                                NSString *msg = [NSString stringWithUTF8String:message];
                                
                                NSString *last = [[msg componentsSeparatedByString:@"&"][1] componentsSeparatedByString:@"="][1];
                                [_lastLoginDiction setObject:@(last.intValue) forKey:ip];
                                
                                WQLog(@"recv msg(form %@): %@ (%@)", ip, msg, last);
                                
                                readDataflag[jum] = 1;
                            }
                        }
                    }
                } else {
                    WQLog("FD_ISSET error, readfds no data!!");
                }
            } break;
        }
    }
    ret = close(mSocket);
    WQLog(@"close socket(%d): %d", mSocket, ret);

    return [self getLastSleepLogin];
}

- (int)getLastSleepLogin {
    
    if (_lastLoginDiction.count == 0) {
        return ERROR_Wakeup_UnKnown;
    } else if (_lastLoginDiction.count == 1) {
        return [_lastLoginDiction.allValues[0] intValue];
    }
    
    int lastLogin = [_lastLoginDiction.allValues[0] intValue];
    for (NSString *value in _lastLoginDiction.allValues) {
        
        if (value.intValue < 0) {
            
            if (lastLogin < value.intValue) {
                lastLogin = value.intValue;
            }
        } else if (lastLogin < 0 || lastLogin > value.intValue) {
            lastLogin = value.intValue;
        }
    }
    
    return lastLogin;
}

@end
