//
//  MDragCellTableView.h
//  BlocksFive
//
//  Created by 李华 on 2016/11/25.
//  Copyright © 2017年 Philip Lee. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MDragCellTableView;

@protocol  MDragCellTableViewDelegate<UITableViewDelegate>

@required
/**
 *  当数据源更新的到时候调用，必须实现，需将新的数据源设置为当前tableView的数据源(例如 :_data = newDataArray)
 *  @param newDataArray   更新后的数据源
 */
- (void)dragCellTableView:(MDragCellTableView *)tableView newDataArrayAfterMove:(NSArray *)newDataArray;

@optional

/**
 *  某些indexPaths是不需要交换和晃动的，常见的比如添加按钮等，传入这些indexPaths数组排出交换和抖动操作
 @param tableView   需要排除的indexPath数组，该数组中的indexPath无法长按交换的
 */
- (NSArray<NSIndexPath *> *)excludeIndexPathsWhenMoveDragCellTableView:(MDragCellTableView *)tableView;

/**
 *  某个cell将要开始移动的时候调用
 *  @param indexPath      该cell当前的indexPath
 */
- (void)dragCellTableView:(MDragCellTableView *)tableView cellWillBeginMoveAtIndexPath:(NSIndexPath *)indexPath;
- (void)dragCellTableView:(MDragCellTableView *)tableView cellDidBeginMoveWithView:(UIView *)view atIndexPath:(NSIndexPath *)indexPath;

/** cell移动完毕，并成功移动到新位置的时候调用
 */
- (void)dragCellTableView:(MDragCellTableView *)tableView cellDidEndMoveToIndexPath:(NSIndexPath *)toIndexPath fromIndexPath:(NSIndexPath *)fromIndexPath;

/** 某个cell正在移动的时候 */
- (void)dragCellTableViewCellisMoving:(MDragCellTableView *)tableView;
/**
 *  成功交换了位置的时候调用
 *  @param fromIndexPath    交换cell的起始位置
 *  @param toIndexPath      交换cell的新位置
 */
- (void)dragCellTableView:(MDragCellTableView *)tableView moveCellFromIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath;

@end

@protocol  MDragCellTableViewDataSource<UITableViewDataSource>


@required

/** 返回整个TableView的数据，必须实现，需根据数据进行移动后的数据重排 */
- (NSArray *)dataSourceArrayOfTableView:(MDragCellTableView *)tableView;

@end

@interface MDragCellTableView : UITableView

@property (nonatomic, assign) id<MDragCellTableViewDelegate> delegate;
@property (nonatomic, assign) id<MDragCellTableViewDataSource> dataSource;

/**长按多少秒触发拖动手势，默认1秒，如果设置为0，表示手指按下去立刻就触发拖动*/
@property (nonatomic, assign) NSTimeInterval minimumPressDuration;
/**是否开启拖动到边缘滚动UITableView的功能，默认YES*/
@property (nonatomic, assign) BOOL edgeScrollEable;
/**是否开启拖动超过可编辑区域，默认YES*/
@property (nonatomic, assign) BOOL isScrollEable;
@property (nonatomic, assign) CGFloat maxY;

/** 是否允许拖拽， 默认 YES */
@property (nonatomic, assign) BOOL enableDraggable;

@end
