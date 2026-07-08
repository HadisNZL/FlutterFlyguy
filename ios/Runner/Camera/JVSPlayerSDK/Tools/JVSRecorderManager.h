//
//  JVSRecorderManager.h
//  appdemo
//
//  Created by 李华 on 2025/2/21.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <CoreAudio/CoreAudioTypes.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

// Audio Settings
#define kNumberBuffers       1

#define kSampleRate          8000
#define kNumberChannels      1
#define kBitsPerChannels     16

#define kFrameSize           640


typedef void (^JVSCommonSuccessBlock)(BOOL success);

@protocol JVSRecorderManagerDelegate <NSObject>

-(void)didRecordAudioWithData:(NSData *)data;

@end


@interface JVSRecorderManager : NSObject

@property(nonatomic, weak) id<JVSRecorderManagerDelegate> delegate;

- (void) start;
- (void) stop;
- (void) pause;

/// 请求权限
+(void)requestRecordPermission:(JVSCommonSuccessBlock)block;

@end

NS_ASSUME_NONNULL_END
