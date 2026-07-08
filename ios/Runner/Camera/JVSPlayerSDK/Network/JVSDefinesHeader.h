//
//  JVSDefinesHeader.h
//  appdemo
//
//  Created by 李华 on 2025/1/22.
//

#import <Foundation/Foundation.h>
#import "JVSDataLogManager.h"


/// 1 开启日志打印 & 同时写本地日志， 0： 关闭打印, 写本地日志
#define JVSLogOpen                    0

/// 1 开启本地写日志， 0： 不写入本地
#define JVSLogWriteLocalOpen          0

/// 1 打印读数据的日志&写本地日志， 0：不打印，也不写本地日志
#define JVSLogDataReadOpen            0


#if JVSLogOpen==1
#define JVSLog(fmt, ...) {\
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
    [dateFormatter setDateFormat:@"yyy:MM:dd HH:mm:ss:SSSSS"]; \
    NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
    NSString *_logStr__ = [NSString stringWithFormat: fmt, ##__VA_ARGS__];\
    _logStr__ = [NSString stringWithFormat:@"\n%@ %s\n%@\n", str, __FUNCTION__, _logStr__];JVSWriteLocalLog(_logStr__);\
    fprintf(stderr, "\n\n***-------------------------*** 🌺bigin🌺 ***-------------------------****  \n%s %s:%d\t%s\n%s\n***-------------------------***  🌺end🌺  ***-------------------------***  \n", [str UTF8String], [[[NSString stringWithUTF8String: __FILE__] lastPathComponent] UTF8String], __LINE__, __FUNCTION__, [[NSString stringWithFormat: fmt, ##__VA_ARGS__] UTF8String]);\
}
#else
#define JVSLog(fmt, ...) {\
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];\
    [dateFormatter setDateStyle:NSDateFormatterMediumStyle];\
    [dateFormatter setTimeStyle:NSDateFormatterShortStyle];\
    [dateFormatter setDateFormat:@"yyy:MM:dd HH:mm:ss:SSSSS"]; \
    NSString *str = [dateFormatter stringFromDate:[NSDate date]];\
    NSString *_logStr__ = [NSString stringWithFormat: fmt, ##__VA_ARGS__];\
    _logStr__ = [NSString stringWithFormat:@"\n%@ %s\n%@\n", str, __FUNCTION__, _logStr__];JVSWriteLocalLog(_logStr__);\
}
#endif



typedef NS_ENUM(NSInteger, JVSStreamType) {
    JVSStreamTypeHD = 0,  // 高清
    JVSStreamTypeSD = 1,  // 标清
};

typedef NS_ENUM(NSInteger, JVSPlayerCMDType) {
    JVSPlayerCMDType_PLAY,       // 播放
    JVSPlayerCMDType_PAUSE,      // 暂停
    JVSPlayerCMDType_RESUME,     // 继续
    JVSPlayerCMDType_SEEK = 3,   // 定位播放
    JVSPlayerCMDType_ONLY_SEEK,  // 只定位
    JVSPlayerCMDType_FAST,       // 快进
    JVSPlayerCMDType_SLOW = 6,   // 慢放
    JVSPlayerCMDType_SPEED,      // 指定速度播放
    JVSPlayerCMDType_MUTE,       // 静音
    JVSPlayerCMDType_UNMUTE = 9, // 取消静音
    JVSPlayerCMDType_LONG_SEEK,
    JVSPlayerCMDType_STOP  = 11,  // 停止播放视频
    JVSPlayerCMDType_MAX
};


// PTZ 方向
typedef NS_ENUM(NSInteger, JVSPTZDirection) {
    JVSPTZDirectionUp  = 0,    // 向上
    JVSPTZDirectionLeft,  // 向左
    JVSPTZDirectionDown,  // 向下
    JVSPTZDirectionRight, // 向右
};

// 视频状态
typedef NS_ENUM(NSInteger, JVSVideoStatus) {
    JVSVideoStatusNone          = 0,
    JVSVideoStatusConnecting    = 1,  // 视频连接中
    JVSVideoStatusConnectFailed = 2,  // 视频连接失败
    JVSVideoStatusConnected     = 3,  // 视频连接
    JVSVideoStatusVideoPlaying  = 4,  // 视频播放
    JVSVideoStatusDisconnected  = 5,  // 视频断开连接了
};

FOUNDATION_EXPORT NSString *GetJVSVideoStatusString(JVSVideoStatus status);
