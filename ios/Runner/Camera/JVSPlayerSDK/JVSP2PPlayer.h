//
//  JVSP2PPlayer.h
//  appdemo
//
//  Created by 李华 on 2025/1/17.
//

#import <Foundation/Foundation.h>
#import "JVSDefinesHeader.h"

typedef NS_ENUM(NSInteger, JVSVideoType) {
    JVSVideoTypeOnline    = 0,    // 实况视频
    JVSVideoTypePlayBack  = 1,    // 回放视频
};

@class DIDModel;

typedef void (^MCommonCompletionBlock)(BOOL success, id _Nullable data, NSError * _Nullable error);

NS_ASSUME_NONNULL_BEGIN

@interface JVSP2PPlayer : NSObject
// 初始化播放库
+(void)registerPlayerSDK;
// 释放一些资源, 调用需使用 registerPlayerSDK 重新注册
+(void)releasePlayerSDK;

/// OPENGL 视频画面渲染 view
@property(nonatomic, strong, readonly) UIView *videoView;

@property(nonatomic, assign, readonly) int nLocalChannel;

@property(nonatomic, assign, readonly) int frameRate; // 视频帧率
/// 播放器类型，
/// 0：直播播放器，
/// 1：回放播放器
@property(nonatomic, assign, readonly) JVSVideoType videoType;

/// view -- 视频渲染的view
/// type 用于区分 是实况还是回放视频
+(instancetype)playerWithView:(UIView *)view type:(JVSVideoType) type;

/// 重新设置数据
//-(void)resetPlayerWithType:(JVSVideoType) type;
-(void)resetPlayerWithType:(JVSVideoType) type videoView:(UIView *)videoView;


/// 视频状态 支持 KVO
@property(nonatomic, assign) JVSVideoStatus videoStatus;
/// 流量统计，每秒字节数
@property(nonatomic, assign, readonly) NSInteger bytePerSecond;

/// 设备信息
@property(nonatomic, assign, readonly) DIDModel *didModel;

/// 是否显示 连接模式，默认隐藏
@property(nonatomic, assign) BOOL shouldShowConnectModeMark;


/// 连接视频，会自动播放视频
-(void)connectVideoWith:(DIDModel *)DIDModel;
/// 停止播放视频 - 停止播放直播/回放视频
/// 清理视频流缓存，停止接收视频流
-(void)stopPlayVideo;

/// 断联直播/回放视频
-(void)disconnect;

/// 清理缓存， 切换回放和直播的时候
-(void)resetBufferWhenSwitchedType;


/// 横竖屏切换时 需要调用这个方法
// 修改画布的大小  可以是 videoView.bound
-(void)changeOpenGLViewFrame:(CGRect)frame;

#pragma mark --------------------------  视频回放
/// 回放视频是否 暂停状态
@property(nonatomic, assign, readonly) BOOL isPaused;

/// 视频回放 - 暂停后，再次播放视频
/// 需视频已经连接并且播放状态下
-(void)resumePBVideoWithCallback:(MCommonCompletionBlock)callback;

/// 视频回放 - 暂停回放
/// 需视频已经连接并且播放状态下
-(void)pausePBVideoWithCallback:(MCommonCompletionBlock)callback;

/// 视频回放 - 停止回放
-(void)stopPBVideoWithCallback:(MCommonCompletionBlock)callback;

/// 按时间播放 回放视频， 时间格式 ： yyyyMMddHHmmss
-(void)playPBVideoAtTime:(NSString *)time callback:(MCommonCompletionBlock)callback;

#pragma mark --------------------------  视频录制
/// 是否在录制视频
@property(nonatomic, assign, readonly) BOOL isRecording;
/// 开始录制视频, 返回录制视频文件全路径，
/// 文件名格式 YYYYMMddHHmmssSSSS.mp4
-(NSString *)startRecord;
/// 结束录制视频
-(void)stopRecord;

// 录像前获取帧率数据
-(void)getVideoStreamsWithCallback:(MCommonCompletionBlock)callback;

#pragma mark --------------------------  开启对讲
/// 开启对讲，返回对讲 id，
/// 1、判断权限语音权限
/// 2、调用开启对讲接口
/// 3、使用该方法开启对讲，给设备发送对讲数据
-(int)startTalk;
-(void)stopTalk;


/// 是否静音 - 默认 NO， 默认 开启声音，
/// 需等连接视频后才能开启
@property(nonatomic, assign) BOOL voiceMute;


/// 播放报警音
/// times -1是一直播放，0是播放1次，其它按次数播放(如 times=2 则播放俩次)
-(void)playAlarmSoundWith:(NSString *)soundName times:(int)times callback:(MCommonCompletionBlock)callback;
-(void)stopPlayAlarmSoundWith:(MCommonCompletionBlock)callback;

/// 获取视频截图 -
/// 视频需正常播放，否则会截图失败
/// path 可选，图片全路径，设置path则内部将图片存储在 path
/// 不填则内部自动分配一个地址，返回UIImage
-(UIImage *)snapshotImageAtPath:(NSString * _Nullable )path;



@end

NS_ASSUME_NONNULL_END
