//
//  YMPersonCenterViewController.m
//  Running
//
//  Created by freshment on 16/9/28.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMPersonChangeViewController.h"

#import "YMUserManager.h"

#import "TTTAttributedLabel.h"

#import "YMCell.h"

#define kRegisterReadMeFont [UIFont systemFontOfSize:14]

@interface YMPersonChangeViewController () <UITableViewDelegate, UITableViewDataSource,UITextFieldDelegate, YMBaseCellDelegate, TTTAttributedLabelDelegate,UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIActionSheetDelegate>
{
    UITableView *_mainTableView;
    float rowHeight;
    NSArray *dataArr;
    NSArray *itemlist;
    
    UIButton *_verifyBtn;
    BOOL _hasRead;
    
    UIActivityIndicatorView *indicator;
}
@end

@implementation YMPersonChangeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.navigationItem.title = @"修改信息";
    self.navigationItem.leftBarButtonItem = createBarItemIcon(@"nav_back",self, @selector(back));
    
    self.view.backgroundColor = rgba(247, 247, 247, 1.0);
    
    indicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    indicator.center = CGPointMake(self.view.frame.size.width * 0.5, self.view.frame.size.height * 0.5);
    [self.view addSubview:indicator];
    
    rowHeight = 44.f;
    
    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(kYMBorderMargin, kYMTopBarHeight, g_screenWidth-2*kYMBorderMargin, g_screenHeight-kYMNavigationBarHeight-kYMTopBarHeight) style:UITableViewStylePlain];
    _mainTableView.backgroundColor = [UIColor clearColor];
    _mainTableView.separatorStyle=UITableViewCellSeparatorStyleSingleLine;
    _mainTableView.separatorColor = [UIColor lightGrayColor];
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.scrollEnabled = NO;
    _mainTableView.delegate=self;
    _mainTableView.dataSource=self;
    
    _mainTableView.tableFooterView = [[UIView alloc] init];
    if([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    //设置成NO表示当前控件响应后会传播到其他控件上，默认为YES。
    tapGestureRecognizer.cancelsTouchesInView = NO;
    //将触摸事件添加到当前view
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    [self.view addSubview:_mainTableView];

    YMImageCellItem *item1=[[YMImageCellItem alloc] init];
    item1.title = @"头像";
    item1.key = @"user_icon";
    item1.anchor = NSTextAlignmentRight;
    
    YMFieldCellItem *item2=[[YMFieldCellItem alloc] init];
    item2.title = @"姓名";
    item2.key = @"true_name";
    item2.actionLen = 20;
    item2.fieldType = YMFieldTypeCharater;
    item2.anchor = NSTextAlignmentRight;
    item2.showClear = NO;
    
    YMFieldCellItem *item3=[[YMFieldCellItem alloc] init];
    item3.title = @"昵称";
    item3.key = @"nick_name";
    item3.actionLen = 40;
    item3.fieldType = YMFieldTypeCharater;
    item3.anchor = NSTextAlignmentRight;
    item3.showClear = NO;
    
    YMDateCellItem *item4=[[YMDateCellItem alloc] init];
    item4.title = @"生日";
    item4.key = @"birthday";
    
    YMRadioCellItem *item5=[[YMRadioCellItem alloc] init];
    item5.title = @"性别";
    item5.key = @"sexual";
    item5.value = @"-1";
    item5.titleItems = @[@"男", @"女"];
    
    YMBaseCellItem *item6=[[YMBaseCellItem alloc] init];
    item6.title = @"邀请码";
    item6.key = kYM_REMARKCODE;

    NSArray *section1 = @[item1, item2, item3, item4, item5, item6];
    
    YMBaseCellItem *item7=[[YMBaseCellItem alloc] init];
    item7.title = @"确定";
    item7.key = @"submit";
    NSArray *section2 = @[item7];
    
    YMBaseCellItem *item8=[[YMBaseCellItem alloc] init];
//    item8.title = @"我已阅读并接受 版权声明 和 隐私保护 条款";
    item8.title = @"我已阅读并接受 版权声明和隐私保护 条款";
    item8.key = @"readme";
    
    NSArray *section3 = @[item8];
    
    itemlist = @[item1,item2,item3,item4,item5,item6,item7,item8];
    dataArr = @[section1, section2, section3];
    [self startGetInfo];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

-(void)keyboardHide:(UITapGestureRecognizer*)tap{
    [self.view endEditing:YES];
}

#pragma mark UITableViewDelegate UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 20;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.backgroundColor = [UIColor clearColor];
    return view;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==2) {
        if([cell respondsToSelector:@selector(setSeparatorInset:)]){
            [cell setSeparatorInset:UIEdgeInsetsMake(0,0,0,cell.bounds.size.width)];
        }
        if([cell respondsToSelector:@selector(setLayoutMargins:)]){
            [cell setLayoutMargins:UIEdgeInsetsMake(0,0,0,cell.bounds.size.width)];
        }
        return;
    }
    if([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *arr = dataArr[section];
    return arr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = dataArr[indexPath.section];
    YMBaseCellItem *item = arr[indexPath.row];
    item.indexPath = indexPath;
    
    YMRoundCornerCell *cell;
    if ([item isKindOfClass:[YMFieldCellItem class]]) {
        cell = [YMRCFieldCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"defaultCellId"] ;
        cell.delegate = self;
        [cell setItem:item];
    } else if ([item isKindOfClass:[YMRadioCellItem class]]) {
        cell = [YMRCRadioCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"radioCellId"] ;
        cell.delegate = self;
        [cell setItem:item];

    } else if([item isKindOfClass:[YMDateCellItem class]]) {
        cell = [YMRCDateCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"dateCellId"] ;
        cell.delegate = self;
        [cell setItem:item];
    } else if ([item isKindOfClass:[YMImageCellItem class]]) {
        cell = [YMRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"imageCellId"];
        
        YMImageCellItem *imageItem = (YMImageCellItem *)item;
        UIImageView *headImgV = (UIImageView *)[cell viewWithTag:1000];
        if (headImgV==nil) {
            CGFloat width = 40.f;
            headImgV = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,width, width)];
            headImgV.layer.cornerRadius = width/2;
            headImgV.contentMode = UIViewContentModeScaleAspectFill;
            headImgV.layer.masksToBounds = YES;
            headImgV.tag = 1000;
            
            CGSize size = [YMUtil sizeWithFont:@"确认密码" withFont:kYMNormalFont];
            if (imageItem.anchor == NSTextAlignmentRight) {
                headImgV.center = CGPointMake(g_screenWidth-3*kYMBorderMargin-width/2, 44.f/2);
            } else {
                headImgV.center = CGPointMake(size.width+30+width/2, 44.f/2);
            }

            [cell addSubview:headImgV];
        }
        
        if (imageItem.value!=nil && imageItem.value.length!=0) {
            NSData *decodeImgData = [[NSData alloc] initWithBase64EncodedString:imageItem.value options:NSDataBase64DecodingIgnoreUnknownCharacters];
            UIImage *detailImg = [UIImage imageWithData:decodeImgData];
            headImgV.image = detailImg;
        } else if (imageItem.value!=nil) {
            headImgV.image = [UIImage imageNamed:@"defaultHead"];
        }
        
        cell.textLabel.font = kYMNormalFont;
        cell.textLabel.text = item.title;
        [cell setItem:item];
    } else {
        if ([item.key isEqualToString:@"remark_code"]) {
            cell = [YMRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"remarkCodeidentifier"] ;
            cell.backgroundColor = rgba(221, 221, 221, 1);
            
            UILabel *detailLabel = (UILabel *)cell.accessoryView;
            if (detailLabel==nil) {
                detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,g_screenWidth/2,44)];
                detailLabel.backgroundColor = [UIColor clearColor];
                detailLabel.textAlignment = NSTextAlignmentRight;
                detailLabel.font = kYMBigFont;
                detailLabel.textColor = rgba(150, 150, 150, 1);
                cell.accessoryView = detailLabel;
            }
            cell.textLabel.font = kYMNormalFont;
            cell.textLabel.text = item.title;
        
            if (item.value!=nil) {
                detailLabel.text = item.value;
            }
        } else if ([item.key isEqualToString:@"submit"]) {
            cell = [YMRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"btnidentifier"] ;
            
            UIButton *btn = [cell viewWithTag:1100];
            if (btn==nil) {
                btn = [UIButton buttonWithType:UIButtonTypeCustom];
                btn.tag = 1100;
                btn.frame = CGRectMake(0,0,g_screenWidth-2*kYMBorderMargin,44);
                btn.backgroundColor = [YMUtil colorWithHex:0xffcc02];
                [btn setTitle:item.title forState:UIControlStateNormal];
                btn.titleLabel.font = kYMBigFont;
                [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [btn setCornerRadius:5.0f];
                [cell.contentView addSubview:btn];
            }
            [btn setTitle:item.title forState:UIControlStateNormal];
        } else if ([item.key isEqualToString:@"readme"]) {
            cell = [YMRoundCornerCell cellWithTableView:tableView style:UITableViewCellStyleValue1 radius:5.0f indexPath:indexPath strokeLineWidth:0.0f strokeColor:[UIColor lightGrayColor] cellIdentifier:@"readmeidentifier"] ;
            
            
            cell.backgroundView = nil;
            cell.backgroundColor = [UIColor clearColor];
            cell.contentView.backgroundColor = [UIColor clearColor];
            
            UIButton *checkBtn = [cell viewWithTag:1200];
            if (checkBtn==nil) {
                checkBtn = [UIButton buttonWithType:UIButtonTypeCustom];
                checkBtn.tag = 1200;
                checkBtn.frame = CGRectMake(5,12,20,20);
                [checkBtn setContentMode:UIViewContentModeScaleAspectFit];
                [checkBtn setImage:[UIImage imageNamed:@"icon_box_nonselect.png"] forState:UIControlStateNormal];
                [checkBtn setImage:[UIImage imageNamed:@"icon_box_select.png"] forState:UIControlStateSelected];
                
                [checkBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
                [cell.contentView addSubview:checkBtn];
            }
            
            TTTAttributedLabel *detailLabel = [cell viewWithTag:1201];
            if (detailLabel==nil) {
                detailLabel = [[TTTAttributedLabel alloc] initWithFrame:CGRectMake(30, 0, g_screenWidth-2*kYMBorderMargin-34, 44)];
                detailLabel.tag = 1201;
                detailLabel.delegate = self;
                detailLabel.font = kRegisterReadMeFont;
                detailLabel.textAlignment = NSTextAlignmentLeft;
                detailLabel.textColor = rgba(128, 128, 128, 1.f);
                detailLabel.backgroundColor = [UIColor clearColor];
                detailLabel.lineBreakMode = NSLineBreakByWordWrapping;
                detailLabel.numberOfLines = 0;
                
                [detailLabel setText:item.title afterInheritingLabelAttributesAndConfiguringWithBlock:^ NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString)
                 {
                     //注销划线
                     NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"版权声明和" options:NSCaseInsensitiveSearch];
                     NSRange strikeRange = [[mutableAttributedString string] rangeOfString:@"隐私保护" options:NSCaseInsensitiveSearch];
                     
                     // Core Text APIs use C functions without a direct bridge to UIFont. See Apple's "Core Text Programming Guide" to learn how to configure string attributes.
                     UIFont *boldSystemFont = [UIFont systemFontOfSize:14];
                     
                     CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
                     if (font) {
                         //字体
                         [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:boldRange];
                         [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)font range:strikeRange];
                         //                     [mutableAttributedString addAttribute:kTTTStrikeOutAttributeName value:@YES range:strikeRange];
                         //下划线
                         [mutableAttributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]  range:boldRange];
                         [mutableAttributedString addAttribute:(NSString *)kCTUnderlineStyleAttributeName value:[NSNumber numberWithInt:kCTUnderlineStyleSingle]  range:strikeRange];
                         //颜色
                         [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:boldRange];
                         [mutableAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:strikeRange];
                         CFRelease(font);
                     }
                     return mutableAttributedString;
                 }];
                
                [cell.contentView addSubview:detailLabel];
            }
            
            UIFont *boldSystemFont = [UIFont systemFontOfSize:14];
            CTFontRef font = CTFontCreateWithName((__bridge CFStringRef)boldSystemFont.fontName, boldSystemFont.pointSize, NULL);
            //添加点击事件
            detailLabel.enabledTextCheckingTypes = NSTextCheckingTypeLink;
            detailLabel.delegate = self;
            detailLabel.linkAttributes = @{(NSString *)kCTFontAttributeName:(__bridge id)font,(id)kCTForegroundColorAttributeName:[UIColor blueColor]};//NSForegroundColorAttributeName  不能改变颜色 必须用   (id)kCTForegroundColorAttributeName,此段代码必须在前设置
//            NSRange range1= [detailLabel.text rangeOfString:@"版权声明"];
            NSRange range1= [detailLabel.text rangeOfString:@"版权声明和隐私保护"];
            NSString* path = @"authority";//[[NSBundle mainBundle] pathForResource:@"软件许可及服务协议" ofType:@"html"];
            NSURL* url = [NSURL fileURLWithPath:path];
            [detailLabel addLinkToURL:url withRange:range1];
            
//            NSRange range2= [detailLabel.text rangeOfString:@"隐私保护"];
//            path = @"privacy";//[[NSBundle mainBundle] pathForResource:@"会员服务协议" ofType:@"html"];
//            url = [NSURL fileURLWithPath:path];
//            [detailLabel addLinkToURL:url withRange:range2];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    NSString *title = nil;
    NSString *msgContent = @"重要须知：上海铂登实业有限公司电商平台“长生汇”一贯重视用户的个人信息及隐私的保护，在您使用长生汇的服务和/或在长生汇购物的时候，长生汇有可能会收集和使用您的个人信息及隐私。为此，长生汇通过本《长生汇用户个人信息及隐私保护政策》（以下简称“本《隐私政策》”）向您说明您在使用长生汇的服务和/或在长生汇购物时，长生汇是如何收集、存储、使用和分享这些信息的，以及长生汇向您提供的访问、更新、控制和保护这些信息的方式。\n"
    "本《隐私政策》与您使用长生汇的服务、在长生汇购物息息相关，请您务必仔细阅读、充分理解（未成年人应当在其监护人的陪同下阅读），包括但不限于免除或者限制长生汇责任的条款。\n"
    "您如果使用或者继续使用长生汇的服务和/或在长生汇购物，即视为您充分理解并完全接受本《隐私政策》；您如果对本《隐私政策》有任何疑问、异议或者不能完全接受本《隐私政策》，请联系长生汇客户服务部，客户服务电话：021-23560070。\n"
    "第一条    本《隐私政策》所述的个人信息，是指个人姓名、住址、出生日期、身份证号码、银行账号、移动电话号码等单独或与其他信息对照可以设别特定的个人的信息，包括但不限于您在注册长生汇用户账号时填写并提供给长生汇的姓名、性别、生日、移动电话号码、送货地址、身高、体重。\n"
    "第二条    您承诺并保证：您主动填写或者提供给长生汇的个人信息是真实的、准确的、完整的。而且，填写或者提供给长生汇后，如果发生了变更的，您会在第一时间内，通过原有的渠道或者长生汇提供的新的渠道进行更新，以确保长生汇所获得的您的这些个人信息是最新的、真实的、准确的和完整的；否则，长生汇无须承担由此给您造成的任何损失。\n"
    "第三条    您应当重视您的个人信息的保护，您如果发现您的个人信息已经被泄露或者存在被泄露的可能，且有可能会危及您注册获得的长生汇账户安全，或者给您造成其他的损失的，您务必在第一时间通知长生汇，以便长生汇采取相应的措施确保您的长生汇账户安全，防止损失的发生或者进一步扩大；否则，长生汇无须承担由此给您造成的任何损失（及扩大的损失）。\n"
    "第四条    您充分理解并完全接受：您在使用长生汇的服务和/或在长生汇购物时，长生汇有可能会收集您的如下信息（以下统称“用户信息”）：\n"
    "（一） 第一条所述的您的个人信息；\n"
    "（二） 您提供给第三方或者向第三方披露的个人信息及隐私；\n"
    "（三） 您登录和使用长生汇网站、App的时间、时长、支付账号、购物记录、系统日志信息以及行为数据（包括但不限于订单下达及取消数据、退货退款申请数据、手机钱包账户余额、交易纠纷数据等）；\n"
    "（四） 您所使用的台式计算机、移动设备的品牌、型号、IP地址以及软件版本信息\n"
    "（五） 为了实现前述目的，通过cookie或者其他方式自动采集到的您的其他个人信息或者隐私。\n"
    "您通过具有定位功能的移动设备登录、使用长生汇的App时，长生汇有可能会通过GPS或者Wifi收集您的地理位置信息；您如果不同意收集，您在您的移动设备上关闭此项功能。\n"
    "第五条    您充分理解并完全接受：保护用户信息是长生汇一贯的政策，长生汇将会使用各种安全技术和程序存储、保护用户信息，防止其被未经授权的访问、使用、复制和泄露。长生汇不向任何第三方透漏用户信息，但存在下列任何一项情形或者为第七条所述的目的而披露给第三方的除外：\n"
    "（一） 基于国家法律法规的规定而对外披露；\n"
    "（二） 应国家司法机关及其他有法律权限的政府机关基于法定程序的要求而披露；\n"
    "（三） 为保护长生汇或您的合法权益而披露；\n"
    "（四） 在紧急情况下，为保护其他用户或者第三方人身安全而披露；\n"
    "（五） 用户本人或其监护人授权披露；\n"
    "（六） 应用户的监护人的合法要求而向其披露。\n"
    "长生汇即便是按照前款约定将用户信息披露给第三方，亦会要求接收上述用户信息的第三方严格按照国家法律法规使用和保护用户信息。\n"
    "第六条    您充分理解并完全接受：即便是长生汇采取各种安全技术和程序存储、保护用户信息，防止其被未经授权的访问、使用、复制和泄露，但用户信息仍然有可能发生被黑客攻击、窃取，因不可抗力或者其他非长生汇的自身原因而被泄露的情形。对此，只要是长生汇采取了必要的措施防止上述情形之发生，并在上述情形发生之后采取必要的措施防止其损失进一步扩大，长生汇则无须赔偿由此给您造成的任何损失。\n"
    "第七条    您充分理解并完全接受：长生汇有可能将用户信息用于下列某一个或者某几个目的：\n"
    "（一）在您登录长生汇网站或者App时，用于验证您的身份、供您支付货款、为您提供送货服务、售后服务以及其他客户服务；\n"
    "（二）帮助长生汇分析、了解用户需求，设计新的商业模式，向您及其他用户推荐新的商品，或者将其用于长生汇所开展的新业务当中；\n"
    "（三）评估和改进长生汇服务中的广告和其他促销及推广活动。\n";
    
    NSString *hrefStr = url.absoluteString;
    if ([hrefStr rangeOfString:@"authority"].location!=NSNotFound) {
        title = @"版权声明和隐私保护";//@"版权声明";
    } else if ([hrefStr rangeOfString:@"privacy"].location!=NSNotFound) {
        title = @"隐私保护";
    }
    showDefaultAlert(title, msgContent);
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return dataArr.count;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section==0 && indexPath.row==0) {
        [self openMenu];
    }
    if (indexPath.section==2) {
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        UIButton *checkBtn = [cell viewWithTag:1200];
        if (checkBtn!=nil) {
            checkBtn.selected = !checkBtn.isSelected;
            _hasRead = checkBtn.isSelected;
        }
    }
}

#pragma mark take photo methods
- (void)openMenu
{
    if (g_nOSVersion>=8.0) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
            NSLog(@"取消");
        }];
        [alertController addAction:action];
        
        [alertController addAction:({
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"从手机相册中获取" style:UIAlertActionStyleDefault  handler:^(UIAlertAction *action) {
                NSLog(@"从手机相册中获取");
                [self localPhoto];
            }];
            action;
        })];
        
        [alertController addAction:({
            UIAlertAction *action = [UIAlertAction actionWithTitle:@"打开照相机" style:UIAlertActionStyleDefault  handler:^(UIAlertAction *action) {
                NSLog(@"打开照相机");
                [self takePhoto];
            }];
            action;
        })];
        
        [self presentViewController:alertController animated:YES completion:nil];
    } else {
        UIActionSheet *menuSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"从手机相册中获取", @"打开照相机", nil];
        menuSheet.actionSheetStyle = UIActionSheetStyleDefault;
        [menuSheet showInView:self.view];
    }
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==0) {
        [self localPhoto];
    } else if (buttonIndex==1) {
        [self takePhoto];
    }
}
//开始拍照
- (void)takePhoto
{
    UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
    if ([UIImagePickerController isSourceTypeAvailable:sourceType]) {
        UIImagePickerController *picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        //设置拍照后的图片可被编辑
        picker.allowsEditing = YES;
        picker.sourceType = sourceType;
        [self presentViewController:picker animated:YES completion:nil];
    } else
    {
        NSLog(@"模拟器无法打开照相机");
    }
}
//打开本地相册
- (void)localPhoto
{
    UIImagePickerController *picker = [[UIImagePickerController alloc]init];
    picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    picker.delegate = self;
    //设置选择后的图片可被编辑
    picker.allowsEditing = YES;
    [self presentViewController:picker animated:YES completion:nil];
}

//当选择一张图片后进入处理
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    NSString *type = [info objectForKey:UIImagePickerControllerMediaType];
    //当选择的类型是图片
    if ([type isEqualToString:@"public.image"]) {
        //先把图片转成NSData
        UIImage *image = [info objectForKey:@"UIImagePickerControllerOriginalImage"];
        image = [YMUtil fixOrientation:image];
        
        CGSize imgSize = [image size];
        CGFloat kWidth = imgSize.width<imgSize.height?imgSize.width:imgSize.height;
        UIImage *cutImage = [YMUtil cutImage:image withSize:CGSizeMake(kWidth, kWidth)];
        
        NSUInteger maxFileSize = 50*1024;
        CGFloat compressionRatio = 0.7f;
        CGFloat maxCompressionRatio = 0.1f;

        cutImage = [YMUtil image:cutImage scaledToSize:CGSizeMake(80, 80)];
        
        NSData *imageData = UIImageJPEGRepresentation(cutImage, compressionRatio);
        
        while (imageData.length > maxFileSize && compressionRatio > maxCompressionRatio) {
            compressionRatio -= 0.1f;
            imageData = UIImageJPEGRepresentation(image, compressionRatio);
        }
    
        //关闭相册界面
        [picker dismissViewControllerAnimated:YES completion:nil];
        
        for (YMBaseCellItem *cellItem in itemlist) {
            if ([cellItem.key isEqualToString:@"user_icon"]) {
                cellItem.value = [imageData base64EncodedStringWithOptions:0];
                [_mainTableView reloadRowsAtIndexPaths:@[cellItem.indexPath] withRowAnimation:UITableViewRowAnimationFade];
                break;
            }
        }
    }
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"您取消了选择图片");
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)btnClick:(UIButton *)sender
{
    //
    if (sender.tag==1100) { //submit
        [self updateUserInfo];
        
    } else if (sender.tag==1200) {
        //
        [sender setSelected:!sender.isSelected];
        _hasRead = sender.isSelected;
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

#pragma mark -cell delegate
-(void)viewValueChanged:(NSString *)value withIndexPath:(NSIndexPath*)indexPath
{
    NSArray *arr = dataArr[indexPath.section];
    YMBaseCellItem *cellitem = arr[indexPath.row];
    
    NSString *className = NSStringFromClass([cellitem class]);
    if ([className isEqualToString:@"YMFieldCellItem"]) {
        YMFieldCellItem *item = (YMFieldCellItem *)cellitem;
        item.value = value;
    }
    if ([className isEqualToString:@"YMDateCellItem"]) {
        YMDateCellItem *item = (YMDateCellItem *)cellitem;
        item.value = value;
    }
}

- (void)radioButtonSelect:(int)index withIndexPath:(NSIndexPath *)indexPath
{
    NSArray *arr = dataArr[indexPath.section];
    YMRadioCellItem *item = arr[indexPath.row];
    item.value = [NSString stringWithFormat:@"%d", index];
}

#pragma mark 网络请求
- (void)startGetInfo
{
    [indicator startAnimating];
    
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
    parameters[@"qry_usr_id"] = [YMUserManager sharedInstance].user.user_id;
    
    BOOL networkStatus = [PPNetworkHelper currentNetworkStatus];
    if (!networkStatus) {
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        return;
    }
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserQuery"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
        });
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                YMUser *model = [YMUser objectWithKeyValues:respDict[kYM_RESPDATA]];
                for (YMBaseCellItem *item in itemlist) {
                    if ([item.key isEqualToString:@"submit"]||[item.key isEqualToString:@"readme"]) {
                        continue;
                    }
                    item.value = [model valueForKey:item.key];
                }
                [_mainTableView reloadData];
                
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
        });
    }];
}

- (void)updateUserInfo
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;

    
    BOOL networkStatus = [PPNetworkHelper currentNetworkStatus];
    if (!networkStatus) {
        showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        return;
    }
    
    if (!_hasRead) {
        showDefaultAlert(@"提示",@"请阅读并接受相关服务条款");
        return;
    }
    
    [indicator startAnimating];
    
    for (YMBaseCellItem *item in itemlist) {
        if ([item.key isEqualToString:@"submit"]||[item.key isEqualToString:@"readme"]||[item.key isEqualToString:@"remark_code"]) {
            continue;
        }
        [parameters setObject:item.value forKey:item.key];
    }
    
    
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=UserModify"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
        });
        NSDictionary *respDict = responseObject;
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                [YMUserManager sharedInstance].user.user_icon = parameters[@"user_icon"];
                [YMUserManager sharedInstance].user.true_name = parameters[@"true_name"];
                [YMUserManager sharedInstance].user.nick_name = parameters[@"nick_name"];
                [YMUserManager sharedInstance].user.birthday  = parameters[@"birthday"];
                [YMUserManager sharedInstance].user.sexual    = parameters[@"sexual"];
                [self showTextHUDView:@"个人资料更新成功"];
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [indicator stopAnimating];
        });
    }];
}



@end
