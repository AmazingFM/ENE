//
//  YMBaseViewController.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBaseViewController.h"
#import "YMDataManager.h"
#import "YMUserManager.h"

@interface YMBaseViewController ()

@end

@implementation YMBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    if ([[UIDevice currentDevice].systemVersion floatValue]>=7) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.extendedLayoutIncludesOpaqueBars = NO;
        self.modalPresentationCapturesStatusBarAppearance = NO;
        self.automaticallyAdjustsScrollViewInsets = NO;
    } else {
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
        self.wantsFullScreenLayout = YES;
#endif
    }
    
    if ([self.navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    }
}

- (NSMutableDictionary<NSString *, NSString *> *)params
{
    if (_params==nil) {
        _params = [NSMutableDictionary new];
    }
    return _params;
}

-(void)refresh{}


- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setRefresh:(BOOL)flag{
}

- (void)showCustomHUDView:(NSString *)title {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the custom view mode to show any view.
    hud.mode = MBProgressHUDModeCustomView;
    // Set an image view with a checkmark.
    UIImage *image = [[UIImage imageNamed:@"Checkmark"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    hud.customView = [[UIImageView alloc] initWithImage:image];
    // Looks a bit nicer if we make it square.
    hud.square = YES;
    // Optional label text.
    hud.label.text = NSLocalizedString(title, @"HUD done title");
    
    [hud hideAnimated:YES afterDelay:1.5f];
}

- (void)showTextHUDView:(NSString *)title {
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    
    // Set the annular determinate mode to show task progress.
    hud.mode = MBProgressHUDModeText;
    hud.label.text = NSLocalizedString(title, @"HUD message title");
    // Move to bottm center.
    hud.offset = CGPointMake(0.f, self.view.frame.size.height/4);
    
    [hud hideAnimated:YES afterDelay:1.5f];
}

- (BOOL)getParameters
{
    [self.params removeAllObjects];
    
    NSString *uuid = [YMDataManager shared].uuid;
    NSString *currentDate = [YMUtil stringFromDate:[NSDate date] withFormat:@"yyyyMMddHHmmss"];
    [YMDataManager shared].reqSeq++;
    NSString *reqSeq = [YMDataManager shared].reqSeqStr;
    
    self.params[kYM_APPID] = uuid;
    self.params[kYM_REQSEQ] = reqSeq;
    self.params[kYM_TIMESTAMP] = currentDate;
    
    if ([YMUserManager sharedInstance].user!=nil) {
        self.params[kYM_TOKEN] = [YMUserManager sharedInstance].user.token;
    }
    
    return YES;
}
//
//- (void)signParameters
//{
//    NSString *md5Str = self.params[kYM_SIGN];
//    
//    if (md5Str!=nil && md5Str.length>0) {
//        return;
//    }
//    
//    NSArray *keys = self.params.allKeys;
//    NSArray *sortedKeys = [keys sortedArrayUsingSelector:@selector(compare:)];
//    
//    NSMutableString *mStr = [NSMutableString stringWithString:@"ene"];
//    for (int i=0; i<sortedKeys.count; i++) {
//        [mStr appendFormat:@"%@%@", sortedKeys[i], self.params[sortedKeys[i]]];
//    }
//    [mStr appendString:@"ene"];
//    md5Str = [YMUtil md5HexDigest:mStr];
//    self.params[kYM_SIGN] = md5Str;
//}
//
@end
