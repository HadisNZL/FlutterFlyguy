//
//  JVSChannelData.m
//  appdemo
//
//  Created by 李华 on 2025/1/18.
//

#import "JVSWriteData.h"
#import "NSData+HexExtension.h"

@implementation JVSWriteData


+(instancetype)modelWithChannel:(int)channel data:(NSData *)data requestId:(int64_t)requestId {
    JVSWriteData *model = JVSWriteData.new;
    model->_requestId = requestId;
    model->_channel = channel;
    model->_toSendData = [model dataByJoinHeaderWithContentData:data];
    return model;
}

-(NSData *)dataByJoinHeaderWithContentData:(NSData *)data {
    NSMutableData *bodyData = NSMutableData.new;
    
    // 组装返送的头部数据
    [bodyData appendData:[NSData dataWithInteger:0xaaaaaaaa length:4]];
    [bodyData appendData:[NSData dataWithInteger:0x55555555 length:4]];
    // type==0 I帧， type==1: P帧
    // type==3: 音频
    // type==4: 给设备端发送的GRPC数据 文本类型
    if (self.channel==2) {  // 音频
        [bodyData appendData:[NSData dataWithInteger:3 length:4]];  // type 音频
    }
    else {
        [bodyData appendData:[NSData dataWithInteger:4 length:4]];  // type 文本
    }
    [bodyData appendData:[NSData dataWithInteger:(int)data.length length:4]];  // size
    [bodyData appendData:[NSData dataWithLong:_requestId length:8]];           // 请求ID  - 8位  - 时间戳
    
    // 内容数据
    [bodyData appendData:data];
    
    return bodyData.copy;
}

@end
