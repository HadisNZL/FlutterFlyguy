//
//  DCSModel.h
//  P2PTester
//
//  Created by yc on 2022/3/28.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DCSModel : NSObject

@property (nonatomic, assign) BOOL getRespAck;
@property (nonatomic, assign) int  respSendCount;
@property (nonatomic, assign) double lastRespTime;

@property (nonatomic, assign) struct sockaddr_in addr;
@property (nonatomic, assign) int cmdIndex;

@property (nonatomic, copy) NSString *packet;
@property (nonatomic, copy) NSString *DCSTRID;
@property (nonatomic, copy) NSString *DCmd;

+ (instancetype) dcsModelWithPacket:(char *)packet Size:(int)size Index:(int)index Addr:(struct sockaddr_in)addr;

- (NSString *)toString;

@end

NS_ASSUME_NONNULL_END
