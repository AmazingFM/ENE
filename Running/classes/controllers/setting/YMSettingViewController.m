//
//  YMSettingViewController.m
//  Running
//
//  Created by freshment on 16/9/23.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMSettingViewController.h"
#import "YMResetPwdViewController.h"

#import "YMUserManager.h"
#import "YMGlobal.h"
#import "YMConfig.h"

@interface YMSettingViewController () <UITableViewDelegate, UITableViewDataSource>
{
    UITableView *_mainTableView;
    
    UIButton *_quitButton;
    
    NSArray *_titles;
    
    UISwitch*   _openSwitch;
    UIActivityIndicatorView* _calcLocalWaitingView;
    NSString*   _localBufferSizeTitle;
}

@end

@implementation YMSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"设置";
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    
    _titles = @[@[@"推送消息设置", @"清除本地缓存"], @[@"修改密码", @"关于"]];
    
    float tableHeight = 4*kYMTableViewDefaultRowHeight+20.f;
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0,kYMTopBarHeight, g_screenWidth,tableHeight)];
    _mainTableView.delegate = self;
    _mainTableView.dataSource = self;
    _mainTableView.backgroundColor = [UIColor whiteColor];
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    _mainTableView.scrollEnabled = NO;
    _mainTableView.tableFooterView = [[UIView alloc] init];
    
    _quitButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _quitButton.frame = CGRectMake(kYMBorderMargin,kYMTopBarHeight+_mainTableView.frame.size.height+10,g_screenWidth-2*kYMBorderMargin, 40);
    [_quitButton setCornerRadius:5.f];
    
    _quitButton.backgroundColor = [UIColor redColor];
    [_quitButton setTitle:@"退出登录" forState:UIControlStateNormal];
    [_quitButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _quitButton.titleLabel.font = kYMNormalFont;
    [_quitButton addTarget:self action:@selector(quitLogin:) forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:_quitButton];
    [self.view addSubview:_mainTableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self performSelector:@selector(refresh) withObject:nil afterDelay:0.2];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
    [self.navigationController.navigationBar setShadowImage:nil];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)refresh{
    _localBufferSizeTitle=@" ";
    UITableViewCell* calcCell=[_mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    if(calcCell){
        calcCell.accessoryView=_calcLocalWaitingView;
        calcCell.detailTextLabel.text=@" ";
        [_calcLocalWaitingView startAnimating];
        [self performSelector:@selector(calcLocalData) withObject:nil afterDelay:1];
    }
}

-(void)calcLocalData{
#define kYMLenM (1024*1024.0)
#define kYMLenK 1024.0
    dispatch_queue_t calc_queue = dispatch_queue_create("calc.local.bufferdata", 0);
    dispatch_async(calc_queue, ^{
        unsigned long long localBufferSize=0;
        localBufferSize = 5.7*1024*1024;
        
        //自选股,最近浏览
//        NSString* storePath=[NSString stringWithFormat:@"%@/store",g_quoteStockDocumentPath];
        //        localBufferSize+=[self fileSizeAtPath:optionalPath];
//        localBufferSize+=[self folderSizeAtPath:storePath];
//        localBufferSize+=[self folderSizeAtPath:g_quoteStockCachePath];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [_calcLocalWaitingView stopAnimating];
            _localBufferSizeTitle=[self localSize2String:localBufferSize];
            UITableViewCell* calcCell=[_mainTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:0]];
            calcCell.detailTextLabel.text=_localBufferSizeTitle;
            calcCell.accessoryView=nil;
        });
    });
}

-(NSString*)localSize2String:(unsigned long long)len{
    if(len>kYMLenM){
        return [NSString stringWithFormat:@"%.01fM",len/kYMLenM];
    }else if(len>kYMLenK){
        return [NSString stringWithFormat:@"%.01fK",len/kYMLenK];
    }else {
        return @"小于1K";
    }
}

-(unsigned long long)fileSizeAtPath:(NSString*)path{
    if([[NSFileManager defaultManager] fileExistsAtPath:path]){
        NSError* error=nil;
        NSDictionary* fileAttr=[[NSFileManager defaultManager] attributesOfItemAtPath:path error:&error];
        if(fileAttr){
            return [fileAttr fileSize];
        }
    }
    return 0;
}

//遍历文件夹获得文件夹大小，返回多少M
- (unsigned long long) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    unsigned long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize;
}

-(void)clearLocalBufferData{
//    NSString* optionalName=@"optional";
//    NSString* optionalPath=[NSString stringWithFormat:@"%@/store/%@",g_quoteStockDocumentPath,optionalName];
//    [[NSFileManager defaultManager] removeItemAtPath:optionalPath error:nil];
//    [[NSFileManager defaultManager] removeItemAtPath:g_quoteStockCachePath error:nil];
}

- (void)quitLogin:(UIButton *)sender
{
    [YMConfig deleteOwnAccount];
    [YMUserManager sharedInstance].user = nil;
    
    [g_mainMenu setMenuSelectedAtIndex:0];
    [self.navigationController popViewControllerAnimated:YES];

    [g_appDelegate setRootViewControllerWithLogin];
}

#pragma mark -UITableViewDelegate
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return kYMTableViewDefaultRowHeight;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    UIView* myView = [[UIView alloc] init];
//    myView.backgroundColor = rgba(242, 242, 242, 1);
//    return myView;
//}
//
- (nullable UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UIView* myView = [[UIView alloc] init];
    myView.backgroundColor = rgba(242, 242, 242, 1);
    return myView;
}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    if(section==1){
//        return 10.f;
//    }
//    return 0;
//}
-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 10.f;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return _titles.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *sectionArr = _titles[section];
    return sectionArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    NSString *cellIdentifier = @"defaultCellId";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell==nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.accessoryView = nil;
    }
    
    NSArray *sectionArr = _titles[indexPath.section];
    cell.textLabel.text = sectionArr[indexPath.row];
    cell.textLabel.font = kYMNormalFont;
    cell.textLabel.textColor = [UIColor blackColor];
    
    
    
    if(indexPath.section==0){
        switch (indexPath.row) {
            case 0:
                cell.accessoryView = nil;
                break;
            case 1:
                if(_calcLocalWaitingView==nil){
                    _calcLocalWaitingView=[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
                }
                cell.accessoryView=_calcLocalWaitingView;
                if(_localBufferSizeTitle==nil||_localBufferSizeTitle.length<2){
                    [_calcLocalWaitingView startAnimating];
                    cell.detailTextLabel.text=@" ";
                    cell.accessoryType=UITableViewCellAccessoryDisclosureIndicator;
                }else {
                    cell.detailTextLabel.text=_localBufferSizeTitle;
                    cell.accessoryView=nil;
                }
                break;
            default:
                break;
        }
    }else if(indexPath.section==1) {
        switch (indexPath.row) {
            case 0:
                cell.accessoryView = nil;
                break;
            case 1:
            {
                NSDictionary* infoDict =[[NSBundle mainBundle] infoDictionary];
                NSString* version=[infoDict objectForKey:@"CFBundleShortVersionString"];
                cell.detailTextLabel.text=version;
                cell.accessoryView=nil;
            }
                break;
            default:
                break;
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==1) {
        if (indexPath.row==0) {
            YMResetPwdViewController *resetpwdVC = [[YMResetPwdViewController alloc] init];
            [self.navigationController pushViewController:resetpwdVC animated:YES];
        }
    }
}

//
//-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    if(indexPath.section==0){
//        if(indexPath.row==3||indexPath.row==4){
//            _netCheckController=[[HTNetCheckViewController alloc] init];
//            _netCheckController.checkTrade=indexPath.row==3;
//            [_netCheckController setHidesBottomBarWhenPushed:YES];
//            [self.navigationController pushViewController:_netCheckController animated:YES];
//            return;
//        }else if(indexPath.row==kHTLocalQuoteBufCellIndex){
//            showConfirmTagAlert(@"温馨提示",@"确认清除行情缓存数据吗？", self, kHTLocalQuoteBufRemoveTag);
//        }else if(indexPath.row==kHTLocalRegistBufCellIndex){
//            if([HTTradeDataManager sharedData].registered){
//                if([HTTradeDataManager sharedData].logined){
//                    showConfirmAlert(@"温馨提示", @"当前已登录交易，确认退出交易，注销用户所有信息吗？", self);
//                }else {
//                    showConfirmAlert(@"温馨提示", @"确认注销用户所有信息吗？", self);
//                }
//            }
//        }
//        return;
//    }else if(indexPath.section==1){
//        if(indexPath.row==0){
//            //风险揭示
//        }else if(indexPath.row==1){
//        }else if(indexPath.row==2){
//            //版本升级
//            //            if(g_strNewVersion){
//            //                [[HTNetManager sharedNet] showUpgradeAlert:g_strNewVersion msg:g_strNewVersionAlert force:g_newVersiontType==kTK_VERSION_UPGRADE_FORCE];
//            //            }else {
//            //                g_newVersionHide=NO;
//            //                g_checkNewVersion=YES;
//            //                [[HTNetManager sharedNet] loadSiteList:YES];
//            //            }
//            //            return;
//        }
//    }else if(indexPath.section==2){
//        if(indexPath.row==0){
//            //#ifdef kHTUse_SNS_SHARE
//            //            //分享到朋友圈或分享给好友
//            //            if([WXApi isWXAppInstalled]){
//            //                if(g_nOSVersion>=6){
//            //                    NSArray* activity = @[[[WeixinSessionActivity alloc] init], [[WeixinTimelineActivity alloc] init]];
//            //                    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:@[@"分享e海通财", [UIImage imageNamed:@"Icon.png"],[NSURL URLWithString:@"https://itunes.apple.com/us/app/e-hai-tong-cai/id1021519341"]] applicationActivities:activity];
//            //                    activityView.excludedActivityTypes = nil;//@[UIActivityTypeAssignToContact, UIActivityTypeCopyToPasteboard, UIActivityTypePrint];
//            //                    [self presentViewController:activityView animated:YES completion:nil];
//            //                }else {
//            //                    UIActionSheet* actionSheet=[[UIActionSheet alloc] initWithTitle:@"分享到微信" delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"分享给好友",@"分享到朋友圈", nil];
//            //                    [actionSheet showInView:self.view];
//            //                }
//            //            }else {
//            //                showAlert(@"未安装微信，无法分享");
//            //            }
//            //#endif
//        }
//        return;
//    }
//    [super tableView:tableView didSelectRowAtIndexPath:indexPath];
//}

- (void)switchChanged:(UISwitch *)sender
{
    //
}

@end
