//
//  P2PUtil.h
//  P2PTester
//
//  Created by yc on 2020/3/25.
//  Copyright © 2020 CS2-Network All rights reserved.
//

#import <Foundation/Foundation.h>

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/socket.h>
#include <arpa/inet.h>

#include "PPCS_API.h"

NS_ASSUME_NONNULL_BEGIN

@interface P2PUtil : NSObject

/// PPCS Wakeup encryption method
/// @param keystr WakeupKey
/// @param src A string to encrypt
/// @param dest The encrypted string
/// @param maxsize The size of the encrypted string
int HS_iPN_StringEnc(const char *keystr, const char *src, char *dest, unsigned int maxsize);

/// PPCS Wakeup decryption method
/// @param keystr WakeupKey
/// @param src The string to decrypt
/// @param dest The decrypted string
/// @param maxsize The size of the decrypted string
int HS_iPN_StringDnc(const char *keystr, const char *src, char *dest, unsigned int maxsize);

/// sleep
/// @param ms millisecond.
void HS_mSecSleep(UINT32 ms);

/// Determine whether two IPs are under the same Intranet.
/// @param IP1 IP1 description
/// @param IP2 IP2 description
int isLANcmp(const char *IP1, const char *IP2);

/// Check that the IP address is correct
/// @param ip ip address
int isValidIPv4(const char *ip);

/// Gets a standard string for the current time.
/// MM-dd HH:mm:ss.sss
const char *getTimeString(void);

/// Based on the error value, get the error definition
/// @param err PPCS API return value.
const char *getP2PErrorInfo(int err);

/// get socket type. ret = 0: UDP, 1:TCP
int getSocketType(int skt);

@end

NS_ASSUME_NONNULL_END
