//
//  YMRoundCornerCell.h
//  Running
//
//  Created by 张永明 on 16/9/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMCellItems.h"

@protocol YMBaseCellDelegate <NSObject>

@optional
- (void)radioButtonSelect:(int)index withIndexPath:(NSIndexPath *)indexPath;
-(void)viewValueChanged:(NSString *)fieldText withIndexPath:(NSIndexPath*)indexPath;

@end

@interface YMRoundCornerCell : UITableViewCell

@property (nonatomic, retain) YMBaseCellItem *item;
@property (nonatomic, copy) NSString * kYMRoundCornerCellReuseId;
@property (nonatomic, weak) id<YMBaseCellDelegate> delegate;
/**
 *  带边框的cell
 *
 *  @param tableView   cell所属的tableView
 *  @param style       tableView style
 *  @param radius      圆角大小
 *  @param indexPath   indexPath
 *  @param lineWidth   边框线的宽度，不宜过大
 *  @param strokeColor 边框线的颜色，默认grayColor
 *
 *  @return cell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style radius:(CGFloat)radius indexPath:(NSIndexPath *)indexPath strokeLineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)strokeColor cellIdentifier:(NSString *)cellId;


- (instancetype)initWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier radius:(CGFloat)radius indexPath:(NSIndexPath *)indexPath strokeLineWidth:(CGFloat)lineWidth strokeColor:(UIColor *)strokeColor;

/**
 *  无边框
 *
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView style:(UITableViewCellStyle)style radius:(CGFloat)radius indexPath:(NSIndexPath *)indexPath;

@end
