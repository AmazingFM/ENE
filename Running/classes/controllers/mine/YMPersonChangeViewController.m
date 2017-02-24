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
    item8.title = @"我已阅读并接受 版权声明 和 隐私保护 条款";
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
                     NSRange boldRange = [[mutableAttributedString string] rangeOfString:@"版权声明" options:NSCaseInsensitiveSearch];
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
            NSRange range1= [detailLabel.text rangeOfString:@"版权声明"];
            NSString* path = @"authority";//[[NSBundle mainBundle] pathForResource:@"软件许可及服务协议" ofType:@"html"];
            NSURL* url = [NSURL fileURLWithPath:path];
            [detailLabel addLinkToURL:url withRange:range1];
            
            NSRange range2= [detailLabel.text rangeOfString:@"隐私保护"];
            path = @"privacy";//[[NSBundle mainBundle] pathForResource:@"会员服务协议" ofType:@"html"];
            url = [NSURL fileURLWithPath:path];
            [detailLabel addLinkToURL:url withRange:range2];
        }
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (void)attributedLabel:(__unused TTTAttributedLabel *)label
   didSelectLinkWithURL:(NSURL *)url
{
    NSString *title = nil;
    NSString *msgContent = @"基金定期定额申购(以下简称“基金定投”)是指投资者委托海通证券(以下简称“我公司”)，以约定时间、约定金额、约定基金按照基金公司业务规则定期定额申购相应基金，并从投资者客户交易结算资金账户中扣取相应申购款的一种长期投资方式。\n"
    "一、 基金定投业务办理时间\n"
    "基金定投签约、解约及变更业务办理时间为上海、深圳证券交易所交易日的9:30-15:00。\n"
    "二、 基金定投业务签约\n"
    "投资者通过营业部柜台方式申请办理基金定投业务的签约。投资者应确保在我公司资金账户中已成功开立开放式基金账户，并已完成《风险承受能力测评问卷》。\n\n"
    "三、 基金定投业务的要素\n"
    "1、 定投的基金产品\n"
    "投资者申请的定投基金品种仅限于已公告我公司可开通基金定投业务的基金产品。\n"
    "2、 最低金额\n"
    "投资者选择的基金定投扣款金额应大于或等于基金定投产品日最低金额。若我公司对基金产品最低定投金额有明确规定的，以我公司为准；若我公司无明确规定的，以基金公司为准。\n"
    "3、 基金定投周期\n"
    "投资者可以选择按三个月、二个月和一个月进行基金定投。\n";
    
    
    NSString *hrefStr = url.absoluteString;
    if ([hrefStr rangeOfString:@"authority"].location!=NSNotFound) {
        title = @"版权声明";
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
//- (BOOL)getParameters
//{
////    [super getParameters];
//    
//    NSMutableDictionary *parameters = [NSMutableDictionary new];
//    parameters[kYM_USERID] = [YMUserManager sharedInstance].user.user_id;
//    return YES;
//}

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
