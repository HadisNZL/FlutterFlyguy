//
//  JVSP2PPlayer.m
//  appdemo
//
//  Created by 李华 on 2025/1/17.
//

#import "JVSP2PPlayer.h"
#import "DIDModel.h"
#import "JVSP2PSDKManager.h"
#import "JVSDataRequest.h"
#import "JVSFrameParser.h"
#import "NSData+HexExtension.h"
#import <JVSPlayerSDK/JVSPlayerSDK.h>
#import <AVFoundation/AVFoundation.h>

// 视频状态 转 string
FOUNDATION_EXPORT NSString *GetJVSVideoStatusString(JVSVideoStatus status) {
    switch (status) {
        case JVSVideoStatusNone:            return @"Status_None"; break;
        case JVSVideoStatusConnecting:      return @"Status_Connecting"; break;
        case JVSVideoStatusConnectFailed:   return @"Status_ConnectFailed"; break;
        case JVSVideoStatusConnected:       return @"Status_Connected"; break;
        case JVSVideoStatusVideoPlaying:    return @"Status_VideoPlaying"; break;
        case JVSVideoStatusDisconnected:    return @"Status_Disconnected"; break;
        default:
            break;
    }
    return @"";
}

#define JVSGetNowTime [[NSDate date] timeIntervalSince1970]

@interface JVSP2PPlayer ()<
JVSP2PSDKManagerDelegate
, AVAudioRecorderDelegate
, JVSFrameParserDelegate
, BeiKeTalkCallBackDelegate
, ConnectDelegate
> {
    BOOL _isPlaying;
    NSString *_fileName;
    
    dispatch_queue_t _writeFileQueue;
    dispatch_queue_t _parserVideoQueue;
    int _processedCount;
    
    NSCondition *_condition;
    
    NSString *_playedSoundName;
    
    NSMutableData *_tmpData;
    
    JVSFrameParser *_videoParser;
    
    JVSVideoType _videoType;
    
    NSInteger _byteCount;
    NSInteger _startTime;
    NSInteger _endTime;
    
    BOOL _hasInitPBVideo;
    dispatch_queue_t _queue_video_parser;
    
    UILabel *_markLabel;
    BOOL _isConnectingJVSPlayer;
}
@property(nonatomic, strong) UIView *videoView;
//@property(nonatomic, assign) JVSVideoStatus videoStatus;

@property(nonatomic, assign) int chatId;
@property(nonatomic, assign) int video_fps;

@end

@implementation JVSP2PPlayer

-(int)frameRate { return _video_fps; }

+(void)registerPlayerSDK {
    JVSLog(@"JVSP2PPlayer_Version 1.5.13(16) ");
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [paths objectAtIndex:0];
        NSString *projectLOGPath = [path stringByAppendingPathComponent:@"ProjectLOG"];
        [[NSFileManager defaultManager] createDirectoryAtPath:projectLOGPath withIntermediateDirectories:YES attributes:nil error:nil];
        int logLevel = 0;
#if JVSLogOpen==1
        // 打印详细日志的 - 开启日志了
        logLevel = 1;
        [[JVSPlayerSDK shareInstanceSDK]playerConfig:@{@"stream_debug": @(YES)}];
#endif
        [[JVSPlayerSDK shareInstanceSDK]initPlayerSDK:logLevel logPath:projectLOGPath];

    });
}
+(void)releasePlayerSDK {
    [JVSPlayerSDK.shareInstanceSDK releasePlayerSDK];
}

+(instancetype)playerWithView:(UIView *)view type:(JVSVideoType)type nLocalChannel:(int)nLocalChannel {
    JVSP2PPlayer *player = JVSP2PPlayer.new;
    player.videoView = view;
    player->_nLocalChannel = arc4random_uniform(1001)+1; // nLocalChannel;
    player->_videoType = type;
    [player setupBaseData];
    JVSPlayerSDK.shareInstanceSDK.ConnectDelegate = player;
    JVSLog(@"---- playerWithView_nLocalChannel = %ld,  _nLocalChannel=%d", type, player->_nLocalChannel);
    
    return player;
}

/// 视频连接状态回调
/// @param channel 通道号
/// @param eventState 事件类型
-(void)VideoEventCallBackChannel:(int)channel withEventState:(int)eventState withMsg:(id)msgDic {
    m_dispatch_main_async(^{
        if (eventState == JVS_VIDEO_DECODE_SUCCESS) {
            [JVSPlayerSDK.shareInstanceSDK playerControlSoundChannel:_nLocalChannel withSound:!_voiceMute];
        }
        
    });
}

/// 重新设置数据
-(void)resetPlayerWithType:(JVSVideoType) type {
    _videoType = type;
    
    [JVSPlayerSDK.shareInstanceSDK disconnect:_nLocalChannel];
    [self _connectJVSPlayerSDK];
}

-(void)resetPlayerWithType:(JVSVideoType) type videoView:(UIView *)videoView {
    _videoView = videoView;
    [self resetPlayerWithType:type];
}

+(instancetype)playerWithView:(UIView *)view type:(JVSVideoType) type {
    return [self playerWithView:view type:type nLocalChannel:1];
}

-(void)setupBaseData {
    _voiceMute = NO;
    _fileName = [NSString stringWithFormat:@"%@.es", [[NSDate date] jvs_stringWithFormat:@"yyMMddHHmmss"]];
    _writeFileQueue = dispatch_queue_create("_Write_File_Queue", 0);
    _parserVideoQueue = dispatch_queue_create("_Write_File_Queue", DISPATCH_QUEUE_CONCURRENT);
    _condition = [[NSCondition alloc] init];
    
    _videoParser = [[JVSFrameParser alloc] initWithType:JVSFrameParseTypeVideo];
    _videoParser.delegate = self;
    
    _queue_video_parser = dispatch_queue_create("Queue_Video_Parser", DISPATCH_QUEUE_SERIAL);
    
    _markLabel = [UILabel new];
    _markLabel.layer.zPosition = 1000;
    _markLabel.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.45];
    _markLabel.textColor = UIColor.whiteColor;
    _markLabel.font = [UIFont systemFontOfSize:12];
    [_videoView addSubview:_markLabel];
    _markLabel.hidden = YES;
    [_markLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.offset(8);
    }];
}

-(void)setShouldShowConnectModeMark:(BOOL)shouldShowConnectModeMark {
    _shouldShowConnectModeMark = shouldShowConnectModeMark;
    _markLabel.hidden = !shouldShowConnectModeMark;
}

-(void)connectVideoWith:(DIDModel *)DIDModel {
    _didModel = DIDModel;
    [_videoParser resetBuffer];
    _videoParser.delegate = self;
    _isPlaying = NO;
    _isRecording = NO;
    JVSLog(@"---------------  _connectVideoWith_");
    
    [JVSP2PSDKManager addDelegateForTarget:self forKey:[NSString stringWithFormat:@"JVSP2PPlayer_%d", _nLocalChannel]];
    if (![JVSP2PSDKManager.shared connectWithDIDModel:DIDModel]) {
        self.videoStatus = JVSVideoStatusConnectFailed;
    }
}
/// 停止播放视频
-(void)stopPlayVideo {
    [JVSP2PSDKManager removeDelegateForKey:[NSString stringWithFormat:@"JVSP2PPlayer_%d", _nLocalChannel]];
    _videoStatus = JVSVideoStatusNone;
    _isPlaying = NO;
    _isRecording = NO;
    _hasInitPBVideo = NO;
    
    _videoParser.delegate = nil;
    [_videoParser resetBuffer];
    
    [JVSPlayerSDK.shareInstanceSDK disconnect:_nLocalChannel];
}

-(void)disconnect {
    [self stopRecord];
    [self stopPlayVideo];
    [JVSPlayerSDK.shareInstanceSDK disconnect:_nLocalChannel];
    self.videoStatus = JVSVideoStatusDisconnected;
    
    _videoParser.delegate = nil;
    [_videoParser resetBuffer];
    [JVSP2PSDKManager.shared disconnect];
    
    _nLocalChannel = arc4random_uniform(1001)+1; // nLocalChannel;  使用新的一个
}

/// 切换回放和直播的时候
-(void)resetBufferWhenSwitchedType {
    [_videoParser resetBuffer];
    
    _isPlaying = NO;
    _isRecording = NO;
    if (_videoType == JVSVideoTypeOnline) {
        _hasInitPBVideo = NO;
    }
}

// 修改画布的大小  可以是 videoView.bound
-(void)changeOpenGLViewFrame:(CGRect)frame {
    [JVSPlayerSDK.shareInstanceSDK changeOpenGLViewFrameChannel:_nLocalChannel withFrame:frame];
}

#pragma mark --------------------------  回放视频操作
// 视频回放 - 暂停后，再次播放视频
-(void)resumePBVideoWithCallback:(MCommonCompletionBlock)callback {
    [JVSDataRequest sendVideoControlWith:JVSPlayerCMDType_RESUME value:1 success:^(id data) {
        [JVSPlayerSDK.shareInstanceSDK playBackPauseChannel:_nLocalChannel withPause:NO];
        _isPaused = NO;
        if (callback) callback(YES, data, nil);
    } fail:^(NSError * _Nonnull error) {
        if (callback) callback(NO, nil, error);
    }];
}

// 视频回放 - 暂停回放
-(void)pausePBVideoWithCallback:(MCommonCompletionBlock)callback {
    [JVSDataRequest sendVideoControlWith:JVSPlayerCMDType_PAUSE value:1 success:^(id data) {
        _isPaused = YES;
        [JVSPlayerSDK.shareInstanceSDK playBackPauseChannel:_nLocalChannel withPause:YES];
        if (callback) callback(YES, data, nil);
    } fail:^(NSError * _Nonnull error) {
        if (callback) callback(NO, nil, error);
    }];
}

// 视频回放 - 停止回放
-(void)stopPBVideoWithCallback:(MCommonCompletionBlock)callback {
    [JVSDataRequest sendVideoControlWith:JVSPlayerCMDType_STOP value:1 success:^(id data) {
        if (callback) callback(YES, data, nil);
    } fail:^(NSError * _Nonnull error) {
        if (callback) callback(NO, nil, error);
    }];
}
/// 按时间播放 回放视频
-(void)playPBVideoAtTime:(NSString *)time callback:(MCommonCompletionBlock)callback {
    if (_videoType !=  JVSVideoTypePlayBack) {
        NSLog(@"请在回放播放器中调用此方法");
        return;
    }
    if (!_hasInitPBVideo) {
        _hasInitPBVideo = YES;
        [JVSDataRequest playPBVideoAtTime:time.integerValue success:^(id  _Nullable data) {
            // withRemoteChannel 必须是 1 是 视频通道
            [self _connectJVSPlayerSDK];
            
            JVSLog(@"playPBVideoAtTime 播放成功");
            if (callback) callback(YES, data, nil);
        } fail:^(NSError * _Nonnull error) {
            _hasInitPBVideo = NO;
            JVSLog(@"playPBVideoAtTime 播放失败");
            if (callback) callback(NO, @{@"type": @"playPB"},  error);
        }];
        return;
    }
    if (_videoStatus != JVSVideoStatusVideoPlaying) {
        JVSLog(@" Want_To_SEEK, BUT _videoStatus is NOT JVSVideoStatusVideoPlaying");
        return;
    }
    
    [JVSDataRequest sendVideoControlWith:JVSPlayerCMDType_SEEK value:time.integerValue success:^(id data) {
        JVSLog(@"JVSPlayerCMDType_SEEK 成功");
        if (callback) callback(YES, @{@"type": @"seek"}, nil);
    } fail:^(NSError * _Nonnull error) {
        if (error.code == -7) {
            _hasInitPBVideo = NO;
        }
        JVSLog(@"JVSPlayerCMDType_SEEK 失败");
        if (callback) callback(NO, @{@"type": @"seek"}, error);
    }];
}

/// 持续调用 播放视频流程
/// channel 0通道是信令，也就是我们的grpc协议，1通道是视频，2通道是音频
-(void)playWithData:(NSData *)data channel:(int)channel {
    if (!_videoView) {
        JVSAssertFailed(@"videoView是nil 请先设置 视频View");
        return;
    }
    [self _playWithData:data channel:channel];
    
}

// data为 P2P 读到的原始数据
-(void)_playWithData:(NSData *)data channel:(int)channel {
    if (channel==1) {
        dispatch_async(_queue_video_parser, ^{
            [_videoParser parseData:data];
        });
        // for Test
//        NSString *hexStr = [[data convertDataToHexStr] stringByAppendingString:@"\n"];
//        [JVSDataLogManager writeDataLocalWith:hexStr.mj_JSONData fileName:_fileName subDirectory:@"Channel44"];
    }

}

-(void)_connectJVSPlayerSDK {
    // withRemoteChannel 必须是 1 是 视频通道
    [JVSPlayerSDK.shareInstanceSDK deviceConnect:@"esframe" withChannel:_nLocalChannel
                               withShowVideoView:_videoView withRemoteChannel:1 withStream:0 isratio:NO];
    
    [self _updateVideo_fps_Info];
}

/// 更新视频的 帧率
-(void)_updateVideo_fps_Info {
    JVSLog(@"\n VideoType1: %@ ----- video_fps = %d\n", _videoType==0?@"VideoOnline":@"PlayBack", _video_fps);
    
    if (_video_fps > 0 && _videoStatus==JVSVideoStatusVideoPlaying) {
        NSDictionary *videoParamD = @{@"video_fps": @(_video_fps*1.0)};
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:videoParamD options:NSJSONWritingPrettyPrinted error:nil];
         
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSLog(@"JSON String: %@", jsonString);
        [JVSPlayerSDK.shareInstanceSDK playerPushFrameDataChannel:_nLocalChannel
                                                             type:6 frameData:jsonData pts:0];
        
        JVSLog(@"\n VideoType2: %@ ----- video_fps = %@\n", _videoType==0?@"VideoOnline":@"PlayBack", jsonString);
    }
}

#pragma mark --------------------------  帧解析了，推给播放库
// channel 0通道是信令，也就是我们的grpc协议，
// 1通道是视频，
// 2通道是音频
// JVSFrameParserDelegate <NSObject>
- (void)JVSFrameParser:(JVSFrameParser *)parser onRevicedFrameParse:(JVSFrameInfo * _Nullable)frame {
    if (!frame || frame.size <= 0) return;
//    int channel = (int)parser.parseType;  // 视频 还是 语音
    if (JVSLogDataReadOpen)JVSLog(@"JVSFrameParser - type=%d - timestamp=%lld - size=%d -- videoType=%ld", frame.type, frame.timeStamp, frame.size, _videoType);
    m_dispatch_main_async(^{
        
        if (_videoStatus != JVSVideoStatusVideoPlaying && JVSP2PSDKManager.shared.connectStatus==JVSP2PStateCodeVideoPlaying) {
            if (JVSLogDataReadOpen)JVSLog(@"_videoStatus=%ld - JVSP2PSDKManager_connectStatus=%ld", _videoStatus, JVSP2PSDKManager.shared.connectStatus);
            self.videoStatus = JVSVideoStatusVideoPlaying;
            
            if (_videoType==JVSVideoTypePlayBack) {
                _hasInitPBVideo = YES;
            }
            VideoStatus status = [JVSPlayerSDK.shareInstanceSDK playerConnectStatusChannel:_nLocalChannel];
            if (status!=VideoPlaying) {
                _isConnectingJVSPlayer = YES;
                if (_isConnectingJVSPlayer) return;
                JVSLog(@"_videoStatus=%@ - _isConnectingJVSPlayer_YES", GetJVSVideoStatusString(_videoStatus));
                [self _connectJVSPlayerSDK];
            }
            else if (status==VideoPlaying) {
                _isConnectingJVSPlayer = NO;
            }
        }
    });
    
    if ( _videoType==JVSVideoTypePlayBack ) {
        if (frame.isPlaybackVideoData) {
            int type = 1; // 视频
            if (frame.type == 0x82) type = 2; // 音频
            if (type == 2 && frame.size != frame.frameData.length) {
                /// 音频长度和 实际长度不一致，丢了
                JVSLog(@"------  Not_SAME_JVSVideoTypePlayBack %d 实际=%d - hex = %@\n", frame.size, (int)frame.frameData.length,
                       [frame.frameData convertDataToHexStr]);
                return;
            }
            if (JVSLogDataReadOpen)JVSLog(@"playerPushFrameDataChannel PlayBack - %d - %d - %lld - _nLocalChannel=%d", _nLocalChannel, frame.type, frame.timeStamp, _nLocalChannel);
            
            if (frame.type == 0x83) {
                const uint8_t *bytes = (const uint8_t *)[frame.frameData bytes];
//                uint32_t video_codec = *(uint32_t *)&bytes[0];
//                uint32_t video_width = *(uint32_t *)&bytes[4];
//                uint32_t video_height = *(uint32_t *)&bytes[8];
                uint32_t video_fps = *(uint32_t *)&bytes[12];
//                uint32_t audio_codec = *(uint32_t *)&bytes[16];
//                uint32_t audio_channels = *(uint32_t *)&bytes[20];
//                uint32_t audio_sample_rate = *(uint32_t *)&bytes[24];
//                uint32_t audio_sample_bits = *(uint32_t *)&bytes[28];
                
                self.video_fps = video_fps;
                [self _updateVideo_fps_Info];
                
            }else {
                [JVSPlayerSDK.shareInstanceSDK playerPushFrameDataChannel:_nLocalChannel
                                                                     type:type frameData:frame.frameData pts:frame.timeStamp];
            }
            //            if (type == 1) {
            //                [JVSDataLogManager writeDataLocalWith:frame.frameData fileName:_fileName subDirectory:@"Channel23"];
            //            }
        }
    
    }
    else if ( _videoType==JVSVideoTypeOnline ) {
        if (!frame.isPlaybackVideoData) {
            int type = 1; // 视频
            if (frame.type == 3) type = 2; // 音频
            if (type == 2 && frame.size != frame.frameData.length) {
                /// 音频长度和 实际长度不一致，丢了
                JVSLog(@"------  Not_SAME_JVSVideoTypeOnline %d 实际=%d - hex = %@\n", frame.size, (int)frame.frameData.length,
                       [frame.frameData convertDataToHexStr]);
                return;
            }
            if (JVSLogDataReadOpen)JVSLog(@"playerPushFrameDataChannel Online - %d - %d - %lld", _nLocalChannel, type, frame.timeStamp);
            if (frame.type == 5) {
                
                const uint8_t *bytes = (const uint8_t *)[frame.frameData bytes];
//                uint32_t video_codec = *(uint32_t *)&bytes[0];
//                uint32_t video_width = *(uint32_t *)&bytes[4];
//                uint32_t video_height = *(uint32_t *)&bytes[8];
                uint32_t video_fps = *(uint32_t *)&bytes[12];
//                uint32_t audio_codec = *(uint32_t *)&bytes[16];
//                uint32_t audio_channels = *(uint32_t *)&bytes[20];
//                uint32_t audio_sample_rate = *(uint32_t *)&bytes[24];
//                uint32_t audio_sample_bits = *(uint32_t *)&bytes[28];
                
                self.video_fps = video_fps;
                [self _updateVideo_fps_Info];
            }else {
                [JVSPlayerSDK.shareInstanceSDK playerPushFrameDataChannel:_nLocalChannel
                                                                     type:type frameData:frame.frameData pts:frame.timeStamp];
            }
            
            //#if DEBUG
            //        if (type == 2) {
            //            [JVSDataLogManager writeDataLocalWith:frame.data fileName:_fileName subDirectory:@"Channel1"];
            //        }
            //#endif
        }
    }
    
}

-(void)setVoiceMute:(BOOL)voiceMute {
    _voiceMute = voiceMute;
    
    JVSLog(@"\n setVoiceMute_withSound: %d ----- _nLocalChannel = %d\n", !_voiceMute, _nLocalChannel);
    [JVSPlayerSDK.shareInstanceSDK playerControlSoundChannel:_nLocalChannel withSound:!_voiceMute];
}


#pragma mark --------------------------   播放报警音
-(void)playAlarmSoundWith:(NSString *)soundName times:(int)times callback:(MCommonCompletionBlock)callback {
    _playedSoundName = soundName?:@"";
    /// times -1是一直播放，0是播放1次，其它按次数播放(如 times=2 则播放俩次)
    [JVSDataRequest playAlarmSoundWith:_playedSoundName channelid:0 times:times success:^(id data) {
        JVSLog(@"播放报警声音");
        if (callback) callback(YES, data, nil);
    } fail:^(NSError * _Nonnull error) {
        JVSLog(@"播放报警声音失败");
        if (callback) callback(NO, nil, error);
    }];
}

-(void)stopPlayAlarmSoundWith:(MCommonCompletionBlock)callback {
    /// 如果是 times = -1时，则是一直播放，需要调用该方法停止播放
    [JVSDataRequest stopPlayAlarmSoundWith:_playedSoundName channelid:0 success:^(id data) {
        // 停止播放报警声音
        JVSLog(@"停止播放报警声音");
        if (callback) callback(YES, data, nil);
    } fail:^(NSError * _Nonnull error) {
        JVSLog(@"停止播放报警声音失败");
        if (callback) callback(NO, nil, error);
    }];
}

// 开始视频录制
-(NSString *)startRecord {
    _isRecording = YES;
    
    NSArray *patchs = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *tmpDir = [patchs objectAtIndex:0];
    NSString *timeDay = [NSDate.date jvs_stringWithFormat:@"YYYYMMdd"];
    NSString *fileDirPath = [tmpDir stringByAppendingPathComponent:[NSString stringWithFormat:@"SASS_Video/%@",timeDay]];
    NSString *fileName = [[NSDate.date jvs_stringWithFormat:@"YYYYMMddHHmmssSSSS"] stringByAppendingString:@".mp4"];
    
    BOOL isDir = NO;
    BOOL existed = [[NSFileManager defaultManager] fileExistsAtPath:fileDirPath isDirectory:&isDir];
    if (!(isDir && existed)) {
        [[NSFileManager defaultManager] createDirectoryAtPath:fileDirPath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    [JVSPlayerSDK.shareInstanceSDK playRecordChannel:_nLocalChannel withWritePath:fileDirPath
                                      withNamePrefix:fileName withIsOpen:YES];
    NSString *videoFullPath = [fileDirPath stringByAppendingPathComponent:fileName];
    JVSLog(@"-------- 录制视频的文件地址： %@", videoFullPath);
    
    return videoFullPath;
}

-(void)stopRecord {
    _isRecording = NO;
    [JVSPlayerSDK.shareInstanceSDK playRecordChannel:_nLocalChannel withWritePath:nil withNamePrefix:nil withIsOpen:NO];
}

// 录像前获取帧率数据
-(void)getVideoStreamsWithCallback:(MCommonCompletionBlock)callback {
    [JVSDataRequest getStreamsWith:@{} success:^(id data) {
        if (callback) callback(YES, data, nil);
    } fail:^(NSError * _Nonnull error) {
        if (callback) callback(NO, nil, error);
    }];
}
#pragma mark --------------------------  开启对讲
-(int)startTalk {
    _chatId = [[JVSPlayerSDK shareInstanceSDK]startTalk:@"esframe" remoteChannel:0];
    [JVSPlayerSDK shareInstanceSDK].beiKeTalkDelegate = self;
    [[JVSPlayerSDK shareInstanceSDK]beiKeTalkSetCallBackChatId:_chatId];
    
    NSDictionary *audioParamD = @{@"audio_codec": @"G711a", @"audio_channels": @(1), @"audio_sample_rate": @(8000),
                                  @"audio_sample_bites": @(16)};
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:audioParamD options:0 error:nil];
    [JVSPlayerSDK.shareInstanceSDK playerPushFrameDataChatId:_chatId
                                                         type:6 frameData:jsonData pts:0];
    
    return _chatId;
}
-(void)stopTalk {
    [[JVSPlayerSDK shareInstanceSDK]stopTalk:_chatId];
    _chatId = 0;
}

#pragma mark --------------------------  BeiKeTalkCallBackDelegate
//贝壳物联对讲数据回调
-(void)beiKeTalkCallBackData:(uint8_t *)talkData length:(uint32_t)size {
    NSData *g711Data = [NSData dataWithBytes:talkData length:size];
    if (!g711Data) {
        return;
    }
    [JVSP2PSDKManager.shared sendoAudioDataWith:g711Data];
}


#pragma mark -------------------------- JVSP2PSDKManagerDelegate
/// channel
/// 0：通道是信令，也就是我们的grpc协议，
/// 1: 视频 通道， 音频 通道
-(void)JVSP2PSDKManager:(JVSP2PSDKManager *)manager didReadData:(JVSReadData *)model channel:(int)channel {
    if (channel==1) {
        if (_startTime == 0) {
            _startTime = JVSGetNowTime;
        }
        _endTime = JVSGetNowTime;
        CGFloat offsetTime = _endTime - _startTime;
        _byteCount += model.readData.length;
        if (offsetTime > 1) {
            _bytePerSecond = _byteCount*1000/(offsetTime*1000);
            _endTime = _startTime = _byteCount = 0;
            JVSLog(@"------- ____bytePerSecond = %ld", _bytePerSecond);
        }
        [self playWithData:model.readData channel:channel];
        
        if (_shouldShowConnectModeMark) {
            m_dispatch_main_async(^{
                [_markLabel.superview bringSubviewToFront:_markLabel];
                _markLabel.text = [NSString stringWithFormat:@"%@ %.2lfkb/s", _didModel.modeString?:@"", _bytePerSecond/1000.0];
            });
        }
    }
}

-(void)JVSP2PSDKManager:(JVSP2PSDKManager *)manager didChangeVideoState:(JVSP2PStateCode)code forKey:(nonnull NSString *)key {
    m_dispatch_on_main_thread(^{
        NSString *orgKey = [NSString stringWithFormat:@"JVSP2PPlayer_%d", _nLocalChannel];
        if (![orgKey isEqualToString:key]) {
            JVSLog(@"------- Status_IS_NOT_SAME_WITH_CALLBACK");
            return;
        }
        self.videoStatus = (NSInteger)code;
    });
}

-(void)setVideoStatus:(JVSVideoStatus)videoStatus {
    if (_videoStatus == videoStatus) return;
    if (_videoStatus==JVSVideoStatusDisconnected && videoStatus==JVSVideoStatusConnectFailed) {
        return;
    }
    if (_videoType==JVSVideoTypePlayBack &&
        (videoStatus==JVSVideoStatusDisconnected || videoStatus==JVSVideoStatusConnectFailed)) {
        _hasInitPBVideo = NO;
    }
    if (videoStatus==JVSVideoStatusDisconnected || videoStatus==JVSVideoStatusConnectFailed || videoStatus==JVSVideoStatusNone) {
        _video_fps = 0;
    }
    _videoStatus = videoStatus;
    JVSLog(@"------- __setVideoStatus__%d = %@", _nLocalChannel, GetJVSVideoStatusString(videoStatus));
    
    if (videoStatus==JVSVideoStatusVideoPlaying) {
        [self _connectJVSPlayerSDK];
    }
//    [self willChangeValueForKey:@"videoStatus"];  // 不需要，否则调用俩次了
    
    
//    if (_videoStatus == JVSVideoStatusConnected) {
//        //连接成功-获取码流信息
//        [self getVideoStreamsWithCallback:^(BOOL success, id  _Nullable data, NSError * _Nullable error) {
//            if (success) {
//                
//                NSDictionary *result = (NSDictionary *)data;
//                NSArray *streams = result[@"streams"];
//                for (NSDictionary *streamDic in streams) {
//                    if (streamDic[@"frameRate"]) {
//                        NSDictionary *fpsDic = @{@"video_fps": streamDic[@"frameRate"]};
//                        NSError *error = nil;
//                        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:fpsDic options:0 error:&error];
//                        if (!error) {
//                            [JVSPlayerSDK.shareInstanceSDK playerPushFrameDataChannel:_nLocalChannel
//                                                                                 type:6 frameData:jsonData pts:0];
//                        }
//                        self.frameRate = [streamDic[@"frameRate"] intValue];
//                        break;
//                    }
//                }
//            }
//        }];
//    }
    
//    [self didChangeValueForKey:@"videoStatus"];  // 不需要，否则调用俩次了
}


+(BOOL)automaticallyNotifiesObserversForKey:(NSString *)key {
    return [key isEqualToString:@"videoStatus"];
}


/// 获取视频截图 - 视频需正常播放，否则会截图失败
-(UIImage *)snapshotImageAtPath:(NSString * _Nullable)path {
    NSString *imagePath = path;
    if (!path) {
        imagePath = [self generateTmpImagePath];
    }
    NSString *directory = imagePath.stringByDeletingLastPathComponent;
    if (![[NSFileManager defaultManager] fileExistsAtPath:directory]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES
                                                   attributes:nil error:nil];
    }
    
    [JVSPlayerSDK.shareInstanceSDK playSnapshotChannel:_nLocalChannel withWritePath:imagePath imageType:1];
    UIImage *image = [UIImage imageWithContentsOfFile:imagePath];
    
#if RELEASE
    if (!path) {  // 自己创建的临时文件
        // 正式环境删除，防止视频过大
        [[NSFileManager defaultManager] removeItemAtPath:imagePath error:nil];
    }
#endif
    
    return image;
}

-(NSString *)generateTmpImagePath {
    NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *path = [documentsDir stringByAppendingPathComponent:@"Tmp"];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg", [NSDate.date jvs_stringWithFormat:@"yyyyMMddHHmmss"]];
    path = [path stringByAppendingPathComponent:fileName];
    
    return path;
}

-(void)dealloc {
    NSLog(@" -----  Dealloc_JVSP2PPlayer - %@", self);
    [self disconnect];
}


-(void)writeLocalWithData:(NSData *)data {
    // 检查帧长度是否足够（至少 kHeaderByteLength 字节头部）
    if (data.length < kHeaderByteLength) {
        return;
    }
    NSMutableData *mdata = [NSMutableData data];
    
    const uint8_t *bytes = (const uint8_t *)[data bytes];
    int index = 0;
    for (int i = 0; i < data.length-8 && data.length > 8; i++) {
        if ((memcmp(bytes+i, kFlagA5, 8)==0)) {
            index = i; break;  // 找到开始位置
        }
    }
    if (index > 0 && index <= data.length) {
        [mdata appendData:[data subdataWithRange:NSMakeRange(0, index)]];
    }
    while ((index+kHeaderByteLength) < data.length) {
        if (!(memcmp(bytes + index, kFlagA5, 8)==0)) {
            // 标识不一致了，结束
            break;
        }
        // 提取数据长度，数据长度在第 12 个字节开始，占 4 个字节
        uint32_t frameSize = *(uint32_t *)&bytes[index+12];   // 占 4 个字节
        
        if ((index+kHeaderByteLength+frameSize) >= data.length) {  // 这一帧被切割 成两次接收
            // 超过了，取最后的所有数据
            frameSize = (int)data.length - (index+kHeaderByteLength);
        }
        NSData *frameData = [data subdataWithRange:NSMakeRange(index+kHeaderByteLength, frameSize)];
        [mdata appendData:frameData];
        
        index += (kHeaderByteLength + frameSize);
    }
    [JVSDataLogManager writeDataLocalWith:mdata fileName:_fileName subDirectory:@"Channel33"];
    
}

@end
