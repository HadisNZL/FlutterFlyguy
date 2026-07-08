//
//  MDragCellCollectionView.h
//  JVSBasicToolFramework
//
//  Created by 李华 on 2024/10/10.
//



#import <UIKit/UIKit.h>
//#import "MWaterFlowLayout.h"

@class MDragCellCollectionView;

@protocol  MDragCellCollectionViewDelegate<UICollectionViewDelegate>

@required
/**
 *  当数据源更新的到时候调用，必须实现，需将新的数据源设置为当前tableView的数据源(例如 :_data = newDataArray)
 *  @param newDataArray   更新后的数据源
 */
- (void)dragCellCollectionView:(MDragCellCollectionView *)collectionView newDataArrayAfterMove:(NSArray *)newDataArray;

@optional

/**
 *  某些indexPaths是不需要交换和晃动的，常见的比如添加按钮等，传入这些indexPaths数组排出交换和抖动操作
 @param collectionView   需要排除的indexPath数组，该数组中的indexPath无法长按抖动和交换
 */
- (NSArray<NSIndexPath *> *)excludeIndexPathsWhenMoveDragCellCollectionView:(MDragCellCollectionView *)collectionView;

/**
 *  某个cell将要开始移动的时候调用
 *  @param indexPath      该cell当前的indexPath
 */
- (void)dragCellCollectionView:(MDragCellCollectionView *)collectionView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath;
- (void)dragCellCollectionView:(MDragCellCollectionView *)tableView cellDidBeginMoveWithView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath;

/** cell移动完毕，并成功移动到新位置的时候调用
 */
//- (void)dragCellCollectionView:(MDragCellCollectionView *)collectionView cellDidEndMoveAtIndexPath:(NSIndexPath *)indexPath;
/**
 *  某个cell正在移动的时候
 */
- (void)dragCellCollectionViewCellisMoving:(MDragCellCollectionView *)collectionView;

///**
// *  cell移动完毕，并成功移动到新位置的时候调用
// */
//- (void)dragCellCollectionViewCellEndMoving:(MDragCellCollectionView *)collectionView;

/**
 *  成功交换了位置的时候调用, 手势可能还没有停止
 *  @param fromIndexPath    交换cell的起始位置
 *  @param toIndexPath      交换cell的新位置
 */
- (void)dragCellCollectionView:(MDragCellCollectionView *)collectionView moveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

/**
 *  成功交换了位置的时候调用, 已经停止手势移动
 *  @param fromIndexPath    交换cell的起始位置
 *  @param toIndexPath      交换cell的新位置
 */
- (void)dragCellCollectionView:(MDragCellCollectionView *)collectionView didEndMoveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol  MDragCellCollectionViewDataSource<UICollectionViewDataSource>


@required
/**
 *  返回整个CollectionView的数据，必须实现，需根据数据进行移动后的数据重排
 */
- (NSArray *)dataSourceArrayOfCollectionView:(MDragCellCollectionView *)collectionView;

@end

@interface MDragCellCollectionView : UICollectionView

@property (nonatomic, assign) id<MDragCellCollectionViewDelegate> delegate;
@property (nonatomic, assign) id<MDragCellCollectionViewDataSource> dataSource;

/**长按多少秒触发拖动手势，默认1秒，如果设置为0，表示手指按下去立刻就触发拖动*/
@property (nonatomic, assign) NSTimeInterval minimumPressDuration;
/**是否开启拖动到边缘滚动CollectionView的功能，默认YES*/
@property (nonatomic, assign) BOOL edgeScrollEable;
/**是否开启拖动超过可编辑区域，默认YES*/
@property (nonatomic, assign) BOOL isScrollEable;
@property (nonatomic, assign) CGFloat maxY;

/**是否开启拖动的时候所有cell抖动的效果，默认YES*/
@property (nonatomic, assign) BOOL shakeWhenMoveing;
/**抖动的等级(1.0f~10.0f)，默认4*/
@property (nonatomic, assign) CGFloat shakeLevel;
/**是否正在编辑模式，调用xwp_enterEditingModel和xw_stopEditingModel会修改该方法的值*/
@property (nonatomic, assign, readonly, getter=isEditing) BOOL editing;

/** 是否允许拖拽， 默认 YES */
@property (nonatomic, assign) BOOL enableDraggable;

/**进入编辑模式，如果开启抖动会自动持续抖动，且不用长按就能出发拖动*/
- (void)xw_enterEditingModel;

/**退出编辑模式*/
- (void)xw_stopEditingModel;

@end
