//
//  P2PUtil.m
//  P2PTester
//
//  Created by yc on 2020/3/25.
//  Copyright © 2020 CS2-Network All rights reserved.
//

#import "P2PUtil.h"

@implementation P2PUtil

int HS_iPN_StringEnc(const char *keystr, const char *src, char *dest, unsigned int maxsize) {
    
    int Key[17] = {0};
    unsigned int i;
    unsigned int s, v;
    if (maxsize < strlen(src) * 2 + 3) {
        return -1;
    }
    for (i = 0 ; i < 16; i++) {
        Key[i] = keystr[i];
    }
    srand((unsigned int)time(NULL));
    s = abs(rand() % 256);
    memset(dest, 0, maxsize);
    dest[0] = 'A' + ((s & 0xF0) >> 4);
    dest[1] = 'a' + (s & 0x0F);
    for (i = 0; i < strlen(src); i++) {
        v = s ^ Key[(i + s * (s % 23))% 16] ^ src[i];
        dest[2 * i + 2] = 'A' + ((v & 0xF0) >> 4);
        dest[2 * i + 3] = 'a' + (v & 0x0F);
        s = v;
    }
    return 0;
}

int HS_iPN_StringDnc(const char *keystr, const char *src, char *dest, unsigned int maxsize) {
    
    int Key[17] = {0};
    unsigned int i;
    unsigned int s, v;
    if ((maxsize < strlen(src) / 2) || (strlen(src) % 2 == 1)) {
        return -1;
    }
    for (i = 0 ; i < 16; i++) {
        Key[i] = keystr[i];
    }
    memset(dest, 0, maxsize);
    s = ((src[0] - 'A') << 4) + (src[1] - 'a');
    for (i = 0; i < strlen(src) / 2 - 1; i++) {
        v = ((src[i * 2 + 2] - 'A') << 4) + (src[i * 2 + 3] - 'a');
        dest[i] = v ^ Key[(i + s * (s % 23))% 16] ^ s;
        if (dest[i] > 127 || dest[i] < 32) {
            return -1; // not a valid character string
        }
        s = v;
    }
    return 0;
}

void HS_mSecSleep(UINT32 ms) {
    usleep(ms * 1000);
}

// -1:invalid parameter,0:not the same LAN Addresses,1:Addresses belonging to the same LAN.
int isLANcmp(const char *IP1, const char *IP2) {
    short Len_IP1 = strlen(IP1);
    short Len_IP2 = strlen(IP2);
    if (!IP1 || 7 > Len_IP1 || !IP2 || 7 > Len_IP2) return -1;
    if (0 == strcmp(IP1, IP2)) return 1;
    const char *pIndex = IP1+Len_IP1-1;
    while (1) {
        if ('.' == *pIndex || pIndex == IP1) break;
        else pIndex--;
    }
    if (0 == strncmp(IP1, IP2, pIndex-IP1)) return 1;
    return 0;
}

int isValidIPv4(const char *ip) {
    if (ip == NULL) return 0;
    int result = -1;
    struct in_addr s;
    result = inet_pton(AF_INET, ip, (void *)&s);
    return result;
}

const char *getTimeString(void) {
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    [formatter setDateFormat:@"MM-dd HH:mm:ss.SSS"];
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    
    return timeString.UTF8String;
}

const char *getP2PErrorInfo(int err) {
    
    if (0 < err) return "NoError";
    switch (err) {
        case 0: return "ERROR_P2P_SUCCESSFUL";
        case -1: return "ERROR_P2P_NOT_INITIALIZED";
        case -2: return "ERROR_P2P_ALREADY_INITIALIZED";
        case -3: return "ERROR_P2P_TIME_OUT";
        case -4: return "ERROR_P2P_INVALID_ID";
        case -5: return "ERROR_P2P_INVALID_PARAMETER";
        case -6: return "ERROR_P2P_DEVICE_NOT_ONLINE";
        case -7: return "ERROR_P2P_FAIL_TO_RESOLVE_NAME";
        case -8: return "ERROR_P2P_INVALID_PREFIX";
        case -9: return "ERROR_P2P_ID_OUT_OF_DATE";
        case -10: return "ERROR_P2P_NO_RELAY_SERVER_AVAILABLE";
        case -11: return "ERROR_P2P_INVALID_SESSION_HANDLE";
        case -12: return "ERROR_P2P_SESSION_CLOSED_REMOTE";
        case -13: return "ERROR_P2P_SESSION_CLOSED_TIMEOUT";
        case -14: return "ERROR_P2P_SESSION_CLOSED_CALLED";
        case -15: return "ERROR_P2P_REMOTE_SITE_BUFFER_FULL";
        case -16: return "ERROR_P2P_USER_LISTEN_BREAK";
        case -17: return "ERROR_P2P_MAX_SESSION";
        case -18: return "ERROR_P2P_UDP_PORT_BIND_FAILED";
        case -19: return "ERROR_P2P_USER_CONNECT_BREAK";
        case -20: return "ERROR_P2P_SESSION_CLOSED_INSUFFICIENT_MEMORY";
        case -21: return "ERROR_P2P_INVALID_APILICENSE";
        case -22: return "ERROR_P2P_FAIL_TO_CREATE_THREAD";
        case -23: return "ERROR_PPCS_INVALID_DSK";
        case -24: return "ERROR_PPCS_FAILED_TO_CONNECT_TCP_RELAY";
        case -25: return "ERROR_PPCS_FAIL_TO_ALLOCATE_MEMORY";
        default: return "Unknow, something is wrong!";
    }
}

//// ret = 0: UDP, 1:TCP
int getSocketType(int skt) {
    int type;
    socklen_t length = sizeof(int);
    getsockopt( skt, SOL_SOCKET, SO_TYPE, &type, &length );

    NSLog(@"getsockopt(skt=%d): %d [%s]", skt, type, type == SOCK_STREAM ? "SOCK_STREAM":"SOCK_DGRAM");
    return (type == SOCK_STREAM); // return 1 or 0
}

@end
