//
//  NSString+Extension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (HexExtension)

/// 返回MD5加密后的字符串
-(NSString *) md5;

/// 16进制字符串，转10进制 数字
- (int)hexStringToInteger;

/// 16进制字符串转  16进制 NSData数据
- (NSData *)convertHexStrToData;

@end

NS_ASSUME_NONNULL_END
