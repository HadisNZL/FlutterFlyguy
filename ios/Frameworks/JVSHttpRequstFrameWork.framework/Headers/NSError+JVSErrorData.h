//
//  NSError+JVSErrorData.h
//  JVSHttpRequstFrameWork
//
//  Created by 李华 on 2024/12/26.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSError (JVSErrorData)

/// fail 回调时，有需要的返回值的数据
@property(nonatomic, strong) id responseData;

@end

NS_ASSUME_NONNULL_END
