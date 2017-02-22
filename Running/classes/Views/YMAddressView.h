//
//  YMAddressView.h
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YMAddress.h"

@protocol YMAddressViewDelegate <NSObject>

- (void)didClick;

@end

@interface YMAddressView : UIView

@property (nonatomic, retain) YMAddress *address;
@property (nonatomic, weak) id<YMAddressViewDelegate> delegate;
@end
