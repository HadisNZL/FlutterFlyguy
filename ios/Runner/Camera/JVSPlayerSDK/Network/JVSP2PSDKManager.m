//
//  JVSP2PRequest.m
//  appdemo
//
//  Created by 李华 on 2025/1/18.
//

#import "JVSP2PSDKManager.h"
#import "P2PSDK.h"
#import "SessionModel.h"
#import "JVSWriteData.h"
#import "JVSFrameParser.h"
#import "JVSP2PSendDataOperation.h"
#import "NSError+JVSErrorData.h"
#import "NSData+HexExtension.h"


const uint8_t kFlagA5[8] = {0xaa,0xaa,0xaa,0xaa,0x55,0x55,0x55,0x55};  // 0xaaaaaaaa55555555

#define JVSLOCK(...)  [_condition lock];\
__VA_ARGS__; \
[_condition unlock];

@interface _JVSInternalTarget:NSObject

@property(nonatomic, weak) id<JVSP2PSDKManagerDelegate> target;

@property(nonatomic, assign, readonly) BOOL impl_didReadData_channel;
@property(nonatomic, assign, readonly) BOOL impl_didChangeVideoState_forKey;

+(instancetype)modelWithTarget:(__weak id)target;

@end

@implementation _JVSInternalTarget

+(instancetype)modelWithTarget:(__weak id<JVSP2PSDKManagerDelegate>)target {
    _JVSInternalTarget *model = [_JVSInternalTarget new];
    model.target = target;
    model->_impl_didReadData_channel = [target respondsToSelector:@selector(JVSP2PSDKManager:didReadData:channel:)];
    model->_impl_didChangeVideoState_forKey = [target respondsToSelector:@selector(JVSP2PSDKManager:didChangeVideoState:forKey:)];
    
    return model;
}

@end

@interface JVSP2PSDKManager ()  {
    
    // 下载相关
    BOOL _downloadThreadStarted;
    JVSSuccessDataBlock _downloadCompletionBlock;
    JVSProgressBlock _downloadProgressBlock;
    NSInteger _fileSize;  // 文件大小
    NSInteger _downloadedFileSize;  // 已下载的文件大小
    NSString *_toLocalFullPath; // 文件下载开始 - 一次只能下载一个
    dispatch_queue_t _writeFileQueue;
    // 下载视频的 本地地址， 下载完成后会 移动到 _toLocalFullPath
    NSString *_tmpLocalFullPath;
    
    // 缓存上次发送语音的 时间戳
    UInt64 _lastAudioRequestId;
    
    dispatch_queue_t _queue_video_read;
    dispatch_queue_t _queue_grpc_read;  // GRPC
    
    BOOL _islastSDKReleaseDelay;
}

@property (nonatomic, assign) INT32 Session;
@property (nonatomic, assign) BOOL  isReadWriteData;

@property (nonatomic, strong) P2PSDK *p2pSDK;
@property (nonatomic, strong) SessionModel *sessionModel;

/// 串行发送数据
@property (nonatomic, strong) NSOperationQueue *sendDataOperationQueue;
/// 下载线程
@property(nonatomic, strong) NSThread *downLoadThread;
@property(nonatomic, strong) dispatch_queue_t sync_queue_writeData;

@property (nonatomic, strong) NSCondition *condition;
@property (nonatomic, strong) NSCondition *sendDataCondition;
@property (nonatomic, strong) NSMutableDictionary<NSString*, _JVSInternalTarget*> *targetMap;

@end

@implementation JVSP2PSDKManager

+ (instancetype)shared {
    static JVSP2PSDKManager *request;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[JVSP2PSDKManager alloc] init];
    });
    return request;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        [self setupData];
    }
    return self;
}

-(void)setupData {
    _targetMap = @{}.mutableCopy;
    _p2pSDK = [P2PSDK shareInstance];
    _condition = [[NSCondition alloc] init];
    _sendDataCondition = [[NSCondition alloc] init];
    
    _downLoadThread = [[NSThread alloc] initWithTarget:self selector:@selector(networkRequestThreadEntryPoint:) object:@"DownLoadThread"];
    _writeFileQueue = dispatch_queue_create("DownLoadThreadWriteQueue", 0);

    _sync_queue_writeData = dispatch_queue_create("Sync_Dispatch_Queue_WriteData", DISPATCH_QUEUE_SERIAL);
    
    _sendDataOperationQueue = [[NSOperationQueue alloc] init];
    _sendDataOperationQueue.maxConcurrentOperationCount = 1;
    
    _queue_video_read = dispatch_queue_create("Queue_Video_Read", DISPATCH_QUEUE_SERIAL);
    _queue_grpc_read = dispatch_queue_create("Queue_GRPC_Read", DISPATCH_QUEUE_SERIAL);
}

#pragma mark --------------------------  Delegate添加和移除
// 添加多个回调，weak 引用 target，根据target的class 缓存对象
+(void)addDelegateForTarget:(id<JVSP2PSDKManagerDelegate> _Nonnull)target forKey:(NSString *)key {
    [JVSP2PSDKManager.shared _addDelegateForTarget:target forKey:key];
}
-(void)_addDelegateForTarget:(id<JVSP2PSDKManagerDelegate> _Nonnull)target forKey:(NSString *)key {
    if(!target) {
        JVSAssertFailed(@"target 不能为空！");
        return;
    }
    NSString *name = key;
    if (!name.length) {
        JVSAssertFailed(@"key 不能为空！");
        return;
    }
    [self _removeDelegateForKey:name];
    
    JVSLOCK({
        _JVSInternalTarget *model = [_JVSInternalTarget modelWithTarget:target];
        JVSP2PSDKManager.shared.targetMap[name] = model;
    });
}
+(void)addDelegateForTarget:(id<JVSP2PSDKManagerDelegate> _Nonnull)target {
    if(!target) {
        JVSAssertFailed(@"target 不能为空！");
        return;
    }
    [self addDelegateForTarget:target forKey:NSStringFromClass(target.class)];
}
+(void)removeDelegateForTarget:(id<JVSP2PSDKManagerDelegate> _Nonnull)target forKey:(NSString *)key {
    [JVSP2PSDKManager.shared _removeDelegateForKey:key];
}
-(void)_removeDelegateForKey:(NSString *)key {
    NSString *name = key;
    if (!name.length) {
        JVSAssertFailed(@"key 不能为空！");
        return;
    }
    JVSLOCK({
        if (JVSP2PSDKManager.shared.targetMap[name]) {
            [JVSP2PSDKManager.shared.targetMap removeObjectForKey:name];
        }
    });
}
+(void)removeDelegateForTarget:(id<JVSP2PSDKManagerDelegate> _Nonnull)target {
    [self removeDelegateForTarget:target forKey:NSStringFromClass([target class])];
}
+(void)removeDelegateForKey:(NSString *)key {
    [JVSP2PSDKManager.shared _removeDelegateForKey:key];
}

#pragma mark -------------------------- 连接设备
- (BOOL)connectWithDIDModel:(DIDModel *)model {
    if (![self checkDIDModel:model]) {
        return NO;
    }
    if ((_connectStatus==JVSP2PStateCodeConnecting ||
         _connectStatus==JVSP2PStateCodeConnected)
        && [model.DID isEqualToString:_sessionModel.did]) {
        return YES;
    }
    JVSLog(@"----- connectWithDIDModel = %@ - %ld", model.DID, _connectStatus);
    dispatch_barrier_async(dispatch_get_global_queue(0, 0), ^{
        [self _connectWithDIDModel:model];
    });
    return YES;
}

#pragma mark -------------------------- 断开连接
- (void)disconnect {
    JVSLOCK({
        
        _connectStatus = 0;
        PPCS_Connect_Break();
        if (_isReadWriteData) {
            _isReadWriteData = NO;
            PPCS_ForceClose(_Session);
        }
        
        JVSLog(@"disconnect _deInitP2P 1");
        int gRet = [self.p2pSDK deInitP2P];
        if (gRet == ERROR_PPCS_SUCCESSFUL) {
            JVSLog(@"disconnect ERROR_PPCS_SUCCESSFUL lastResultString = %@", self.p2pSDK.lastResultString);
        }
        
    });
}

#pragma mark -------------------------- 发送数据 WriteThread 中执行 该方法
/// 发送数据
- (BOOL)sendDataWith:(JVSWriteData *)data {
    if ([self isConnected]) {
        dispatch_async(_sync_queue_writeData, ^{
            JVSLog(@"-------- Init_Did_Send_Data - %lld - %@", data.requestId, [NSThread currentThread]);
            JVSP2PSendDataOperation *operation = [[JVSP2PSendDataOperation alloc] initWithSession:_Session dataModel:data completion:^(JVSWriteData * _Nonnull dataModel) {
                JVSLog(@"-------- Done_Did_Send_Data - %lld  - %@", dataModel.requestId, [NSThread currentThread]);
            }];
            /// 需枷锁
            [_sendDataCondition lock];
            [_sendDataOperationQueue addOperation:operation];
            [_sendDataCondition unlock];
        });
        return YES;
    }
    return NO;
}

/// 发送语音数据
- (void)sendoAudioDataWith:(NSData *)audioData {
    UInt64 requestId = [NSNumber numberWithDouble:[NSDate.date timeIntervalSince1970]*1000].longValue;
    if (requestId <= (_lastAudioRequestId-10)) {
        requestId += 20;
    }
    _lastAudioRequestId = requestId;
//    JVSLog(@"------sendoAudioDataWith_ %lld", requestId);
    /// 向通道 2 语音通道发送数据
    JVSWriteData *dataModel = [JVSWriteData modelWithChannel:2 data:audioData requestId:requestId];
    [self sendDataWith:dataModel];
}

-(void)downloadVideoWith:(NSString *)filePath toLocalPath:(NSString *)localPath fileSize:(NSInteger)fileSize
           progressBlock:(JVSProgressBlock)progressBlock
         completionBlock:(JVSSuccessDataBlock)completionBlock {
    if (localPath.length==0) {
        if (completionBlock) completionBlock(nil, [NSError errorWithMsg:@"localPath 为空"]);
        JVSLog(@"----- Local Path is null");
        return;
    }
    if (_toLocalFullPath.length) {
        JVSLog(@"----- 文件还在下载, 请稍等 - %@", _toLocalFullPath);
        return;
    }
    if ([self isConnected]) {
        [_condition lock];
        _toLocalFullPath = localPath;
        _downloadCompletionBlock = completionBlock;
        _downloadProgressBlock = progressBlock;
        _fileSize = fileSize;
        
        if (!_downloadThreadStarted) {
            _downloadThreadStarted = YES;
            [_downLoadThread start];
        }
        [_condition unlock];
        
        [self performSelector:@selector(ThreadDownloadWithSessionModel:) onThread:_downLoadThread
                   withObject:_sessionModel waitUntilDone:NO];
        return;
    }
    JVSLog(@"----- Device is Not connected");
    if (completionBlock) completionBlock(nil, [NSError errorWithMsg:@"先连接设备，再下载"]);
}

#pragma mark --------------------------  Private
- (BOOL)checkDIDModel:(DIDModel *)model {
    if (model.ThreadNum > 8) {
        JVSAssertFailed(_LStr(@"ThreadNumERROR"));
        return NO;
    }
    model.DID = [_p2pSDK checkDID:model.DID];
    if (model.DID == nil) {
        JVSAssertFailed(_p2pSDK.lastResultString);
        return NO;
    }
    if (model.InitString.length < 18) {
        JVSAssertFailed(_LStr(@"InitStringERROR"));
        return NO;
    }
    
    return YES;
}

- (NSString *)getInitString:(NSString *)initStr {
    NSString *cmd = initStr;
    if (Available_0x7X_Timeout && ![initStr hasPrefix:@"{"]) {
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithCapacity:0];
        [dic setObject:initStr forKey:@"InitString"];
        if (Available_0x7X_Timeout) {
            [dic setObject:@(Default_0x7X_Timeout) forKey:@"0x7X_Timeout"];
        }
        if (Available_RP2P) {
            [dic setObject:@(Allow_RP2P) forKey:@"AllowRP2P"];
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        cmd = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }

    return cmd;
}

- (void)startUDPPing:(NSString *)remoteIP {
    JVSLog(@"$$$ UDP_PING_THREAD(%@) start..", remoteIP);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        int mSocket;
        if ((mSocket = socket(AF_INET, SOCK_DGRAM, 0)) == -1) {
            JVSLog(@"$$$ UDP_PING_THREAD: socket create fail error: %s", strerror(errno));
            return;
        }
        
        struct sockaddr_in remote_addr = {0};
        remote_addr.sin_len = sizeof(remote_addr);
        remote_addr.sin_family = AF_INET;
        remote_addr.sin_addr.s_addr = inet_addr([remoteIP UTF8String]);
        remote_addr.sin_port = htons(UDP_PING_PORT);
        
        UINT32 remote_addr_size = sizeof(struct sockaddr_in);
        
        char Message[1024] = {0};
        memset(Message, 0, sizeof(Message));
        int index = 0;
        long time = GetNowTime_ms;
        NSString *msg = [NSString stringWithFormat:@"index=%d,Tick_mSec=%ld&", index, time];
        strcpy(Message, [msg UTF8String]);
        
        ssize_t ret_size = sendto(mSocket, Message, sizeof(Message), 0, (struct sockaddr *)&remote_addr, remote_addr_size);
        if (ret_size == -1) {
            JVSLog(@"$$$ UDP_PING_THREAD: sendto fail error: %s", strerror(errno));
            return;
        }
    
        fd_set readFd;
        struct timeval timeout = {0, UDP_PING_TIMEOUT * 1000};
        
        FD_ZERO(&readFd);
        FD_SET(mSocket, &readFd);
        int ret = select(mSocket + 1, &readFd, NULL, NULL, &timeout);
        switch (ret) {
        case 0:
            JVSLog(@"%d - $$$ UDP_PING_THREAD socket receive timeout!", index);
//            // [self.delegate updateLog:@"UDP_PING_THREAD socket receive timeout!"];
        break;
        case -1:
            JVSLog(@"UDP_PING_THREAD: select error: %s", strerror(errno));
//            // [self.delegate updateLog:[NSString stringWithFormat:@"UDP_PING_THREAD: select error: %s", strerror(errno)]];
            close(mSocket);
        break;
        default:
            if (FD_ISSET(mSocket, &readFd)) {
                char receiveMessage[1024] = {0};
                memset(receiveMessage, 0, sizeof(receiveMessage));
                
                ret_size = recvfrom(mSocket, receiveMessage, sizeof(receiveMessage), 0, (struct sockaddr *)&remote_addr, &remote_addr_size);
                long stop_time = GetNowTime_ms;
                
                if (ret_size == -1) {
                    JVSLog(@"$$$ UDP_PING_THREAD: recvfrom fail errno: %s", strerror(errno));
                    return;
                }
                
                NSString *recv_msg = [NSString stringWithUTF8String:receiveMessage];
                JVSLog(@"$$$ UDP_PING_THREAD packet:%@", msg);
                
                long rece_time = 0;
                if ([recv_msg containsString:@"Sec="] && [recv_msg containsString:@"&"]) {
                    rece_time = (long)[[[recv_msg componentsSeparatedByString:@"Sec="][1] componentsSeparatedByString:@"&"][0] doubleValue];
                }
                NSString *logStr = [NSString stringWithFormat:@"[%s]UPD_PING: from %s:%d, Size=%zdByte, Time=%ldms\n", getTimeString(), inet_ntoa(remote_addr.sin_addr), ntohs(remote_addr.sin_port), ret_size, stop_time-rece_time];
                JVSLog(@"%@", logStr);
                JVSLog(@"$$$ UDP_PING_THREAD receive packet:%@", recv_msg);
                JVSLog(@"$$$ UDP_PING_THREAD done, time: %ld", stop_time);
            }
        break;
        }
    });
}

- (void)startCheckBuffer:(INT32)session chArray:(NSArray *)array {
    if (Allow_Check_Buffer) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            UINT32 wSize = 0;
            UINT32 rSize = 0;
            INT32 gRet = 0;
            while (gRet >= 0 && Allow_Check_Buffer) {
                for (NSString *channelStr in array) {
                    gRet = PPCS_Check_Buffer(session, channelStr.intValue, &wSize, &rSize);
                    if (gRet != ERROR_PPCS_SUCCESSFUL) {
                        break;
                    }
                    NSString *log = [NSString stringWithFormat:@"startCheckBuffer(%d :_channel_= %@) rSize:%d wSize:%d\n", session, channelStr, rSize, wSize];
                    JVSLog(@"%@", log);
                }
                HS_mSecSleep(1000);
            }
        });
    }
}

- (void)startDetectRP2PWithSessionModel:(SessionModel *)model {
    JVSLog(@"startDetectRP2PWithSessionModel Enter.");
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        double start = GetNowTime_ms;
        while (GetNowTime_ms - start <= 60000) {  // 1 min
            SessionModel *new_Model = [self.p2pSDK checkSessionHandle:model.session];
            if (!new_Model) {
                JVSLog(@"Thread_PPCS_Check exit for %@\n", self.p2pSDK.lastResultString);
                break;;
            }
            
            if (![model.mode isEqualToString:new_Model.mode]) {
                self.sessionModel = new_Model;
                JVSLog(@"Thread_PPCS_Check: Mode is changed!! Mode: %@ -> %@, DID=%@, Session=%d, Wan=%@:%d, Local=%@:%d, Rmt=%@:%d\n", model.mode, new_Model.mode, new_Model.did, new_Model.session, new_Model.my_lan_ip, new_Model.my_lan_port, new_Model.my_wan_ip, new_Model.my_wan_port, new_Model.remote_ip, new_Model.remote_port);
                JVSLog(@"new mode: \n%@\n%@", [new_Model showSessionInfo], [self.p2pSDK getAPIInformation]);
                break;
            }
            HS_mSecSleep(100);
        }
        JVSLog(@"startDetectRP2PWithSessionModel Exit.");
    });
}


-(BOOL)isConnecting {
    return self.connectStatus==JVSP2PStateCodeConnecting;
}
-(BOOL)isConnected {
    return self.connectStatus==JVSP2PStateCodeConnected||self.connectStatus==JVSP2PStateCodeVideoPlaying;
}


#pragma mark --------------------------  Thread Releated
- (BOOL)_connectWithDIDModel:(DIDModel *)model {
    BOOL hasSleep = NO;
    JVSLOCK(BOOL flag = self.p2pSDK.isReadWriteTesterRunning)
    if (flag) {
        JVSLOCK(_islastSDKReleaseDelay = YES);
        hasSleep = YES;
        JVSLog(@"_connectWithDIDModel_Sleep 180");
        HS_mSecSleep(180);  // 解决释放问题， 让上一次释放有时间；
    }
    JVSLOCK(flag = self.p2pSDK.isReadWriteTesterRunning)
    if (hasSleep && flag) {  // 还是运行中的话
        JVSLog(@"_connectWithDIDModel_Sleep JVSP2PStateCodeVideoPlaying");
        [self videoStatusDidUpdateWith:JVSP2PStateCodeVideoPlaying];
        return YES;
    }
    
    [self videoStatusDidUpdateWith:JVSP2PStateCodeConnecting];
    JVSLOCK(self.p2pSDK.isReadWriteTesterRunning = YES)
    
    INT32 gRet;
    INT32 session = -99;
    UINT16 UDPPort = 0;// The UDP port used by PPCS_Connect is filled in with 0 for the underlying automatic allocation.
    
    CHAR gDeviceID[SIZE_DID];
    CHAR gInitString[SIZE_InitString];
    CHAR gThreadNum = (CHAR)model.ThreadNum;
    CHAR gSizeOption = (CHAR)model.SizeOption;
    CHAR gDirectionMode = (CHAR)model.Direction;
    CHAR gTestMode = (CHAR)model.Mode;
    CHAR bEnableLanSearch = Available_TCP_Relay ? 0x7A : 0x7E;   // Quick connection device.

    if ([UNGetObject(@"Mode_RLY") boolValue]) {  // 强制开始 转发模式
        JVSLog(@"开启了 转发模式");
        bEnableLanSearch = 0x5E;
    }
    
    BOOL useByServer = Available_RP2P;
    double startTime, stopTime;
    
    strcpy(gDeviceID, model.DID.UTF8String);
    strcpy(gInitString, model.InitString.UTF8String);
    
    [self.p2pSDK updateDIDInfo:model];
    
    // p2p api init
    JVSLog(@"start_p2p init: %@", model.InitString);
    gRet = [self.p2pSDK initP2P:model.InitString];
    JVSLog(@"start_p2p %@", self.p2pSDK.lastResultString);
    
    if(gRet == ERROR_PPCS_ALREADY_INITIALIZED) {
        useByServer = YES;
    } else if (gRet != ERROR_PPCS_SUCCESSFUL) {
        [self videoStatusDidUpdateWith:JVSP2PStateCodeConnectFailed];
        return NO;
    }
    
    // p2p networkDetect.
    JVSLog(@"start_p2p network: %@", useByServer ? model.InitString : nil);
    [self.p2pSDK networkDetect:useByServer ? model.InitString : nil];
    JVSLog(@"start_p2p lastResultString = %@", self.p2pSDK.lastResultString);
    
    if (useByServer) {
        strcpy(gInitString, [[self getInitString:model.InitString] UTF8String]);
    }
    //        if (Available_RP2P) bEnableLanSearch = 0x5E; // for RP2P test
    
    {
        NSString *log = [NSString stringWithFormat:@"[%s] PPCS_Connect%s(%s, 0x%02X, %d%s%s)...\n", getTimeString(), useByServer ? "ByServer":"", gDeviceID, bEnableLanSearch, UDPPort, useByServer ? ", ":"", useByServer ? gInitString:""];
        JVSLog(@"%@", log);
    }
    
    [self videoStatusDidUpdateWith:JVSP2PStateCodeConnecting];
    // connect device.
    SessionModel *info = nil;
    for (int item = 0; self.isConnecting && item < 3; item++) {
        startTime = GetNowTime;
        if (useByServer) {
            session = PPCS_ConnectByServer(gDeviceID, bEnableLanSearch, UDPPort, gInitString);
        } else {
            session = PPCS_Connect(gDeviceID, bEnableLanSearch, UDPPort);
        }
        stopTime = GetNowTime;
        
        if (session < ERROR_PPCS_SUCCESSFUL) {
            JVSLog(@"[%s]Connect failed: %.3f sec, %d [%s]\n", getTimeString(), stopTime - startTime, session, getP2PErrorInfo(session));
            if (session == ERROR_PPCS_TIME_OUT) continue; // 连接超时，再次连接
            else {
                break;
            }
        }
        self.Session = session;
        JVSLog(@"[%s]Connect Success!! %.3f ms, Session=%d.\n", getTimeString(), (stopTime - startTime) * 1000, session);
        
        info = [self.p2pSDK checkSessionHandle:session];
        self.sessionModel = info;
        if (info == nil) {
            JVSLog(@"info is nil %@", self.p2pSDK.lastResultString)
            continue;
        }
        
        if ([info.mode hasPrefix:@"LAN"] && ![info.remote_ip isEqualToString:info.my_lan_ip]) {
            [self startUDPPing:info.remote_ip];
        } else if ([info.mode hasPrefix:@"RLY"] && Available_RP2P) { // detect P2P After UDP Relay.
            [self startDetectRP2PWithSessionModel:info];
        }
        JVSLog(@"%@", info.showSessionInfo);
        break;
    }
    JVSLog(@"Connect_Read_BY_%@__", _sessionModel.mode);
    m_dispatch_main_async(^{
        model.modeString = _sessionModel.mode;
    });
    
    if ([_sessionModel.mode containsString:@"P2P"] ||
        [_sessionModel.mode containsString:@"LAN"] ) {
        self.isReadWriteData = YES;
        // 连接成功了； 开始读数据
        [self videoStatusDidUpdateWith:JVSP2PStateCodeConnected];
        // -- 阻塞中
        [self ThreadReadWithSessionModel:info];
        
        JVSLog(@"Connect_disconnnect  _sessionModel.mode = %@  = %@", _sessionModel.mode, self.p2pSDK.lastResultString);
        // 如果到这里 直接 就断开连接了
    }
    else {
        self.isReadWriteData = YES;
        for (int item = 0; info != nil && item < 3; item++) {  // 重试3次
            
            int timeout = [info.mode isEqualToString:@"TCP"] ? 3500 : 1000;
            CHAR readData = -99;
            INT32 readSize = 1;
            gRet = PPCS_Read(session, CH_CMD, (CHAR *)&readData, &readSize, timeout);
            
            if (gRet < 0 && readSize == 0) {
                JVSLog(@"Connect_Read: Session=%d, CH=%d, ReadSize=%d, ret=%d [%s]", session, CH_CMD, readSize, gRet, getP2PErrorInfo(gRet));
                if (gRet == ERROR_PPCS_TIME_OUT) {
                    continue;
                } else {
                    break;
                }
            }
            else if (gRet != ERROR_PPCS_INVALID_PREFIX || gRet != ERROR_PPCS_INVALID_SESSION_HANDLE || readSize) {
                JVSLog(@"Connect_Read: ret=%d, Session=%d, CH=%d, ReadSize=%d => [%d]", gRet, session, CH_CMD, readSize, readData);
                
                // 回应 ACK
                INT32 SendData = gDirectionMode<<9|gSizeOption<<7|gThreadNum<<3|gTestMode<<1|0x01;
                gRet = PPCS_Write(session, CH_CMD, (CHAR *)&SendData, sizeof(SendData));
                if (gRet < 0) {
                    JVSLog(@"Connect_Write: Session=%d, CH=%d, SendSize=%lu, Data:[%d], ret=%d [%s]", session, CH_CMD, sizeof(SendData), SendData, gRet, getP2PErrorInfo(gRet));
                } else {
                    JVSLog(@"Connect_Write: ret=%d, Session=%d, CH=%d, SendSize=%lu => [%d]", gRet, session, CH_CMD, sizeof(SendData), SendData);
                    // 连接成功了； 开始读数据
                    [self videoStatusDidUpdateWith:JVSP2PStateCodeConnected];
                    // -- 阻塞中
                    [self ThreadReadWithSessionModel:info];
                }
                break;
            } else {
                JVSLog(@"Connect_Read: Session=%d, CH=%d, ReadSize=%d, ret=%d [%s]", session, CH_CMD, readSize, gRet, getP2PErrorInfo(gRet));
            }
        }
        
    }
    
    /// 释放资源，更新状态
    [_sendDataOperationQueue cancelAllOperations];
    
    JVSLOCK(BOOL islastSDKReleaseDelay = _islastSDKReleaseDelay);
    if (!islastSDKReleaseDelay) {
        JVSLog(@"disconnect_islastSDKReleaseDelay_NO");
        [self videoStatusDidUpdateWith:JVSP2PStateCodeConnectFailed];
    } else {
        JVSLog(@"disconnect_islastSDKReleaseDelay_YES");
    }
    
    HS_mSecSleep(100);
    self.isReadWriteData = NO;
    if (session >= 0) {
        PPCS_Close(session);
    }
    JVSLOCK({
        [self.p2pSDK deInitP2P];
        self.p2pSDK.isReadWriteTesterRunning = NO;
        _islastSDKReleaseDelay = NO;
    })
    JVSLog(@"disconnect_deInitP2P lastResultString = %@", self.p2pSDK.lastResultString);
    
    return NO;
}

#pragma mark -------------------------- 线程操作 - 停止和保留
- (void)networkRequestThreadEntryPoint:(NSString *)threadName {
    @autoreleasepool {
        [[NSThread currentThread] setName:threadName?:@"JVSP2PRequest"];
        NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
        [runLoop addPort:[NSMachPort port] forMode:NSDefaultRunLoopMode];
        [runLoop run];
    }
}

#pragma mark --------------------------  读
- (void)ThreadReadWithSessionModel:(SessionModel *)sInfo {
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray *array = [NSMutableArray array];
    
    // 产生 通道0(读取GRPC) 通道1(读取音频和视频) 的处理线程  2个线程 分别去读
    for (int channel = 0; channel < 2; ++channel) {
        
        [array addObject:[NSString stringWithFormat:@"%d", channel]];
        dispatch_group_async(group, queue, ^{
            [self ThreadReadWithSession:sInfo.session Channel:channel];
        });
        
        HS_mSecSleep(10);
    }
    [self startCheckBuffer:sInfo.session chArray:array];
    dispatch_group_wait(group, DISPATCH_TIME_FOREVER);
}

// 0: GRPC, 1: 视频 / 音频
- (void)ThreadReadWithSession:(INT32)session Channel:(INT32)channel {
    JVSLog(@"ThreadReadWithSession: session= %d   - Read Channel= %d", session, channel);
    if (session < 0) {
        JVSLog(@"!!!!!!!!!!!!!!!!!ThreadRead_exit_for_Invalid_SessionID(%d)!!\n", session);
        return;
    }
    if (channel < 0 || channel > 7) {
        JVSLog(@"!!!!!!!!!!!!!!!!!ThreadRead_exit_for_Invalid_Channel(%d)!!\n", channel);
        return;
    }
    INT32 ret = -1;
    ULONG totalSize = 0;
    INT32 sizeToRead = 56 * 1024;  // 音频和视频
    INT32 timeOut_ms = 100;
    if (channel == 0) {
        sizeToRead = 1024*1024;  // GRPC
        timeOut_ms = 800;
    }
    INT32 bufSize = sizeToRead + 4;
    UCHAR *readBuf = (unsigned char*)malloc(bufSize);
    
    while (1) {
        while (1) {
            // ReadSize: Expected size of data to be read.
            // Readszie must specify size to be read before each PPCS_Read.
            // Very important!!
            INT32 readSize = sizeToRead;
            memset(readBuf, 0, bufSize);
            ret = PPCS_Read(session, channel, (CHAR *)readBuf, &readSize, timeOut_ms);
            if (JVSLogDataReadOpen)JVSLog(@"--ThreadRead__channel =%d  - ret=%d - readSize = %d", channel, ret, readSize);

            /********************************************************
               PPCS_Read() return ERROR_PPCS_TIME_OUT(-3) :
               1. PPCS_Read: -3 timeout error is normal, but the default size cannot be read within the set timeout time,
                  is not a breakout error, need to continue to read the remaining data loop.
               2. PPCS_read returns -3 timeout and it is possible to read some data,
                  so it is necessary to check the size of ReadSize.
                  This sample code will directly add the size of ReadSize.
               3. Readszie is the actual data size read. If PPCS_read does not read the data,
                  the Readszie variable will be cleared to zero and must be reassigned before the next PPCS_read,
                  otherwise Readszie 0 to PPCS_read will return a -5 error (-5: invalid parameter).
             *********************************************************/
            if (ret != ERROR_PPCS_INVALID_PREFIX && ret != ERROR_PPCS_INVALID_SESSION_HANDLE && readSize) {
                NSData *data = [NSData dataWithBytes:readBuf length:readSize];
                JVSReadData *model = [JVSReadData modelWithData:data];
                [self didReadData:model channel:channel];
                totalSize += readSize;
                
                if (channel==1 && model.size > 0 && model.hasTypeIFrame) {  // 相当于读到了 i帧
                    [self videoStatusDidUpdateWith:JVSP2PStateCodeVideoPlaying]; // 播放了 ， 会同步到所有的 player
                }
            }
            if (ret < 0 && ret != ERROR_PPCS_TIME_OUT) {
                JVSLog(@"ThreadRead__Error - !!!!!!!!!!!!!!!!! %s \n", getP2PErrorInfo(ret));
                break;
            }
            HS_mSecSleep(10);
        }
        if (totalSize % 16 == totalSize % (1*1024*1024)) {
            setbuf(stdout, NULL);
        }
        if ((ret != ERROR_PPCS_SUCCESSFUL && ret != ERROR_PPCS_TIME_OUT)) {
            JVSLog(@"--ThreadRead__Break ===!!!!!!!!!!!!!!!!! Break %s \n", getP2PErrorInfo(ret));
            break;
        }
    }
    if (readBuf) {
        free(readBuf);
    }
    JVSLog(@"--ThreadRead__Break ===!!!!!!!!!!!!!!!!! ThreadReadWithSession(Channel=%d) %s \n", channel, getP2PErrorInfo(ret));
    return;
}

#pragma mark --------------------------  下载
- (void)ThreadDownloadWithSessionModel:(SessionModel *)sInfo {
    int channel = 4; // 通道4 去下载视频
//    NSMutableArray *array = [NSMutableArray array];
//    [array addObject:[NSString stringWithFormat:@"%d", channel]];
//    [self startCheckBuffer:sInfo.session chArray:array];
    
    [self ThreadDownloadWithSession:sInfo.session Channel:channel];
}

// 0: GRPC, 1: 视频， 2：音频  4 视频下载
- (void)ThreadDownloadWithSession:(INT32)session Channel:(INT32)channel {
    JVSLog(@"ThreadDownloadWithSession: session= %d   - Read Channel= %d", session, channel);
    if (session < 0) {
        JVSLog(@"!!!!!!!!!!!!!!!!!ThreadDownload exit for Invalid SessionID(%d)!!\n", session);
        return;
    }
    INT32 ret = -1;
    ULONG totalSize = 0;
    INT32 sizeToRead = 400 * 1024;
    INT32 timeOut_ms = 200;
    INT32 bufSize = sizeToRead + 4;
    UCHAR *readBuf = (unsigned char*)malloc(bufSize);
    BOOL readStarted = NO;
    
    while (1) {
        while (1) {
            // ReadSize: Expected size of data to be read.
            // Readszie must specify size to be read before each PPCS_Read.
            // Very important!!
            INT32 readSize = sizeToRead;
            memset(readBuf, 0, bufSize);
            ret = PPCS_Read(session, channel, (CHAR *)readBuf, &readSize, timeOut_ms);
            JVSLog(@"--Thread_Download_channel =%d  - ret=%d - readSize = %d", channel, ret, readSize);
            /********************************************************
               PPCS_Read() return ERROR_PPCS_TIME_OUT(-3) :
               1. PPCS_Read: -3 timeout error is normal, but the default size cannot be read within the set timeout time,
                  is not a breakout error, need to continue to read the remaining data loop.
               2. PPCS_read returns -3 timeout and it is possible to read some data,
                  so it is necessary to check the size of ReadSize.
                  This sample code will directly add the size of ReadSize.
               3. Readszie is the actual data size read. If PPCS_read does not read the data,
                  the Readszie variable will be cleared to zero and must be reassigned before the next PPCS_read,
                  otherwise Readszie 0 to PPCS_read will return a -5 error (-5: invalid parameter).
             *********************************************************/
            if (ret != ERROR_PPCS_INVALID_PREFIX && ret != ERROR_PPCS_INVALID_SESSION_HANDLE && readSize) {
                readStarted = YES;
                NSData *data = [NSData dataWithBytes:readBuf length:readSize];
                JVSReadData *model = [JVSReadData modelWithData:data];
                [self didDownloadData:model channel:channel];
                totalSize += readSize;
            }
            if (ret < 0 && ret != ERROR_PPCS_TIME_OUT) {
                if (readStarted && readSize == 0 && _tmpLocalFullPath) {
                    readStarted = NO;
                    // 已经开始读了，但是数据不完整
                    JVSLog(@"--- Download_File Failed - _downloadedFileSize-%ld -- _fileSize = %ld", _downloadedFileSize, _fileSize);
                    dispatch_barrier_async(dispatch_get_main_queue(), ^{
                        if (_downloadCompletionBlock) {
                            _downloadCompletionBlock(nil, [NSError errorWithMsg:@"下载失败"]);
                        }
                        _downloadProgressBlock = nil;
                        _toLocalFullPath = nil;
                        _tmpLocalFullPath = nil;
                        _downloadedFileSize = 0;
                        _downloadCompletionBlock = nil;
                    });
                }
                break;
            }
            HS_mSecSleep(30);
        }
        if (totalSize % 16 == totalSize % (1*1024*1024)) {
            setbuf(stdout, NULL);
        }
        if ((ret != ERROR_PPCS_SUCCESSFUL && ret != ERROR_PPCS_TIME_OUT)) {
            break;
        }
    }
    if (readBuf) {
        free(readBuf);
    }
    JVSLog(@"===!!!!!!!!!!!!!!!!! ThreadDownloadWithSession(Channel=%d) %s \n", channel, getP2PErrorInfo(ret));
    return;
}

#pragma mark --------------------------  DelegateCallback
-(void)didReadData:(JVSReadData *)model channel:(int)channel {
    if (channel==1) {  // 音视频
        dispatch_async(_queue_video_read, ^{
            [self __didReadData:model channel:channel];
        });
    }
    else {
        dispatch_async(_queue_grpc_read, ^{
            [self __didReadData:model channel:channel];
        });
    }
    
}
-(void)__didReadData:(JVSReadData *)model channel:(int)channel {
    NSDictionary *map = JVSP2PSDKManager.shared.targetMap.copy;
    [map enumerateKeysAndObjectsUsingBlock:^(NSString *key, _JVSInternalTarget *obj, BOOL *stop) {
        if (!obj.target) {
            JVSLOCK({
                [JVSP2PSDKManager.shared.targetMap removeObjectForKey:key];
                JVSLog(@"----- DelegateRemoved = %@", key);
            });
            return;
        }
        if ( obj.target && obj.impl_didReadData_channel ) {
            [obj.target JVSP2PSDKManager:self didReadData:model channel:channel];
        }
    }];
}

-(void)didDownloadData:(JVSReadData *)model channel:(int)channel {
    if (!_tmpLocalFullPath) {
        _tmpLocalFullPath = [self generateTmpVideoPath];
    }
    NSMutableData *toWriteData = [NSMutableData data];
    // 矫正 一帧数据 被拆开了
    for (int i = 0; i < model.readData.length-8 && model.readData.length > 8; i++) {
        if (memcmp(model.readData.bytes+i, kFlagA5, 8)==0) {
            if (i > 0) {
                [toWriteData appendData:[model.readData subdataWithRange:NSMakeRange(0, i)]];
            }
            break;  // 找到开始位置
        }
    }
    
    NSArray <JVSFrameInfo *> *frames = model.frameDatas;
    [frames enumerateObjectsUsingBlock:^(JVSFrameInfo *obj, NSUInteger idx, BOOL *stop) {
        [toWriteData appendData:obj.frameData];
    }];
    [JVSP2PSDKManager writeDataLocalWith:toWriteData toLocalFile:_tmpLocalFullPath];
    
    _downloadedFileSize += toWriteData.length;
    if (_downloadProgressBlock) {
        m_dispatch_main_async(^{
            _downloadProgressBlock(_downloadedFileSize<=_fileSize?_downloadedFileSize:_fileSize);
        });
    }
    JVSLog(@"--- Download_File ING - _downloadedFileSize-%ld -- _fileSize = %ld", _downloadedFileSize, _fileSize);
    JVSLog(@"--- Download_File ING - _toLocalFullPath = %@", _toLocalFullPath);
    if (_downloadedFileSize >= _fileSize) {  // 已下载完成
        
        [NSFileManager.defaultManager moveItemAtPath:_tmpLocalFullPath toPath:_toLocalFullPath error:nil];
        NSString *fullPath = _toLocalFullPath;
        JVSLog(@"--- Download_File Success - _downloadedFileSize-%ld -- _fileSize = %ld", _downloadedFileSize, _fileSize);
        _toLocalFullPath = nil;
        _tmpLocalFullPath = nil;
        _downloadedFileSize = 0;
        
        dispatch_barrier_async(dispatch_get_main_queue(), ^{
            if (_downloadCompletionBlock) {
                _downloadCompletionBlock(fullPath, nil);
            }
            _downloadCompletionBlock = nil;
        });
    }
    
}

/// 视频状态更新了
-(void)videoStatusDidUpdateWith:(JVSP2PStateCode)code {
    dispatch_barrier_async(dispatch_get_main_queue(), ^{
        [self _videoStatusDidUpdateWith_:code];
    });
}
-(void)_videoStatusDidUpdateWith_:(JVSP2PStateCode)code {
    if (_connectStatus==code) {
        return;
    }
    
    _connectStatus = code;
    NSDictionary *map = JVSP2PSDKManager.shared.targetMap.copy;
    [map enumerateKeysAndObjectsUsingBlock:^(NSString *key, _JVSInternalTarget *obj, BOOL *stop) {
        if (!obj.target) {
            [_condition lock];
            [JVSP2PSDKManager.shared.targetMap removeObjectForKey:key];
            [_condition unlock];
            return;
        }
        if (obj.target && obj.impl_didChangeVideoState_forKey) {
            [obj.target JVSP2PSDKManager:self didChangeVideoState:code forKey:key];
        }
    }];
}

static long _indexCount_ = 0;
-(long)getUniqueRequestId {
    [_condition lock];
    _indexCount_ ++;
    [_condition unlock];
    return _indexCount_;
}

// 写本地数据
+(void)writeDataLocalWith:(NSData *)data toLocalFile:(NSString *)toLocalFile {
    if (!data || !toLocalFile) {
        NSLog(@"------- logData can't be NULL,  or fileName can't be NULL ");
        return;
    }
    dispatch_barrier_async(JVSP2PSDKManager.shared->_writeFileQueue, ^{
        [JVSP2PSDKManager _writeDataLocalWith:data toLocalFile:toLocalFile];
    });
}

+(void)_writeDataLocalWith:(NSData *)data toLocalFile:(NSString *)toLocalFile {
    if (![[NSFileManager defaultManager] fileExistsAtPath:toLocalFile]) {
        [[NSFileManager defaultManager] createFileAtPath:toLocalFile contents:nil attributes:nil];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:toLocalFile];
    if (fileHandle == nil) {
        return;
    }
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:data];
    [fileHandle synchronizeFile];
    [fileHandle closeFile];
}

-(NSString *)generateTmpVideoPath {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"Tmp"];
    if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *fileName = [NSString stringWithFormat:@"%@.mp4", [NSDate.date jvs_stringWithFormat:@"yyyyMMddHHmmss"]];
    path = [path stringByAppendingPathComponent:fileName];
    
    return path;
}


- (BOOL)checkDID:(NSString *)DID andInitString:(NSString *)InitString {
    DID = [_p2pSDK checkDID:DID];
    if (DID == nil) {
        NSLog(@"--checkDID -- %@ ", _p2pSDK.lastResultString);
        return NO;
    }
    if (InitString.length < 18) {
        NSLog(@"--checkDID -- %@ ", _LStr(@"InitStringERROR"));
        return NO;
    }
    
    return YES;
}

@end
