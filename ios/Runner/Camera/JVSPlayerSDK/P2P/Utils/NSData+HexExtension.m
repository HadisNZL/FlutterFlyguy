//
//  NSData+JVSExtension.m
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/11/1.
//

#import "NSData+HexExtension.h"
#import "NSString+HexExtension.h"

@implementation NSData (HexExtension)

// 高低位 互换
-(NSData *)highLowSwitch {
    NSData *org = self;
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:org.length];
    for (NSInteger i=org.length-1; i>=0; i--) {
        [data appendData:[org subdataWithRange:NSMakeRange(i, 1)]];
    }
    return data.copy;
}

//16进制数据 转 16进制字符串
- (NSString *)convertDataToHexStr {
    NSData *data = self;
    if ([data length] == 0) {
        return @"";
    }
    NSMutableString *string = [[NSMutableString alloc] initWithCapacity:[data length]];
    [data enumerateByteRangesUsingBlock:^(const void *bytes, NSRange byteRange, BOOL *stop) {
        unsigned char *dataBytes = (unsigned char*)bytes;
        for (NSInteger i = 0; i < byteRange.length; i++) {
            NSString *hexStr = [NSString stringWithFormat:@"%x", (dataBytes[i]) & 0xff];
            if ([hexStr length] == 2) {
                [string appendString:hexStr];
            } else {
                [string appendFormat:@"0%@", hexStr];
            }
        }
    }];
    return string.copy;
}

/// Data 转 16进制， 再转 10进制
- (int)convertDataToInteger {
    NSData *data = self;
    NSString *str = [data convertDataToHexStr];
    return [str hexStringToInteger];
}


/// 自动判断 数字的字节数
+(NSData *)dataWithInteger:(int)integer {
    NSString *hexStr  = [NSString stringWithFormat:@"%x", integer];
    int length = ((int)hexStr.length-1)/2 + 1;
    return [self dataWithInteger:integer length:length];
}

+(NSData *)dataWithInteger:(int)integer length:(int)length {
    NSString *hexStr  = [NSString stringWithFormat:@"%x", integer];
    if (integer >= powl(2, length*8)) {  // 装不下
        NSLog(@"dataWithInteger -- %d(length=%d) 数据太大了，装不下", integer, length);
        return NSData.new;
    }
    NSMutableString *mHexStr = hexStr.mutableCopy;
    int offset = length*2 - (int)hexStr.length;
    /// 占位 和 补0
    for (int i = 0; i < offset; i++) {
        [mHexStr insertString:@"0" atIndex:0];
    }
    NSData *hexData = [mHexStr convertHexStrToData];
    
    return hexData;
}


+(NSData *)dataWithLong:(int64_t)longInt length:(int)length {
    NSString *hexStr  = [NSString stringWithFormat:@"%llx", longInt];
    if (longInt >= powl(2, length*8)) {  // 装不下
        NSLog(@"dataWithInteger -- %lld(length=%d) 数据太大了，装不下", longInt, length);
        return NSData.new;
    }
    NSMutableString *mHexStr = hexStr.mutableCopy;
    int offset = length*2 - (int)hexStr.length;
    /// 占位 和 补0
    for (int i = 0; i < offset; i++) {
        [mHexStr insertString:@"0" atIndex:0];
    }
    NSData *hexData = [mHexStr convertHexStrToData];
    
    return hexData;
}


/// 16进制的 字符串
+(NSData *)dataWithHexStr:(NSString *)hexStr {
    return hexStr.convertHexStrToData;
}


@end
