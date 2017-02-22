//
//  YMAddressViewController.h
//  Running
//
//  Created by 张永明 on 16/9/22.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"


@protocol YMAddressViewControllerDelegate <NSObject>

- (void)didSelectAddress:(YMAddress *)address;

@end


@interface YMAddressViewController : YMBaseViewController
@property (nonatomic, weak) id<YMAddressViewControllerDelegate> delegate;
@end
