//
//  P2PSDK.h
//  P2PTester
//
//  Used to control P2P API initialization, network detection, and save DID local information.
//
//  Created by yc on 2021/2/7.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2PSDKHeader.h"

//@class SessionModel;
//@class DIDModel;
NS_ASSUME_NONNULL_BEGIN

#if Allow_P2PSDK_DeBug
#define P2PLog(fmt, ...) NSLog((@"P2P: " fmt), ##__VA_ARGS__);
#else
#define P2PLog(...)
#endif

@interface P2PSDK : NSObject

@property (nonatomic, copy)   NSString *lastResultString;

@property (nonatomic, assign) BOOL isListenTesterRunning;
@property (nonatomic, assign) BOOL isConnectionTesterRunning;
@property (nonatomic, assign) BOOL isReadWriteTesterRunning;

@property (nonatomic, strong) NSMutableDictionary *localDIDInfoDiction;

+ (instancetype)shareInstance;

#pragma mark - DID

/// Check if DID is standard
/// @param did DID
- (NSString *)checkDID:(NSString *)did;

/// Update did info to local save
/// @param model did model.
- (void)updateDIDInfo:(DIDModel *)model;

/// delete did info
/// @param DID did
- (void)deleteDIDinfo:(NSString *)DID;
 
#pragma mark - P2P API

/// get PPCS API Information
- (NSString *)getAPIInformation;

/// Initialize the PPCS API
/// @param initString Platform server string
- (INT32)initP2P:(NSString *)initString;

/// DeInitialize the PPCS API
- (INT32)deInitP2P;

/// Network detection
/// @param initString The InitString of the target platform is detected, and nil is used to detect the initializing platform.
- (INT32)networkDetect:( NSString * _Nullable )initString;

/// check sessionhandle info
/// @param session session
- (SessionModel *)checkSessionHandle:(INT32)session;

@end

NS_ASSUME_NONNULL_END
