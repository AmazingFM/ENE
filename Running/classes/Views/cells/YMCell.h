//
//  YMCell.h
//  Running
//
//  Created by freshment on 16/9/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMCellItems.h"

#import "YMRoundCornerCell.h"

@interface YMBaseCell : UITableViewCell

@property (nonatomic, retain) YMBaseCellItem *item;

@end

@interface YMRCFieldCell : YMRoundCornerCell

@end

@interface YMRCRadioCell : YMRoundCornerCell

@end

@interface YMRCDateCell : YMRoundCornerCell
@end
