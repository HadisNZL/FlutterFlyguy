//
//  NSError+JVSErrorData.m
//  JVSHttpRequstFrameWork
//
//  Created by 李华 on 2024/12/26.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import "NSError+JVSErrorData.h"
#import <objc/runtime.h>

@implementation NSError (JVSErrorData)

-(void)setResponseData:(id)responseData {
    objc_setAssociatedObject(self, @selector(responseData), responseData, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

-(id)responseData {
    return objc_getAssociatedObject(self, _cmd);
}


/// 快速创建一个错误信息
+(NSError *)errorWithMsg:(NSString *)errorMsg {
    return [NSError errorWithDomain:@"JVSP2PSDKManager" code:-1 userInfo:@{NSLocalizedDescriptionKey: errorMsg ?:@""}];
}


@end
