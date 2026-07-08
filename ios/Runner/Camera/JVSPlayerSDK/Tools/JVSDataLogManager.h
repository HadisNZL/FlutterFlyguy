//
//  JVSLogManager.h
//  appdemo
//
//  Created by 李华 on 2025/2/23.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define JVSWriteLocalLog(logStr)      [JVSDataLogManager writeDataLocalWith:(logStr)];

// 写日志到本地，追加到 已存在的相同文件的 最后面
@interface JVSDataLogManager : NSObject

/// 使用默认 子目录 - _DataLog_
+(void)writeDataLocalWith:(NSData *)logData fileName:(NSString *)fileName;

+(void)writeDataLocalWith:(NSData *)logData fileName:(NSString *)fileName subDirectory:(NSString *)subDir;

/// 使用默认 子目录 - _DataLog_
+(void)writeDataLocalWith:(NSString *)logDataStr;

@end

NS_ASSUME_NONNULL_END
