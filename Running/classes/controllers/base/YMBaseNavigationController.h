//
//  YMBaseNavigationController.h
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YMBaseNavigationController : UINavigationController
{
    BOOL _changing;
}
@property(nonatomic, retain)UIView *alphaView;

//-(void)setAlph:(BOOL)flag;
@end
