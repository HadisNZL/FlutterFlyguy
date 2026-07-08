//
//  NSArray+SAExtension.h
//  SAASTest
//
//  Created by 李华 on 2024/1/19.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSArray (SAExtension)


/// 使用Compare:方法 返回一个升序数组
-(NSArray *)jvs_sortArrayOrderedAscending;
-(NSArray *)jvs_sortArrayOrderedDecending;

/// 如果是自定义对象，使用对象的 key 去调用 compare:方法 返回一个升序数组
-(NSArray *)jvs_sortArrayOrderedAscendingUsingKey:(NSString *)key;

///  如果是自定义对象，使用对象的 key 去调用 compare:方法 返回一个降序序数组
-(NSArray *)jvs_sortArrayOrderedDecendingUsingKey:(NSString *)key;


/// 支持 NSString，NSNumber
-(NSString *)jvs_componentsJoinedByString:(NSString *)separator;

/// 倒序输出
-(NSArray *)jvs_reversed;

@end

NS_ASSUME_NONNULL_END
