//
//  JVSFastMethod.h
//  JVSBasicToolFramework
//
//  Created by 张晓东 on 2024/9/27.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import <AddressBookUI/AddressBookUI.h>
#import <Photos/Photos.h>
#import <JVSBasicToolFramework/JVSBasicToolDefines.h>

NS_ASSUME_NONNULL_BEGIN


FOUNDATION_EXPORT BOOL jvsHasCurrentMode(void);

@interface JVSFastMethod : NSObject

+ (NSString*)appStoreVersion;

#pragma mark - 保存账号密码
+ (void)operaAccountInfo:(NSString*)account password:(NSString*)psd isSave:(BOOL)isSave;
+ (NSArray*)loadAccountInfor;
+ (NSString*)loadPasswordInfor:(NSString*)account;
+ (void)saveAccessToken:(NSString *)access_token;
+ (NSString*)loadAccessToken;

+ (void)CustomPopView:(CALayer*)layer type:(CATransitionType)type subType:(CATransitionSubtype)subType time:(CFTimeInterval)time;

+ (void)CustomPushview:(CALayer*)layer type:(CATransitionType)type subType:(CATransitionSubtype)subType time:(CFTimeInterval)time;

/**
 颜色渐变
 @param formerView 父视图
 @param colorArray 渐变颜色数组
 @param starPoint 开始的位置
 @param endPoint 结束的位置
 @param locationsArray  颜色的范围
 *******/
+(CAGradientLayer *)colorGradient:(UIView *)formerView andColorsArray:(NSArray *)colorArray andStartPoint:(CGPoint)starPoint andEndPoint:(CGPoint)endPoint andlocationsArray:(NSArray *)locationsArray andGradualType:(gradualType) gradualColorType;

#pragma mark - 获得当前网络状态
+ (NetworkState) getCurrentNetworkStatus;

/// 复制到 剪切板
+(void)copyString:(NSString*)string;

/**
 *  手机震动
 */
+(void)shock;


@end

NS_ASSUME_NONNULL_END
