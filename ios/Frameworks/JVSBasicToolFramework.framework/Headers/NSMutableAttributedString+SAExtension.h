//
//  NSMutableAttributedString+SAExtension.h
//  SAASTest
//
//  Created by 李华 on 2024/3/7.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NSString (SAExtension)

/// 截取字符串长度 length；
-(NSString *)jvs_substrWithLength:(NSInteger)length;

/// 从html 符文本转换来的
-(NSMutableAttributedString *)jvs_attributedStringFromHtmlString;

-(NSMutableAttributedString *)jvs_attributedString;
-(NSMutableAttributedString *)jvs_attributedString:(UIColor *)color font:(UIFont *)font;
-(NSMutableAttributedString *)jvs_attributedStringColor:(UIColor *)color;
-(NSMutableAttributedString *)jvs_attributedStringFont:(UIFont *)font;
-(NSRange)jvs_rangeOfAll;


-(CGSize)jvs_sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width;
-(CGSize)jvs_sizeWithFont:(UIFont *)font maxWidth:(CGFloat)width lineSpacing:(CGFloat)lineSpacing;
/// char wrap
-(CGSize)jvs_charWrapSizeWithFont:(UIFont *)font maxWidth:(CGFloat)width;
/**
 根据最大适应的高度和字体，来计算文字的宽度
 /// word wrap
 @param font 文本的字体
 @param height 最大适应的宽度
 @return 计算的文字的大小
 */
- (CGSize)jvs_sizeWithFont:(UIFont *)font maxHeight:(CGFloat)height;
@end

@interface NSArray (SAAttributedExtension)

/// 富文本 数组元素个数需要与颜色、字体一一对应
/// @param colors 颜色
/// @param fonts 字体
- (NSMutableAttributedString *)jvs_attributedStringWithColors:(NSArray *)colors fonts:(NSArray *)fonts;


@end

@interface NSMutableAttributedString (SAExtension)

-(NSMutableAttributedString *)jvs_attributedArrayString:(NSArray *)texts colors:(NSArray *)colors fonts:(NSArray *)fonts;

-(NSMutableAttributedString *)jvs_setColor:(UIColor *)color font:(UIFont *)font forRange:(NSRange)range;
-(NSMutableAttributedString *)jvs_setColor:(UIColor *)color forRange:(NSRange)range;
-(NSMutableAttributedString *)jvs_setFont:(UIFont *)font forRange:(NSRange)range;

@end

