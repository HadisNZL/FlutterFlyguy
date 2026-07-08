//
//  JVSReadData.m
//  appdemo
//
//  Created by 李华 on 2025/1/18.
//

#import "JVSReadData.h"
#import "NSData+HexExtension.h"


@implementation JVSReadData {
    NSArray <JVSFrameInfo *> *_frameDatas;
}

+(instancetype)modelWithData:(NSData *) data {
    if (data.length <= kHeaderByteLength) {
        return nil;
    }
    int index = -1;
    for (int i = 0; i < data.length-kHeaderByteLength; i++) {
        if ((memcmp(data.bytes+i, kFlagA5, 8)==0)) {
            index = i; break;  // 找到开始位置
        }
    }
    if (index < 0) {  // 没有找到帧头， 直接返回吧
        JVSReadData *readData = JVSReadData.new;
        readData->_readData = data;
        return readData;
    }
    
    const uint8_t *bytes = (const uint8_t *)[data bytes];
    // 提取数据长度，数据长度在第 12 个字节开始，占 4 个字节
    uint32_t type = *(uint32_t *)&bytes[index+8];         // 占 4 个字节
    uint32_t frameSize = *(uint32_t *)&bytes[index+12];   // 占 4 个字节
    uint64_t timeStamp = *(uint64_t *)&bytes[index+16];   // 占 8 个字节
    
    __block BOOL hasTypeIFrame = NO;
    while ((index+kHeaderByteLength) < data.length) {
        if (!(memcmp(bytes + index, kFlagA5, 8)==0)) { // 标识不一致了，结束
            break;
        }
        // 提取数据长度，数据长度在第 12 个字节开始，占 4 个字节
        uint32_t type = *(uint32_t *)&bytes[index+8];         // 占 4 个字节
        uint32_t frameSize = *(uint32_t *)&bytes[index+12];   // 占 4 个字节
        if (type == 0) {
            hasTypeIFrame = YES;
            break;
        }
        index += (kHeaderByteLength + frameSize);
    }
    
    if (type == 5) {
        
        // 提取数据长度，数据长度在第 12 个字节开始，占 4 个字节
        uint32_t dataLength = *(uint32_t *)&bytes[12];
        // 提取数据
        NSData *frameData = [NSData dataWithBytes:bytes+kHeaderByteLength length:dataLength];
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:frameData options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"---");
    }
    
    
    JVSReadData *model = JVSReadData.new;
    model->_type = type;
    model->_size = frameSize;
    model->_timeStamp = timeStamp;
    model->_readData = data;
    model->_hasTypeIFrame = hasTypeIFrame;
    
    return model;
}


-(NSArray<JVSFrameInfo *> *)frameDatas {
    if (_frameDatas.count) return _frameDatas;
    
    NSData *data = _readData;
    const uint8_t *bytes = (const uint8_t *)[data bytes];
    int index = 0;
    for (int i = 0; i < data.length-8 && data.length > 8; i++) {
        if ((memcmp(bytes+i, kFlagA5, 8)==0)) {
            index = i; break;  // 找到开始位置
        }
    }
    _headTruncatedData = nil;
    if (index > 0 && index <= data.length) {
        _headTruncatedData = [_readData subdataWithRange:NSMakeRange(0, index)];
    }
    NSMutableArray *array = @[].mutableCopy;
    while ((index+kHeaderByteLength) < data.length) {
        if (!(memcmp(bytes + index, kFlagA5, 8)==0)) {
            // 标识不一致了，结束
            break;
        }
        // 提取数据长度，数据长度在第 12 个字节开始，占 4 个字节
        uint32_t type = *(uint32_t *)&bytes[index+8];         // 占 4 个字节
        uint32_t frameSize = *(uint32_t *)&bytes[index+12];   // 占 4 个字节
        uint64_t timeStamp = *(uint64_t *)&bytes[index+16];   // 占 8 个字节
        
        if ((index+kHeaderByteLength+frameSize) >= data.length) {  // 这一帧被切割 成两次接收
            // 超过了，取最后的所有数据
            frameSize = (int)data.length - (index+kHeaderByteLength);
        }
        NSData *frameData = [data subdataWithRange:NSMakeRange(index+kHeaderByteLength, frameSize)];
        
        JVSFrameInfo *model = [JVSFrameInfo modelWith:type timeStamp:timeStamp size:frameSize frameData:frameData];
        [array addObject:model];
        
        index += (kHeaderByteLength + frameSize);
    }
    _frameDatas = array;
    return array;
}

-(BOOL)isPlaybackVideoData {
    return _type==0x80||_type==0x81||_type==0x82;
}

@end
