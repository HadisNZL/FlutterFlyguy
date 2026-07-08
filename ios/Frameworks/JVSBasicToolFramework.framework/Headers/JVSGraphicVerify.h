//
//  SAGraphicVerify.h
//  图像验证码
//
//  Created by 冷春雨 on 2023/8/15.
//  Copyright © 2023 中维世纪. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface JVSGraphicVerify : NSObject

+(instancetype)showWebViewGraphicVerifySuccessBack:(void(^)(NSString *codeToken))successBlock withFail:(void(^)(void))failBlock;

@end

NS_ASSUME_NONNULL_END
