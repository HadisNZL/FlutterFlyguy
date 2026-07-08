//
//  NSObject+PLExtension.h
//  PLExtension
//
//  Created by 李华 on 2017/1/10.
//  Copyright © 2017年 Philip Lee. All rights reserved.
//

#import <Foundation/Foundation.h>

// - 移除 NSArray， NSDictionary 中的NSNull 数据
// JSONObject 是NSNull 则返回 nil
FOUNDATION_EXPORT id JVSJSONObjectByRemovingKeysWithNullValues(id JSONObject);

@interface NSObject (MJOSNFormat_)


/**
 把 NSObject数据 转化成 NSDictionary 或者 NSArray。
 转化失败 则返回 nil

 @return NSDictionary 或者 NSArray
 */
-(id) m_JSONObject;

/**
字典转化为 NSData
 
 @return NSData
 */
-(NSData *) m_JSONData;
-(NSString *) m_JSONString;

/**
 把当前模型 转 字典
 @return 字典
 */
- (NSMutableDictionary *)m_modelToDictionary;

@end

@interface NSData (_JSON_)

/**
 使用UTF8 转换为 String
 @return String
 */
-(NSString *) m_dataToString;

@end


