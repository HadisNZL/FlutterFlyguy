//
//  JVSFrameInfo.h
//  appdemo
//
//  Created by 李华 on 2025/3/4.
//

#import <Foundation/Foundation.h>

#define kHeaderByteLength         24

NS_ASSUME_NONNULL_BEGIN

@interface JVSFrameInfo : NSObject

@property(nonatomic, assign, readonly) int size;

/// type==0 I帧， type==1: P帧
/// type==3: 音频
/// type==4: 给设备端发送的GRPC数据 文本类型
/// 
///回放视频
/// 0x80 0x81 0x82(音频) 是回放视频
@property(nonatomic, assign, readonly) int type;

@property(nonatomic, assign, readonly) UInt64 timeStamp;

/// 帧数据
@property(nonatomic, strong, readonly) NSData *frameData;

/// 是不是回放 音频/视频 数据
@property(nonatomic, assign, readonly) BOOL isPlaybackVideoData;

+(instancetype)modelWith:(int)type timeStamp:(uint64_t)timeStamp size:(int)size frameData:(NSData *)frameData;

@end

NS_ASSUME_NONNULL_END
