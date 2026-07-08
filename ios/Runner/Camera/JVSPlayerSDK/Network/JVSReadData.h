//
//  JVSReadData.h
//  appdemo
//
//  Created by 李华 on 2025/1/18.
//

#import <Foundation/Foundation.h>
#import "JVSFrameInfo.h"
#import "JVSSDKHeader.h"

NS_ASSUME_NONNULL_BEGIN


@interface JVSReadData : NSObject

#pragma mark --------------------------  没有读到头部信息 则无法解析数据，直接返回 readData
/// type==0 I帧， type==1: P帧
/// type==3: 音频
/// type==4: 给设备端发送的GRPC数据 文本类型
///
///回放视频
/// 0x80(=128) 0x81(=129) 0x82(=130音频) 是回放视频
@property(nonatomic, assign, readonly) int type;
@property(nonatomic, assign, readonly) int size;

/// 回放时：时间戳，当前视频的 毫秒级别时间轴；
/// 实况时：毫秒级别的 唯一编码
@property(nonatomic, assign, readonly) uint64_t timeStamp;

// modelWithData: 传过来的数据, 可能包含多帧数据
@property(nonatomic, strong, readonly) NSData *readData;

/// 是否包含了I帧
@property(nonatomic, assign, readonly) BOOL hasTypeIFrame;

+(instancetype)modelWithData:(NSData *) data;


/// 返回所有的帧数据
/// 如果首帧不是 kFlagA5 开头的，则丢弃首帧
-(NSArray<JVSFrameInfo *> *)frameDatas;

/// 被丢弃的 首帧
@property(nonatomic, strong, readonly) NSData *headTruncatedData;

/// 是不是回放 音频/视频 数据
@property(nonatomic, assign, readonly) BOOL isPlaybackVideoData;

@end

NS_ASSUME_NONNULL_END
