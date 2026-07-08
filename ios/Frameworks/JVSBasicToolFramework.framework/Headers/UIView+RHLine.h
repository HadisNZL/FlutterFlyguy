//
//  UIView+RHLine.h
//  KongFu
//
//  Created by zero on 2018/2/9.
//  Copyright © 2018年 zero. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (RHLine)

- (UIView *)addTopLine;
- (UIView *)addTopLineWithcolor:(UIColor *)color;
- (UIView *)addTopLine:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace;
- (UIView *)addTopLine:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace color:(UIColor *)color;

- (UIView *)addLeftLine;
- (UIView *)addLeftLineWithcolor:(UIColor *)color;
- (UIView *)addLeftLine:(CGFloat)topSpace bottomSpace:(CGFloat)bottomSpace;
- (UIView *)addLeftLine:(CGFloat)topSpace bottomSpace:(CGFloat)bottomSpace color:(UIColor *)color;

- (UIView *)addBottomLine;
- (UIView *)addBottomLineWithcolor:(UIColor *)color;
- (UIView *)addBottomLine:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace;
- (UIView *)addBottomLine:(CGFloat)leftSpace rightSpace:(CGFloat)rightSpace color:(UIColor *)color;

- (UIView *)addRightLine;
- (UIView *)addRightLineWithcolor:(UIColor *)color;
- (UIView *)addRightLine:(CGFloat)topSpace bottomSpace:(CGFloat)bottomSpace;
- (UIView *)addRightLine:(CGFloat)topSpace bottomSpace:(CGFloat)bottomSpace color:(UIColor *)color;

@end
