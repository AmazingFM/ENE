//
//  YMBaseViewController.h
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "PPNetworkHelper.h"
#import "YMCommon.h"
#import "YMGlobal.h"
#import "YMUtil.h"

#import "YMDataBase.h"

#import "UIView+Util.h"
#import "MBProgressHUD.h"

@interface YMBaseViewController : UIViewController
//@property (nonatomic, retain) NSMutableDictionary<NSString *, NSString *> *params;

- (void)refresh;
- (void)setRefresh:(BOOL)flag;
- (void)showCustomHUDView:(NSString *)title;
- (void)showTextHUDView:(NSString *)title;
//- (BOOL)getParameters;
- (void)back;
//- (void)signParameters;
@end
