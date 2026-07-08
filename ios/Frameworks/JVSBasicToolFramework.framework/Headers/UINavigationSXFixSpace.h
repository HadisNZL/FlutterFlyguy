//
//  UINavigationSXFixSpace.h
//  UINavigation-SXFixSpace
//
//  Created by charles on 2019/7/26.
//  Copyright © 2018年 None. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UINavigationConfig : NSObject

/// item距离两端的间距,默认为15
@property (nonatomic, assign) CGFloat sx_defaultFixSpace;
/// 是否禁止使用修正,默认为NO
@property (nonatomic, assign) BOOL sx_disableFixSpace;

+ (instancetype)shared;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;

- (CGFloat)sx_systemSpace;

@end

@interface UINavigationItem (SXFixSpace)

@end

@interface NSObject (SXFixSpace)

@end

