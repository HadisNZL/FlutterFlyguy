//
//  JVSP2PSendDataOperation.m
//  appdemo
//
//  Created by 李华 on 2025/3/27.
//

#import "JVSP2PSendDataOperation.h"
#import "JVSDefinesHeader.h"
#import "P2PSDKHeader.h"

@implementation JVSP2PSendDataOperation

@synthesize executing = _executing;
@synthesize finished = _finished;



-(instancetype)initWithSession:(int)session dataModel:(JVSWriteData *)dataModel completion:(JVSDataSendCompleteBlock)completion {
    self = [super init];
    if (self) {
        _dataModel = dataModel;
        _completedBlock = completion;
        _session = session;
        
        _executing = NO;
        _finished = NO;
    }
    return self;
}

- (void)start {
    if (self.isCancelled) {
        [self done];
        return;
    }
    self.executing = YES;
    int session = _session;
    int channel = _dataModel.channel;
    _dataModel.startTime = NSDate.date.timeIntervalSince1970;
    
    JVSLog(@"-------- Start_Did_Send_Data - %lld - channel=%d", _dataModel.requestId, channel);
    // 该方法是阻塞线程的
    [self ThreadWriteWithSession:session Channel:channel data:_dataModel.toSendData];
    
    if (_completedBlock) _completedBlock(_dataModel);
    [self done];
}

- (BOOL)ThreadWriteWithSession:(INT32)session Channel:(INT32)channel data:(NSData *)data {
    JVSLog(@"ThreadWriteWithSession: %d - %d", session, channel);
    if (session < 0) {
        JVSLog(@"%@", [NSString stringWithFormat:@"ThreadWrite_exit_for_Invalid_SessionID(%d)!!\n", session]);
        return NO;
    }
    if (channel < 0 || channel > 7) {
        JVSLog(@"%@", [NSString stringWithFormat:@"ThreadWrite_exit_for_Invalid_Channel(%d)!!\n", channel]);
        return NO;
    }
    
    INT32 _total_write_size = (int)data.length;
    UCHAR *buffer = (UCHAR *)data.bytes;
    INT32 ret = -1, checkRET = -1;
    ULONG totalSize = 0;
    UINT32 writeSize = 0;
    if (!buffer) {
        JVSLog(@"%@", [NSString stringWithFormat:@"ThreadWrite_exit_buffer %02d - Malloc failed!!\n", channel]);
        return NO;
    }
    JVSLog(@"--ThreadWrite__channel: %d - RequestId=%lld \n!!!!!!!!!!!! \n Audio_Send Start ", channel, _dataModel.requestId);
    
    BOOL sendSuccess = NO;
    while (1) {
        // Before PPCS_Write is called,
        // PPCS_Check_Buffer must be called to check how much data has not yet been sent from the write cache,
        // which should be controlled within a reasonable range, generally around 128KB/256KB.
        checkRET = PPCS_Check_Buffer(session, channel, &writeSize, nil);
        if (checkRET < 0) {
            JVSLog(@"%@", [NSString stringWithFormat:@"\n ThreadWrite_PPCS_Check_Buffer: Session=%d,CH=%d,WriteSize=%d,ret=%d %s\n", session, channel, writeSize, checkRET, getP2PErrorInfo(checkRET)]);
            /// 写失败了
            break;
        }
        // If the size of the write cache exceeds 128KB/256KB, there is a delay to consider.
        // If you find that writeSize is getting larger and larger,
        // the network state may be very poor,
        // you need to consider losing frames or decreasing the bit rate,
        // which is a dynamic adjustment strategy, very important!!
        if ((writeSize < TEST_WRITE_THRESHOLD) && (totalSize < _total_write_size)) {
            ret = PPCS_Write(session, channel, (CHAR *)buffer, (int)data.length); // TEST_ONE_WRITE_SIZE;
            
            if (ret < 0) {
                if (ret == ERROR_PPCS_SESSION_CLOSED_TIMEOUT) {// Bad network leads to disconnection.
                    JVSLog(@"!!!!!!!!!!!!!!!!!ERROR_PPCS_SESSION_CLOSED_TIMEOUT\n");
                }else if (ret == ERROR_PPCS_SESSION_CLOSED_REMOTE) {// The other party closes the connection voluntarily.
                    JVSLog(@"!!!!!!!!!!!!!!!!!ERROR_PPCS_SESSION_CLOSED_REMOTE\n");
                } else {
                    JVSLog(@"!!!!!!!!!!!!!!!!! %s \n", getP2PErrorInfo(ret));
                }
                continue;
            }
            totalSize += ret;
            writeSize += ret;
        } else if (writeSize == 0) { // 所有数据都已经发送成功
            JVSLog(@"--ThreadWrite__channel: %d RequestId=%lld \n!!!!!!!!!!!! \n Audio_Send Success ", channel, _dataModel.requestId);
            sendSuccess = YES;
            break;
        } else {
            HS_mSecSleep(2);
        }
    }
    return sendSuccess;
}

- (void)done {
    self.finished = YES;
    self.executing = NO;
    [self reset];
}

- (void)reset {
    _dataModel = nil;
    _session = 0;
    _completedBlock = nil;
}

- (void)setFinished:(BOOL)finished {
    [self willChangeValueForKey:@"isFinished"];
    _finished = finished;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)setExecuting:(BOOL)executing {
    [self willChangeValueForKey:@"isExecuting"];
    _executing = executing;
    [self didChangeValueForKey:@"isExecuting"];
}

- (BOOL)isAsynchronous {
    return YES;
}


@end
