//
//  G711Coder.m
//  appdemo
//
//  Created by 李华 on 2025/2/20.
//
#import <Foundation/Foundation.h>


@interface G711Coder : NSObject


// PCM 音频转 为G711A 或者 G711U格式音频
+(NSData *)encodeG711FromPCMData:(NSData *)data isFlagA:(BOOL)flaga;

@end



