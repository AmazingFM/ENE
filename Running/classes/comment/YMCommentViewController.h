//
//  YMCommentViewController.h
//  Running
//
//  Created by 张永明 on 2017/2/24.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMBaseViewController.h"
#import "YMOrder.h"

@interface YMCommentCell : UITableViewCell

@property (nonatomic,retain) YMGoods* goods;

@end

@interface YMCommentViewController : YMBaseViewController

@property (nonatomic, retain) YMOrder   *order;

@end
