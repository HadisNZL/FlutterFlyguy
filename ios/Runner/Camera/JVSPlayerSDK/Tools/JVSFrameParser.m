//
//  JVSFrameParser.m
//  appdemo
//
//  Created by 李华 on 2025/3/4.
//

#import "JVSFrameParser.h"
#import "NSData+HexExtension.h"

#define kBufferSize       (2560*1440*1.5)


@interface JVSFrameParser () {
    JVSFrameParseType _parseType;
    BOOL _delegate_onRevicedFrameParse;
    NSInteger _bufferSize;
}

@property (nonatomic, strong) NSMutableData *frameBuffer;

@end


@implementation JVSFrameParser

/// 1: 视频， 2： 音频
-(instancetype)initWithType:(JVSFrameParseType)type {
    self = [super init];
    if (self) {
        _parseType = type;
        [self setupData];
    }
    return self;
}

-(instancetype)init {
    self = [self initWithType:JVSFrameParseTypeVideo];
    return self;
}
-(void)setupData {
//    if (_parseType==JVSFrameParseTypeAudio) {
//        _bufferSize = 1024*1024;   // 音频 缓冲区
//    } else {
//        _bufferSize = kBufferSize; // 视频 缓冲区
//    }
    _frameBuffer = [NSMutableData data];
}

-(void)setDelegate:(id<JVSFrameParserDelegate>)delegate {
    _delegate = delegate;
    _delegate_onRevicedFrameParse = [delegate respondsToSelector:@selector(JVSFrameParser:onRevicedFrameParse:)];
}


// 重置Buffter
-(void)resetBuffer {
    [_frameBuffer setLength:0];
}

// 解析数据
- (void)parseData:(NSData * _Nullable)buffers {
    if (buffers.length==0) {
        JVSLog(@"视频数据读取TAG：buffers 是空的");
        if (_delegate_onRevicedFrameParse) [_delegate JVSFrameParser:self onRevicedFrameParse:nil];
        return;
    }
    // 追加数据到 frameBuffer
    [self.frameBuffer appendData:buffers];
//
    BOOL hasFrame = YES;
    while (hasFrame) {
        JVSFrameInfo *frameInfo = [self readFrame3];
        if (frameInfo) {
            if (_delegate_onRevicedFrameParse) {
                [_delegate JVSFrameParser:self onRevicedFrameParse:frameInfo];
            }
        } else {
            hasFrame = NO;
        }
    }
}

// 解析帧，读取一帧 - 根据头部中的 长度读取
- (JVSFrameInfo * _Nullable)readFrame {
    const uint8_t *bytes = (const uint8_t *)[_frameBuffer bytes];
    NSUInteger length = [_frameBuffer length];
    
    // 查找帧头
    NSUInteger headerIndex = 0;
    while (headerIndex < length - 7) {
        if (memcmp(_frameBuffer.bytes + headerIndex, kFlagA5, 8) == 0) {
            break;
        }
        headerIndex++;
    }
    
    // 如果没有找到帧头，清空缓冲区
    if (headerIndex == length - 7) {
        NSInteger length = _frameBuffer.length;
//        NSString *hex = [_frameBuffer convertDataToHexStr];
        [_frameBuffer setLength:0];
        JVSLog(@"----- _readFrame2_setLength0_1 %ld", length);
        return nil;
    }
    
    // 移除帧头之前的数据
    if (headerIndex > 0) {
        [_frameBuffer replaceBytesInRange:NSMakeRange(0, headerIndex) withBytes:nil length:0];
        bytes = (const uint8_t *)[_frameBuffer bytes];
        length = [_frameBuffer length];
    }
    
    // 检查帧长度是否足够（至少 kHeaderByteLength 字节头部）
    if (length < kHeaderByteLength) {
        return nil;
    }
    
    // 提取数据长度，数据长度在第 12 个字节开始，占 4 个字节
    uint32_t dataLength = *(uint32_t *)&bytes[12];
    
    // 检查是否有完整的帧
    if (length < kHeaderByteLength + dataLength) {
        return nil;
    }
    
    uint32_t type = *(uint32_t *)&bytes[8];        // 占 4 个字节
    uint64_t timeStamp = *(uint64_t *)&bytes[16];  // 占 8 个字节
    
    // 提取数据
    NSData *frameData = [NSData dataWithBytes:bytes+kHeaderByteLength length:dataLength];
    JVSFrameInfo *frameInfo = [JVSFrameInfo modelWith:type timeStamp:timeStamp
                                                 size:dataLength frameData:frameData];
    
    // 移除已解析的帧
    [_frameBuffer replaceBytesInRange:NSMakeRange(0, kHeaderByteLength + dataLength) withBytes:nil length:0];
    
    return frameInfo;
}

// 解析帧，读取 2帧的标记 之间的数据
- (JVSFrameInfo * _Nullable)readFrame3 {
    const uint8_t *bytes = (const uint8_t *)[_frameBuffer bytes];
    NSUInteger length = [_frameBuffer length];
    
    // 查找第一帧 帧头
    NSUInteger headerIndex = 0;
    while (headerIndex < length - 7) {
        if (memcmp(_frameBuffer.bytes + headerIndex, kFlagA5, 8) == 0) {
            break;
        }
        headerIndex++;
    }
    
    // 如果没有找到帧头，清空缓冲区
    if (headerIndex == length - 7) {
        NSInteger length = _frameBuffer.length;
//        NSString *hex = [_frameBuffer convertDataToHexStr];
        [_frameBuffer setLength:0];
        JVSLog(@"----- _readFrame2_setLength0_1 %ld", length);
        return nil;
    }
    
    // 移除帧头之前的数据
    if (headerIndex > 0) {
        [_frameBuffer replaceBytesInRange:NSMakeRange(0, headerIndex) withBytes:nil length:0];
        bytes = (const uint8_t *)[_frameBuffer bytes];
        length = [_frameBuffer length];
    }
    
    // 检查帧长度是否足够（至少 kHeaderByteLength 字节头部）
    if (length < kHeaderByteLength) {
        return nil;
    }
    
    // 提取数据长度，数据长度在第 12 个字节开始，占 4 个字节
    uint32_t dataLength = *(uint32_t *)&bytes[12];
    
    // 检查是否有完整的帧
    if (length <= kHeaderByteLength + dataLength - 7) {  // 没有下一帧了，让P2P多读一次
        return nil;
    }
    // 查找 第2帧 的帧头
    NSUInteger nextHeaderIndex = headerIndex+kHeaderByteLength; // + dataLength;
    while (nextHeaderIndex < length - 7) {
        if (memcmp(_frameBuffer.bytes + nextHeaderIndex, kFlagA5, 8) == 0) {
            break;
        }
        nextHeaderIndex++;
    }
    // 如果没有找到 下一个帧头
    if (nextHeaderIndex == length - 7) { // 等待下一次
        return nil;
    }
    dataLength = (uint32_t)(nextHeaderIndex - headerIndex - kHeaderByteLength);
    
    uint32_t type = *(uint32_t *)&bytes[8];        // 占 4 个字节
    uint64_t timeStamp = *(uint64_t *)&bytes[16];  // 占 8 个字节
    
    // 提取数据
    NSData *frameData = [NSData dataWithBytes:bytes+kHeaderByteLength length:dataLength];
//    NSData *header = [NSData dataWithBytes:bytes length:kHeaderByteLength];
//    JVSLog(@"----- _readFrame2_setLength0  dataLength %d\n%@", dataLength, [header convertDataToHexStr]);

    JVSFrameInfo *frameInfo = [JVSFrameInfo modelWith:type timeStamp:timeStamp
                                                 size:dataLength frameData:frameData];
    
    // 移除已解析的帧
    [_frameBuffer replaceBytesInRange:NSMakeRange(0, kHeaderByteLength + dataLength) withBytes:nil length:0];
    
    return frameInfo;
}

/// 同 pq
- (JVSFrameInfo *)readFrame4 {
    const uint8_t *magic = (const uint8_t[]){ 0xAA, 0xAA, 0xAA, 0xAA, 0x55, 0x55, 0x55, 0x55 };
    const NSUInteger magicLen = 8;
    const NSUInteger headerMinLen = 48;
    const NSUInteger bufferLen = self.frameBuffer.length;

    if (bufferLen < headerMinLen) {
        return nil;
    }

    const uint8_t *bytes = self.frameBuffer.bytes;
    NSInteger startIndex = -1;
    NSInteger endIndex = -1;

    for (NSUInteger i = 0; i <= bufferLen - 25; i++) {
        BOOL match = YES;
        for (int j = 0; j < magicLen; j++) {
            if (bytes[i + j] != magic[j]) {
                match = NO;
                break;
            }
        }

        if (match) {
            if (startIndex == -1) {
                startIndex = i + 24;
            } else if (i > startIndex && endIndex == -1) {
                endIndex = i;
            }
        }

        if (startIndex != -1 && endIndex != -1) break;
    }

    if (startIndex == -1 || endIndex == -1 || endIndex <= startIndex) {
        return nil;
    }

    int contentSize = (int)(endIndex - startIndex);
    if (contentSize <= 0) return nil;

    uint32_t type = 0;
    if (startIndex >= 16) {
        const uint8_t *typePtr = &bytes[startIndex - 16];
        type = ((uint32_t)typePtr[3] << 24) | ((uint32_t)typePtr[2] << 16) |
               ((uint32_t)typePtr[1] << 8)  | ((uint32_t)typePtr[0]);
    }

    uint64_t timestamp = 0;
    if (startIndex >= 8) {
        const uint8_t *tsPtr = &bytes[startIndex - 8];
        for (int i = 0; i < 8; i++) {
            timestamp |= ((uint64_t)tsPtr[i] & 0xFF) << (8 * (7 - i));
        }
    }

    NSData *frameData = [NSData dataWithBytes:&bytes[startIndex] length:contentSize];

    // 剩余数据保留
    NSUInteger remainLen = bufferLen - endIndex;
    NSData *remainData = [NSData dataWithBytes:&bytes[endIndex] length:remainLen];
    self.frameBuffer.length = 0;
    [self.frameBuffer appendData:remainData];
    
    JVSFrameInfo *frameInfo = [JVSFrameInfo modelWith:type timeStamp:timestamp
                                                 size:contentSize frameData:frameData];

    return frameInfo;
}


@end
