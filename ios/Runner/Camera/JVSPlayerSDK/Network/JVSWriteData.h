//
//  JVSChannelData.h
//  appdemo
//
//  Created by 李华 on 2025/1/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JVSWriteData : NSObject

/// 向那个通道发送数据，0: GRPC, 1: 视频， 2：音频
@property(nonatomic, assign, readonly) int channel;

/// 本次请求 ID
@property(nonatomic, assign, readonly) int64_t requestId;

/// 发送给 设备的数据 - 组装后，增加了头部的数据
@property(nonatomic, strong, readonly) NSData *toSendData;

// data 原始数据
+(instancetype)modelWithChannel:(int)channel data:(NSData *)data requestId:(int64_t)requestId;


/// 请求开始时间
@property(nonatomic, assign) NSTimeInterval startTime;

@end

NS_ASSUME_NONNULL_END
