//
//  JVSSendDataRequest.h
//  JVSDeviceSetBasicInfo
//
//  Created by 李华 on 2024/12/17.
//

#import "JVSBaseRequest.h"
#import "JVSP2PSDKManager.h"
#import "JVSFrameInfo.h"
#import <JVSBasicToolFramework/MJExtension.h>

@interface _JVSInternalRequestData:NSObject {
    
@package
    JVSWriteData *_sendData;
}

@property(nonatomic, strong, readonly) RequestSuccessDataBlock _Nullable success;
@property(nonatomic, strong, readonly) RequsetFailBlock _Nullable fail;

@property(nonatomic, copy, readonly) NSString * _Nonnull method;
@property(nonatomic, copy, readonly) NSDictionary *_Nullable params;

/// 发给设备的数据
@property(nonatomic, strong, readonly) JVSWriteData *sendData;


@property(nonatomic, assign) long requestId;
@property(nonatomic, assign) BOOL hasCompleted;

// 失效
-(void)invalidate;

+(instancetype)modelWithMethod:(NSString * _Nonnull)method
                    withParams:(NSDictionary * _Nullable)params
                       success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

// timeoutSeconds秒后 超时回调 最低15秒
-(void)makeTimeoutCallbackWith:(int)timeoutSeconds;

@end

@implementation _JVSInternalRequestData


// 失效
-(void)invalidate {
    _hasCompleted = YES;
    _success = nil;
    _fail = nil;
}

// timeoutSeconds秒后 超时回调
-(void)makeTimeoutCallbackWith:(int)timeoutSeconds {
    timeoutSeconds = MAX(15, timeoutSeconds);
    __weak __typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeoutSeconds * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (weakSelf.fail && !weakSelf.hasCompleted) {
            NSString *msg = [NSString stringWithFormat:@"%@ 请求超时", weakSelf.method];
            NSError *error = [NSError errorWithDomain:@"JVSSendDataRequest" code:-1
                                             userInfo:@{NSLocalizedDescriptionKey: msg}];
            
            NSTimeInterval costTime = NSDate.date.timeIntervalSince1970 - weakSelf.sendData.startTime;
            JVSLog(@"----/GRPC////channel0_Send_Data Get_Back 3 Timeout (Cost %.0lf)////---------------\nrequestId=%ld \nparam=%@\n\n ", costTime, weakSelf.requestId, weakSelf.params);
            
            weakSelf.fail(error);
        }
    });
}

+(instancetype)modelWithMethod:(NSString * _Nonnull)method
                    withParams:(NSDictionary * _Nullable)params
                       success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    _JVSInternalRequestData *model = _JVSInternalRequestData.new;
    model->_method = method;
    model->_params = params;
    model->_success = success;
    model->_fail = fail;
    
    return model;
}
@end

@interface JVSBaseRequest ()<JVSP2PSDKManagerDelegate> {
    NSCondition *_condition;
}

@property(nonatomic, strong) NSMutableDictionary<NSString *, _JVSInternalRequestData *> *targetMap;

@end

@implementation JVSBaseRequest

+ (instancetype)shared {
    static JVSBaseRequest *request;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        request = [[JVSBaseRequest alloc] init];
        request->_targetMap = @{}.mutableCopy;
        request->_condition = [[NSCondition alloc] init];
        
        [JVSP2PSDKManager addDelegateForTarget:request];
    });
    return request;
}

+(void)_addRequestWith:(JVSWriteData *)sendData method:(NSString * _Nonnull)method
           withParams:(NSDictionary * _Nullable)params
              success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    if (method.length==0) {
        JVSAssertFailed(@"Method must not be nil");
        return;
    }
    _JVSInternalRequestData *model = [_JVSInternalRequestData modelWithMethod:method withParams:params success:success fail:fail];
    model->_sendData = sendData;
    
    [JVSBaseRequest.shared->_condition lock];
    JVSBaseRequest.shared.targetMap[Int2Str(sendData.requestId)] = model;
    [JVSBaseRequest.shared->_condition unlock];
    
    [model makeTimeoutCallbackWith:15];
}

+(_JVSInternalRequestData *)getRequestWithId:(long)requestId {
    
    _JVSInternalRequestData *model = nil;
    [JVSBaseRequest.shared->_condition lock];
    model = JVSBaseRequest.shared.targetMap[Int2Str(requestId)];
    [JVSBaseRequest.shared->_condition unlock];
    
    return model;
}
+(void)removeRequestWithId:(long)requestId {
    
    [JVSBaseRequest.shared->_condition lock];
    [JVSBaseRequest.shared.targetMap removeObjectForKey:Int2Str(requestId)];
    [JVSBaseRequest.shared->_condition unlock];
}

// 取消所有请求
+(void)cancelAllRequest {
    NSArray<_JVSInternalRequestData *> *values = JVSBaseRequest.shared->_targetMap.allValues;
    [values enumerateObjectsUsingBlock:^(_JVSInternalRequestData *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj invalidate];
    }];
    
    [JVSBaseRequest.shared->_condition lock];
    [JVSBaseRequest.shared->_targetMap removeAllObjects];
    [JVSBaseRequest.shared->_condition unlock];
}


+ (void)sendDataWithMethod:(NSString * _Nonnull)method
                withParams:(NSDictionary * _Nullable)params
                   success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    [self sendDataWithMethod:method channelId:0 withParams:params success:success fail:fail];
}

// 基础发送请求方法 通道channelId  发送消息
+ (void)sendDataWithMethod:(NSString * _Nonnull)method
                 channelId:(int)channelId withParams:(NSDictionary * _Nullable)params
                   success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSMutableDictionary *methodDic = [[NSMutableDictionary alloc]init];
    [methodDic setObject:method forKey:@"method"];
    [methodDic setObject:params?:@{} forKey:@"param"];
    
    long requestId = [JVSP2PSDKManager.shared getUniqueRequestId];
    // 返回值 会打印 JVSLog(@"------------------- channel=0 Get--------------- ");
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:methodDic options:NSJSONWritingPrettyPrinted error:nil];
    JVSLog(@"\n-------------------channel%d_Send_Data (requestId=%ld)---------------\nparams=%@\n\n", channelId, requestId, methodDic.mj_JSONString);
    
    JVSWriteData *dataModel = [JVSWriteData modelWithChannel:channelId data:jsonData requestId:requestId];
    [JVSBaseRequest _addRequestWith:dataModel method:method withParams:params success:success fail:fail];
    
    [JVSP2PSDKManager.shared sendDataWith:dataModel];
}


#pragma mark --------------------------  Callback
+(void)_makeCallbackWithData:(id)data success:(id)success successDataRet:(BOOL)hasDataRet  {
    if (hasDataRet) {  // 有参回调
        id dataMap = data;
        RequestSuccessDataBlock block = success;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block(dataMap);
        });
    } else {  // 无参回调
        RequestSuccessBlock block = success;
        dispatch_async(dispatch_get_main_queue(), ^{
            if (block) block();
        });
    }
}

+(void)_handleSecondTrans:(NSDictionary *)dataDict success:(id)success
                     fail:(RequsetFailBlock)fail successDataRet:(BOOL)hasDataRet  {
    /// 二次穿透的数据 返回值
    
    if (dataDict[@"method"] || dataDict[@"error"]) {
        NSDictionary *errDict = [dataDict[@"error"] isKindOfClass:NSDictionary.class]?dataDict[@"error"]:dataDict;
        NSDictionary *result = @{};
        if (dataDict[@"result"]) {
            result = JVSJSONObjectByRemovingKeysWithNullValues(dataDict[@"result"]);
        } else if (dataDict[@"data"]) {
            result = JVSJSONObjectByRemovingKeysWithNullValues(dataDict[@"data"]);
        }
        if (dataDict[@"code"] && [errDict[@"code"] intValue]==0) {
            [self _makeCallbackWithData:result?:@{} success:success successDataRet:hasDataRet];
            return;
        }
        else if (errDict[@"errorcode"] && [errDict[@"errorcode"] intValue]==0) {
            [self _makeCallbackWithData:result?:@{} success:success successDataRet:hasDataRet];
            return;
        }
        int errorcode = -1;
        if (errDict[@"errorcode"]) {
            errorcode = [errDict[@"errorcode"] intValue];
        } else if ( errDict[@"code"] ) {
            errorcode = [errDict[@"code"] intValue];
        } else if ( dataDict[@"code"] ) {
            errorcode = [dataDict[@"code"] intValue];
        }
        NSError *error = [NSError errorWithDomain:@"JVSSendDataRequest.request" code:errorcode
                                         userInfo:@{NSLocalizedDescriptionKey:errDict[@"errormsg"] ?:@"请求失败"}];
        error.responseData = result;
        if (fail) fail(error);
        return;
    }
}

#pragma mark --------------------------  JVSP2PSDKManagerDelegate
-(void)JVSP2PSDKManager:(JVSP2PSDKManager *)manager didReadData:(JVSReadData *)model channel:(int)channel {
    if (channel==0) { // grpc
        NSArray *list = model.frameDatas;
        JVSLog(@"-------------------GRPC channel0_Send_Data Get_Back 1(Count=%d)--------------- ", (int)list.count);
        [list enumerateObjectsUsingBlock:^(JVSFrameInfo * obj, NSUInteger idx, BOOL * stop) {
            long requestId = obj.timeStamp;
            NSString *resultString = [[NSString alloc] initWithData:obj.frameData encoding:4];
            if (!resultString) {
                resultString = [[NSString alloc] initWithData:obj.frameData encoding:1];
            }
            JVSLog(@"-------------------GRPC channel0_Send_Data Get_Back 1.1\nDataLen=%ld \nresultString=%@----- ", obj.frameData.length, resultString);
            NSDictionary *dict = [resultString mj_JSONObject];
            
            _JVSInternalRequestData *requestModel = [JVSBaseRequest getRequestWithId:requestId];
            [JVSBaseRequest removeRequestWithId:requestId];
            requestModel.hasCompleted = YES;
            [JVSBaseRequest _handleSecondTrans:dict success:requestModel.success fail:requestModel.fail successDataRet:YES];
            
            NSTimeInterval costTime = NSDate.date.timeIntervalSince1970 - requestModel.sendData.startTime;
            JVSLog(@"----/GRPC////------- channel0_Send_Data Get_Back 2 (Cost %.01lf秒)////---------------\nrequestId=%ld \nparam=%@\nresult = %@\n\n\n ", costTime, requestId, requestModel.params, dict);
        }];
    }
}




@end
