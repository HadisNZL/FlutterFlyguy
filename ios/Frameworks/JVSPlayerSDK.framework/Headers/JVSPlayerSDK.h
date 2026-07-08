//
//  JVSPlayerSDK.h
//  JVSPlayerSDK
//
//  Created by Jovision on 2020/7/8.
//  Copyright © 2020 Jovision. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/*
 //搜索和激活的所有枚举
 typedef enum
 {
     BC_SEARCH = 0x01,
     BC_GET,
     BC_SET,
     BC_NOPOWER,
     BC_GET_ERRORCODE,
     BC_MAX,
 }BC_CMD_E;

 typedef enum
 {
     DEVICE_ALL,                //所有设备
     DEVICE_CARD,            //板卡
     DEVICE_NVR_OR_DVR,        //dvr/nvr
     DEVICE_IPC                //ipc
 }DeviceTypeSearch;

 typedef enum
 {
     DISCOVERY_DEV_TYPE_UNKNOWN = 0,
     DISCOVERY_DEV_TYPE_IPC, // IPC
     DISCOVERY_DEV_TYPE_NVR, // NVR
     DISCOVERY_DEV_TYPE_DVR, // DVR
     DISCOVERY_DEV_TYPE_XVR, // XVR
     DISCOVERY_DEV_TYPE_NVD    // 解码器
 }DeviceTypeBack;

 typedef enum
 {
     BROADCAST_1,            //云视通1.0广播搜索
     SEARCH_1,                //云视通1.0点对点搜索
     BROADCAST_2_OLD,        //云视通2.0老广播协议搜索
     BROADCAST_2_NEW,        //云视通2.0新广播协议搜索
     SEARCH_2                //云视通2.0点对点搜索
 }SearchMethod;

 typedef enum
 {
     DISCOVERY_PROTOCOL_BROADCAST_1,        //1.0广播协议
     DISCOVERY_PROTOCOL_SEARCH_1,        //1.0点对点搜索协议
     DISCOVERY_PROTOCOL_BROADCAST_2,        //2.0广播协议
     DISCOVERY_PROTOCOL_SEARCH_2,        //2.0点对点搜索协议
     DISCOVERY_PROTOCOL_SEARCH_OVER        //搜索结束
 }ProtocolTypeSdk;

 设备连接协议
 typedef enum
 {
     DISCOVERY_PROTOCOL_UNKNOWN = 0,
     DISCOVERY_PROTOCOL_YST_2,        // 云视通2.0
     DISCOVERY_PROTOCOL_YST_1,        // 云视通1.0
     DISCOVERY_PROTOCOL_ONVIF,        // onvif
     DISCOVERY_PROTOCOL_DAHUA,        // 大华私有协议
     DISCOVERY_PROTOCOL_HIK,            // 海康私有协议
     DISCOVERY_PROTOCAL_SAAS            // 公有云协议
 }DiscoveryProtocolType;

 typedef enum
 {
     ACTIVE_NOT_NEED,        //不需要激活，云视通1.0搜索、2.0老广播协议和2.0点对点搜索
     ACTIVED,                //已激活，云视通2.0新广播协议
     NOT_ACTIVED                //未激活，云视通2.0新广播协议
 }ActiveStatus;

 typedef enum
 {
     CMD_TIMEOUT = -2,
     CMD_ERROR = -1,
     CMD_SUCCESS = 0,
     CMD_NOPOWER = 1
 }CmdState;
 */
typedef enum
{
    JVS_NONE = 0,                        /*!< 无状态 */
    JVS_CONNECTED,                       /*!< 已连接 */
    JVS_CONNECT_FAILED,                  /*!< 连接失败 */
    JVS_CONNECTION_LIMIT,                /*!< 连接限制（p2p连接时，设备连接达到上线了） */
    JVS_CONNECTION_BROKEN,               /*!< 连接中断（网络异常或服务中断） */
    JVS_CONNECTION_PLAYBACK_OVER,        /*!< 回放结束 */
    JVS_CONNECTION_DISCONNECTED,         /*!< 连接断开（连接正常结束，录像回放结束） */

    JVS_VIDEO_LOADING,                   /*!< 正在缓冲 */
    JVS_VIDEO_DECODE_FAILED,             /*!< 解码失败 */
    JVS_VIDEO_DECODE_SUCCESS,            /*!< 解码成功，收到解码成功后即可调用show接口来预览图像 */
    JVS_VIDEO_INFO_ENCRYPTION,           /*!< 视频信息，收到此状态表明视频流是加密流 */
    JVS_CONNECT_USER_VERIFY_FAILED,        /*!< 用户认证失败 */
    
    JVS_CONNECT_CLOUDSEE1_P2P_READY,    /*!< 云视通1.0的预穿透准备好了，app可以选择断开重连 */
    JVS_VIDEO_INFO_CLOUDSEE1_CHANGE,    /*!< 视频信息，收到此状态表明视频流改变，app需请求当前码流信息 */
    JVS_CONNECTION_INFO,                /*!< 连接信息，收到此状态可解析附带的json信息，格式参考jav_player_def.json中的connection_info */
    JVS_MAX
}play_state;
typedef enum {
    VideoNormal,                         /*!<未连接状态 */
    VideoConnect,                        /*!<连接*/
    VideoConnecting,                     /*!<已连接*/
    NewVideoConnected,                   /*!<缓冲中*/
    VideoPlaying,                        /*!<播放状态*/
    VideoFailed                          /*!<失败状态*/
}VideoStatus;
typedef enum
{
    Video_HRS_NONE = 0,                        /*!< 无状态 */
    Video_HRS_START_RECORD,                    /*!< 开始录像 */
    Video_HRS_CREATE_PACKAGE_OK,                /*!< 创建录像文件成功，收到json数据，详见：player_record */
    Video_HRS_CREATE_PACKAGE_FAILED,            /*!< 创建录像文件失败 */
    Video_HRS_CLOSE_PACKAGE_OK,                /*!< 关闭录像文件成功，收到json数据，详见：player_record */
    Video_HRS_CLOSE_PACKAGE_FAILED,            /*!< 关闭录像文件失败 */
    Video_HRS_WRITE_FAILED,                    /*!< 写入失败 */
    Video_HRS_STORE_THE_WARNING,                /*!< 存储空间不足*/
    Video_HRS_STOP_RECORD,                    /*!< 关闭录像 */
    Video_HRS_STOP_RECORD2,                   /*!< 配置record_stop_when_stream_changed，且检测到码流参数发生了变化（App的枪球录像时需要） */
    
    Video_HRS_MAX
}record_state;

/* JPET_INTERCOM 状态定义 */
typedef enum
{
    Chat_NONE = 0,                        /*!< 无状态 */
    Chat_START_OK,                        /*!< 开始对讲成功 */
    Chat_START_FAILED,                    /*!< 开始对讲失败 */
    Chat_BROKEN,                          /*!< 对讲中断 */
    Chat_OVER,                            /*!< 对讲结束 */
    Chat_MAX
}chat_state;
/* JPET_DOWNLOAD 状态定义 */
typedef enum
{
    Down_NONE = 0,                        /*!< 无状态 */
    Down_START_DOWNLOAD_FAILED,            /*!< 开始下载失败 */
    Down_CREATE_PACKAGE_OK,                /*!< 创建录像文件成功，收到json数据，详见：player_download */
    Down_CREATE_PACKAGE_FAILED,            /*!< 创建下载文件失败 */
    Down_CLOSE_PACKAGE_OK,                /*!< 关闭下载文件成功，收到json数据，详见：player_download */
    Down_WRITE_FAILED,                    /*!< 写入失败 */
    Down_STORE_THE_WARNING,                /*!< 存储空间不足*/
    Down_DOWNLOAD_OVER,                    /*!< 下载完成 */
    Down_PLAY_DOWNLOAD_POS,                /*!< 下载录像进度，详见json定义，method：player_download_pos */
    Down_DOWNLOAD_LIMIT,                    /*!< 设备支持的下载任务达到上限 */
    Down_START_DOWNLOAD_OK,                /*!< 开始下载成功 */
    Down_JDS_BROKEN,                            /*!< 下载中断 */
    Down_MAX
}Download_state_e;
typedef enum
{
    DownFile_NONE = 0,                        /*!< 无状态 */
    DownFile_START_OK,                        /*!< 开始下载成功 */
    DownFile_START_FAILED,                    /*!< 开始下载失败 */
    DownFile_BROKEN,                        /*!< 下载中断 */
    DownFile_PROGRESS,                        /*!< 下载进度 */
    DownFile_OVER,                            /*!< 下载结束 */
    
    DownFile_MAX
}Download_file_state_e;
typedef enum{
    
    Ap_NONE = 0,                        /*!< 无状态 */
    Ap_CONNECT_FAIL,                    /*!< 连接设备失败 */
    Ap_CONNECT_OVERTIME,                /*!< 无操作超时断开 */
    Ap_GET_WIFI_LIST_OK,                /*!< 获取WIFI列表成功 */
    Ap_GET_WIFI_LIST_FAIL,              /*!< 获取WIFI列表失败 */
    Ap_SET_WIFI_OK,                     /*!< 设置设备WIFI成功 */
    Ap_SET_WIFI_FAIL,                   /*!< 设置设备WIFI失败 */

    Ap_MAX    
}Ap_state_e;
typedef struct
{
    uint32_t video_codec;                /*!< 视频编码类型，参考jav_player_video_codec_type_e */
    uint32_t video_width;                /*!< 宽 */
    uint32_t video_height;                /*!< 高 */
    uint32_t video_fps_numerator;        /*!< fps的分子，因为帧率有可能是12.5帧等浮点数，所以用分子分母形式 */
    uint32_t video_fps_denominator;        /*!< fps的分母 */
    uint32_t video_bps;                    /*!< 视频码率 */
    
    uint32_t audio_codec;                /*!< 音频编码类型，参考jav_player_audio_codec_type_e */
    uint32_t audio_channels;            /*!< 音频通道数 */
    uint32_t audio_sample_rate;            /*!< 采样频率 */
    uint32_t audio_sample_bits;            /*!< 每个采样位数 */
    uint32_t audio_bps;                    /*!< 音频码率 */
    NSString *method;                       //方法名称
}jav_player_metadata_t1;
@protocol ConnectDelegate <NSObject>

/// 连接事件状态回调
/// @param channel 通道号
/// @param eventType 事件类型
-(void)ConnectEventCallBackChannel:(int)channel withEventType:(int)eventType;

/// 视频连接状态回调
/// @param channel 通道号
/// @param eventState 事件类型
-(void)VideoEventCallBackChannel:(int)channel withEventState:(int)eventState withMsg:(id)msgDic;

/// 录像回调
/// @param channel          本地通道号
/// @param recordState 录像状态
/// @param recordInfo   录像信息
-(void)RecordVideoEventCallBackChannel:(int)channel withEventState:(int)recordState recordInfo:(NSDictionary *)recordInfo;



@end
@protocol ChatEventDelegate <NSObject>

/// 对讲状态回调
/// @param channel 本地通道号
/// @param chatState 对讲状态回调
-(void)ChatEventCallBackChannel:(int)channel withEventState:(int)chatState withJsonData:(NSDictionary *)jsonData;

@end
@protocol DownDelegate <NSObject>

/// 下载回调
/// @param playerId 下载playerId
/// @param donwState 下载状态
/// @param jsonData 下载回调数据
-(void)downPlayerId:(int)playerId withEventState:(Download_state_e)donwState withJsonData:(NSDictionary *)jsonData;

@end
@protocol DownFileDelegate <NSObject>

/// 下载文件回调
/// @param playerId 下载playerId
/// @param donwState 下载状态
/// @param jsonData 下载回调数据
-(void)downFilePlayerId:(int)playerId withEventState:(Download_file_state_e)donwState withJsonData:(NSDictionary *)jsonData;

@end
@protocol PlayBackCallBackDelegate <NSObject>
//实时回放数据
-(void)playBackTimeInfoChannel:(int)nLocalChannel withTimeInfo:(id)timeInfo;
//回放列表
-(void)playBackRecordListData:(id)recordData;
//回放天数查询回调
-(void)playBackDateListData:(id)recordData;
@end

@protocol ApNetDelegate <NSObject>

-(void)apPlayerId:(int)playerId withEventState:(Ap_state_e)apState withJsonData:(NSDictionary *)jsonData;

@end

@protocol CloudseeSendDataDelegate <NSObject>

-(void)cloudseeSendDataCallBackChannel:(int)channel withEventState:(int)state withJsonData:(NSDictionary *)jsonData;

@end
@protocol DeviceSearchCallBackDelegate <NSObject>
//局域网搜索返回的数据
-(void)deviceSearchCallBackData:(NSDictionary *)jsonData;
@end
@protocol BeiKeTalkCallBackDelegate <NSObject>
//贝壳物联对讲数据回调
-(void)beiKeTalkCallBackData:(uint8_t *)talkData length:(uint32_t)size;
@end
@interface JVSPlayerSDK : NSObject
@property(nonatomic, weak) id<ConnectDelegate> ConnectDelegate;
@property(nonatomic, weak) id<PlayBackCallBackDelegate> playBackCallBackDelegate;
@property(nonatomic, weak) id<DownDelegate> playerBackDownDelegate;
@property(nonatomic, weak) id<DownFileDelegate> playerBackDownFileDelegate;
@property(nonatomic, weak) id<ApNetDelegate> apDelegate;
@property(nonatomic, weak) id<CloudseeSendDataDelegate> cloudseeSendDataDelegate;
@property(nonatomic, weak) id<DeviceSearchCallBackDelegate> deviceSearchDelegate;
@property(nonatomic, weak) id<ChatEventDelegate> chatSdkDelegate;
@property(nonatomic, weak) id<BeiKeTalkCallBackDelegate> beiKeTalkDelegate;

//获取版本信息
-(NSString *)getVersion;
//销毁网络库
-(void)releasePlayerSDK;

/// 初始化单例
+(instancetype)shareInstanceSDK;

/// 初始化网路库
/// @param logLevel 日志等级  0：无日志，1：有日志，2...其他暂未定义
/// @param logPath   日志本地路径
-(void)initPlayerSDK:(int)logLevel logPath:(NSString *)logPath;

/// 进入前台重置播放库
-(void)resetPlayerForEnterForgroud;

/// 连接设备
/// @param p2pInfo   流信息
/// @param deviceChannel 本地通道号
/// @param remoteChannel 远程通道号（p2p能用到）
/// @param stream 码流（p2p能用到）
/// @param isratio 是否保持原画面比
-(void)deviceConnect:(NSString *)p2pInfo withChannel:(int)deviceChannel withShowVideoView:(UIView *)showVideoView withRemoteChannel:(int)remoteChannel withStream:(int)stream isratio:(BOOL)isratio;
/// 断开视频
/// @param nLocalChannel 本地channel号
-(void)disconnect:(int)nLocalChannel;
/// 只发关键帧
/// @param nLocalChannel 本地通道号
/// @param isOpen 是否开启关键帧
-(void)playerSetStreamIFrameOnlyLocalChannel:(int)nLocalChannel withOpen:(BOOL)isOpen;
/// 控制实况暂停/播放
/// @param nLocalChannel 本地通道号
/// @param isPause 是否暂停
-(void)livePauseChannel:(int)nLocalChannel withPause:(BOOL)isPause;
/// 请求I帧
/// @param nLocalChannel 本地通道号
-(void)requestIFrameChannel:(int)nLocalChannel;

/// 播放回放
/// @param deviceInfo 设备详情
/// @param nLocalChannel 本地通道号
/// @param stream 码流
/// @param remoteChannel 远程通道号
/// @param startTime 开始时间
/// @param endTime 结束时间
/// @param showVideoView 播放窗口
-(void)playerBackDeviceInfo:(NSString *)deviceInfo withLocalChannel:(int)nLocalChannel withStream:(int)stream withRemoteChannel:(int)remoteChannel withStartTime:(NSString *)startTime withEndTime:(NSString *)endTime withShowVideoView:(UIView *)showVideoView isratio:(BOOL)isratio;
///云视通2.0和1.0按照文件非精准播放
/// @param deviceInfo 设备详情
/// @param nLocalChannel 本地通道号
/// @param fileName 码流
/// @param remoteChannel 远程通道号
/// @param startTime 开始时间
/// @param endTime 结束时间
/// @param showVideoView 播放窗口
-(void)playerBackFileDeviceInfo:(NSString *)deviceInfo withLocalChannel:(int)nLocalChannel withFileName:(NSString *)fileName withRemoteChannel:(int)remoteChannel withStartTime:(NSString *)startTime withEndTime:(NSString *)endTime withShowVideoView:(UIView *)showVideoView isratio:(BOOL)isratio;
/// 云存储播放
/// @param p2pInfo 流信息
/// @param deviceChannel 本地通道号
/// @param remoteChannel 远程通道号（p2p能用到）
/// @param stream 码流（p2p能用到）
/// @param isratio 是否保持原画面比
/// @param showVideoView  播放窗口
-(void)CloudDeviceConnect:(NSString *)p2pInfo withChannel:(int)deviceChannel withShowVideoView:(UIView *)showVideoView withRemoteChannel:(int)remoteChannel withStream:(int)stream isratio:(BOOL)isratio;
/// 是否开启监听
/// @param nLocalChannel 本地通道号
/// @param isOpen 状态 开启 YES  关闭 NO
-(void)playerControlSoundChannel:(int)nLocalChannel withSound:(BOOL)isOpen;

/// 获取视频连接状态
/// @param nLocalChannel 本地通道号
-(VideoStatus)playerConnectStatusChannel:(int)nLocalChannel;

/// 控制回放暂停/播放
/// @param nLocalChannel 本地通道号
/// @param isPause 是否暂停
-(void)playBackPauseChannel:(int)nLocalChannel withPause:(BOOL)isPause;
/// 跳单针
/// @param nLocalChannel 本地通道号
-(void)playBackOneStepChannel:(int)nLocalChannel;
/// 设置回放速度
/// @param nLocalChannel 本地通道号
/// @param speed 速度 取值（-3~0~3）播放速度为：2^speed
-(void)playBackSetSpeedChannel:(int)nLocalChannel withSpeed:(int)speed;
/// 根据时间进行跳转
/// @param nLocalChannel 本地通道号
/// @param time 跳转的时间点
-(void)playBackStepChannel:(int)nLocalChannel withTime:(NSString *)time;

/// 本地录像跳转
/// @param nLocalChannel 本地通道号
/// @param time 时间点（毫秒）
-(void)localPlayBackStepChannel:(int)nLocalChannel withTime:(int)time;
/// 改变画布大小
/// @param channnel 通道号
/// @param frame 大小
-(void)changeOpenGLViewFrameChannel:(int)channnel withFrame:(CGRect)frame;

/// 抓拍
/// @param nLocalChannel 本地通道号
/// @param path 本地路径（全路径）.bmp
/// @param imageType 图片类型  0 bmp 1 jpg   2 PNG 其他类型不支持
-(void)playSnapshotChannel:(int)nLocalChannel withWritePath:(NSString *)path imageType:(int)imageType;

/// 录像开始结束命令
/// @param nLocalChannel 本地通道号
/// @param path 本地路径（全路径）/Document/
/// @param name_prefix 录像名称 例如:creat_time
/// @param isOpen Yes开启、No关闭
-(void)playRecordChannel:(int)nLocalChannel withWritePath:(NSString *)path withNamePrefix:(NSString *)name_prefix withIsOpen:(BOOL)isOpen;

/// 按时间段下载
/// @param p2pInfo 流信息
/// @param remoteChannel 远程通道号（p2p能用到）
/// @param stream 码流（p2p能用到）
/// @param beginTime 开始时间 格式的时间，如：2020-06-27T17:18:00+08:00
/// @param endTime 结束时间 格式的时间，如：2020-06-27T17:18:00+08:00
/// @param fileFormat 文件类型 （目前仅支持 0 mp4）
/// @param savePath 保存路径
/// @param saveFileNamePrefix 录像名为：saveFileNamePrefix_开始时间_结束时间.mp4
/// @return playerid 流id 暂停，继续，停止需要用到此id。
-(int)playerDownloadForTimeStart:(NSString *)p2pInfo withRemoteChannel:(int)remoteChannel withStream:(int)stream withBeginTime:(NSString *)beginTime withEndTime:(NSString *)endTime withFileFormat:(int)fileFormat withSavePath:(NSString *)savePath withSaveFileNamePrefix:(NSString *)saveFileNamePrefix;

/// 按文件下载
/// @param p2pInfo 流信息
/// @param fileName 按文件下载时需传入文件名
/// @param beginTime 开始时间 格式的时间，如：2020-06-27T17:18:00+08:00
/// @param endTime 结束时间 格式的时间，如：2020-06-27T17:18:00+08:00
/// @param fileFormat 文件类型 （目前仅支持 0 mp4）
/// @param savePath 保存路径
/// @param saveFileNamePrefix 录像名为：saveFileNamePrefix_开始时间_结束时间.mp4
/// @return playerid  流id 暂停，继续，停止需要用到此id。
-(int)playerDownloadForFileStart:(NSString *)p2pInfo withFileName:(NSString *)fileName withBeginTime:(NSString *)beginTime withEndTime:(NSString *)endTime withFileFormat:(int)fileFormat withSavePath:(NSString *)savePath withSaveFileNamePrefix:(NSString *)saveFileNamePrefix;

/// 暂停下载
/// @param playerId 流id
-(void)playerDownloadPause:(int)playerId;

/// 继续下载
/// @param playerId 流id
-(void)playerDownloadResume:(int)playerId;

/// 继续下载
/// @param playerId 流id
-(void)playerDownloadStop:(int)playerId;

/// 开始对讲
/// @param remoteChannel 远程通道号
/// @param channelInfo    对讲信息
- (int)startTalk:(NSString *)channelInfo remoteChannel:(int)remoteChannel;

/// 开启语音对讲，融视云平台
/// @param server 服务器地址，形如：127.0.0.1:15050
/// @param devSN 设备SN
/// @param audioCodec 音频编码类型，字符串，例如："g711a" "g711u"
/// @param audioChannel 音频通道数
/// @param audioSamplingRate 音频采样率
/// @param audioSamplingBits 音频采样位宽
/// @return chatid    对讲id

- (int)startTalk:(NSString *)server devSN:(NSString *)devSN audioCodec:(NSString *)audioCodec audioChannel:(int)audioChannel audioSamplingRate:(int)audioSamplingRate audioSamplingBits:(int)audioSamplingBits;

/// 结束对讲
/// @param chat_id 本地通道号
- (void)stopTalk:(int)chat_id;

/// 画面比例配置
/// @param isRatio  NO 铺满 YES 原始比例显示
/// @param nLocalChannel 通道号
/// @param frame      frame
- (void)playerSetVideoIsRatio:(BOOL)isRatio Channel:(int)nLocalChannel withFrame:(CGRect)frame;


/***************************************以下接口为附加功能接口**************************************/

/// 二维码配置网络
/// @param wifiName wifi名称
/// @param wifiPwd  wifi密码
/// @return 二维码图片
//-(UIImage*)JVSCreateQR:(NSString*)wifiName wifiPwd:(NSString*)wifiPwd;

/// 二维码配置网络
/// @param wifiName wifi名称
/// @param wifiPwd  wifi密码
/// @return 二维码信息字符串
//-(NSString *)JVSCreateQRStr:(NSString*)wifiName wifiPwd:(NSString*)wifiPwd;


/// 发送声波
/// - Parameters:
///   - wifiName: wifi名称
///   - wifiPwd: wifi密码
///   - count: 执行次数
///   - isOld: 是否是老声波
- (void)JVSSendSoundWave:(NSString *)wifiName wifiPwd:(NSString *)wifiPwd count:(int)count isOld:(BOOL)isOld;

/// 停止声波配置网络
- (void)JVSStopSendSoundWave;

///开始采集声音到文件（AAC编码格式ADTS文件格式），仅支持手机端，不能与语音对讲功能同时使用
/// @param channels 通道数，目前仅支持1通道
/// @param sample_rate 采样率，支持8000、16000
/// @param sample_bits 采样位宽，支持8、16
/// @param fullname aac文件路径
- (void)playerStartCollectSoundToAACFile:(int)channels sample_rate:(int)sample_rate sample_bits:(int)sample_bits fullname:(NSString *)fullname;

///停止采集声音，结束文件写入
- (void)playerStopCollectSound;

/// 播放aac格式的声音文件（AAC编码格式ADTS文件格式），仅支持手机端，不能与语音对讲功能同时使用
/// @param channels 通道数，目前仅支持1通道
/// @param sample_rate 采样率，支持8000、16000
/// @param sample_bits 采样位宽，支持8、16
/// @param fullname aac文件路径
- (void)playerPlayAACFile:(int)channels sample_rate:(int)sample_rate sample_bits:(int)sample_bits fullname:(NSString *)fullname;

///停止播放aac声音文件
- (void)playerStopPlayAACFile;

/// 图片解密（返回图片数据）
///@param pJav                   需要解密的图片
///@param n_size               n_size
///@param dec_key             key
///@param dec_iv               iv
///@param buf                     解密后的图片数据

- (int)JVSDecDataImage:(unsigned char*)pJav n_size:(int)n_size dec_key:(NSString *)dec_key dec_iv:(NSString *)dec_iv buf:(unsigned char*)buf;

/// 图片解密（返回图片路径）
///@param pJav                   需要解密的图片
///@param dec_key             key
///@param dec_iv               iv
///@param path                    解密后的图片路径

- (int)JVSDecPathImage:(unsigned char*)pJav dec_key:(NSString *)dec_key dec_iv:(NSString *)dec_iv path:(NSString*)path;

/// 获取AP配网wifi信息
/// @param userName 设备连接用户名
/// @param password 设备连接密码
-(void)JVSGetApWifiListUserName:(NSString *)userName withPassword:(NSString *)password;

/// 配置ap
/// @param userName 设备用户名
/// @param password 设备密码
/// @param wifiName wifi名称
/// @param wifiPassword wifi密码
-(void)JVSSetApWifiUserName:(NSString *)userName withPassword:(NSString *)password withWifiName:(NSString *)wifiName withPassword:(NSString *)wifiPassword;

/// 向设备发送控制命令（仅适用于cloudsee1.0协议的设备）
/// @param nLocalChannel 本地通道号
/// @param dataType            JVN_REQ_TEXT等命令，具体参考cloudsee1.0的命令定义
/// @param data                       PACKET结构体的数据，具体参考RConfig.h中的定义
/// @param dataSize              数据大小
-(void)JVSCloudseeSendData:(int)nLocalChannel dataType:(uint8_t)dataType data:(const uint8_t*)data dataSize:(uint32_t)dataSize;

/// 获取web服务地址，用于向2.0设备透传命令等
/// @return 服务地址，形如：http://127.0.0.1:12345/, 使用时需追加上"/v1/udms/send_cmd"等服务名使用
-(NSString *)JVSPlayerGetUrl;
/**
* @brief 录像查询，结果在回调函数中返回
* @param p2pInfo 连接所需的信息，utf8编码
* @param remoteChannel 通道标号，从0开始
* @param stream 码流标号，从0开始
* @param beginTime rfc3999 格式的时间，如：2020-06-27T17:18:00.000+08:00
* @param endTime rfc3999 格式的时间，如：2020-06-27T17:18:00.000+08:00
* @return 成功返回player_id，失败返回0
*/
-(int)playBackCloudDeviceRecordListConnectInfo:(NSString *)p2pInfo withRemoteChannel:(int)remoteChannel withStream:(int)stream withBeginTime:(NSString *)beginTime withEndTime:(NSString *)endTime;
/**
* @brief 录像日期查询，查询存在录像的日期列表，结果在回调函数中返回
* @param p2pInfo 连接所需的信息（参考jav_player_connect参数），utf8编码
* @param remoteChannel 通道标号，从0开始
* @param stream 码流标号，从0开始
* @param beginTime rfc3999 格式的时间，如：2020-06-27T17:18:00.000+08:00
* @param endTime rfc3999 格式的时间，如：2020-06-27T17:18:00.000+08:00
* @return 成功返回player_id，失败返回0
*/
-(int)playBackCloudDeviceRecordDatasConnectInfo:(NSString *)p2pInfo withRemoteChannel:(int)remoteChannel withStream:(int)stream withBeginTime:(NSString *)beginTime withEndTime:(NSString *)endTime;
/**
* @brief 设置aksk，连接外网cloudsee1.0设备时需要，初始化sdk后调用一次
* @param host 鉴权服务器地址，示例：cloudsee.com; 错误示例：https://cloudsee.com, www.cloudsee.com
* @param port 鉴权服务器端口
* @param ak Access Key
* @param sk Secret Key
*/
-(void)playerSetAkskHost:(NSString *)host port:(int)port ak:(NSString *)ak sk:(NSString *)sk;
/**
* @brief 开始下载图片
* @param info 连接所需的信息（平台返回的json串），utf8编码
* @param fileName 远程文件名（根据远程要求，需传入全路径）
* @param filePath 下载到本地后保存的文件名
* @return 成功返回player_id，失败返回0
*/
-(int)playerStartDownloadPictureInfo:(NSString *)info fileName:(NSString *)fileName downFilePath:(NSString *)filePath;
/**
* @brief 停止下载
* @param playerId 播放器id
*/
-(void)playerStopDownLoadPicturePlayerId:(int)playerId;
//局域网搜索(本地获取到ip传入的)
-(BOOL)deviceDiscoveryStart:(int)timeOut;
/// 无网段局域网搜索
/// @param timeout 最小值6000
-(void)deviceNoIpPortSearchTimeout:(int)timeout;
//ap快熟搜索只搜索2.0的
-(void)deviceDiscoveryStartAutoFast:(int)timeOut;
/// 激活设备
/// @param info 命令详情
//成功返回0   json解析失败返回-1
-(int)activeDeviceInfoDic:(NSDictionary *)info;
//重置搜索库
-(void)deviceDiscoveryReset;
//回声抑制开关-在播放库初始化的时候调用0：硬件回声消除，1：软件回声消除，2：无回声消除，3：硬件+软件回声消除语音对讲 （注：3只有android使用）
-(int)playerAecSetStatus:(int)aec_mode;
//检测IP变化changeStatus:0进入AP模式，不检测IP变化。2离开AP模式后检测IP变化
-(int)playerCheckIpChangeStatus:(int)changeStatus;
//添加预连接
-(int)playerPreconnectionAdd:(NSString *)connectInfo;
//删除预连接
-(int)playerPreconnectionRemove:(NSString *)connectInfo;
//清空预连接
-(void)playerPreconnectionClear;
-(void)playerPreconnectionReconnect;
//预连接销毁
-(void)playerPreconnectionDeinit;
//预连接初始化
-(void)playerPreconnectionInit;
/// jav_player_config
/// @param config 对应的参数
-(int)playerConfig:(NSDictionary *)config;
/// 修改对讲音量增益倍数（默认不调用是1.0）
/// @param mutiple 增益倍数
-(void)playerDeviceTalkAGCMutiple:(float)mutiple;
//修改对讲增益
-(void)playerDeviceTalkAGCGain:(float)gain withAgcType:(int)agcType;
/// 对讲前修改参数
/// @param deviceInfo 包括uc3-e的增益，手机型号，系统版本
-(void)playerDeviceTalkDeviceInfo:(NSDictionary *)deviceInfo;
/// 获取playId
/// @param nLocalChannel 本地通道号
-(int)playerGetPlayIdLocalChannel:(int)nLocalChannel;
/// 对讲是否发送声音
/// @param chatId 对讲id
/// @param mute 是否静音
-(void)playerIntercomMuteChatId:(int)chatId mute:(BOOL)mute;
/// 重启对讲录制模式
/// @param chatId 对讲id
-(void)playerIntercomAudioRestartChatId:(int)chatId;
/// 公有云设备断开预连接
/// @param deviceSN 设备号
-(void)publicCloudDisconnectPreconnectDeviceSN:(NSString *)deviceSN;
/// 设置播放帧率控制模式
/// @param nLocalChannel 本地通道号
/// @param mode 控制模式：1：不控制+不丢帧，2：缓存xx毫秒，3：固定帧率，4：动态调整帧率控制缓存，5：固定缓存+动态帧率控制+不丢帧
/// @param bufferSize 单位毫秒，默认200毫秒，建议最大不超过3000毫秒
-(void)playerSetFpsControlModeLocalChannel:(int)nLocalChannel mode:(int)mode bufferSize:(int)bufferSize;
/// pushFrameData
/// @param nLocalChannel 本地通道
/// @param type 类型
/// @param frameData 帧数据
/// @param pts 时间戳
-(void)playerPushFrameDataChannel:(int)nLocalChannel type:(int)type frameData:(NSData *)frameData pts:(long)pts;

- (void)beiKeTalkSetCallBackChatId:(int)chatId;

-(void)playerPushFrameDataChatId:(int)chatId type:(int)type frameData:(NSData *)frameData pts:(long)pts;
@end
