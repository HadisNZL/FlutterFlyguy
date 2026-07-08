//
//  JVSSecondRequest_.h
//  JVSDeviceNetConfigComponent
//
//  Created by 李华 on 7/11/2024.
//

#import <Foundation/Foundation.h>
#import <JVSHttpRequstFrameWork/JVSHttpRequstFrameWork.h>

@class JVSDeviceInfoBase;

//2.0透传接口
@interface JVSSecondRequest_ : NSObject


/// localChannelId 本地播放的 通道id
+ (void)secondSendDataWithModel:(JVSDeviceInfoBase *)channelModel
                 localChannelId:(int)localChannelId
                     withParame:(NSDictionary *)parame
                        success:(RequestSuccessDataBlock)success
                           fail:(RequsetFailBlock)fail;

//2.0透传接口（可以通过传入model)
+ (void)secondSendDataWithModel:(JVSDeviceInfoBase *)channelModel
                     withParame:(NSDictionary *)parame
                        success:(RequestSuccessDataBlock)success
                           fail:(RequsetFailBlock)fail;
//2.0透传接口
+ (void)setSecondDataWithParame:(NSDictionary *)parame
                        success:(RequestSuccessDataBlock)success
                           fail:(RequsetFailBlock)fail
                  withOldParame:(NSDictionary *)oldParame;



@end


