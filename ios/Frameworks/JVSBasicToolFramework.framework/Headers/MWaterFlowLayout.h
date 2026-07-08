//
//  MWaterFlowLayout.h
//  Sales
//
//  Created by Mayflower on 2020/9/11.
//  Copyright © 2020 MJD. All rights reserved.
//

#import <UIKit/UIKit.h>



typedef enum {
    WSLWaterFlowVerticalEqualWidth = 0, /** 竖向瀑布流 item等宽不等高 */
    WSLWaterFlowHorizontalEqualHeight = 1, /** 水平瀑布流 item等高不等宽 不支持头脚视图*/
    WSLWaterFlowVerticalEqualHeight = 2,  /** 竖向瀑布流 item等高不等宽 */
    WSLWaterFlowHorizontalGrid = 3,  /** */
    WSLLineWaterFlow = 4 /** 线性布局 待完成 */
} WSLWaterFlowLayoutStyle; //样式

@class MWaterFlowLayout;

NS_ASSUME_NONNULL_BEGIN

@protocol MWaterFlowLayoutDelegate <NSObject>

/**
 返回item的大小
 注意：根据当前的瀑布流样式需知的事项：
 当样式为WSLWaterFlowVerticalEqualWidth 传入的size.width无效 ，所以可以是任意值，因为内部会根据样式自己计算布局
 WSLWaterFlowHorizontalEqualHeight 传入的size.height无效 ，所以可以是任意值 ，因为内部会根据样式自己计算布局
 WSLWaterFlowHorizontalGrid   传入的size宽高都有效， 此时返回列数、行数的代理方法无效，
 WSLWaterFlowVerticalEqualHeight 传入的size宽高都有效， 此时返回列数、行数的代理方法无效
 */
- (CGSize)waterFlowLayout:(MWaterFlowLayout *)waterFlowLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath;

@optional //以下都有默认值
/** 头视图Size */
-(CGSize )waterFlowLayout:(MWaterFlowLayout *)waterFlowLayout sizeForHeaderViewInSection:(NSInteger)section;
/** 脚视图Size */
-(CGSize )waterFlowLayout:(MWaterFlowLayout *)waterFlowLayout sizeForFooterViewInSection:(NSInteger)section;

/** 行数*/
-(CGFloat)rowCountInWaterFlowLayout:(MWaterFlowLayout *)waterFlowLayout;
/** 边缘之间的间距*/
-(UIEdgeInsets)edgeInsetInWaterFlowLayout:(MWaterFlowLayout *)waterFlowLayout;

///** 列数*/
//-(CGFloat)columnCountInWaterFlowLayout:(MWaterFlowLayout *)waterFlowLayout MDeprecated("请使用 -columnCountInWaterFlowLayout: section:方法替换");
///** 列间距*/
//-(CGFloat)columnMarginInWaterFlowLayout:(MWaterFlowLayout *)waterFlowLayout MDeprecated("请使用 -columnMarginInWaterFlowLayout: section:方法替换");
///** 行间距*/
//-(CGFloat)rowMarginInWaterFlowLayout:(MWaterFlowLayout *)waterFlowLayout MDeprecated("请使用 -rowMarginInWaterFlowLayout: section:方法替换");

/** 指定seciton的列数*/
-(CGFloat)columnCountInWaterFlowLayout:(MWaterFlowLayout *)waterFlowLayout section:(NSInteger)section;
/** 指定seciton的行数(还没需要用到的情形，所以没写)*/
//-(CGFloat)rowCountInWaterFlowLayout:(MWaterFlowLayout *)waterFlowLayout section:(NSInteger)section;

/** 指定seciton的列间距*/
-(CGFloat)columnMarginInWaterFlowLayout:(MWaterFlowLayout *)waterFlowLayout section:(NSInteger)section;
/** 指定seciton的行间距*/
-(CGFloat)rowMarginInWaterFlowLayout:(MWaterFlowLayout *)waterFlowLayout section:(NSInteger)section;

@end

@interface MWaterFlowLayout : UICollectionViewLayout

/** delegate*/
@property (nonatomic, weak) id<MWaterFlowLayoutDelegate> delegate;
/** 瀑布流样式*/
@property (nonatomic, assign) WSLWaterFlowLayoutStyle  flowLayoutStyle;
/** 固定列数目(优先级高于columnCountArray)*/
@property (nonatomic, assign) NSInteger  staticColumnCount;
/** 最大列数(用来确定高度数组的数据量,如果超过3列，则必须设置大于3的值)*/
@property (nonatomic, assign)NSInteger maxColumeCount;
/** 最大行数(用来确定高度数组的数据量,如果超过5行，则必须设置大于5的值)*/
@property (nonatomic, assign)NSInteger maxRowCount;
@end


NS_ASSUME_NONNULL_END
