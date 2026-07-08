//
//  JVSP2PRequest.h
//  appdemo
//
//  Created by 李华 on 2025/1/18.
//

#import <Foundation/Foundation.h>
#import "DIDModel.h"
#import "JVSWriteData.h"
#import "JVSReadData.h"


NS_ASSUME_NONNULL_BEGIN


// videoFullPath视频详细地址， 如果出错 error会有值，二者只能有一个有值
typedef void(^JVSSuccessDataBlock)(NSString * _Nullable videoFullPath, NSError * _Nullable error);
typedef void(^JVSProgressBlock)(NSInteger revicedByte);

typedef NS_ENUM(NSInteger, JVSP2PStateCode) {
    JVSP2PStateCodeNone           = 0,
    JVSP2PStateCodeConnecting     = 1, // 视频连接中
    JVSP2PStateCodeConnectFailed  = 2, // 视频连接失败
    JVSP2PStateCodeConnected      = 3, // 视频连接
    JVSP2PStateCodeVideoPlaying   = 4, // 视频播放
    JVSP2PStateCodeDisconnected   = 5, // 视频断开连接了
    
//    JVSP2PStateCodeTimeOut        = -3,
//    JVSP2PStateCodeInvalidID      = -4,
//    JVSP2PStateCodeNotOnline      = -5,
//    JVSP2PStateCodeIDOutOfDate    = -9,
//    JVSP2PStateCodeClosedRemote   = -12,
};

@class JVSP2PSDKManager;

@protocol JVSP2PSDKManagerDelegate <NSObject>

@optional
/// channel  不要阻塞这个方法
/// 0: 通道是信令，也就是我们的grpc协议，
/// 1: 视频 通道，
/// 2: 音频 通道
-(void)JVSP2PSDKManager:(JVSP2PSDKManager *)manager didReadData:(JVSReadData *)model channel:(int)channel;

//-(void)JVSP2PSDKManager:(JVSP2PSDKManager *)manager didChangeVideoState:(JVSP2PStateCode)stateCode;
-(void)JVSP2PSDKManager:(JVSP2PSDKManager *)manager didChangeVideoState:(JVSP2PStateCode)stateCode forKey:(NSString *)key;

@end

@interface JVSP2PSDKManager : NSObject
+(instancetype) alloc __attribute__((unavailable("call shared instead")));
+(instancetype) new __attribute__((unavailable("call shared instead")));
-(instancetype) copy __attribute__((unavailable("call shared instead")));
-(instancetype) mutableCopy __attribute__((unavailable("call shared instead")));

+ (instancetype)shared;

/// 是否打印日志 default 未 YES  - 打印日志
@property(nonatomic, assign) BOOL shouldShowLog;

@property(assign, readonly) JVSP2PStateCode connectStatus;
@property (nonatomic, strong,readonly) SessionModel *sessionModel;
-(void)videoStatusDidUpdateWith:(JVSP2PStateCode)code;

//@property(nonatomic, weak) id<JVSP2PSDKManagerDelegate> delegate;

/// 添加多个回调，weak 引用 target，根据target的class 缓存对象
+(void)addDelegateForTarget:(id<JVSP2PSDKManagerDelegate> _Nonnull)target;
+(void)addDelegateForTarget:(id<JVSP2PSDKManagerDelegate> _Nonnull)target forKey:(NSString *)key;


+(void)removeDelegateForTarget:(id<JVSP2PSDKManagerDelegate> _Nonnull)target;
+(void)removeDelegateForKey:(NSString *)key;


- (BOOL)connectWithDIDModel:(DIDModel *)model;
/// 断开连接
- (void)disconnect;

/// 发送数据
- (BOOL)sendDataWith:(JVSWriteData *)data;

/// 发送语音数据 G711格式的 语音
/// 在同一个线程调用，保证语音的 顺序
- (void)sendoAudioDataWith:(NSData *)audioData;

/// 下载视频  到本地路径 localPath
- (void)downloadVideoWith:(NSString *)filePath toLocalPath:(NSString *)localPath fileSize:(NSInteger)fileSize
            progressBlock:(JVSProgressBlock)progressBlock
          completionBlock:(JVSSuccessDataBlock)completionBlock;


/// 获取一个请求的唯一 ID
-(long)getUniqueRequestId;

/// 检测 DID 和 InitString 是否 是有效的
- (BOOL)checkDID:(NSString *)DID andInitString:(NSString *)InitString;
@end

NS_ASSUME_NONNULL_END
