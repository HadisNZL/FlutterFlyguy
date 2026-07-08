//
//  JVSBasicToolDefines.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/12.
//

#import <Foundation/Foundation.h>

#ifndef JVSBasicToolDefines_h
#define JVSBasicToolDefines_h


NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString * JVSGetTenantId(void);
FOUNDATION_EXPORT NSString * JVSGetRealmID(void);
FOUNDATION_EXPORT NSString * JVSGetClientID(void);
FOUNDATION_EXPORT NSString * JVSGetUserID(void);
FOUNDATION_EXPORT NSString * JVSGetUserAccount(void);
FOUNDATION_EXPORT NSString * JVSGetUserToken(void);
FOUNDATION_EXPORT NSString * JVSGetRefreshToken(void);

// 内部判断是否是 iOS基础对象，不是基础对象则转NSDictionary保存
FOUNDATION_EXPORT void UNSaveObject(id _Nonnull object, NSString *_Nonnull forKey);
FOUNDATION_EXPORT void UNSaveInteger(NSInteger value, NSString *_Nonnull forKey);
FOUNDATION_EXPORT void UNSaveBool(BOOL value, NSString *_Nonnull forKey);

FOUNDATION_EXPORT BOOL UNGetBool(NSString *_Nonnull forKey);
FOUNDATION_EXPORT NSInteger UNGetInteger(NSString *_Nonnull forKey);
FOUNDATION_EXPORT id UNGetObject(NSString *_Nonnull forKey);

//FOUNDATION_EXPORT BOOL UNSaveSerializedObject(id object, NSString *forKey);
//FOUNDATION_EXPORT id UNGetSerializedObject(NSString *forKey);

FOUNDATION_EXPORT void UNDeletedDataForKey(NSString *key);

FOUNDATION_EXPORT void UNSynchronizeData(void);

FOUNDATION_EXPORT NSIndexPath *jvsMakeIndexPath(NSInteger section, NSInteger row);


/// 设备权限
typedef NSString * JVSDevicePermission;
FOUNDATION_EXPORT JVSDevicePermission const _Nonnull JVSDevicePermissionView;           // 视频预览权限
FOUNDATION_EXPORT JVSDevicePermission const _Nonnull JVSDevicePermissionVoice;          // 语音对讲
FOUNDATION_EXPORT JVSDevicePermission const _Nonnull JVSDevicePermissionLocalRecord;    // 本地录像回放
FOUNDATION_EXPORT JVSDevicePermission const _Nonnull JVSDevicePermissionCloudRecord;    // 云端录像回放
FOUNDATION_EXPORT JVSDevicePermission const _Nonnull JVSDevicePermissionPTZ;            // 云台控制
FOUNDATION_EXPORT JVSDevicePermission const _Nonnull JVSDevicePermissionAlarmMsg;       // 报警消息

/// 获取所有的分享权限 数组
FOUNDATION_EXPORT NSArray<JVSDevicePermission> *_Nonnull JVSGetDeviceSharePermissionArray(void);

/// 设备协议
typedef NSString * JVSDeviceProtocol;
/// 公有云
FOUNDATION_EXPORT JVSDeviceProtocol const _Nonnull JVSDeviceProtocolPublicCloud;
/// 云视通2.0
FOUNDATION_EXPORT JVSDeviceProtocol const _Nonnull JVSDeviceProtocolCloudSeeV2;
/// 云视通1.0
FOUNDATION_EXPORT JVSDeviceProtocol const _Nonnull JVSDeviceProtocolCloudSeeV1;

/// 场景中 对设备的操作，场景中增加设备和删除设备

typedef NSString *  JVSSceneDeviceAction;
FOUNDATION_EXPORT JVSSceneDeviceAction const _Nonnull JVSSceneDeviceActionAdd;
FOUNDATION_EXPORT JVSSceneDeviceAction const _Nonnull JVSSceneDeviceActionRemove;

/// 分享常量
FOUNDATION_EXPORT NSString * const _Nonnull kShared;



NS_ASSUME_NONNULL_END




typedef NS_ENUM(NSInteger, JVSGradientType) {
    JVSTopToBottom      = 0,    //从上到小
    JVSLeftToRight      = 1,    //从左到右
    JVSUpleftToLowRight = 2,    //左上到右下
    JVSUprightToLowLeft = 3,    //右上到左下
};

typedef NS_ENUM(NSUInteger, NetworkState) {
    NetworkStateNone, // 没有网络
    NetworkState2G, // 2G
    NetworkState3G, // 3G
    NetworkState4G, // 4G
    NetworkStateWIFI, // WIFI
    NetworkStateWWAN, // 流量
    NetworkStateUnknown //未知网络
};

typedef enum : NSUInteger {
    CustomType,//自定义
    TopDownType,// 从上到下
} gradualType;


#define JVSWeakObj(object)      __weak __typeof__(object) weak##_##object = object;
#define JVSStrongObj(object)    __typeof__(object) object = block##_##object;

#define JVSWeakSelf             JVSWeakObj(self)
#define JVSStrongSelf           JVSStrongObj(self)

#define kDevice_Is_iPhoneX      ([[UIApplication sharedApplication] delegate].window.safeAreaInsets.bottom>0.0)

#define kSafeBottomMargin       ([[UIApplication sharedApplication] statusBarFrame].size.height>20?34:0)
#define kStatusBarHeight        ([[UIApplication sharedApplication] statusBarFrame].size.height)
#define kNavBarHeight           (44+kStatusBarHeight)

/// 底部TabBar高度 49/83
#define kAppTabbarHeight        (kNavBarHeight>64 ? 83.0 : 49.0)

// 判断是否是ipad
#define isPad                 ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
#define mHasCurrentMode       (jvsHasCurrentMode())
#define mEqualScreenSize(si)  CGSizeEqualToSize(si, [[UIScreen mainScreen].currentMode size])

// iPhone4
#define miPhone4                (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(640, 960)) && !isPad : NO)
// iPhone5   4 英寸
#define miPhone5                (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(640, 1136)) && !isPad : NO)
// iPhone6   5.5英寸
#define miPhone6                (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(750, 1334)) && !isPad : NO)
//判断iphone6+系列 -5.5英寸
#define miPhone6Plus            (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(1242, 2208)) && !isPad : NO)
// 判断iPhoneX | iPhoneXs | 11Pro
#define IS_IPHONE_X             (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(1125, 2436)) && !isPad : NO)
// 判断iPHoneXr    -6.1英寸  这个判断 不太准确 获取的 ScreenHeight 不对 少了84
#define IS_IPHONE_Xr            (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(828, 1792)) && !isPad : NO)
// 判断iPhoneXs Max
#define IS_IPHONE_Xs_Max        (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(1242, 2688)) && !isPad : NO)
// 判断iPhone12_mini   -5.4英寸
#define IS_IPHONE_12mini        (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(1080, 2340)) && !isPad : NO)
//判断iPhone12|12Pro  12Pro/iPHone12  -6.1英寸
#define IS_IPHONE_12            (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(1170, 2532)) && !isPad : NO)
//判断iPhone12 Pro Max     -6.7英寸
#define IS_IPHONE_12ProMax      (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(1284, 2778)) && !isPad : NO)
#define IS_IPHONE_7Plus         (mHasCurrentMode ? mEqualScreenSize(CGSizeMake(1242, 2208)) && !isPad : NO)

//token
#define JVS_USERID_KEY          @"JVS_USERID_KEY"


#define SAOBJ_NULL_2NIL(_obj_)       ((_obj_)==NSNull.null?nil:(_obj_))
#define Int2Str(intVal)              [NSString stringWithFormat:@"%lld", (long long)(intVal)]
#define Float2Str(floatVal)          [NSString stringWithFormat:@"%.02lf", (double)(floatVal)]


// 移除警告
#define  M_REMOVE_CODE_WARNING(block)\
_Pragma("clang diagnostic push") \
_Pragma("clang diagnostic ignored \"-Warc-performSelector-leaks\"") \
if (block)  { block(); } \
_Pragma("clang diagnostic pop")


#define  M_ADJUST_SCROLLVIEW_INSETS(scrollView) { scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever; }

#endif /* JVSBasicToolDefines_h */
