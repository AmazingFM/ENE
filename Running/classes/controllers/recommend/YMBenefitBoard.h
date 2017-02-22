//
//  YMBenefitBoard.h
//  Running
//
//  Created by 张永明 on 16/10/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMMyBoy.h"

@protocol YMBenefitDelegate <NSObject>

- (void)showTips;

@end

@interface YMSjView : UIView

@end

@interface YMBenefitBoard : UIView

@property (nonatomic, weak) id<YMBenefitDelegate> delegate;
- (void)setProfit:(YMMyProfit *)profit;

@end

@interface YMBenefitChart :UIView

- (void)setProfit:(YMMyProfit *)profit;

@end
