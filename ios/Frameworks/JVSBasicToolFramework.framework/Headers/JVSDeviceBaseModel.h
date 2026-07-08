//
//  JVSDeviceBaseModel.h
//  JVSDeviceManagerComponent
//
//  Created by 李华 on 2024/10/16.
//

#import <Foundation/Foundation.h>
#import <JVSBasicToolFramework/JVSBasicToolDefines.h>
#import <JVSBasicToolFramework/JVSDeviceInfoBase.h>


NS_ASSUME_NONNULL_BEGIN


@interface JVSDeviceBaseModel : JVSDeviceInfoBase<NSCopying>

/// 通道列表
@property (nonatomic, strong) NSArray<JVSDeviceBaseModel *> *channelList;


/** 是否是场景列表来的 */
@property (nonatomic, assign) BOOL isSence;
@property (nonatomic, copy) NSString *channelCnt;//通道数

/// 我的设备下通道没有deviceSn，需要自己反绑一下 场景下的通道下面的都会返回
//@property (nonatomic, copy) NSString *deviceSn;//设备序列号
/**不要使用deviceName，使用channelName*/
@property (nonatomic, copy) NSString *deviceName;//设备名 如果是通道的话拿到的是NVR的
@property (nonatomic, copy) NSString *channelName;//显示设备名字用这个
/**不要使用deviceType，使用channelType*/
@property (nonatomic, copy) NSString *deviceType;//设备类型
@property (nonatomic, copy) NSString *model;//设备型号

@property (nonatomic, strong) NSString *channelType;//设备类型，使用这个判断类型准确
/// 我的设备列表外层没有，只有通道才会有，没有默认0
//@property (nonatomic, copy) NSString *channelId;
/// 设备在线状态（ONLINE：在线,OFFLINE：离线）
@property (nonatomic, copy) NSString *onlineState;
/// 通道在线状态（ONLINE：在线,OFFLINE：离线）
@property (nonatomic, copy) NSString *channelState;

@property (nonatomic, assign) int nLocalChannelNumber;
/**
云台能力    ptz             通道能力集
对讲能力    talk            通道、设备能力集
本地存储    localstorage    设备能力集
云端存储    cloudstorage    设备能力集
报警声音    alarmsound      通道、设备能力集
人形检测    peopledetect    通道、设备能力集
云台追踪    ptzautotrace    通道、设备能力集
智能分析    intelligent     通道、设备能力集
指示灯开关   statuslight    设备能力集
喇叭开关    audioout        通道，设备能力集
物理遮蔽    physicalcover   设备能力集、通道能力
 */
@property (nonatomic, strong) NSArray<NSString *> *ability;        //设备能力集
@property (nonatomic, strong) NSArray<NSString *> *channelAbility; //通道的能力集
///设备升级使用
@property (nonatomic, copy) NSString *currentVersion;
@property (nonatomic, copy) NSString *latestVersion;

/// INIT:初始分享(未分享) ,SHARING：分享中,SHARED：被分享
@property (nonatomic, copy) NSString *shareType;

/// 设备是否是 被分享的 shareType = SHARED
@property (nonatomic, assign, readonly) BOOL isDeviceShared;
/// 我分享了
@property (nonatomic, assign, readonly) BOOL isDeviceMySharing;
/** 是不是我的设备 */
@property (nonatomic, assign, readonly) BOOL isMyDevice;

/// 不显示分享，也不显示被分享
@property (nonatomic, assign, readonly) BOOL isDeviceShareINIT;

@property (nonatomic, strong) NSString *offlineTime;//设备离线时间 NVR要求通道里面取
/// IPC、通道专有的 - 设备云存开启状态 CLOSE-关闭 OPEN-开启
@property (nonatomic, copy) NSString *cloudStorageStatus;

#pragma mark - 新加的字段------------
///(通道级别)设备套餐状态 0-已关闭,1-使用中,2-已到期 3-未开通
@property (nonatomic, assign) int cloudStatus;
// 被分享的权限 - (设备级别)
@property (nonatomic, copy) NSDictionary<JVSDevicePermission, NSNumber *> *permission;

/** 是否包含枪球 1 不用用于判断是枪球设备，IPC并且是1  bulletDemoType !=-1 才是枪球*/
@property (nonatomic, copy) NSNumber *isBulletDemoDevice;
/// 是枪机 根据isBulletDemoDevice
@property (nonatomic, assign, readonly) BOOL isDeviceBulletType;
/// 是球机 根据isBulletDemoDevice
@property (nonatomic, assign, readonly) BOOL isDeviceBallType;
/** 枪球判断 枪球机类型0-枪机1-球机 -1普通设备 */
@property (nonatomic, copy) NSNumber *bulletDemoType;
/** 是否是枪球设备 设备级别，不是通道级别 */
@property (nonatomic, assign, readonly) BOOL isGunBallForMyDevice;

/// 自己定义的 标记是通道还是IPC
@property (nonatomic, assign) BOOL isBelongtoNVR;
/// 自己添加的 进入视频预览页面出图的需要刷新显示
@property (nonatomic, strong) NSString *url;

/// 自己添加 记录设备是否是选中 NVR不能选择
@property (nonatomic, assign) BOOL isSelect;
/// 自己添加 隐私状态开关
@property (nonatomic, assign) BOOL enable;
/// 自己添加 媒体加密开关
@property (nonatomic, assign) BOOL privateEnable;
/// 是否是NVR
@property (nonatomic, assign) BOOL isNVR;
/// 非设备返回数据
@property (nonatomic, assign) int remoteChannel;//远程通道
/// 二级设备数组
@property (nonatomic, strong) NSMutableArray *children;
/// 0:未选中、1:选中、2:不可以选中
@property (nonatomic, assign) int        selectType;
/// nvr在线数量
@property (nonatomic, assign) int onlineCount;

/// unreadCount 设备报警消息未读数量 >0代表有未读
@property (nonatomic, assign) NSInteger unreadCount;

/**
 设备接入协议
 PUBLICCLOUD:公有云设备,CLOUDSEE1:云视通1.0设备,CLOUDSEE2:云视通2.0设备
 */
//@property (nonatomic, copy) NSString *accessProtocol;
//
//@property (nonatomic, copy) NSString *deviceIp; /** 云视通设备Ip     */
//@property (nonatomic, copy) NSString *devicePort; /** 云视通设备端口号 */
//@property (nonatomic, copy) NSString *deviceUser; /** 云视通设备用户名 */
//@property (nonatomic, copy) NSString *devicePwd; /** 云视通设备密码 */
@property (nonatomic, copy) NSString *weakPwd; /** 是否弱密码 YES;是弱密码,NO：不是弱密码 */
@property (nonatomic, copy) NSString *ownType; /** 设备分享状态
                                                  OWNER：所有者,SHARE：被分享者 */
//@property (nonatomic, assign) BOOL isApwifi;//判断ap配网 无需传sn 以及port是int类型；

/** 设备名称 人为处理 如果是nvr  deviceName  nvr的通道  用channelName  如果是ipc 用 deviceName  */
@property (nonatomic, copy) NSString *mName;
/// 没有实际意义只是刷新
@property (nonatomic, assign) BOOL userReload;
/// 设备上线类型 0-4G上线 1-网线上线
@property (nonatomic, copy) NSString *onlineType;
/// 4G卡卡号
@property (nonatomic, copy) NSString *iccId;
/// 4G卡状态 0-已停用 1-使用中
@property (nonatomic, copy) NSString *status;


@property (nonatomic, copy) NSString *jsonDataString;

- (void)updateName:(NSString *)mName;


@end

NS_ASSUME_NONNULL_END
