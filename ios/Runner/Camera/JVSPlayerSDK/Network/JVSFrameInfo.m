//
//  JVSFrameInfo.m
//  appdemo
//
//  Created by 李华 on 2025/3/4.
//

#import "JVSFrameInfo.h"

@implementation JVSFrameInfo



+(instancetype)modelWith:(int)type timeStamp:(uint64_t)timeStamp size:(int)size frameData:(NSData *)frameData {
    JVSFrameInfo *info = JVSFrameInfo.new;
    info->_type = type;
    info->_timeStamp = timeStamp;
    info->_size = size;
    info->_frameData = frameData;
    
    return info;
}

-(BOOL)isPlaybackVideoData {
    return _type>=0x80;
}

@end
