//
//  NSDate+JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/12.
//

#import <Foundation/Foundation.h>
#import <JVSBasicToolFramework/NSDate+YYAdd.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSString (JVSDate)

-(NSDate *)jvs_dateWithFormat:(NSString *)format;


/// 显示 hh:MM:ss 时分秒
+(NSString *)jvs_timeClockFormatWith:(NSTimeInterval)time;

@end

@interface NSDate (JVSExtension)


/// 当前时间戳 到秒
+ (NSString *)jvs_currentTimeStamp;
+ (NSString *)jvs_currentDateString;

/// 是不是今天
-(BOOL)jvs_isToday;

/// 当前日期 增加/减少  天数 
-(NSDate *)jvs_dateByAddDay:(int)day;


/// 中国的 时间格式化
- (NSString *)jvs_stringWithFormat:(NSString *)format;


//比较2个日期 返回差值秒数
- (NSTimeInterval)compareWithOtherDate:(NSDate *)date;

@end

NS_ASSUME_NONNULL_END
