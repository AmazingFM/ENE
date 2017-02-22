//
//  YMCitySelectViewController.h
//  Running
//
//  Created by 张永明 on 16/10/2.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"

@class YMCity;

@protocol YMCitySelectDelegate <NSObject>

- (void)didSelectCity:(YMCity *)city;

@end

@interface YMCitySelectViewController : YMBaseViewController

@property (nonatomic,weak) id<YMCitySelectDelegate> delegate;

@end
