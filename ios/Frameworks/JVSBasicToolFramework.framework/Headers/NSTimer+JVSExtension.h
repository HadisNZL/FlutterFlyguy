//
//  NSTimer+JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/11/1.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSTimer (JVSExtension)


/// 使用 NSRunLoopCommonModes 模式，
/// 在Main RunLoop中运行，滚动Scroll也会监听到
+ (instancetype)jvs_scheduledTimerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;


+ (NSTimer *)jvs_timerWithTimeInterval:(NSTimeInterval)seconds repeats:(BOOL)repeats block:(void (^)(NSTimer *timer))block;

@end

NS_ASSUME_NONNULL_END
