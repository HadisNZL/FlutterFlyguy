//
//  SABleResultModel.h
//  SAASTest
//
//  Created by 李华 on 2024/1/16.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SABleDataCoder.h"

NS_ASSUME_NONNULL_BEGIN

/// 服务端发送的数据 的 解码器
@interface SABleReadDataCoder : NSObject<SABleDataCoder>

#pragma mark --------------------------  Decode
-(BOOL)canDecodeDataWith:(NSData *)partData;

/// 增加分包数据, 如果完整了，则返回数据，否则返回 Error
/// 先 canDecodeDataWith 判断后，在添加分包数据
/// - Parameter partData: 分包数据
-(NSDictionary *)resultDataByAddingPartData:(NSData *)partData error:(NSError **)error;



@end

NS_ASSUME_NONNULL_END
