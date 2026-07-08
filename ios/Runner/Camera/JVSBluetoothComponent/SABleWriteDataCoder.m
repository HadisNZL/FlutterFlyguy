//
//  SABleWriteDataCoder.m
//  SAASTest
//
//  Created by 李华 on 2024/1/26.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import "SABleWriteDataCoder.h"
#import "NSString+HexExtension.h"
#import "NSData+HexExtension.h"
#import <JVSBasicToolFramework/JVSLogManager.h>

@implementation SABleWriteDataCoder


// 每个包按最大字节 125 字节传输，超过则分包发送
// 头部：包的数量(1) 包的序号(1, 范围1-255) 起始包(1) 结束包(1) 报文体长度(2) md5校验(16)
// 内容 (125-22=103)
/// 支持分包 - 发送给服务端
-(NSArray<NSData *> *)encodeDataWith:(NSData *)rawData {
    
    NSMutableArray *array = NSMutableArray.new;
    int totalDataLen = (int)[rawData length];
    int dataMaxLenEach = SAMaxLenPerTime;
    
    NSString *md5String = [[NSString alloc] initWithData:rawData encoding:NSUTF8StringEncoding].md5;
    NSData *md5Data = [md5String convertHexStrToData];  // md5的 Data值
    if (totalDataLen > dataMaxLenEach){
        int times = (totalDataLen-1)/dataMaxLenEach+1;  // 分包数量
        for (int i = 0; i < times; i++) {
            int curDataLength = MIN(dataMaxLenEach, totalDataLen-dataMaxLenEach*i);
            NSData *dataTemp = [rawData subdataWithRange:NSMakeRange(dataMaxLenEach*i,
                                                                  curDataLength)];
            int startIdx = i + 1;   // 包的序号 从1开始，后台规定的
            NSData *toSendData = [self _buildSendDataAtIdx:startIdx totalDataLen:totalDataLen
                                                       md5:md5Data body:dataTemp];
            [array addObject:toSendData];
        }
    } else { // 小于 SAMaxLenPerTime 个字节时，不用分包直接写入
        NSData *toSendData = [self _buildSendDataAtIdx:1 totalDataLen:totalDataLen
                                                   md5:md5Data body:rawData];
        [array addObject:toSendData];
    }
    
    return array;
}

/// 组装蓝牙数据
/// @param i 分包的序号 从1开始
/// @param totalDataLen 总数据的 字节长度
-(NSData *)_buildSendDataAtIdx:(int)i totalDataLen:(int)totalDataLen md5:(NSData *)md5Data body:(NSData *)partBodyData {
    
    //当写入的数据大于120个字节时，分包发送
    int partBodyDataLen = (int)partBodyData.length;
    int dataCount = (totalDataLen-1)/SAMaxLenPerTime+1;
    
    BOOL isStart = i == 1;
    BOOL isEnd = i == dataCount;
    
    NSMutableData *body = [NSMutableData new];
    // 分包的数量
    [body appendData:[NSData dataWithInteger:dataCount length:1]];
    // 包的序号
    [body appendData:[NSData dataWithInteger:i length:1]];
    // 是不是起始包
    [body appendData:[NSData dataWithInteger:isStart?1:0 length:1]];
    // 是不是结束包
    [body appendData:[NSData dataWithInteger:isEnd?1:0 length:1]];
    // 报文体长度
    [body appendData:[NSData dataWithInteger:partBodyDataLen length:2]];
    
    [body appendData:md5Data];
    [body appendData:partBodyData];
    
    return body;
}

@end
