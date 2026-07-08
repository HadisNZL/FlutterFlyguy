//
//  ToolsMacro.h
//  P2PTester
//
//  Created by yc on 2021/1/14.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#ifndef ToolsMacro_h
#define ToolsMacro_h

#define P2P_API_VERSION (PPCS_GetAPIVersion() >> 8)

// Available after ver 3.5.0
#define Available_Information

#define Available_TCP_Relay             P2P_API_VERSION >= 0x040100
#define Available_Init_With_Json        P2P_API_VERSION >= 0x040200
#define Available_Check_0x79            P2P_API_VERSION >= 0x040300
#define Available_Connect_With_Json     P2P_API_VERSION >= 0x040503
#define Available_0x7X_Timeout          P2P_API_VERSION >= 0x040503
#define Available_DCS                   P2P_API_VERSION >= 0x050000
#define Available_RP2P                  P2P_API_VERSION >= 0x050001
#define Available_WakeupInfo            P2P_API_VERSION >= 0x050004
#define Avaliable_EmptyP2PKey           P2P_API_VERSION >= 0x050100
#define Avaliable_NoWaitOffLine         P2P_API_VERSION >= 0x050103
#define Avaliable_APILog                P2P_API_VERSION >= 0x050200

#define Allow_Interrupt_Tester 1
#define Allow_Check_Login_Ack  1    // check login ack ?
#define Allow_Check_Buffer     0
#define Allow_RP2P             1    // allow P2P retry After UDP Server Relay
#define Allow_EmptyP2PKey      1    // allow device use empty p2pkey.

#define Allow_P2PSDK_DeBug     1    // P2PSDK
#define Allow_WQ_DeBug         0    // Wakeup Query
#define Allow_RE_DeBug         0    // UDP Recv Echo
#define Allow_LC_DeBug         0    // ListenTester login check debug
#define Allow_output_debug     1
#define Allow_APILog           1    // enable APILog

#define Wakeup_Server_Num                     3
#define ERROR_Wakeup_NoLogin                 -1
#define ERROR_Wakeup_InvalidParameter        -2
#define ERROR_Wakeup_SocketCreateFailed      -3
#define ERROR_Wakeup_SendToFailed            -4
#define ERROR_Wakeup_RecvFromFailed          -5
#define ERROR_Wakeup_UnKnown                 -99

#define _LStr(str) NSLocalizedString(str, nil)

#define GetNowTime [[NSDate date]timeIntervalSince1970]
#define GetNowTime_ms [[NSDate date]timeIntervalSince1970]*1000.0

#define SWidth [UIScreen mainScreen].bounds.size.width
#define SHeight [UIScreen mainScreen].bounds.size.height
#define IPHONE_X (SWidth >= 375.f && SHeight >= 812.f)
#define IPHONE_MINI (SWidth == 375.f && SHeight == 812.f)
#define IPHONE_SE (SWidth <= 320.f && SHeight <= 568.f)

#define HexColor(hex)                   [UIColor CS2ColorWithHex:hex Alpha:1]
#define HexColorAlpha(hex, alpha)       [UIColor CS2ColorWithHex:hex Alpha:alpha]

#define GeneralTextFontSize             IPHONE_SE ? 11 : (IPHONE_MINI ? 12 : 13)

#define START_BUTTON_COLOR_X            0x43CD80
#define STOP_BUTTON_COLOR_X             0xCD2626
#define GRAY_COLOR_X                    0xCC0033

// define for Read/Write test mode
#define TEST_ONE_WRITE_SIZE      128 * 1004    // (251 * 4), 251 is a prime number
#define TEST_WRITE_THRESHOLD     256 * 1024   // ppcs_write 阈值
#define NUMBER_OF_P2P_CHANNEL    8

#define TEST_WRITE_SIZE_1         (TEST_ONE_WRITE_SIZE * 8 * 1)        // ~ 0.98MB
#define TEST_WRITE_SIZE_10        (TEST_ONE_WRITE_SIZE * 8 * 11)       // ~ 10.7MB
#define TEST_WRITE_SIZE_100       (TEST_ONE_WRITE_SIZE * 8 * 110)      // ~ 107MB
#define TEST_WRITE_SIZE_1000      (TEST_ONE_WRITE_SIZE * 8 * 1024)     // ~ 1004MB

#define SIZE_DID                  60
#define SIZE_APILicense           20
#define SIZE_InitString           512
#define SIZE_Wakeup_Key           20
#define CH_CMD                    1
#define CH_DATA                   1
#define MSG_LOG                   0
#define MSG_ENABLE_TEXTFIELD      1

// PPCS_Initialize
#define Default_SessAliveSec      6
#define Default_MaxNumSess        128
//#define Default_MaxNumSess        512

// 0x7x_Timeout
#define Default_0x7X_Timeout      15

#define UDP_PING_PORT             8899
#define UDP_PING_TIMEOUT          500

// DCS add in 5.0.0
#define Default_DCS_PORT                    16888

#define DCSEchoResponse                1
#define DCSRsponseRetryTimes           3
#define DCSRsponseRetryInterval_sec    2

//#define Default_WakeupInfo   @"PPCS_Wakeup_Info"
#define Default_0x7X_Timeout   15
#define Default_InitString     @"ECGCEPBPKFJMHGJGEKGMFOEBHHMEHKNAGOEBBCCBBKIELELGCGAMCHOBHILEJIKKBLMBLBCIPCMCAODOJENNIJBOMM:P2PPrJTlEiY2M"

#if DEBUG
#define JVSAssertFailed(msg)         NSAssert(NO, (msg))
#else
#define JVSAssertFailed(msg)         {}
#endif


#endif /* ToolsMacro_h */
