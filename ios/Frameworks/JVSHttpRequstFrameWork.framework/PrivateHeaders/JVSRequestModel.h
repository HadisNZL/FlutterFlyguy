//
//  JVSRequestData.h
//  JVSHttpRequstFrameWork
//
//  Created by 李华 on 2024/9/20.
//

#import <Foundation/Foundation.h>
#import "JVSNetworkDefines.h"

typedef enum {
    JVSApiGet     = 0,                     // Get方式
    JVSApiPost    = 1,                     // Post方式
    JVSApiDelete  = 2,                     // Delete方式
    JVSApiPut     = 3,                     // Put方式
    JVSApiUpload,                          // 上传
    JVSApiSecond                           // 二次穿透接口
}JVSRequestType;

NS_ASSUME_NONNULL_BEGIN

@interface JVSRequestModel : NSObject

/// 请求方式 GET， POST， Delete， Put等
@property(nonatomic, assign) JVSRequestType apiType;
@property(nonatomic, copy) NSString *apiName;
@property(nonatomic, strong) NSDictionary *headers;

@property(nonatomic, strong) id params;
@property(nonatomic, strong) IRequestSuccessBlock successBlock;
@property(nonatomic, strong) IRequsetFailBlock failBlock;

/** 请求超时时间(默认:GET/POST 20秒) */
@property (nonatomic, assign) NSTimeInterval timeoutInterval;


/**
 @param type default Get
 @param uri 需要以 / 开头
 @return instance
 */
+(instancetype)modelWithType:(JVSRequestType)type uri:(NSString *)uri;

+(instancetype)modelWithType:(JVSRequestType)type uri:(NSString *)uri params:(id)params
                     success:(IRequestSuccessBlock)success fail:(IRequsetFailBlock)fail;


@end

NS_ASSUME_NONNULL_END
