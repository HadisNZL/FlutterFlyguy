//
//  UIView+JVSToast.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/12.
//

#import <UIKit/UIKit.h>

@interface UIView (JVSToast)

/**
 自己工程使用
 @param message 提示语
 */
- (void)jvs_makeToast:(NSString *)message;

- (void)jvs_makeToast:(NSString *)message duration:(NSTimeInterval)duration;
- (void)jvs_makeToast:(NSString *)message duration:(NSTimeInterval)duration title:(NSString *)title;
- (void)jvs_makeToast:(NSString *)message duration:(NSTimeInterval)duration image:(UIImage *)image;

- (void)jvs_makeToast:(NSString *)message position:(id)position;

- (void)jvs_makeToast:(NSString *)message duration:(NSTimeInterval)duration position:(id)position;

- (void)jvs_makeToast:(NSString *)message completion:(void(^)(BOOL didTap))completion;

- (void)jvs_makeToast:(NSString *)message duration:(NSTimeInterval)duration completion:(void(^)(BOOL didTap))completion;

@end
