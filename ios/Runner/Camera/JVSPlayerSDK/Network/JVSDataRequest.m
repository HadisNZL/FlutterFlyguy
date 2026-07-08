//
//  JVSDataRequest.m
//  appdemo
//
//  Created by 李华 on 2025/1/22.
//

#import "JVSDataRequest.h"
#import "JVSP2PSDKManager.h"
#import <JVSPlayerSDK/JVSPlayerSDK.h>

@implementation JVSDataRequest


+(void)updateVideoStreamType:(JVSStreamType)type
                     success:(RequestSuccessDataBlock _Nullable)success
                        fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{@"type": @(type)};
    [JVSBaseRequest sendDataWithMethod:@"/stream/stream_type" withParams:params success:success fail:fail];
}

/// 发送下载视频指令, fileName 是下载视频文件路径
+(void)downloadVideoWith:(NSString *)fileName toLocalPath:(NSString *)localPath
                 success:(RequestSuccessDataBlock _Nullable)successBlock
                    fail:(RequsetFailBlock _Nullable)failBlock
{
    [self downloadVideoWith:fileName toLocalPath:localPath progress:nil success:successBlock fail:failBlock];
}

+(void)downloadVideoWith:(NSString *)fileName toLocalPath:(NSString *)localPath
                progress:(RequestProgressBlock _Nullable)progressBlock
                 success:(RequestSuccessDataBlock _Nullable)successBlock fail:(RequsetFailBlock _Nullable)failBlock {
    NSString *fullFileLocalPath = [self checkDownloadPathWith:localPath];
    if (![localPath containsString:@".mp4"]) {
        NSString *fileName = [[NSDate.date jvs_stringWithFormat:@"yyyyMMddHHmmss"] stringByAppendingString:@".mp4"];
        fullFileLocalPath = [fullFileLocalPath stringByAppendingPathComponent:fileName];
    }
    JVSLog(@"------- Download_Video_To_Path ------- \n%@", fullFileLocalPath);
    NSDictionary *params = @{@"cmd": @(1), @"filename": fileName?:@"" };
    [JVSBaseRequest sendDataWithMethod:@"/storage/download" withParams:params success:^(NSDictionary *data) {
        // 开启下载线程，去读取线程
        NSInteger fileSize = [data[@"fileSize"] integerValue];  // 文件总大小 总字节数
        [JVSP2PSDKManager.shared downloadVideoWith:fileName toLocalPath:fullFileLocalPath
                                          fileSize:fileSize progressBlock:^(NSInteger revicedByte) {
            
            if (progressBlock) progressBlock(revicedByte, fileSize);
            
        } completionBlock:^(NSString *videoFullPath, NSError *error) {
            if (videoFullPath) {
                if (successBlock) successBlock(videoFullPath);
            } else {
                if (failBlock) failBlock(error);
            }
        }];
    } fail:failBlock];
}

/// 给视频发送指令
+(void)sendVideoControlWith:(JVSPlayerCMDType)type
                    success:(RequestSuccessDataBlock _Nullable)success
                       fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{@"play_cmd": @(type), @"value": @(11) };
    [JVSBaseRequest sendDataWithMethod:@"/stream/play_control" withParams:params success:success fail:fail];
}

/// 给视频发送指令
+(void)sendVideoControlWith:(JVSPlayerCMDType)type
                      value:(long)value
                    success:(RequestSuccessDataBlock _Nullable)success
                       fail:(RequsetFailBlock _Nullable)fail {
    id val = @(value);
    if (type==JVSPlayerCMDType_SEEK) {
        val = Int2Str(value);
        JVSLog(@"----- Seek_Time = %@", val);
    }
    NSDictionary *params = @{@"play_cmd": @(type), @"value": val };
    [JVSBaseRequest sendDataWithMethod:@"/stream/play_control" withParams:params success:success fail:fail];
}

///  按照文件回放
+(void)playBackVideoWithTs:(NSInteger)ts
                      fileName:(NSString *)fileName
                    success:(RequestSuccessDataBlock _Nullable)success
                       fail:(RequsetFailBlock _Nullable)fail {
    if (fileName.length == 0) {
        return;
    }
    NSDictionary *params = @{@"ts": @(ts), @"filename": fileName };
    [JVSBaseRequest sendDataWithMethod:@"/stream/play_record" withParams:params success:success fail:fail];
}


/// 获取该月 数据的时间掩码
+(void)getPlayBackDateMaskWith:(int)year month:(int)month
                       success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSString *startTime = [NSString stringWithFormat:@"%d%02d01000000", year, month];
    int lastDay = (int)[NSDate dateOfLastDayInMonth: [NSDate dateWithString:startTime format:@"yyyyMMdd000000"]].day;
    NSString *endTime = [NSString stringWithFormat:@"%d%02d%02d235959", year, month, lastDay];
    NSDictionary *params = @{
        @"start_time": startTime, @"end_time": endTime,
        @"channelid": @(0),
    };
    [JVSBaseRequest sendDataWithMethod:@"get_record_date_list" withParams:params success:success fail:fail];
}
//
//// 获取指定月份的 回放视频列表
//+(void)getPlayBackRecordsWith:(int)year month:(int)month
//                      success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
//    [self getPlayBackRecordsWith:year month:month pageIndex:0 pageSize:30 success:success fail:fail];
//}
//
//+(void)getPlayBackRecordsWith:(int)year month:(int)month
//                    pageIndex:(int)pageIndex pageSize:(int)pageSize
//                      success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
//    NSString *startTime = [NSString stringWithFormat:@"%d%02d01000000", year, month];
//    int lastDay = (int)[NSDate dateOfLastDayInMonth: [NSDate dateWithString:startTime format:@"yyyyMMdd"]].day;
//    NSString *endTime = [NSString stringWithFormat:@"%d%02d%02d235959", year, month, lastDay];
//    NSDictionary *params = @{
//        @"starttime": startTime, @"endtime": endTime,
//        @"channelid": @(0),
//        @"page": @(MAX(pageIndex, 0)),
//        @"cntFilePerPage": @(MAX(1, pageSize))
//    };
//    [JVSBaseRequest sendDataWithMethod:@"get_record_list" withParams:params success:success fail:fail];
//}


/// 获取当天的回放列表
+(void)getPlayBackRecordsWithDate:(NSDate *)date pageIndex:(int)pageIndex pageSize:(int)pageSize
                      success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    date = date?:NSDate.date;
    NSString *yearMonthDay = [NSString stringWithFormat:@"%ld%02ld%02ld", date.year, date.month, date.day];
    NSString *startTime = [NSString stringWithFormat:@"%@000000", yearMonthDay];
    NSString *endTime = [NSString stringWithFormat:@"%@235959", yearMonthDay];
    [self getPBRecordsWithStartTime:startTime endTime:endTime pageIndex:pageIndex pageSize:pageSize success:success fail:fail];
}

/// 获取 开始时间和结束时间的 回放列表
/// startTime: 20250101000000
/// endTime:   20250101000200
+(void)getPBRecordsWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
                        pageIndex:(int)pageIndex pageSize:(int)pageSize
                         success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{
        @"starttime": startTime, @"endtime": endTime,
        @"channelid": @(0),
        @"page": @(MAX(pageIndex, 0)),
        @"cntFilePerPage": @(MAX(1, pageSize))
    };
    [JVSBaseRequest sendDataWithMethod:@"get_record_list" withParams:params success:success fail:fail];
}


/// 指定时间播放 回放
+(void)playPBVideoAtTime:(NSInteger)timeStamp
                 success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{
        @"stime": Int2Str(timeStamp),
    };
    [JVSBaseRequest sendDataWithMethod:@"/stream/play_record_ts" withParams:params success:success fail:fail];
}

/// open: YES 开始， NO关闭对讲
+(void)sendVideoTalkStatus:(BOOL)open
                   success:(RequestSuccessDataBlock _Nullable)success
                      fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{@"type": @(open?1:0) };
    [JVSBaseRequest sendDataWithMethod:@"/audio/talk" withParams:params success:success fail:fail];
}

#pragma mark --------------------------  获取报警列表
// 获取报警声音列表
+(void)getAlarmFileNameListWith:(int)channelid
                        success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail
{
    NSDictionary *params = @{ @"channelid": @(channelid) };
    [JVSBaseRequest sendDataWithMethod:@"alarm_soundlist_get" withParams:params success:success fail:fail];
    
}

// 设置 报警声音
+(void)getAlarmInfoWith:(int)linkId
                success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail
{
    NSDictionary *params = @{ @"link_id": @(linkId), @"bdefault": @(NO) };
    [JVSBaseRequest sendDataWithMethod:@"alarm_link_get" withParams:params success:success fail:fail];
    
}

/// 播放报警声音
+(void)playAlarmSoundWith:(NSString *)soundName channelid:(int)channelid
                    times:(int)times
                  success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    times = MAX(times, -1);
    NSDictionary *params = @{
        @"channelid": @(channelid), @"status": @(YES),
        @"times": @(times), @"file_name": soundName?:@"",
    };
    [JVSBaseRequest sendDataWithMethod:@"alarm_sound_play" withParams:params success:success fail:fail];
}

/// 停止播放报警声音
+(void)stopPlayAlarmSoundWith:(NSString *)soundName channelid:(int)channelid
                      success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{
        @"channelid": @(channelid), @"status": @(NO),
        @"times": @(0), @"file_name": soundName?:@"",
    };
    [JVSBaseRequest sendDataWithMethod:@"alarm_sound_play" withParams:params success:success fail:fail];
}

// 更新报警信息
+(void)updateAlarmInfoWith:(NSDictionary *)param
                   success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail
{
    NSDictionary *params = param?: @{};
    [JVSBaseRequest sendDataWithMethod:@"alarm_link_set" withParams:params success:success fail:fail];
}


// 获取 补光灯信息
+(void)getWhiteLightInfoWith:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{};
    [JVSBaseRequest sendDataWithMethod:@"dev_get_whitelight_status" withParams:params success:success fail:fail];
}

// 开启或者 关闭补光灯信息  status: YES 开启， NO：关闭
+(void)updateWhiteLightStatus:(BOOL)status
                      success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{ @"status": @(status) };
    [JVSBaseRequest sendDataWithMethod:@"dev_set_whitelight_status" withParams:params success:success fail:fail];
    
}

// 获取 补光灯模式
+(void)getWhiteLightModeWith:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{ };
    [JVSBaseRequest sendDataWithMethod:@"image_get_dncut_param" withParams:params success:success fail:fail];
}

// 更新 补光灯模式
+(void)updateWhiteLightMode:(NSDictionary *)params
                    success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    [JVSBaseRequest sendDataWithMethod:@"image_set_dncut_param" withParams:params success:success fail:fail];
}

#pragma mark --------------------------  PTZ 相关接口
/** 返回值
 @{"max_preset": 255,  //最大预置点个数
 "max_patrol": 2,    //最大巡航条数
 "max_trail": 4,        //最大轨迹条数
 "max_task": 2       //最大定时任务个数
 }
 */
+(void)getPTZAbilityWith:(int)channelId
                 success:(RequestSuccessDataBlock _Nullable)success
                    fail:(RequsetFailBlock _Nullable)fail
{
    NSDictionary *params = @{ @"channelid": @(channelId) };
    [JVSBaseRequest sendDataWithMethod:@"ptz_ability_get" withParams:params success:success fail:fail];
}

/// 移动 PTZ
/// speed 移动速度：0~254
+(void)movePTZWithDirection:(JVSPTZDirection)direction
                  channelId:(int)channelId speed:(int)speed
                    success:(RequestSuccessDataBlock _Nullable)success
                       fail:(RequsetFailBlock _Nullable)fail
{
    NSMutableDictionary *params = @{ @"channelid": @(channelId) }.mutableCopy;
    int panLeft = 0;  //左右转动，-254～-4，4～255。>0左，<0右
    int tiltUp = 0;   //垂直转动，-254～-4，4～255。>0上，<0下
    int zoomIn = 0;   //zoom，-254～-4，4～255。>0放大，<0缩小
    if (direction==JVSPTZDirectionUp) {
        tiltUp = abs(speed);
    } else if (direction==JVSPTZDirectionDown) {
        tiltUp = -1*abs(speed);
    } else if (direction==JVSPTZDirectionLeft) {
        panLeft = abs(speed);
    } else if (direction==JVSPTZDirectionRight) {
        panLeft = -1*abs(speed);
    }
    [params setObject:@(panLeft) forKey:@"panLeft"];
    [params setObject:@(tiltUp) forKey:@"tiltUp"];
    [params setObject:@(zoomIn) forKey:@"zoomIn"];
    [JVSBaseRequest sendDataWithMethod:@"ptz_move_start" withParams:params success:success fail:fail];
}

/// 停止移动 PTZ
+(void)stopMovePTZWithChannelId:(int)channelId
                        success:(RequestSuccessDataBlock _Nullable)success
                           fail:(RequsetFailBlock _Nullable)fail
{
    NSDictionary *params = @{ @"channelId": @(channelId) };
    [JVSBaseRequest sendDataWithMethod:@"ptz_move_stop" withParams:params success:success fail:fail];
}


#pragma mark --------------------------  预置点
/// 获取 预置点列表
+(void)getPresetPointListWith:(int)channelId
                 success:(RequestSuccessDataBlock _Nullable)success
                    fail:(RequsetFailBlock _Nullable)fail
{
    NSDictionary *params = @{
        @"channelid": @(channelId),
    };
    [JVSBaseRequest sendDataWithMethod:@"ptz_presets_get" withParams:params success:success fail:fail];
}

/// 添加预置点
+(void)addPresetPointWith:(int)channelId
            presetNo:(int)presetNo
          presetName:(NSString *)presetName
             success:(RequestSuccessDataBlock _Nullable)success
                fail:(RequsetFailBlock _Nullable)fail
{
    NSDictionary *params = @{
        @"channelid": @(channelId),
        @"presetno": @(presetNo),
        @"name": presetName,
    };
    [JVSBaseRequest sendDataWithMethod:@"ptz_locate_set" withParams:params success:success fail:fail];
}

/// 使用预置点，定位预置
+(void)locatePresetPointWith:(int)channelId presetNo:(int)presetNo speed:(int)speed
                     success:(RequestSuccessDataBlock _Nullable)success
                        fail:(RequsetFailBlock _Nullable)fail
{
    speed = MIN(MAX(0, speed), 254);
    NSDictionary *params = @{
        @"channelid": @(channelId),
        @"presetno": @(presetNo),
        @"movespeed": @(speed)
    };
    [JVSBaseRequest sendDataWithMethod:@"ptz_locate_run" withParams:params success:success fail:fail];
}

/// 删除预置点
+(void)deletePresetPointWith:(int)channelId
               presetNo:(int)presetNo
                success:(RequestSuccessDataBlock _Nullable)success
                   fail:(RequsetFailBlock _Nullable)fail
{
    NSDictionary *params = @{
        @"channelid": @(channelId),
        @"presetno": @(presetNo),
    };
    [JVSBaseRequest sendDataWithMethod:@"ptz_preset_delete" withParams:params success:success fail:fail];
}

/// 云台复位
+(void)resetPTZPresetPoint:(int)channelId
                   success:(RequestSuccessDataBlock _Nullable)success
                      fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *params = @{
        @"channelid": @(channelId),
    };
    [JVSBaseRequest sendDataWithMethod:@"ptz_reset" withParams:params success:success fail:fail];
}

// reboot
+(void)rebootWith:(NSDictionary *)params success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *param = @{
        @"channelid": @(0),
        @"delaymSec": @(3),
    };
    [JVSBaseRequest sendDataWithMethod:@"dev_reboot" withParams:param success:success fail:fail];
}

// getStreams
+(void)getStreamsWith:(NSDictionary *)params success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail {
    NSDictionary *param = @{
        @"channelid": @(0)
    };
    [JVSBaseRequest sendDataWithMethod:@"stream_get_params" withParams:param success:success fail:fail];
}

// 检测和生成默认 视频地址
+(NSString *)checkDownloadPathWith:(NSString *)path {
    if (path.length == 0) {
        NSString *documentsDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
        path = [documentsDir stringByAppendingPathComponent:@"VideoDownload"];
        if (![[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [[NSFileManager defaultManager] createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:nil];
        }
    }
    return path;
}


// 取消所有请求
+(void)cancelAllRequest {
    [JVSBaseRequest cancelAllRequest];
}

@end
