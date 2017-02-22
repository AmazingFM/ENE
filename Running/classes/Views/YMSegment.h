//
//  YMSegment.h
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 *  样式
 */
typedef enum {
    /**
     *  线条样式
     */
    YMSegmentLineStyle = 0,
    /**
     *  矩形样式
     */
    YMSegmentRectangleStyle = 1,
    /**
     *  文字样式
     */
    YMSegmentTextStyle = 2
} YMSegmentStyle;

@interface YMSegment : UIScrollView
/**
 *  每一项默认颜色
 *  默认 [r:102.0f,g:102.0f,b:102.0f]
 */
@property(nonatomic, strong) UIColor *itemDefaultColor;
/**
 *  选中项颜色
 *
 *  YMSegmentLineStyle 默认[r:202.0, g:51.0, b:54.0]
 *  YMSegmentRectangleStyle 默认[r:250.0, g:250.0, b:250.0]
 */
@property(nonatomic, strong) UIColor *itemSelectedColor;
/**
 *  选中项样式颜色
 *
 *  默认[r:202.0, g:51.0, b:54.0]
 */
@property(nonatomic, strong) UIColor *itemStyleSelectedColor;
/**
 *  背景色
 *
 *  默认[r:238.0, g:238.0, b:238.0]
 */
@property(nonatomic, strong) UIColor *backgroundColor;
/**
 *  项切换 Block
 */
@property(nonatomic, copy) void (^itemClickBlock) (NSString *itemName, NSInteger itemIndex);
/**
 *  获取当前选中项索引
 */
@property(nonatomic, readonly, getter=selectedItemIndex) int selectedItemIndex;
/**
 *  获取当前选中项
 */
@property(nonatomic, strong, readonly, getter=selectedItem) NSString *selectedItem;
/**
 *  版本号
 */
@property(nonatomic, strong, readonly) NSString *version;
/**
 *  工厂方法，创建不同样式的选择器
 */
+ (YMSegment *)segmentWithFrame:(CGRect)frame style:(YMSegmentStyle)style;
/**
 *  初始化
 */
- (id)initWithFrame:(CGRect)frame style:(YMSegmentStyle)style;
/**
 *  设置项目集合
 */
- (void)setItems:(NSArray *)items;
/**
 *  获取项目集合
 */
- (NSArray *)items;
/**
 *  根据索引触发单击事件
 */
- (void)itemClickByIndex:(NSInteger)index;
/**
 *  添加一项
 */
- (void)addItem:(NSString *)item;
/**
 *  根据索引移除一项
 */
- (void)removeItemAtIndex:(NSInteger)index;
/**
 *  移除指定项
 */
- (void)removeItem:(NSString *)item;
@end
