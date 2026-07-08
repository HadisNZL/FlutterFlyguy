//
//  NSObject+JVSJSONFormat.h
//  JVSHttpRequstFrameWork
//
//  Created by 李华 on 2024/9/20.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSObject (JVSJSONFormat)


/**
 把 NSObject数据 转化成 NSDictionary 或者 NSArray。
 转化失败 则返回 nil

 @return NSDictionary 或者 NSArray
 */
-(id) jvs_dataToJSONObject;

/**
 使用UTF8 转换为 String
 @return String
 */
-(NSString *) jvs_dataToString;

/**
 把当前模型 转 字典
 @return 字典
 */
- (NSMutableDictionary *)jvs_modelToDictionary;

@end

@interface NSString (_JSON_)

/// NSString 转 NSData
-(NSData *) jvs_stringToData;

@end




NS_ASSUME_NONNULL_END
