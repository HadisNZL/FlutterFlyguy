//
//  JVSLogManager.h
//  SAASTest
//
//  Created by 中维世纪 on 2022/4/1.
//  Copyright © 2022 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

#define JVSWriteNetLogToLocalFileWith(logStr)      [JVSLogManager outLogToLocalDiskWith:(logStr)];

@interface JVSLogManager : NSObject

+(void)setLogEnabled:(BOOL)logEnabled;

+ (instancetype)sharedManager;
- (void)redirectLogToDocumentsWithMainDirect:(NSString *)mainDirect subDirect:(NSString *)subDirect thirdDirect:(NSString *)thirdDirect fileName:(NSString *)fileName content:(NSString *)content;

+(void)redirectLogToDocumentsWithMainDirect:(NSString *)mainDirect subDirect:(NSString *)subDirect fileName:(NSString *)fileName content:(NSString *)content;


/// 把日志写入本地 Account目录下 - 开启 logEnabled = YES 或者 Debug 模式
+(void)outLogToLocalDiskWith:(NSString *)logStr;

@end

NS_ASSUME_NONNULL_END
