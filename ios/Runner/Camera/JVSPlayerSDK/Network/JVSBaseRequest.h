//
//  JVSSendDataRequest.h
//  JVSDeviceSetBasicInfo
//
//  Created by 李华 on 2024/12/17.
//

#import <Foundation/Foundation.h>
#import "NSError+JVSErrorData.h"

typedef void(^RequestSuccessDataBlock)(id _Nullable data);

/// revicedByte 已收到的数据， totalByte总数据大小
typedef void(^RequestProgressBlock)(NSInteger revicedByte, NSInteger totalByte);
typedef void(^RequsetFailBlock)(NSError * _Nonnull error);
typedef void(^RequestSuccessBlock)(void);


//2.0透传接口
@interface JVSBaseRequest : NSObject


/// 基础发送请求方法 通道0 发送消息
+ (void)sendDataWithMethod:(NSString * _Nonnull)method
                withParams:(NSDictionary * _Nullable)withParams
                   success:(RequestSuccessDataBlock _Nullable)success
                      fail:(RequsetFailBlock _Nullable)fail;


/// 基础发送请求方法 通道channelId  发送消息
+ (void)sendDataWithMethod:(NSString * _Nonnull)method
                 channelId:(int)channelId
                withParams:(NSDictionary * _Nullable)withParams
                   success:(RequestSuccessDataBlock _Nullable)success
                      fail:(RequsetFailBlock _Nullable)fail;


// 取消所有请求
+(void)cancelAllRequest;

@end


