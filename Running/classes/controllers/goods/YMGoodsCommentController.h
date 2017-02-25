//
//  YMGoodsCommentController.h
//  Running
//
//  Created by 张永明 on 2017/2/25.
//  Copyright © 2017年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

@interface YMCommentItem : NSObject

@property (nonatomic, copy) NSString *a;
@property (nonatomic, copy) NSString *b;
@property (nonatomic, copy) NSString *c;
@property (nonatomic, copy) NSString *d;
@property (nonatomic, copy) NSString *e;

@end

@interface YMCommentCell : UITableViewCell
@property (nonatomic, retain) NSIndexPath *indexPath;

@property (nonatomic) CGFloat cellHeight;
@end

@interface YMGoodsCommentController : YMBaseViewController

@end
