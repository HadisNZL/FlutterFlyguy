//
//  JVSDataRequest.h
//  appdemo
//
//  Created by 李华 on 2025/1/22.
//

#import <Foundation/Foundation.h>
#import "JVSBaseRequest.h"
#import "JVSDefinesHeader.h"


NS_ASSUME_NONNULL_BEGIN

@interface JVSDataRequest : NSObject

// 更新视频的 高清，标清
+(void)updateVideoStreamType:(JVSStreamType)type
                     success:(RequestSuccessDataBlock _Nullable)success
                        fail:(RequsetFailBlock _Nullable)fail;



/// 给视频发送指令
//+(void)sendVideoControlWith:(JVSPlayerCMDType)type success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;


/// 给视频发送指令
+(void)sendVideoControlWith:(JVSPlayerCMDType)type value:(long)value
                    success:(RequestSuccessDataBlock _Nullable)success
                       fail:(RequsetFailBlock _Nullable)fail;

#pragma mark --------------------------  下载视频
/// 下载视频, fileName 是下载视频文件路径，
/// localPath 是下载视频到那个文件， success会返回 下载的文件的全地址
/// localPath 中包含 .mp4 则会下载视频文件 到这个指定的 localPath 文件
+(void)downloadVideoWith:(NSString *)fileName toLocalPath:(NSString *)localPath
                    success:(RequestSuccessDataBlock _Nullable)success
                       fail:(RequsetFailBlock _Nullable)fail;

+(void)downloadVideoWith:(NSString *)fileName toLocalPath:(NSString *)localPath
                progress:(RequestProgressBlock _Nullable)progressBlock
                 success:(RequestSuccessDataBlock _Nullable)successBlock
                    fail:(RequsetFailBlock _Nullable)failBlock;
#pragma mark --------------------------  对讲
/// open: YES 开始， NO关闭对讲
+(void)sendVideoTalkStatus:(BOOL)open
                   success:(RequestSuccessDataBlock _Nullable)success
                      fail:(RequsetFailBlock _Nullable)fail;

#pragma mark --------------------------  回放
///  按照文件回放
+(void)playBackVideoWithTs:(NSInteger)ts
                      fileName:(NSString *)fileName
                    success:(RequestSuccessDataBlock _Nullable)success
                      fail:(RequsetFailBlock _Nullable)fail;

#pragma mark --------------------------  回放相关接口
/// 获取该月的时间掩码
+(void)getPlayBackDateMaskWith:(int)year month:(int)month
                       success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

/// 分页加载，获取当天的回放列表
+(void)getPlayBackRecordsWithDate:(NSDate *)date
                        pageIndex:(int)pageIndex pageSize:(int)pageSize
                          success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

/// 获取 开始时间和结束时间的 回放列表
/// startTime: 20250101000000
/// endTime:   20250101000200
+(void)getPBRecordsWithStartTime:(NSString *)startTime endTime:(NSString *)endTime
                       pageIndex:(int)pageIndex pageSize:(int)pageSize
                         success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;


/// 指定时间播放 回放
/// timestamp 如 2025020100000  2025年2月1日 0点开始播放
+(void)playPBVideoAtTime:(NSInteger)timeStamp
                 success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;


#pragma mark --------------------------  获取报警列表
// 获取报警声音列表
+(void)getAlarmFileNameListWith:(int)channelid
                        success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

// 获取 报警声音 信息 包含开关等
+(void)getAlarmInfoWith:(int)linkId
                success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

/**
 {
   "method": "alarm_sound_play",
   "param": {
     "channelid": 0,
     "status":true,
     "times":2,
     "file_name":"DangerZoneKeepAway"
   }
 }
 */
/// 播放报警声音
/// times -1是一直播放，0是播放1次，其它按次数播放
+(void)playAlarmSoundWith:(NSString *)soundName
                channelid:(int)channelid
                    times:(int)times
                  success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

/// 停止播放报警声音
+(void)stopPlayAlarmSoundWith:(NSString *)soundName channelid:(int)channelid
                  success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

// 更新报警信息
+(void)updateAlarmInfoWith:(NSDictionary *)params
                   success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

// 获取 补光灯信息
+(void)getWhiteLightInfoWith:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

// 开启或者 关闭补光灯信息  status: YES 开启， NO：关闭
+(void)updateWhiteLightStatus:(BOOL)status
                      success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;


// 获取 补光灯模式
+(void)getWhiteLightModeWith:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

// 更新 补光灯模式
+(void)updateWhiteLightMode:(NSDictionary *)params
                    success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

// reboot
+(void)rebootWith:(NSDictionary *)params success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

// getStreams
+(void)getStreamsWith:(NSDictionary *)params success:(RequestSuccessDataBlock _Nullable)success fail:(RequsetFailBlock _Nullable)fail;

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
                    fail:(RequsetFailBlock _Nullable)fail;

/// 移动 PTZ
/// speed 移动速度：0~254
+(void)movePTZWithDirection:(JVSPTZDirection)direction
                  channelId:(int)channelId
                      speed:(int)speed
                    success:(RequestSuccessDataBlock _Nullable)success
                       fail:(RequsetFailBlock _Nullable)fail;

/// 停止移动 PTZ
+(void)stopMovePTZWithChannelId:(int)channelId
                        success:(RequestSuccessDataBlock _Nullable)success
                           fail:(RequsetFailBlock _Nullable)fail;

#pragma mark --------------------------  预置点
/// 获取 预置点列表
+(void)getPresetPointListWith:(int)channelId
                      success:(RequestSuccessDataBlock _Nullable)success
                         fail:(RequsetFailBlock _Nullable)fail;

/// 删除预置点列表
+(void)deletePresetPointWith:(int)channelId
                    presetNo:(int)presetNo
                     success:(RequestSuccessDataBlock _Nullable)success
                        fail:(RequsetFailBlock _Nullable)fail;
                        
/// 添加预置点
+(void)addPresetPointWith:(int)channelId
                 presetNo:(int)presetNo
               presetName:(NSString *)presetName
                  success:(RequestSuccessDataBlock _Nullable)success
                     fail:(RequsetFailBlock _Nullable)fail;

/// 使用预置点，定位预置
+(void)locatePresetPointWith:(int)channelId
                    presetNo:(int)presetNo
                       speed:(int)speed
                     success:(RequestSuccessDataBlock _Nullable)success
                        fail:(RequsetFailBlock _Nullable)fail;

/// 云台复位
+(void)resetPTZPresetPoint:(int)channelId
                   success:(RequestSuccessDataBlock _Nullable)success
                      fail:(RequsetFailBlock _Nullable)fail;



// 取消所有请求
+(void)cancelAllRequest;

@end

NS_ASSUME_NONNULL_END
