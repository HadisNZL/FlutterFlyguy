//
//  P2PSDK.m
//  P2PTester
//
//  Created by yc on 2021/2/7.
//  Copyright © 2021 CS2-Network All rights reserved.
//

#import "P2PSDK.h"
#import <ulimit.h>

#define LOCAL_DIDINFO_HISTORY_KEY @"LOCAL_DIDINFO_HISTORY_KEY"
static NSString *g_didInfoData = @"g_didInfoData";

static NSString *apiLogFilePath = @"";

@interface P2PSDK()

@property (nonatomic, strong) dispatch_queue_t syncQueue;

@property (nonatomic, assign) BOOL       isInit;
@property (nonatomic, strong) NSLock     *p2pLock;
@property (nonatomic, copy)   NSString   *InitString;

@end

@implementation P2PSDK

+ (instancetype)shareInstance {
    
    static P2PSDK *p2psdk;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        p2psdk = [[P2PSDK alloc] init];
    });
    return p2psdk;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        
        NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        [formatter setDateFormat:@"MMdd_HHmmss"];
        NSString *file = [NSString stringWithFormat:@"%@_iOS.log", [formatter stringFromDate:[NSDate date]]];
        apiLogFilePath = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
        apiLogFilePath = [apiLogFilePath stringByAppendingPathComponent:file];
        
        self.p2pLock = [[NSLock alloc] init];
        self.InitString = @"";
        self.isInit = NO;
        self.syncQueue = dispatch_queue_create("com.p2p.p2psdk", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

- (NSMutableDictionary *)localDIDInfoDiction {
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    if ([user objectForKey:LOCAL_DIDINFO_HISTORY_KEY]) {
        NSMutableDictionary *diction = [NSMutableDictionary dictionaryWithDictionary:[user objectForKey:LOCAL_DIDINFO_HISTORY_KEY]];
        return diction;
    }
    return nil;
}

- (void)setLocalDIDInfoDiction:(NSMutableDictionary *)localDIDInfoDiction {
    
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:localDIDInfoDiction forKey:LOCAL_DIDINFO_HISTORY_KEY];
    [user synchronize];
}

#pragma mark - DID

- (NSString *)checkDID:(NSString *)did {
    
    P2PLog(@"checkDID: [%@] Enter.", did);
    did = [did stringByReplacingOccurrencesOfString:@"-" withString:@""];
//    NSRange range = [did rangeOfString:@"^([a-zA-z]{3,7})([0-9]{6})([a-zA-Z]{5})" options:NSRegularExpressionSearch];
//    if (range.location == NSNotFound) {
//        self.lastResultString = @"DID error!";
//        P2PLog(@"%@", self.lastResultString);
//        return nil;
//    }
    
    if ([did rangeOfString:@":"].location != NSNotFound) {
        NSRange range = [did rangeOfString:@":[a-zA-Z0-9]{8,23}$" options:NSRegularExpressionSearch];
        if (range.location == NSNotFound) {
            self.lastResultString = @"dsk must be 8~23 character of [a~z, A~Z, 0~9].";
            P2PLog(@"%@", self.lastResultString);
            return nil;
        }
        NSArray *ary = [did componentsSeparatedByString:@":"];
        NSMutableString *str = [NSMutableString stringWithString:ary[0]];
        [str insertString:@"-" atIndex:str.length-11];
        [str insertString:@"-" atIndex:str.length-5];
        did = [NSString stringWithFormat:@"%@:%@", [str uppercaseString], ary[1]];
    } else {
        NSMutableString *str = [NSMutableString stringWithString:did];
        [str insertString:@"-" atIndex:str.length-11];
        [str insertString:@"-" atIndex:str.length-5];
        did = [str uppercaseString];
    }
    P2PLog(@"checkDID: [%@] Exit.", did);
    
    return did;
}

- (void)updateDIDInfo:(DIDModel *)model {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.localDIDInfoDiction];
    
    if ([dic objectForKey:model.DID]) {
        
        DIDModel *existModel = [[DIDModel alloc] initWithDictionary:[dic objectForKey:model.DID]];
        if ([DIDModel isSame:model Sec:existModel]) {
            P2PLog(@"DID(%@) model exist!", model.DID);
            return;
        }
        
        existModel.InitString = model.InitString;
        if (model.APILicense != nil && model.APILicense.length > 0) {
            existModel.APILicense = model.APILicense;
        }
        if (model.CRCKey != nil && model.CRCKey.length > 0) {
            existModel.CRCKey = model.CRCKey;
        }
        if (model.WakeupKey != nil && model.WakeupKey.length > 0) {
            existModel.WakeupKey = model.WakeupKey;
        }
        if (model.ServerIP1 != nil && model.ServerIP1.length > 0) {
            existModel.ServerIP1 = model.ServerIP1;
        }
        if (model.ServerIP2 != nil && model.ServerIP2.length > 0) {
            existModel.ServerIP2 = model.ServerIP2;
        }
        if (model.ServerIP3 != nil && model.ServerIP3.length > 0) {
            existModel.ServerIP3 = model.ServerIP3;
        }
        [dic setObject:existModel.toDictionary forKey:existModel.DID];
    } else {
        [dic setObject:model.toDictionary forKey:model.DID];
    }
    
    self.localDIDInfoDiction = [NSMutableDictionary dictionaryWithDictionary:dic];
}

- (void)deleteDIDinfo:(NSString *)DID {
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:self.localDIDInfoDiction];
    [dic removeObjectForKey:DID];
    self.localDIDInfoDiction = [NSMutableDictionary dictionaryWithDictionary:dic];
}

#pragma mark - P2P API

- (NSString *)getAPIInformation {
    
    UINT32 version = PPCS_GetAPIVersion();
    NSString *APIInformation = [NSString stringWithFormat:@"PPCS API Version: %d.%d.%d.%d\n",
            (version >> 24), (version >> 16) & 0xff, (version >> 8) & 0xff, version & 0xff];
    
#ifdef Available_Information
    char *info = PPCS_GetAPIInformation();
    APIInformation = [NSString stringWithFormat:@"PPCS API Information(%lu byte): %s\n", strlen(info), info];
#endif
    
    return APIInformation;
}

- (int)initP2P:(NSString *)initString {
    
    if (self.isInit) {
        if ([initString isEqualToString:self.InitString]) {
            self.lastResultString = @"PPCS_Initialize() already done!\n";
            return ERROR_PPCS_SUCCESSFUL;
        } else {
            self.lastResultString = @"Already init with Different InitString.\n";
            return ERROR_PPCS_ALREADY_INITIALIZED;
        }
    }
    
    __block int ret = -99;
    dispatch_sync(self.syncQueue, ^{
        NSString *jsonStr = [self getInitString:initString SessionAlive:Default_SessAliveSec MaxNumSession:Default_MaxNumSess];
        
        P2PLog(@"init P2P: '%@'", jsonStr);
        CHAR gInitString[SIZE_InitString];
        strcpy(gInitString, [jsonStr UTF8String]);
        double start = GetNowTime_ms;
        ret = PPCS_Initialize(gInitString);
        double stop = GetNowTime_ms;
        
        if (ret == ERROR_PPCS_SUCCESSFUL) {
            self.isInit = YES;
            self.InitString = initString;
            self.lastResultString = [NSString stringWithFormat:@"PPCS_Initialize(%@) done! time: %.3f ms\n", jsonStr, stop - start];
        } else {
            self.lastResultString = [NSString stringWithFormat:@"PPCS_Initialize(%@) failed time: %.3f ms ret=%d[%s]\n", jsonStr, stop - start, ret, getP2PErrorInfo(ret)];
        }
        P2PLog(@"%@", [self getAPIInformation]);
    });
    
    return ret;
}

- (int)deInitP2P {
    
    __block int ret = -99;
    dispatch_sync(self.syncQueue, ^{
        if (self.isInit && !_isListenTesterRunning && !_isConnectionTesterRunning && !_isReadWriteTesterRunning) {
            double start = GetNowTime_ms;
            ret = PPCS_DeInitialize();
            double stop = GetNowTime_ms;
            if (ret == ERROR_PPCS_SUCCESSFUL) {
                self.lastResultString = [NSString stringWithFormat:@"PPCS_DeInitialize() done! time=%.3f ms.\n", stop - start];
                P2PLog(@"%@", self.lastResultString);
                self.isInit = NO;
            } else {
                P2PLog(@"PPCS_DeInitialize failed time: %.3f ms ret=%d[%s]", stop - start, ret, getP2PErrorInfo(ret));
            }
        }
    });
    return ret;
}

- (NSString *)getInitStringFromJson:(NSString *)json {
    P2PLog(@"getInitStringFromJson Enter: '%@'", json);
    if (!json && [json hasPrefix:@"{"]) {
        NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        if (jsonData) {
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
            if (dic) {
                [dic valueForKey:@"InitString"];
                P2PLog(@"getInitStringFromJson exit: '%@'", dic[@"InitString"]);
                return dic[@"InitString"];
            } else {
                P2PLog(@"Error converting JSON string to dictionary: %@", error.localizedDescription);
                return nil;
            }
        }
    }
    P2PLog(@"getInitStringFromJson exit: '%@'", json);
    return json;
}

- (int)networkDetect:(NSString *)initString {
    
    st_PPCS_NetInfo netInfo;
    double start;
    INT32 gRet = -99;
    initString = [self getInitStringFromJson:initString];
    if (initString == nil) {
        start = GetNowTime_ms;
        gRet = PPCS_NetworkDetect(&netInfo, 0);
    } else {
        CHAR gInitString[SIZE_InitString];
        strcpy(gInitString, [initString UTF8String]);
        start = GetNowTime_ms;
        gRet = PPCS_NetworkDetectByServer(&netInfo, 0, gInitString);
    }
    double stop = GetNowTime_ms;
    if (gRet != ERROR_PPCS_SUCCESSFUL) {
        self.lastResultString = [NSString stringWithFormat:@"PPCS_NetworkDetect%s() failed! time: %.3f ms, ret=%d[%s]\n", initString == nil ? "":"ByServer", stop - start, gRet, getP2PErrorInfo(gRet)];
    } else {
        NSString *networkStr = [NSString stringWithFormat:@"PPCS_NetworkDetect%s() done! time: %.3f ms\n", initString == nil ? "":"ByServer", stop - start];
        networkStr = [networkStr stringByAppendingString:[self getNetworkInfo:netInfo]];
        self.lastResultString = networkStr;
    }
    
    return gRet;
}

- (SessionModel *)checkSessionHandle:(INT32)session {
    
    st_PPCS_Session sInfo;
    double start = GetNowTime_ms;
    int gRet = PPCS_Check(session, &sInfo);
    double stop  = GetNowTime_ms;
    if (gRet != ERROR_PPCS_SUCCESSFUL) {
        self.lastResultString = [NSString stringWithFormat:@"PPCS_Check() fail, time=%.3f ms, ret=%d, %s", stop - start, gRet, getP2PErrorInfo(gRet)];
        return nil;
    }
    SessionModel *info = [SessionModel SessionInfoWithSession:session Info:sInfo];
    
    return info;
}

#pragma mark -- ather

- (NSString *)getInitString:(NSString *)initStr 
               SessionAlive:(int)sessAliveSec
              MaxNumSession:(int)maxNumSeccion {
    NSString *cmd = initStr;
    if (Available_Init_With_Json) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        if ([initStr hasPrefix:@"{"]) {
            NSData *jsonData = [initStr dataUsingEncoding:NSUTF8StringEncoding];
            NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
            if (dict) {
                [dic setDictionary:dict];
            }
        } else {
            [dic setObject:initStr forKey:@"InitString"];
            [dic setObject:@(sessAliveSec) forKey:@"SessAliveSec"];
            [dic setObject:@(maxNumSeccion) forKey:@"MaxNumSess"];
        }
        
        // APILog
        if (Allow_APILog) {
            [dic setObject:apiLogFilePath forKey:@"APILogFile"];
            if (@available(iOS 13.0, *)) {
                NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                               options:NSJSONWritingPrettyPrinted | NSJSONWritingWithoutEscapingSlashes
                                                                 error:nil];
                cmd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            } else {
                NSData *data = [NSJSONSerialization dataWithJSONObject:dic
                                                               options:NSJSONWritingPrettyPrinted
                                                                 error:nil];
                cmd = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] stringByReplacingOccurrencesOfString:@"\\" withString:@""];
            }
        }
    }

    return cmd;
}

- (NSString *)getNetworkInfo:(st_PPCS_NetInfo)netInfo {
    NSString *networkStr = [NSString stringWithFormat:@"---------------- NetInfo: -------------------\n"];
    networkStr = [networkStr stringByAppendingFormat:@"Internet Reachable     : %s\n",  (netInfo.bFlagInternet == 1) ? "YES":"NO"];
    networkStr = [networkStr stringByAppendingFormat:@"P2P Server IP resolved : %s\n",  (netInfo.bFlagHostResolved == 1) ? "YES":"NO"];
    networkStr = [networkStr stringByAppendingFormat:@"P2P Server Hello Ack   : %s\n",  (netInfo.bFlagServerHello == 1) ? "YES":"NO"];
    switch(netInfo.NAT_Type)
    {
        case 0:
            networkStr = [networkStr stringByAppendingFormat:@"Local NAT Type         : Unknow\n"];
            break;
        case 1:
            networkStr = [networkStr stringByAppendingFormat:@"Local NAT Type         : IP-Restricted Cone\n"];
            break;
        case 2:
            networkStr = [networkStr stringByAppendingFormat:@"Local NAT Type         : Port-Restricted Cone\n"];
            break;
        case 3:
            networkStr = [networkStr stringByAppendingFormat:@"Local NAT Type         : Symmetric\n"];
            break;
        case 4:
            networkStr = [networkStr stringByAppendingFormat:@"Local NAT Type         : Different Wan IP Detected!!\n"];
            break;
    }
    networkStr = [networkStr stringByAppendingFormat:@"My Wan IP : %s\n", netInfo.MyWanIP];
    networkStr = [networkStr stringByAppendingFormat:@"My Lan IP : %s\n", netInfo.MyLanIP];
    networkStr = [networkStr stringByAppendingFormat:@"--------------------------------------------\n"];
    return networkStr;
}

@end
