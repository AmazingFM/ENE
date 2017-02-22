//
//  YMPayResultViewController.h
//  Running
//
//  Created by 张永明 on 16/10/11.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"
#import "YMOrder.h"

@interface YMPayResultViewController : YMBaseViewController

@property (nonatomic, retain) YMOrder *order;
@property (nonatomic, retain) NSDictionary *resultDict;

@end
