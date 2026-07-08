//
//  NSObject+SATableIndexView.h
//  SAASTest
//
//  Created by 李华 on 2024/1/19.
//  Copyright © 2024 中维世纪. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UICollectionView (MExtension_)

/**
 注册一个cell xib/class文件
 
 @param cellClass class of collection cell
 */
- (void)jvs_registerCellClass:(Class)cellClass reuseIdentifier:(NSString *)reuseIdentifier;

- (void)jvs_registerCellClass:(Class)cellClass;

// 获取一个cell
- (__kindof UICollectionViewCell *)jvs_dequeueReusableCellWithClass:(Class)cellClass forIndexPath:(NSIndexPath *)indexPath;
- (__kindof UICollectionViewCell *)jvs_dequeueReusableCellWithIdentifier:(NSString *)reuseIdentifier forIndexPath:(NSIndexPath *)indexPath;
/**
 注册一个段头/尾类， 可以使Class ，也可以 NIB 文件
 
 @param sectionHeaderClass 段头类
 @param reuseIdentifier 复用id
 */
- (void)jvs_registerSectionHeaderClass:(Class)sectionHeaderClass reuseIdentifier:(NSString *)reuseIdentifier;
- (void)jvs_registerSectionFooterClass:(Class)sectionHeaderClass reuseIdentifier:(NSString *)reuseIdentifier;

- (void)jvs_registerSectionHeaderClass:(Class)sectionHeaderClass;
- (void)jvs_registerSectionFooterClass:(Class)sectionHeaderClass;

// 获取一个段头/尾
- (__kindof UICollectionReusableView *)jvs_dequeueReusableHeaderWithClass:(Class)headerClass forIndexPath:(NSIndexPath *)indexPath;
- (__kindof UICollectionReusableView *)jvs_dequeueReusableHeaderWithReuseIdentifier:(NSString *)identifier
                                                                  forIndexPath:(NSIndexPath *)indexPath;

- (__kindof UICollectionReusableView *)jvs_dequeueReusableFooterWithClass:(Class)footerClass forIndexPath:(NSIndexPath *)indexPath;
- (__kindof UICollectionReusableView *)jvs_dequeueReusableFooterWithReuseIdentifier:(NSString *)identifier
                                                                  forIndexPath:(NSIndexPath *)indexPath;

-(UICollectionViewCell *)currentDisplayingCell;

-(void)jvs_reloadItemAtRow:(NSInteger)item section:(NSInteger)section;
-(void)jvs_reloadItemAtSection:(NSInteger)section;


- (void)scrollToRow:(NSUInteger)row inSection:(NSUInteger)section atScrollPosition:(UICollectionViewScrollPosition)scrollPosition animated:(BOOL)animated;


/// 获取 indexPath 的 frame大小
/// - Parameter indexPath: indexPath
-(CGRect)rectForRowAtIndexPath:(NSIndexPath *)indexPath;

@end

NS_ASSUME_NONNULL_END
