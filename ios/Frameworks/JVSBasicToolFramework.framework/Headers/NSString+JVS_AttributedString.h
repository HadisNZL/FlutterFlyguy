//
//  NSString+jvs_attributedString.h
//  AttributedDemo
//
//  Created by LH on 7/25/20.
//  Copyright © 2020 ysy. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@class AttributedMaker;

@interface NSString (JVS_AttributedString)

- (NSMutableAttributedString *)jvs_attributedMake:(void(^)(AttributedMaker *make))attributed;

@end


