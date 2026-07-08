//
//  SABleResultModel.m
//  SAASTest
//
//  Created by 李华 on 2024/1/16.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import "SABleReadDataCoder.h"
#import "JVSBluetoothManager.h"
#import "NSString+HexExtension.h"
#import "NSData+HexExtension.h"

#import <pthread/pthread.h>
#import <JVSBasicToolFramework/NSObject+JSONFormat.h>
#import <JVSBasicToolFramework/NSDate+JVSExtension.h>
#import <JVSBasicToolFramework/JVSLogManager.h>


@interface SABlePartDataObj : NSObject {
    BOOL _hasReceivedEnd;
    int _totalCount;
    int _receivedCount;
    
    NSMutableArray<NSData *> *_dataList;
}

@property(nonatomic, assign) BOOL isCompleted;
@property(nonatomic, copy) NSString *resultString;

+(instancetype)modelWithData:(NSData *)data;
-(void)addPartDataWith:(NSData *)data;

@end


@implementation SABlePartDataObj

-(instancetype)initWith:(int)totalCount {
    self = [super init];
    _totalCount = totalCount;
    _dataList = @[].mutableCopy;
    /// 占位
    NSData *emptyData = NSData.new;
    for (int i=0; i<totalCount; i++) {
        [_dataList addObject: emptyData];
    }
    return self;
}

+(instancetype)modelWithData:(NSData *)data {
    int dataCount = [[data subdataWithRange:NSMakeRange(0, 1)] convertDataToInteger];
    SABlePartDataObj *model = [[SABlePartDataObj alloc] initWith:dataCount];
    return model;
}

-(void)addPartDataWith:(NSData *)data {
    int dataCount = [[data subdataWithRange:NSMakeRange(0, 1)] convertDataToInteger];
    /// 因为这个是 从 1 开始
    int dataIndex = [[data subdataWithRange:NSMakeRange(1, 1)] convertDataToInteger];
//    int isStartFlag = [[data subdataWithRange:NSMakeRange(2, 1)] convertDataToInteger];
    int isEndFlag = [[data subdataWithRange:NSMakeRange(3, 1)] convertDataToInteger];
    int partDatalen = [[data subdataWithRange:NSMakeRange(4, 2)] convertDataToInteger];
//    NSString *md5String = [[data subdataWithRange:NSMakeRange(6, 16)] convertDataToHexStr];
    
    NSData *partBodyData = [data subdataWithRange:NSMakeRange(22, partDatalen)];
    NSLog(@"----addPartDataWith 收到数据 - \nDataIndex=%d\t(TotalCount=%d)\tReceivedCount=%d\tisEndFlag=%d\nData=%@",
          dataIndex, _totalCount, _receivedCount+1, isEndFlag, data.convertDataToHexStr);

    NSString *dataHexStr = data.convertDataToHexStr;
    NSString *logStr = [NSString stringWithFormat:@"\n[%@][BLE Add PartData]\n\nDataIndex=%d\t(TotalCount=%d)\tReceivedCount=%d\tisEndFlag=%d\nData[Len=%lld]=%@", [NSDate jvs_currentDateString], dataIndex, _totalCount, _receivedCount+1, isEndFlag, (long long)dataHexStr.length/2, dataHexStr ];
    JVSWriteNetLogToLocalFileWith(logStr);

    int startIdx = MAX(dataIndex-1, 0);
    if (startIdx<_dataList.count) {
        _dataList[startIdx]=partBodyData;
    }
    _receivedCount ++;  // 收到的数据包数量
    if (isEndFlag==1) {  // 收到了结束标识
        _hasReceivedEnd = YES;
    }
    if (_hasReceivedEnd && _receivedCount>=_totalCount) {
        NSMutableData *body = [NSMutableData new];
        for (NSData *obj in _dataList) {
            [body appendData:obj];
        }
        NSString *useEncoding = @"NSUTF8StringEncoding";
        NSString *result = [[NSString alloc] initWithData:body encoding:NSUTF8StringEncoding];
        if (!result) {
            useEncoding = @"kCFStringEncodingGB_18030_2000";
            NSStringEncoding gbkEncoding = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
            result = [[NSString alloc] initWithData:body encoding:gbkEncoding];
        }
        NSString *dataHexStr = body.convertDataToHexStr;
        NSString *logStr = [NSString stringWithFormat:@"\n[%@][BLE Got All Data] %@\n bodyHexData=%@", [NSDate jvs_currentDateString], useEncoding, dataHexStr?:@"无"];
        JVSWriteNetLogToLocalFileWith(logStr);
        
        _isCompleted = YES;
        _resultString = result;
    }
}

@end


#pragma mark --------------------------  解码器 SABleReadDataCoder
@interface SABleReadDataCoder () {
    pthread_mutex_t _lock;
}

@property(nonatomic, strong) NSMutableArray<NSData *> *dataList;
@property(nonatomic, strong) NSMutableDictionary<NSString *, SABlePartDataObj *> *dataMap;


@end

@implementation SABleReadDataCoder

-(instancetype)init {
    self = [super init];
    if (self) {
        _dataMap = NSMutableDictionary.new;
    }
    return self;
}

-(NSString *)identifierForData:(NSData *)partData {
    if (![self canDecodeDataWith:partData]) {
        return nil;
    }
    NSString *md5String = [[partData subdataWithRange:NSMakeRange(6, 16)] convertDataToHexStr];
    return md5String;
}

#pragma mark --------------------------  Override
-(NSDictionary *)resultDataByAddingPartData:(NSData *)partData error:(NSError **)error {
    if (![self canDecodeDataWith:partData]) {
        if (error) {
            NSError *err = [NSError errorWithDomain:@"ble.readDataCoder" code:-1
                                           userInfo:@{NSLocalizedDescriptionKey: @"Data Format Is NOT Right!"}];
            *error = err;
        }
        return nil;
    }
    NSString *dataIdentifier = [self identifierForData:partData];
    SABlePartDataObj *model = [self blePartDataObjForIdentifier:dataIdentifier forPartData:partData];
    
    if (model.isCompleted) {
        *error = nil;
        [self removeBlePartDataObjWith:dataIdentifier];
        return model.resultString.m_JSONObject?:@{};
    }
    if (error) {
        NSError *err = [NSError errorWithDomain:@"ble.readDataCoder" code:-1
                       userInfo:@{NSLocalizedDescriptionKey: @"Data Is Not Completed"}];
        *error = err;
    }
    return nil;
}

-(BOOL)canDecodeDataWith:(NSData *)data {
    if (!data) return NO;
    // 头部校验数据占据 22个字节，其他就是内容数据
    
    // 按最大字节 125 字节传输，分包发送
    // 包体结构： 包的数量(1) 包的序号(1) 起始包(1) 结束包(1) 分包的报文体长度(2) md5校验(16) 内容(SAMaxLenPerTime)
    if (data.length < 22) {
        NSLog(@"--canDecodeDataWith 收到数据长度不够 - str=%@", [[NSString alloc] initWithData:data encoding:4]);
        return NO;
    }
    /// 数据包数量
    int dataCount = [[data subdataWithRange:NSMakeRange(0, 1)] convertDataToInteger];
    /// dataIndex start from 1
    int dataIndex = [[data subdataWithRange:NSMakeRange(1, 1)] convertDataToInteger]-1;
    if (dataCount <= 0) return NO;
    if (dataIndex >= dataCount) return NO;
    
    int len = [[data subdataWithRange:NSMakeRange(4, 2)] convertDataToInteger];
    if (data.length < 22+len) {
        NSLog(@"--canDecodeDataWith数据长度不对 - len=%d(读) - %lu(应有长度)", len, data.length-22);
        return NO;
    }
    return YES;
}

-(void)dealloc {
    NSLog(@"---------- Dealloc SABleReadDataCoder %@", self);
}

// 没有 BlePartData 就创建一个 model
-(SABlePartDataObj *)blePartDataObjForIdentifier:(NSString *)identifier
                                         forPartData:(NSData *)partData {
    pthread_mutex_lock(&_lock);
    SABlePartDataObj *model = _dataMap[identifier];
    if (!model) {
        model = [SABlePartDataObj modelWithData:partData];
        [_dataMap setObject:model forKey:identifier];
    }
    [model addPartDataWith:partData];
    pthread_mutex_unlock(&_lock);
    
    return model;
}

-(void)removeBlePartDataObjWith:(NSString *)identifier {
    pthread_mutex_lock(&_lock);
    [_dataMap removeObjectForKey:identifier];
    pthread_mutex_unlock(&_lock);
}

@end
