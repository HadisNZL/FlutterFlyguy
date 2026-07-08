//
//  JVCCreatImage.h
//  CloudSEENew
//
//  Created by David on 16/7/6.
//  Copyright © 2016年 baoym. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum  {
    topToBottom = 0,//从上到小
    leftToRight = 1,//从左到右
    upleftTolowRight = 2,//左上到右下
    uprightTolowLeft = 3,//右上到左下
} GradientType;

@interface JVCCreatImage : NSObject

+ (UIImage*)creatImageFromColors:(NSArray*)colors gradientType:(GradientType)gradientType frame:(CGRect)frame;
+ (UIColor*)creatColorFromColors:(NSArray*)colors gradientType:(GradientType)gradientType frame:(CGRect)frame;
+ (CAGradientLayer*)creatLayerFromColors:(NSArray*)colors gradientType:(GradientType)gradientType frame:(CGRect)frame;

@end
