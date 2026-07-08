//
//  JVSP2PSendDataOperation.h
//  appdemo
//
//  Created by 李华 on 2025/3/27.
//

#import <Foundation/Foundation.h>
#import "JVSWriteData.h"

NS_ASSUME_NONNULL_BEGIN

typedef void (^JVSDataSendCompleteBlock)(JVSWriteData *dataModel);

@interface JVSP2PSendDataOperation : NSOperation


@property (nonatomic, copy, nullable) JVSDataSendCompleteBlock completedBlock;


@property (assign, nonatomic, getter = isExecuting) BOOL executing;
@property (assign, nonatomic, getter = isFinished) BOOL finished;

@property(nonatomic, strong, readonly) JVSWriteData *dataModel;
@property(nonatomic, assign, readonly) int session;

-(instancetype)initWithSession:(int)session dataModel:(JVSWriteData *)dataModel completion:(JVSDataSendCompleteBlock)completion;

@end

NS_ASSUME_NONNULL_END
