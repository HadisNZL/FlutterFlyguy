//
//  NSData+JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (HexExtension)

// 高低位 互换
-(NSData *)highLowSwitch;

#pragma mark --------------------------  进制转换-蓝牙配网
// 16进制数据 转 16进制字符串
- (NSString *)convertDataToHexStr;
/// Data 转 16进制， 再转 10进制 数字
- (int)convertDataToInteger;

/// 数字 转 NSData
/// @param length 字节数 限制了字节数，超过会报错，返回nil
+(NSData *)dataWithInteger:(int)integer length:(int)length;
+(NSData *)dataWithLong:(int64_t)longInt length:(int)length;
/// 自动判断 数字的字节数
//+(NSData *)dataWithInteger:(int)integer;

/// 16进制的 字符串 转 NSData
+(NSData *)dataWithHexStr:(NSString *)hexStr;

@end

NS_ASSUME_NONNULL_END
