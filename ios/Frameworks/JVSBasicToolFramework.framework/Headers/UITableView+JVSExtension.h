//
//  UITableView+MExtension_.h
//  SAASTest
//
//  Created by 李华 on 2024/1/19.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <UIKit/UIKit.h>


#pragma mark --------------------------  注册Cell的便利方法
@interface UITableView (MExtension_)

/**
 注册一个cell xib/class文件
 
 @param cellClass class of collection cell
 */
- (void)jvs_registerCellClass:(Class)cellClass;
- (void)jvs_registerCellClass:(Class)cellClass reuseIdentifier:(NSString *)reuseIdentifier;

// 获取一个cell
- (__kindof UITableViewCell *)jvs_dequeueReusableCellWithClass:(Class)cellClass;
- (__kindof UITableViewCell *)jvs_dequeueReusableCellWithClass:(Class)cellClass
                                                       forIndexPath:(NSIndexPath *)indexPath;

- (__kindof UITableViewCell *)jvs_dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier;

/**
 注册一个段头/尾类， 可以使Class ，也可以 NIB 文件
 
 @param sectionHeaderClass 段头类
 @param reuseIdentifier 复用id
 */
- (void)jvs_registerSectionHeaderFooterClass:(Class)sectionHeaderClass reuseIdentifier:(NSString *)reuseIdentifier;
- (void)jvs_registerSectionHeaderFooterClass:(Class)sectionHeaderClass;

// 获取一个段头/尾
- (__kindof UITableViewHeaderFooterView *)jvs_dequeueReusableSectionHeaderFooterWithClass:(Class)headerClass;
- (__kindof UITableViewHeaderFooterView *)jvs_dequeueReusableSectionHeaderFooterWithIdentifier:(NSString *)reuseIdentifier;

/// 设置一个空 footer 页面
@property(nonatomic, assign) CGFloat jvs_tableViewFooterHeight;
@property(nonatomic, assign) CGFloat jvs_tableViewHeaderHeight;

@end
