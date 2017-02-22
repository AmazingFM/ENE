//
//  YMAdviceViewController.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMAdviceViewController.h"

#import "YMGlobal.h"

@interface YMAdviceViewController ()

@end

@implementation YMAdviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"咨询";
    self.view.backgroundColor = [UIColor whiteColor];
    
    UILabel *tips = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, g_screenWidth, 100)];
    tips.font = [UIFont systemFontOfSize:20];
    tips.textAlignment = NSTextAlignmentCenter;
    tips.backgroundColor = [UIColor clearColor];
    tips.center = self.view.center;
    tips.text = @"即将上线，敬请期待";
    
    [self.view addSubview:tips];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
