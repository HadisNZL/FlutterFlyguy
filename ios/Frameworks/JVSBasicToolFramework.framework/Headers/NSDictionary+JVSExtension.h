//
//  JVSExtension.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/12.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSDictionary (JVSExtension)


/// 获取 URL的参数对
/// - Parameter url: URL 地址
+(NSDictionary *)jvs_queryPairsWithURLString:(NSString *)url;


@end

NS_ASSUME_NONNULL_END
