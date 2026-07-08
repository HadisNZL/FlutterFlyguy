//
//  SABleWriteDataCoder.h
//  SAASTest
//
//  Created by 李华 on 2024/1/26.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SABleDataCoder.h"


/// 发送给 蓝牙设备的 数据编码器
NS_ASSUME_NONNULL_BEGIN

@interface SABleWriteDataCoder : NSObject<SABleDataCoder>

#pragma mark --------------------------  Encode
/// 把整体数据，分包发送
-(NSArray<NSData *> *)encodeDataWith:(NSData *)rawData;

@end

NS_ASSUME_NONNULL_END
