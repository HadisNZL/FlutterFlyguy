//
//  SABleDataCoder.h
//  SAASTest
//
//  Created by 李华 on 2024/1/26.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>


/// 每次数据发送的最大字节数(不含头部，头部固定22字节，总计125字节)
#define SAMaxLenPerTime                 103


NS_ASSUME_NONNULL_BEGIN

@protocol SABleDataCoder <NSObject>


@optional
#pragma mark --------------------------  Decode
-(BOOL)canDecodeDataWith:(NSData *)partData;

/// 增加分包数据, 如果完整了，则返回完整结果数据，否则返回 Error
/// 先 canDecodeDataWith 判断后，在添加分包数据
/// - Parameter partData: 分包数据
-(NSDictionary *)resultDataByAddingPartData:(NSData *)partData error:(NSError **)error;


#pragma mark --------------------------  Encode
/// rawData 分包，然后分别发送 - 发送给服务端
/// 按最大字节 125 字节传输，分包发送
/// 包体结构： 包的数量(1) 包的序号(1) 起始包(1) 结束包(1) 分包的报文体长度(2) md5校验(16) 内容(SAMaxLenPerTime)
-(NSArray<NSData *> *)encodeDataWith:(NSData *)rawData;

@end

NS_ASSUME_NONNULL_END
