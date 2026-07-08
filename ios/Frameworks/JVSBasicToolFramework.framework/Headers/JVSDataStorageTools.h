//
//  JVSDataStorageTools.h
//  SAAS
//
//  Created by zero on 2020/10/28.
//

#import <Foundation/Foundation.h>

#define JVSCurrentLanguage     [JVSDataStorageTools currentAppLanguage]

NS_ASSUME_NONNULL_BEGIN


@interface JVSDataStorageTools : NSObject


// -------------- 移动网络提醒  -------------------
/* 是否需要移动网络提醒 yes 已关闭 no 未关闭 */
+ (BOOL)isCloseMobileNetwork;
/* 更新移动网络提醒状态 yes 已关闭 no 未关闭 */
+ (void)updateNeedMobileNetworkStatus:(BOOL)status;
/* 今天是否已提示 */
+ (BOOL)mobileNetworkTodayIsShow;
/* 更新移动网络提醒显示时间 */
+ (void)updateMobileNetworkShowDate;


// -------------- 指纹登陆  -------------------
/* 是否开启了touch id */
+ (BOOL)isOpenTouchId;
/* 更新touch id的状态 yes 开启 no 未开启 */
+ (void)updateTouchIdStatus:(BOOL)status;

// -------------- 消息推送设置  -------------------
/* 是否开启消息tips yes 已关闭 no 未关闭 */
+ (BOOL)isCloseMessagePushTips;
/* 更新消息推送提醒tips状态 yes 已关闭 no 未关闭 */
+ (void)updateNeedMessagePushTipsStatus:(BOOL)status;

/* 是否开启消息推送 yes 已关闭 no 未关闭 */
+ (BOOL)isCloseMessagePush;
/* 更新消息推送提醒状态 yes 已关闭 no 未关闭 */
+ (void)updateNeedMessagePushStatus:(BOOL)status;

/* 是否开启报警消息推送 yes 已关闭 no 未关闭 */
+ (BOOL)isCloseWarnMessagePush;
/* 更新报警消息推送提醒状态 yes 已关闭 no 未关闭 */
+ (void)updateNeedWarnMessagePushStatus:(BOOL)status;

/* 是否开启个人消息推送 yes 已关闭 no 未关闭 */
+ (BOOL)isClosePersonalMessagePush;
/* 更新个人消息推送提醒状态 yes 已关闭 no 未关闭 */
+ (void)updateNeedPersonalMessagePushStatus:(BOOL)status;

/* 是否开启系统消息推送 yes 已关闭 no 未关闭 */
+ (BOOL)isCloseSystemMessagePush;
/* 更新系统消息推送提醒状态 yes 已关闭 no 未关闭 */
+ (void)updateNeedSystemMessagePushStatus:(BOOL)status;

/* 是否开启消息推送声音 yes 已关闭 no 未关闭 */
+ (BOOL)isCloseMessagePushVoice;
/* 更新消息推送提醒声音状态 yes 已关闭 no 未关闭 */
+ (void)updateNeedMessagePushVoiceStatus:(BOOL)status;

/* 是否开启消息推送震动 yes 已关闭 no 未关闭 */
+ (BOOL)isCloseMessagePushShake;
/* 更新消息推送提醒状态震动 yes 已关闭 no 未关闭 */
+ (void)updateNeedMessagePushShakeStatus:(BOOL)status;
/* 是否开启在线离线消息推送 yes 已关闭 no 未关闭 */
+ (BOOL)isCloseOnlieMessagePush;
/* 更新设备上线/离线报警 yes 已关闭 no 未关闭 */
+ (void)updateNeedOnLinePushStatus:(BOOL)status;
/* 获取回声抑制 状态  NO ： 硬件回升抑制 sdk 传0  yes：软件回声抑制 sdk 传1*/
+ (BOOL)isEchoSuppressio;
/* 更新 更新回声抑制状态 */
+ (void)updateEchoSuppressioStatus:(BOOL)status;
/** 如果是小图 传yes  else no */
+ (void)updateHomeListTypeBigPic:(BOOL)bigPic;
/** 如果是小图返回yes  else no */
+ (BOOL)getHomeListPicType;
/* 获取场景图开关*/
+ (BOOL)isScenPictureSwitch;
/* 更新场景图开关状态 */
+ (void)updateScenPictureSwitchStatus:(BOOL)status;
/* 获取保存的refreshToken */
//+ (NSString *)getRefreshToken;
/* 保存用户的refreshToken nil时为清空refreshToken */
//+ (void)saveRefreshToken:(NSString *)refreshToken;


+ (void)setLanguage:(BOOL)b;
+ (BOOL)hasSetLanguage;
+ (BOOL)hasNet;
+ (void)launchingUpdateLanguage;
+ (NSString *)currentAppLanguage;

@end

NS_ASSUME_NONNULL_END
