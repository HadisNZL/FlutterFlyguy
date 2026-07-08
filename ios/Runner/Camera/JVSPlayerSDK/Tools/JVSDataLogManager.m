//
//  JVSLogManager.m
//  appdemo
//
//  Created by 李华 on 2025/2/23.
//

#import "JVSDataLogManager.h"
#import "JVSDefinesHeader.h"
#import <JVSBasicToolFramework/JVSSingleton.h>
#import <JVSBasicToolFramework/NSDate+JVSExtension.h>


@interface JVSDataLogManager () {
    dispatch_queue_t _writeFileQueue;
    NSString *_fileName;
}

@end

@implementation JVSDataLogManager

JVS_SINGLETON_IMP(JVSDataLogManager)

- (instancetype)init
{
    self = [super init];
    if (self) {
        _writeFileQueue = dispatch_queue_create("JVSDataLogManager", 0);
        _fileName = [[[NSDate date] jvs_stringWithFormat:@"yyyy-MM-dd_HH.mm.ss"] stringByAppendingFormat:@".log"];
    }
    return self;
}

+(void)writeDataLocalWith:(NSData *)logData fileName:(NSString *)fileName subDirectory:(NSString *)subDir {
    if (!logData || !fileName) {
        NSLog(@"------- logData can't be NULL,  or fileName can't be NULL ");
        return;
    }
    dispatch_barrier_async(JVSDataLogManager.sharedInstance->_writeFileQueue, ^{
        [JVSDataLogManager.sharedInstance _writeDataLocalWith:logData fileName:fileName subDirectory:subDir];
    });
}


+(void)writeDataLocalWith:(NSData *)logData fileName:(NSString *)fileName {
    [self writeDataLocalWith:logData fileName:fileName subDirectory:@"_DataLog_"];
}

-(void)_writeDataLocalWith:(NSData *)logData fileName:(NSString *)fileName subDirectory:(NSString *)subDir {
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    
    NSString *documentsDir = [paths firstObject];
    subDir = subDir.length?subDir:@"_DataLog_";
    documentsDir = [documentsDir stringByAppendingPathComponent:subDir];

    if (![[NSFileManager defaultManager] fileExistsAtPath:documentsDir]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:documentsDir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *filePath = [documentsDir stringByAppendingPathComponent:fileName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
    }
    
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForWritingAtPath:filePath];
    if (fileHandle == nil) {
        return;
    }
    [fileHandle seekToEndOfFile];
    [fileHandle writeData:logData];
    [fileHandle synchronizeFile];
    [fileHandle closeFile];
}



/// 使用默认 子目录 - _DataLog_
+(void)writeDataLocalWith:(NSString *)logDataStr {
    if (JVSLogWriteLocalOpen) {
        NSString *fileName = JVSDataLogManager.sharedInstance->_fileName;
        [self writeDataLocalWith:[logDataStr dataUsingEncoding:4] fileName:fileName subDirectory:@"_ConsoleLog_"];
    }
}

@end
