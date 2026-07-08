//
//  FrameParseUtil.h
//  appdemo
//
//  Created by 李华 on 2025/3/4.
//

#import <Foundation/Foundation.h>
#import "JVSReadData.h"

typedef NS_ENUM(NSInteger, JVSFrameParseType) {
    JVSFrameParseTypeVideo   = 1,
    JVSFrameParseTypeAudio   = 2
};

NS_ASSUME_NONNULL_BEGIN

@class JVSFrameParser;

@protocol JVSFrameParserDelegate <NSObject>

- (void)JVSFrameParser:(JVSFrameParser *)parser onRevicedFrameParse:(JVSFrameInfo * _Nullable)frame;

@end


@interface JVSFrameParser : NSObject

@property(nonatomic, assign, readonly) JVSFrameParseType parseType;

/// 1: 视频， - 默认
/// 2：音频
-(instancetype)initWithType:(JVSFrameParseType)type NS_DESIGNATED_INITIALIZER;

@property(nonatomic, weak) id<JVSFrameParserDelegate> delegate;

- (void)parseData:(NSData * _Nullable)buffers;


// 重置Buffter
-(void)resetBuffer;


@end

NS_ASSUME_NONNULL_END
