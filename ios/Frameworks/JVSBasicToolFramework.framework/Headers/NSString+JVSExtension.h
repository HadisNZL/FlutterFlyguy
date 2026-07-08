//
//  NSString+Judge.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/12.
//

//对字符串的相关判断
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

/// 文件大小 变成 KB，MB，GB等 单位字符串
FOUNDATION_EXPORT NSString* jvs_fileSizeToFormattedString(double value);


@interface NSString (Judge)

/// :是否是空字符串 (""返回否)
- (BOOL)isEmptyString;
/// 密码格式是否正确
- (BOOL)isValidPasswordFormat;
/// 手机号格式是否正确
- (BOOL)isValidPhoneNumber;

/// 都是数字
- (BOOL)isAllNumber;

/// 是不是包含中文
-(BOOL)isChinese;

/// 是否是 有效的输入 - 输入的时候判断
-(BOOL)isValidInput;

/// 中文 字母数字 符号 空格 - 有效的 昵称
- (BOOL)isValidNickName;
/**
 *   验证邮箱
 */
-(BOOL) isValidEmailAdress;

/// 电话号码 加 *
- (NSString *)jvs_phoneMixedFormatter;
/// 邮箱 加 *
- (NSString *)jvs_mailMixedFormatter;
/// 账号 加 *
- (NSString *)jvs_accountMixedFormatter;

+ (BOOL)jvs_checkEmptyWith:(NSString *)string;
FOUNDATION_EXPORT BOOL jvsStringIsEmpty(NSString *string);


// 检测强密码是否有效
+ (BOOL)checkStrongPassword:(NSString *)password briefest:(NSInteger)briefest
                    longest:(NSInteger)longest max:(NSInteger)max;
+ (BOOL)checkStrongPassword:(NSString *)password briefest:(NSInteger)briefest
                    longest:(NSInteger)longest;



/// string 转 URL
-(NSURL *)jvs_URL;

/// 返回MD5加密后的字符串
-(NSString *) jvs_md5;
-(NSString *) jvs_encode2Base64String;
-(NSString *) jvs_decodeFromBase64String;

-(NSData *) jvs_encode2Base64Data;
-(NSData *) jvs_decodeFromBase64Data;


-(NSString *) jvs_encode2URLString;
-(NSString *) jvs_decodeFromURLString;

/// 转换为kCFStringEncodingGB_18030_2000编码 的字符长度
-(NSUInteger) jvs_charactersLength;

/// 是否有表情符号
-(BOOL)jvs_containsEmoji;
//中文 字母数字 符号 空格
- (BOOL)jvs_matchAction;
//中文 大小写字母 数字
- (BOOL)jvs_matchNumCharacterChinese;
//中文 大小写字母
- (BOOL)jvs_matchChineseAndCharacter;
//
- (BOOL)jvs_matchCertificationCharacter;

/// 是否是包含特殊字符 yes不包含，no包含
/// - []{}（#%-*+=_）\\|~(＜＞$%^&*)_+@ 
-(BOOL)jvs_containsSpecialCharacter;

//是否 全是中文
-(BOOL)jvs_isChinese;


/// 计算字节长度
-(NSUInteger)jvs_lengthOfBytesUsingEncoding:(NSStringEncoding)encoding;
-(NSUInteger)jvs_lengthOfBytesUsingGB2000;
-(NSUInteger)jvs_lengthOfBytesUsingUTF8;


// 去掉字符中的 第一个和最后一个空格（如果有的话）
-(NSString *)jvs_trim;
// 去掉字符中的 所有的空格
-(NSString *)jvs_trimAll;


#pragma mark --------------------------  操作 URL的参数
-(NSString *)jvs_URLRemoveParameters;

/// 返回已经 URL解码过的参数
-(NSDictionary<NSString *, NSString *> *) jvs_URLParameters;
/**
 像URL参数一样拼接到该URL中
 例如   https://m.manjd.com   {@"w":@"23"}  =>  https://m.manjd.com?w=23
 @param params 参数，不支持包含NSArray类型
 @return 拼接好的URL
 */
-(NSString *)jvs_URLAppendingParameters:(NSDictionary<NSString *, NSString *> *)params;


-(NSString *)jvs_deleteLastRemovableZero;
/// 去掉小数点一位后面的数字
-(NSString *)jvs_deleteLastRemovableNumber;
+(NSString *)jvs_deleteLastRemovableZeroWith:(double)decimal;

///  去掉小数点一位后面的数字
/// @param decimal double类型的数字
+(NSString *)jvs_deleteLastRemovableNumberWith:(double)decimal;

@end

NS_ASSUME_NONNULL_END
