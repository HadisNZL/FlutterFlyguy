//
//  JVSRecorder.m
//  appdemo
//
//  Created by 李华 on 2025/2/21.
//

#import "JVSRecorderManager.h"

typedef struct AQCallbackStruct
{
    AudioStreamBasicDescription mDataFormat;
    AudioQueueRef               queue;
    AudioQueueBufferRef         _Nonnull mBuffers[kNumberBuffers];

    AudioFileID                 outputFile;
    UInt32                      frameSize;
    long long                   recPtr;
    int                         run;
} AQCallbackStruct;


@interface JVSRecorderManager () {
    AQCallbackStruct aqc;
    
    dispatch_queue_t _sync_queue_send_data;
}

@property (nonatomic, assign) AQCallbackStruct aqc;

@end

@implementation JVSRecorderManager {
    BOOL _method_didRecordAudioWithData_;
}

@synthesize aqc;

static void AQInputCallback (void                   * inUserData,
                             AudioQueueRef          inAudioQueue,
                             AudioQueueBufferRef    inBuffer,
                             const AudioTimeStamp   * inStartTime,
                             unsigned long          inNumPackets,
                             const AudioStreamPacketDescription * inPacketDesc)
{
    JVSRecorderManager *recorder = (__bridge id)inUserData;
    if (inNumPackets > 0) {
        [recorder processAudioBuffer:inBuffer withQueue:inAudioQueue];
    }
    if (recorder.aqc.run) {
        AudioQueueEnqueueBuffer(recorder.aqc.queue, inBuffer, 0, NULL);
    }
}

- (instancetype) init {
    self = [super init];
    if (self) {
        aqc.mDataFormat.mFormatID = kAudioFormatLinearPCM;
        aqc.mDataFormat.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger |kLinearPCMFormatFlagIsPacked;
        aqc.mDataFormat.mFramesPerPacket = 1;
        
        aqc.mDataFormat.mSampleRate = kSampleRate;
        aqc.mDataFormat.mChannelsPerFrame = kNumberChannels;
        aqc.mDataFormat.mBitsPerChannel = kBitsPerChannels;
        aqc.mDataFormat.mBytesPerFrame = (aqc.mDataFormat.mChannelsPerFrame*aqc.mDataFormat.mBitsPerChannel/8);
        aqc.mDataFormat.mBytesPerPacket = aqc.mDataFormat.mBytesPerFrame;
        aqc.frameSize = kFrameSize;
        
        AudioQueueNewInput(&aqc.mDataFormat, (AudioQueueInputCallback)AQInputCallback,
                           (__bridge void *)self, NULL, NULL,0, &aqc.queue);
        for (int i=0; i<kNumberBuffers; i++) {
            AudioQueueAllocateBuffer(aqc.queue, aqc.frameSize, &aqc.mBuffers[i]);
            AudioQueueEnqueueBuffer(aqc.queue, aqc.mBuffers[i], 0, NULL);
        }
        aqc.recPtr = 0;
        aqc.run = 1;
        int status = AudioQueueStart(aqc.queue, NULL);
        NSLog(@"AudioQueueStart = %d", status);
        
        _sync_queue_send_data = dispatch_queue_create("Record_Send_Data", DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(void)setDelegate:(id<JVSRecorderManagerDelegate>)delegate {
    _delegate = delegate;
    _method_didRecordAudioWithData_ = _delegate && [_delegate respondsToSelector:@selector(didRecordAudioWithData:)];
}



- (void) dealloc {
    AudioQueueStop(aqc.queue, true);
    aqc.run = 0;
    AudioQueueDispose(aqc.queue, true);
}

- (void) start {
    AudioQueueStart(aqc.queue, NULL);
}

- (void) stop {
    AudioQueueStop(aqc.queue, true);
}

- (void) pause {
    AudioQueuePause(aqc.queue);
}

// 处理采集的音频回调
- (void) processAudioBuffer:(AudioQueueBufferRef) buffer withQueue:(AudioQueueRef) queue {
    long size = buffer->mAudioDataByteSize;
    NSData *data = [NSData dataWithBytes:buffer->mAudioData length:size];
    if (_method_didRecordAudioWithData_) {
        [_delegate didRecordAudioWithData:data];
    }
}

/// 请求权限
+(void)requestRecordPermission:(JVSCommonSuccessBlock)block {
    // 1. 设置音频会话
    AVAudioSession *session = [AVAudioSession sharedInstance];
    NSError *sessionError;
    [session setCategory:AVAudioSessionCategoryPlayAndRecord
             withOptions:AVAudioSessionCategoryOptionAllowBluetooth|AVAudioSessionCategoryOptionDefaultToSpeaker
                   error:&sessionError];
    [session setActive:YES error:&sessionError];
    
    if (sessionError) {
        NSString *msg = [NSString stringWithFormat:@"音频会话配置失败: %@", sessionError.localizedDescription];
//        ShowToastWith(msg);
        return;
    }
    // 2. 请求麦克风权限
    [session requestRecordPermission:^(BOOL granted) {
        if (block) block(granted);
    }];
    
}



@end
