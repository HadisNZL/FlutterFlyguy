//
//  NSString+Extension.m
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/11/1.
//

#import "NSString+HexExtension.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSString (HexExtension)


-(NSString *)md5 {
    if(self == nil || [self length] == 0)
        return nil;
    
    const char *value = [self UTF8String];
    
    unsigned char outputBuffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(value, (CC_LONG)strlen(value), outputBuffer);
    
    NSMutableString *outputString = [[NSMutableString alloc] initWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(NSInteger count = 0; count < CC_MD5_DIGEST_LENGTH; count++){
        [outputString appendFormat:@"%02x",outputBuffer[count]];
    }
    return outputString;
}

- (NSData *)convertHexStrToData {
    NSString *str = self;
    if ([str length] == 0) {
        return nil;
    }
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range = NSMakeRange(0, 1);
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

int c2i(char ch)
{
    // 如果是数字，则用数字的ASCII码减去48, 如果ch = '2' ,则 '2' - 48 = 2
    if(isdigit(ch))
        return ch - 48;
    
    // 如果是字母，但不是A~F,a~f则返回
    if( ch < 'A' || (ch > 'F' && ch < 'a') || ch > 'z' )
        return -1;
    
    // 如果是大写字母，则用数字的ASCII码减去55, 如果ch = 'A' ,则 'A' - 55 = 10
    // 如果是小写字母，则用数字的ASCII码减去87, 如果ch = 'a' ,则 'a' - 87 = 10
    if(isalpha(ch))
        return isupper(ch) ? ch - 55 : ch - 87;
    
    return -1;
}

/// 16 -> 10进制
int hex2dec(const char *hex)
{
    int len;
    int num = 0;
    int temp;
    int bits;
    int i;
    
    // 此例中 hex = "1de" 长度为3, hex是main函数传递的
    len = (int)strlen(hex);
    
    for (i=0, temp=0; i<len; i++, temp=0)
    {
        // 第一次：i=0, *(hex + i) = *(hex + 0) = '1', 即temp = 1
        // 第二次：i=1, *(hex + i) = *(hex + 1) = 'd', 即temp = 13
        // 第三次：i=2, *(hex + i) = *(hex + 2) = 'd', 即temp = 14
        temp = c2i( *(hex + i) );
        // 总共3位，一个16进制位用 4 bit保存
        // 第一次：'1'为最高位，所以temp左移 (len - i -1) * 4 = 2 * 4 = 8 位
        // 第二次：'d'为次高位，所以temp左移 (len - i -1) * 4 = 1 * 4 = 4 位
        // 第三次：'e'为最低位，所以temp左移 (len - i -1) * 4 = 0 * 4 = 0 位
        bits = (len - i - 1) * 4;
        temp = temp << bits;
        
        // 此处也可以用 num += temp;进行累加
        num = num | temp;
    }
    // 返回结果
    return num;
}
/** 十六进制数的字符串转为整型 */
- (int)hexStringToInteger {
    return hex2dec([self UTF8String]);
}


@end
