//
//  YMShoppingCartViewController.m
//  Running
//
//  Created by 张永明 on 16/8/31.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMShoppingCartViewController.h"
#import "YMOrderGenerateViewController.h"
#import "YMGoodsDetailController.h"

#import "YMChangeCountView.h"

#import "YMUtil.h"

#define kYMShoppingCartTag 1000

#define kYMCartTitleFont [UIFont systemFontOfSize:13]
#define kYMCartDetailFont [UIFont systemFontOfSize:11]
#define kYMCartPriceFont [UIFont systemFontOfSize:14]

#define kBtnWidth 30.f
#define kChangCountViewWidth 75.f
#define kChangCountViewHeight 21.f

@interface YMCartCell() <UITextFieldDelegate, UIAlertViewDelegate>
{
    UIButton *_selectBtn;
    UIImageView *goodImage;
    UILabel *_titleLabel;
    UILabel *_detailLabel;
    UILabel *_priceLabel;
    UILabel *_countLabel;
    YMChangeCountView *_changeCountView;
    
    UIButton *_deleteButton;
    UIButton *_cartButton;
}
@end

@implementation YMCartCell

- (void)prepareForReuse
{
    [super prepareForReuse];
    [_changeCountView removeFromSuperview];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.type = 0;
        
        UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
        header.backgroundColor = rgba(242, 242, 242, 1);
        header.tag = 100;
        
        _selectBtn = [[UIButton alloc] initWithFrame:CGRectZero];
        _selectBtn.tag = kYMShoppingCartTag;
        [_selectBtn setImage:[UIImage imageNamed:@"Unselected.png"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateSelected];
        [_selectBtn setContentMode:UIViewContentModeScaleToFill];
        [_selectBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        goodImage = [[UIImageView alloc] initWithFrame:CGRectZero];
        goodImage.contentMode = UIViewContentModeScaleToFill;
        goodImage.userInteractionEnabled = NO;
        goodImage.backgroundColor = [UIColor clearColor];
        goodImage.layer.borderWidth = 0.1f;
        goodImage.layer.borderColor = [UIColor lightGrayColor].CGColor;
        
        _titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.font = kYMCartTitleFont;
        _titleLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _titleLabel.textColor = [UIColor blackColor];
        
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _detailLabel.backgroundColor = [UIColor clearColor];
        _detailLabel.font = kYMCartDetailFont;
        _detailLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        _detailLabel.textColor = [UIColor grayColor];
        
        _priceLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _priceLabel.backgroundColor = [UIColor clearColor];
        _priceLabel.font = kYMCartPriceFont;
        _priceLabel.textColor = [UIColor redColor];
        
        _countLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _countLabel.backgroundColor = [UIColor clearColor];
        _countLabel.font = kYMCartTitleFont;
        _countLabel.textAlignment = NSTextAlignmentRight;
        _countLabel.textColor = [UIColor blackColor];
        
        _deleteButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteButton.backgroundColor = [UIColor clearColor];
        [_deleteButton setImage:[UIImage imageNamed:@"collect_del"] forState:UIControlStateNormal];
        _deleteButton.tag = kYMShoppingCartTag+100;
        _deleteButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_deleteButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cartButton.backgroundColor = [UIColor clearColor];
        [_cartButton setImage:[UIImage imageNamed:@"collect_cart"] forState:UIControlStateNormal];
        [_cartButton setImage:[UIImage imageNamed:@"collect_cart_sel"] forState:UIControlStateSelected];
        _cartButton.tag = kYMShoppingCartTag+101;
        _cartButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
        [_cartButton addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        [self addSubview:header];
        [self addSubview:_selectBtn];
        [self addSubview:goodImage];
        [self addSubview:_titleLabel];
        [self addSubview:_detailLabel];
        [self addSubview:_priceLabel];
        [self addSubview:_countLabel];
        [self addSubview:_deleteButton];
        [self addSubview:_cartButton];
    }
    return self;
}

- (void)setItem:(YMShoppingCartItem *)item
{
    _item = item;
    self.choosedCount =[item.count integerValue] ;

    CGSize size = item.size;
    
    float offsetx = 0;
    float offsety = 0;
    
    UIView *header = [self viewWithTag:100];
    header.frame = CGRectMake(0,0,size.width,10);
    
    offsety +=10;
    
    if (self.type==0 || self.type==2) {//购物车及编辑
        _selectBtn.hidden = NO;
        _selectBtn.frame = CGRectMake(offsetx+kYMBorderMargin,offsety+kYMPadding,kBtnWidth,kBtnWidth);
        _selectBtn.centerY = (size.height+offsety)/2;
        _selectBtn.selected = item.selected;
        
        if (self.type==0) {
            _countLabel.hidden = YES;
        } else if (self.type==2) {
            _countLabel.hidden = NO;
        }
        _deleteButton.hidden = YES;
        _cartButton.hidden = YES;

        offsetx += kBtnWidth+kYMBorderMargin;
    } else if (self.type==1){//填写订单页面
        _selectBtn.hidden = YES;
        _countLabel.hidden = NO;
        _deleteButton.hidden = YES;
        _cartButton.hidden = YES;

        offsetx = 0;
    } else if (self.type==3) {//我的收藏
        //
        _selectBtn.hidden = YES;
        _countLabel.hidden = YES;
        
        _deleteButton.hidden = NO;
        _cartButton.hidden = NO;
        _cartButton.selected = item.isInCart;
    }
    
    goodImage.frame = CGRectMake(offsetx+kYMPadding, offsety+kYMPadding, size.height-2*kYMPadding, size.height-2*kYMPadding-offsety);
    
    NSString *imageUrl = item.goods.goods_image1;
    [goodImage sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:[UIImage imageNamed:@"default"]];    
    
    offsetx = CGRectGetMaxX(goodImage.frame);
    
    CGSize titleSize =[YMUtil sizeWithFont:@"ENE RGETICA" withFont:kYMCartTitleFont];
    _titleLabel.frame = CGRectMake(offsetx+kYMPadding, offsety+kYMPadding, size.width-offsetx-kYMPadding, titleSize.height);
    _titleLabel.text = _item.goods.goods_name;
    
    offsety+=titleSize.height+kYMPadding;
    CGSize detailSize =[YMUtil sizeWithFont:@"规格分类，13试用装" withFont:kYMCartDetailFont];
    _detailLabel.frame = CGRectMake(offsetx+kYMPadding, offsety+kYMPadding, size.width-offsetx-kYMPadding, detailSize.height);
    _detailLabel.text = @"规格分类，13试用装";
    
    CGSize priceSize =[YMUtil sizeWithFont:[NSString stringWithFormat:@"￥%@", _item.goods.price] withFont:kYMCartPriceFont];
    _priceLabel.frame = CGRectMake(offsetx+kYMPadding, size.height-kYMPadding-priceSize.height, priceSize.width, priceSize.height);
    _priceLabel.text =[NSString stringWithFormat:@"￥%@", _item.goods.price];
    
    _countLabel.text = [NSString stringWithFormat:@"x%@", item.count];
    _countLabel.frame = CGRectMake(size.width-kYMBorderMargin-kChangCountViewWidth, size.height-kYMPadding-kChangCountViewHeight, kChangCountViewWidth, kChangCountViewHeight);
    
    _cartButton.frame =  CGRectMake(size.width-kYMBorderMargin-30, size.height-kYMPadding-30, 30, 30);
    _deleteButton.frame = CGRectMake(size.width-kYMBorderMargin-30-50, size.height-kYMPadding-30, 30, 30);
    
    if (self.type==0) {
        _changeCountView = [[YMChangeCountView alloc] initWithFrame:CGRectMake(size.width-kYMBorderMargin-kChangCountViewWidth, size.height-kYMPadding-kChangCountViewHeight, kChangCountViewWidth, kChangCountViewHeight) chooseCount:self.choosedCount totalCount: [item.goods.store_count integerValue]];
        
        [_changeCountView.subButton addTarget:self action:@selector(subButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        
        _changeCountView.numberFD.delegate = self;
        
        [_changeCountView.addButton addTarget:self action:@selector(addButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_changeCountView];
    }
}

//加
- (void)addButtonPressed:(id)sender
{
    
    if (self.choosedCount<99) {
        [self addCar];
    }
    
    ++self.choosedCount ;
    if (self.choosedCount>0) {
        _changeCountView.subButton.enabled=YES;
    }
    
    
    if ([_item.goods.store_count integerValue]<self.choosedCount) {
        self.choosedCount  = [_item.goods.store_count  intValue];
        _changeCountView.addButton.enabled = NO;
    }
    else
    {
        _changeCountView.subButton.enabled = YES;
    }
    
    if(self.choosedCount>=99)
    {
        self.choosedCount  = 99;
        _changeCountView.addButton.enabled = NO;
    }
    
    _changeCountView.numberFD.text=[NSString stringWithFormat:@"%zi",self.choosedCount];

    //    _item.count = _changeCountView.numberFD.text;
}

//减
- (void)subButtonPressed:(id)sender
{
    
    if (self.choosedCount >1) {
        [self deleteCar];
    }
    
    -- self.choosedCount ;
    
    if (self.choosedCount==0) {
        self.choosedCount= 1;
        _changeCountView.subButton.enabled=NO;
    }
    else
    {
        _changeCountView.addButton.enabled=YES;
        
    }
    _changeCountView.numberFD.text=[NSString stringWithFormat:@"%zi",self.choosedCount];
    
//    _item.count = _changeCountView.numberFD.text;
}

- (void)addCar
{
    if ([self.delegate respondsToSelector:@selector(cellCount:withIndexPath:forType:)]) {
        [self.delegate cellCount:self withIndexPath:self.item.indexPath forType:0];
    }
}

- (void)deleteCar
{
    if ([self.delegate respondsToSelector:@selector(cellCount:withIndexPath:forType:)]) {
        [self.delegate cellCount:self withIndexPath:self.item.indexPath forType:1];
    }
}

- (void)btnClick:(UIButton *)sender
{
    if (sender.tag==kYMShoppingCartTag) {
        _item.selected = !sender.isSelected;
        [sender setSelected:_item.selected];
        
        if ([self.delegate respondsToSelector:@selector(cellButtonSelect:withIndexPath:)]) {
            [self.delegate cellButtonSelect:self withIndexPath:self.item.indexPath];
        }
    } else if (sender.tag==kYMShoppingCartTag+100) {
        UIAlertView* alert=[[UIAlertView alloc] initWithTitle:@"提示" message:@"是否取消收藏" delegate:self cancelButtonTitle:@"取消" otherButtonTitles:@"确认", nil];
        [alert show];
    } else if (sender.tag==kYMShoppingCartTag+101) {
        if ([self.delegate respondsToSelector:@selector(cellAddToCart:withIndexPath:forType:)]) {
            sender.selected = !sender.isSelected;
            [self.delegate cellAddToCart:self withIndexPath:self.item.indexPath forType:sender.selected];
        }
    }
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex==1) {
        if ([self.delegate respondsToSelector:@selector(cellDeleteGoods:withIndexPath:)]) {
            [self.delegate cellDeleteGoods:self withIndexPath:self.item.indexPath];
        }
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    _changeCountView.numberFD = textField;
    if ([self isPureInt:_changeCountView.numberFD.text]) {
        if ([_changeCountView.numberFD.text integerValue]<0) {
            _changeCountView.numberFD.text=@"1";
        }
    }
    else
    {
        _changeCountView.numberFD.text=@"1";
    }
    
    
    if ([_changeCountView.numberFD.text isEqualToString:@""] || [_changeCountView.numberFD.text isEqualToString:@"0"]) {
        self.choosedCount = 1;
        _changeCountView.numberFD.text=@"1";
        
    }
    NSString *numText = _changeCountView.numberFD.text;
    if ([numText intValue]>[_item.goods.store_count  intValue]) {
        _changeCountView.numberFD.text=[NSString stringWithFormat:@"%zi",[_item.goods.store_count intValue]];
        
        
    }
    
    if ([numText intValue] >99) {
        //  [SVProgressHUD showErrorWithStatus:@"最多支持购买99个"];
        _changeCountView.numberFD.text = @"99";
    }
    
    _changeCountView.addButton.enabled=YES;
    _changeCountView.subButton.enabled=YES;
    self.choosedCount = [_changeCountView.numberFD.text integerValue];
    _item.count = _changeCountView.numberFD.text;
    if ([self.delegate respondsToSelector:@selector(cellCount:withIndexPath:withNewValue:)]) {
        [self.delegate cellCount:self withIndexPath:self.item.indexPath withNewValue:_changeCountView.numberFD.text];
    }
}

- (BOOL)isPureInt:(NSString*)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return[scan scanInt:&val] && [scan isAtEnd];
}


@end
@interface YMShoppingCartViewController () <UITableViewDelegate, UITableViewDataSource, YMCartCellDelegate>
{
    UITableView *_mainTableView;
    
    UIImageView *_noItemImg;
    UILabel *_noItemDesc;
    
    UIButton *_allBtn;
    UIButton *_allBottomBtn;
    UIButton *_editBtn;
    UIButton *_checkBtn;
    
    float rowHeight;
    NSMutableArray *dataArr; //
    
    NSString *totalPrice;
    
    UIView *headerViewForSection;
    
    int type;
    BOOL allSelected;
}

@property (nonatomic, retain) UIView *footerViewForSection;
@property (nonatomic, retain) UIToolbar *toolbar;
@property (nonatomic, retain) UIBarButtonItem *preBarButton;

@end

@implementation YMShoppingCartViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        rowHeight = 100.f;
        totalPrice = @"0.00";
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [super viewDidLoad];
    self.navigationItem.title=@"购物车";
    self.view.backgroundColor = rgba(242, 242, 242, 1);

    _mainTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, kYMTopBarHeight, g_screenWidth, g_screenHeight-kYMTopBarHeight-kYMTabbarHeight-44) style:UITableViewStylePlain];
    _mainTableView.backgroundColor = rgba(242, 242, 242, 1);
    _mainTableView.showsVerticalScrollIndicator = NO;
    _mainTableView.showsHorizontalScrollIndicator = NO;
    _mainTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _mainTableView.bounces = YES;
    _mainTableView.delegate=self;
    _mainTableView.dataSource=self;
    _mainTableView.tableFooterView = [[UIView alloc] init];
    
    if([_mainTableView respondsToSelector:@selector(setSeparatorInset:)]){
        [_mainTableView setSeparatorInset:UIEdgeInsetsZero];
    }
    if([_mainTableView respondsToSelector:@selector(setLayoutMargins:)]){
        [_mainTableView setLayoutMargins:UIEdgeInsetsZero];
    }
    
    _noItemDesc = [[UILabel alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, 50)];
    _noItemDesc.center = self.view.center;
    _noItemDesc.text = @"暂无商品，快点去选购点吧!";
    _noItemDesc.textAlignment = NSTextAlignmentCenter;
    _noItemDesc.textColor = rgba(183, 183, 183, 1);
    _noItemDesc.font = kYMBigFont;
    
    _noItemImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"big_cart"]];
    _noItemImg.frame = CGRectMake(0, 0, g_screenWidth/4, g_screenWidth/4);
    _noItemImg.center = CGPointMake(_noItemDesc.centerX, _noItemDesc.centerY-50);
    _noItemImg.hidden = YES;
    _noItemDesc.hidden = YES;

    [self.view addSubview:_noItemDesc];
    [self.view addSubview:_noItemImg];
    
    [self.view addSubview:_mainTableView];
    
    [self.view addSubview:self.footerViewForSection];
    
    [self finishBarView];
    
    [self loadNotificationCell];
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self initItems];
}

- (void)dealloc
{
    [self removeNotificationCell];
}

- (void)finishBarView
{
    _toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0,g_screenHeight,g_screenWidth,44)];
    _toolbar.backgroundColor = [UIColor yellowColor];
    [_toolbar setBarStyle:UIBarStyleDefault];
    
    CGSize size = [YMUtil sizeWithFont:@"完成" withFont:kYMBigFont];
    UIButton *finishBtn=[UIButton buttonWithType:UIButtonTypeCustom];
    finishBtn.frame = CGRectMake(0,0,size.width+20, 44);
    [finishBtn setBackgroundColor:[UIColor clearColor]];
    [finishBtn setTitle:@"完成" forState:UIControlStateNormal];
    finishBtn.titleLabel.font = kYMBigFont;
    [finishBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [finishBtn addTarget:self action:@selector(previousButtonIsClicked:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *flexBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    self.self.preBarButton = [[UIBarButtonItem alloc] initWithCustomView:finishBtn];
    NSArray *barButtonItems = @[flexBarButton,self.preBarButton];
    _toolbar.items = barButtonItems;
    [self.view addSubview:_toolbar];
}

- (void) previousButtonIsClicked:(id)sender
{
    [self.view endEditing:YES];
}

- (void)loadNotificationCell
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardShow:) name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];

//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardHide:) name:UIKeyboardDidHideNotification object:nil];
}

- (void)removeNotificationCell
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)keyboardWillShow:(NSNotification *)notif
{
    if (self.view.hidden == YES) {
        return;
    }
    
    CGRect rect = [[notif.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat y = rect.origin.y;
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25f];
    NSArray *subviews = [self.view subviews];
    for (UIView *sub in subviews) {
        CGFloat maxY = CGRectGetMaxY(sub.frame);
        if ([sub isKindOfClass:[UITableView class]]) {
            sub.frame = CGRectMake(0,kYMTopBarHeight,sub.frame.size.width, g_screenHeight-_toolbar.frame.size.height-rect.size.height-kYMTopBarHeight);
//            sub.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, (kYMTopBarHeight+sub.frame.size.height)/2);
        } else {
            if (maxY > y - 2) {
                sub.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, sub.center.y - maxY + y );
            }
        }
    }
    [UIView commitAnimations];
}

- (void)keyboardShow:(NSNotification *)notif {
    if (self.view.hidden == YES) {
        return;
    }
}

- (void)keyboardWillHide:(NSNotification *)notif {
    if (self.view.hidden == YES) {
        return;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.25];
    NSArray *subviews = [self.view subviews];
    for (UIView *sub in subviews) {
        if (sub.center.y < CGRectGetHeight(self.view.frame)/2.0) {
            sub.center = CGPointMake(CGRectGetWidth(self.view.frame)/2.0, CGRectGetHeight(self.view.frame)/2.0);
        }
    }
    _toolbar.frame=CGRectMake(0, g_screenHeight, g_screenWidth, _toolbar.frame.size.height);
    _footerViewForSection.frame = CGRectMake(0, g_screenHeight-kYMTabbarHeight-44,g_screenWidth, 44);
    
    _mainTableView.frame=CGRectMake(0, kYMTopBarHeight, g_screenWidth, g_screenHeight-kYMTopBarHeight-kYMTabbarHeight-44);
    [UIView commitAnimations];
}

- (void)keyboardHide:(NSNotification *)notif {
    if (self.view.hidden == YES) {
        return;
    }
}

- (void)initItems
{
    allSelected = YES;
    
    dataArr = [NSMutableArray arrayWithArray:[[YMDataBase sharedDatabase] getAllpdcInCart]];
    
    if (dataArr!=nil && dataArr.count>0) {
        for (YMShoppingCartItem *item in dataArr) {
            if (item.goods.price.length==0) {
                item.goods.price = @"-.--";
            }
            
            if (!item.selected) {
                allSelected=NO;
            }
            CGSize size = CGSizeMake(g_screenWidth, rowHeight);
            item.size = size;
        }
        _noItemImg.hidden = YES;
        _noItemDesc.hidden = YES;
        _mainTableView.hidden = NO;
        _footerViewForSection.hidden = NO;
        [self startGetGoodsInfoList];
    } else {
        _mainTableView.hidden = YES;
        _footerViewForSection.hidden = YES;
        _noItemImg.hidden = NO;
        _noItemDesc.hidden = NO;
    }
    
    _allBottomBtn.selected = allSelected;
}

#pragma mark UITableViewDelegate UITableViewDataSource
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (headerViewForSection==nil) {
        headerViewForSection = [[UIView alloc] initWithFrame:CGRectMake(0,0,g_screenWidth, 44.f)];
        headerViewForSection.backgroundColor = [UIColor whiteColor];

        _allBtn = [[UIButton alloc] initWithFrame:CGRectMake(kYMBorderMargin,(44-kBtnWidth)/2,kBtnWidth,kBtnWidth)];
        _allBtn.tag = kYMShoppingCartTag;
        _allBtn.selected = allSelected;
        _allBtn.backgroundColor = [UIColor clearColor];
        [_allBtn setImage:[UIImage imageNamed:@"Unselected.png"] forState:UIControlStateNormal];
        [_allBtn setImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateSelected];
        [_allBtn setContentMode:UIViewContentModeScaleToFill];
        [_allBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        float offsetx = CGRectGetMaxX(_allBtn.frame);
        UILabel *tips = [[UILabel alloc] initWithFrame:CGRectMake(offsetx+kYMPadding, 0, 50, headerViewForSection.frame.size.height)];
        tips.text = @"全选";
        tips.textAlignment = NSTextAlignmentLeft;
        tips.backgroundColor = [UIColor clearColor];
        tips.font = kYMBigFont;
        tips.textColor = [UIColor grayColor];
        
        
        _editBtn = [[UIButton alloc] initWithFrame:CGRectMake(g_screenWidth-kYMBorderMargin-50,0,50,headerViewForSection.frame.size.height)];
        _editBtn.tag = kYMShoppingCartTag+1;
        [_editBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        _editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        _editBtn.backgroundColor = [UIColor clearColor];
        _editBtn.titleLabel.font = kYMBigFont;
        [_editBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        
        type=0;
        
        [headerViewForSection addSubview:_allBtn];
        [headerViewForSection addSubview:tips];
        [headerViewForSection addSubview:_editBtn];
    }
    return headerViewForSection;
}

- (UIView *)footerViewForSection
{
    if (_footerViewForSection==nil) {
        _footerViewForSection = [[UIView alloc] initWithFrame:CGRectMake(0,CGRectGetMaxY(_mainTableView.frame),g_screenWidth, 44.f)];
        _footerViewForSection.backgroundColor = [UIColor whiteColor];
        
        _allBottomBtn = [[UIButton alloc] initWithFrame:CGRectMake(kYMBorderMargin,(44-kBtnWidth)/2,kBtnWidth,kBtnWidth)];
        _allBottomBtn.tag = kYMShoppingCartTag;
        _allBottomBtn.selected = allSelected;
        _allBottomBtn.backgroundColor = [UIColor clearColor];
        [_allBottomBtn setImage:[UIImage imageNamed:@"Unselected.png"] forState:UIControlStateNormal];
        [_allBottomBtn setImage:[UIImage imageNamed:@"Selected.png"] forState:UIControlStateSelected];
        [_allBottomBtn setContentMode:UIViewContentModeScaleToFill];
        [_allBottomBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        float offsetx = CGRectGetMaxX(_allBottomBtn.frame);
        
        CGSize size = [YMUtil sizeWithFont:@"全选" withFont:kYMCartTitleFont];
        UILabel *tips = [[UILabel alloc] initWithFrame:CGRectMake(offsetx+kYMPadding, 0, size.width, _footerViewForSection.frame.size.height)];
        tips.text = @"全选";
        tips.textAlignment = NSTextAlignmentLeft;
        tips.backgroundColor = [UIColor clearColor];
        tips.font = kYMCartTitleFont;
        tips.textColor = [UIColor grayColor];
        
        offsetx = CGRectGetMaxX(tips.frame);
        UILabel *totalLabel = [[UILabel alloc] initWithFrame:CGRectMake(offsetx+kYMBorderMargin, 0, 150, _footerViewForSection.frame.size.height)];
        totalPrice = [self calcTotalPrice];
        totalLabel.attributedText = [self priceString];
        totalLabel.textAlignment = NSTextAlignmentLeft;
        totalLabel.backgroundColor = [UIColor clearColor];
        totalLabel.tag = 101;
        
        _checkBtn = [[UIButton alloc] initWithFrame:CGRectMake(g_screenWidth-100,0,100,_footerViewForSection.frame.size.height)];
        _checkBtn.tag = kYMShoppingCartTag+3;
        [_checkBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        [_checkBtn setTitle:@"去结算" forState:UIControlStateNormal];
        _checkBtn.backgroundColor = [UIColor redColor];
        _checkBtn.titleLabel.font = kYMBigFont;
        [_checkBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        
        [_footerViewForSection addSubview:_allBottomBtn];
        [_footerViewForSection addSubview:tips];
        [_footerViewForSection addSubview:totalLabel];
        [_footerViewForSection addSubview:_checkBtn];
    }
    return _footerViewForSection;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([cell respondsToSelector:@selector(setSeparatorInset:)]){
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    if([cell respondsToSelector:@selector(setLayoutMargins:)]){
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return dataArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    YMShoppingCartItem *item = dataArr[indexPath.row];
    item.indexPath = indexPath;
    static NSString *cellIdentifier = @"cellId";
    YMCartCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell==nil) {
        cell = [[YMCartCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.delegate = self;
    }
    cell.type=type;
    cell.item = item;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.view endEditing:YES];
    
    if (type==0) {//0-编辑
        YMShoppingCartItem *item = dataArr[indexPath.row];
        
        YMGoodsDetailController *detailController = [[YMGoodsDetailController alloc] init];
        detailController.goods_id = item.goods.goods_id;
        detailController.goods_subid = item.goods.sub_gid;
        [self.navigationController pushViewController:detailController animated:YES];
    }
}
#pragma mark 按钮点击
- (void)btnClick:(UIButton *)sender
{
    if (sender.tag == kYMShoppingCartTag) {
        //
        BOOL status = !sender.isSelected;
        _allBtn.selected = status;
        _allBottomBtn.selected = status;
        [self setAllItemSelected:status];
    } else if(sender.tag==kYMShoppingCartTag+1) {//编辑、完成
        if ([sender.currentTitle isEqualToString:@"编辑"]) {
            [sender setTitle:@"完成" forState:UIControlStateNormal];
            type=2;
            
            if (_footerViewForSection) {
                UILabel *totalPriceLabel = [_footerViewForSection viewWithTag:101];
                totalPriceLabel.hidden = YES;
                
                UIButton *btn = [_footerViewForSection viewWithTag:kYMShoppingCartTag+3];
                [btn setTitle:@"删除" forState:UIControlStateNormal];
            }
        } else if ([sender.currentTitle isEqualToString:@"完成"]) {
            [sender setTitle:@"编辑" forState:UIControlStateNormal];
            type=0;
            
            if (_footerViewForSection) {
                UILabel *totalPriceLabel = [_footerViewForSection viewWithTag:101];
                totalPriceLabel.hidden = NO;
                
                UIButton *btn = [_footerViewForSection viewWithTag:kYMShoppingCartTag+3];
                [btn setTitle:@"去结算" forState:UIControlStateNormal];
            }
        }
        
        [_mainTableView reloadData];
    } else if (sender.tag==kYMShoppingCartTag+3) { //删除、结算
        if ([sender.currentTitle isEqualToString:@"删除"]) {
            if ([self itemsSelected].count==0) {
                showAlert(@"请选择至少一件商品");
                return;
            }
            
            BOOL result = [self deleteItemSelected];
            if(result) {
                [self showTextHUDView:@"删除成功"];
            }
        } else if ([sender.currentTitle isEqualToString:@"去结算"]) {
            
            NSArray *itemselected = [self itemsSelected];
            if (itemselected.count==0) {
                showAlert(@"请选择至少一件商品");
            } else {
                YMOrderGenerateViewController *orderGenController = [[YMOrderGenerateViewController alloc] init];
                orderGenController.itemlist = itemselected;
                orderGenController.hidesBottomBarWhenPushed=YES;
                [self.navigationController pushViewController:orderGenController animated:YES];
            }
        }
    }
}

- (void)updatePrice
{
    totalPrice = [self calcTotalPrice];
    UILabel *totalPriceLabel = [_footerViewForSection viewWithTag:101];
    totalPriceLabel.attributedText = [self priceString];
}

- (void)setAllItemSelected:(BOOL)status
{
    for (YMShoppingCartItem *item in dataArr) {
        item.selected = status;
    }
    [_mainTableView reloadData];
    
    [self updatePrice];
}

- (BOOL)allItemSelected
{
    BOOL status = YES;
    for (YMShoppingCartItem *item in dataArr) {
        if (!item.selected) {
            status = NO;
            break;
        }
    }
    return status;
}

- (NSArray *)itemsSelected
{
    NSMutableArray *itemArr = [NSMutableArray array];
    for (YMShoppingCartItem *item in dataArr) {
        if (item.selected) {
            [itemArr addObject:item];
        }
    }
    return itemArr;
}

- (BOOL)deleteItemSelected
{
    NSArray *itemArr = [self itemsSelected];
    [dataArr removeObjectsInArray:itemArr];

    [self updatePrice];
    
    [_mainTableView reloadData];
    
    NSMutableArray *goodslist = [NSMutableArray new];
    for (YMShoppingCartItem *item in itemArr)
    {
        [goodslist addObject:item.goods];
    }
    
    return [[YMDataBase sharedDatabase] deletePdcInCartWithList:goodslist];
}

- (NSAttributedString *)priceString
{
    NSString *totalPriceStr = [NSString stringWithFormat:@"合计:%@", totalPrice];
    //富文本对象
    NSMutableAttributedString * aAttributedString = [[NSMutableAttributedString alloc] initWithString:totalPriceStr];
    
    NSRange range1 = [totalPriceStr rangeOfString:@"合计:"];
    
    NSRange range = NSMakeRange(range1.length,totalPriceStr.length-range1.length);
    //富文本样式
    [aAttributedString addAttribute:NSForegroundColorAttributeName value:[UIColor redColor] range:range];
    [aAttributedString addAttribute:NSFontAttributeName value:kYMNormalFont range:range];
    [aAttributedString addAttribute:NSFontAttributeName value:kYMNormalFont range:range1];
    return aAttributedString;
}

#pragma mark YMCartCellDelegate
- (void)cellButtonSelect:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    YMShoppingCartItem *item = dataArr[indexPath.row];
    item.selected = cell.item.selected;
    BOOL status  = [self allItemSelected];
    _allBtn.selected = status;
    _allBottomBtn.selected = status;
    
    [self updatePrice];
}

- (void)cellCount:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath forType:(int)actiontype
{
    YMShoppingCartItem *item = dataArr[indexPath.row];
    
    int count = [item.count intValue];
    
    if (actiontype==0) {
        count++;
    } else {
        count--;
    }

    item.count = [NSString stringWithFormat:@"%d", count];
    
    [self updatePrice];
}

- (void)cellCount:(YMCartCell *)cell withIndexPath:(NSIndexPath *)indexPath withNewValue:(NSString *)value
{
    if (value!=nil && value.length>0) {
        YMShoppingCartItem *item = dataArr[indexPath.row];
        item.count = value;
        [self updatePrice];
    }
}

- (NSString *)calcTotalPrice
{
    NSString *sum = @"0";
    
    NSMutableArray *operands = [NSMutableArray new];
    for (YMShoppingCartItem *item in dataArr) {
        if (item.selected) {
            [operands addObject: [YMUtil decimalMutiply:item.count with:item.goods.price]];
        }
    }
    
    sum = [YMUtil decimalAdd:operands];
    return sum;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
#pragma mark 网络请求
//- (BOOL)getParameters
//{
////    [super getParameters];
//    NSMutableDictionary *parameters = [NSMutableDictionary new];
//    NSMutableArray *paramsArr = [NSMutableArray array];
//    for (YMShoppingCartItem *item in dataArr) {
//        NSDictionary *dict = @{@"goods_id":[NSNumber numberWithInteger:[item.goods.goods_id integerValue]],@"sub_gid":[NSNumber numberWithInteger:[item.goods.sub_gid integerValue]]};
//        [paramsArr addObject:dict];
//    }
//    
//    NSString *str = [YMUtil stringFromJSON:paramsArr];
//    parameters[kYM_GOODSARRAY] = str;//@"[\n  {\n    'goods_id' : 100001,\n    'sub_gid' : 1002\n  },\n  {\n    'goods_id' : 100001,\n    'sub_gid': 1001\n  }\n]";//str;
//    
//    return YES;
//}

- (void)startGetGoodsInfoList
{
    NSMutableDictionary *parameters = [NSMutableDictionary new];
    NSMutableArray *paramsArr = [NSMutableArray array];
    for (YMShoppingCartItem *item in dataArr) {
        NSDictionary *dict = @{@"goods_id":[NSNumber numberWithInteger:[item.goods.goods_id integerValue]],@"sub_gid":[NSNumber numberWithInteger:[item.goods.sub_gid integerValue]]};
        [paramsArr addObject:dict];
    }
    
    NSString *str = [YMUtil stringFromJSON:paramsArr];
    parameters[kYM_GOODSARRAY] = str;//@"[\n  {\n    'goods_id' : 100001,\n    'sub_gid' : 1002\n  },\n  {\n    'goods_id' : 100001,\n    'sub_gid': 1001\n  }\n]";//str;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    [PPNetworkHelper POST:[NSString stringWithFormat:@"%@?%@", kYMServerBaseURL, @"a=GoodsArrayQuery"] parameters:parameters success:^(id responseObject) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
        });
        NSDictionary *respDict = responseObject;
        
        if (respDict) {
            NSString *resp_id = respDict[kYM_RESPID];
            if ([resp_id integerValue]==0) {
                if ([respDict[kYM_RESPDATA] isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *dataDict = respDict[kYM_RESPDATA];
                    if ([dataDict[@"goods_array"] isKindOfClass:[NSArray class]]) {
                        NSArray *goodsArr = dataDict[@"goods_array"];
                        for (int i=0; i<goodsArr.count; i++) {
                            YMShoppingCartItem *item = dataArr[i];
                            
                            NSDictionary *goodsDict = goodsArr[i];
                            item.goods.goods_id = goodsDict[@"goods_id"];
                            item.goods.goods_image1 = goodsDict[@"goods_image1"];
                            item.goods.goods_image1_mid = goodsDict[@"goods_image1_mid"];
                            item.goods.goods_tag = goodsDict[@"goods_tag"];
                            item.goods.price = goodsDict[@"price"];
                            item.goods.sale_count = goodsDict[@"sale_count"];
                            item.goods.status = goodsDict[@"status"];
                            item.goods.store_count = goodsDict[@"store_count"];
                            item.goods.sub_gid = goodsDict[@"sub_gid"];
                        }
                        [self updatePrice];
                    }
                }
                [_mainTableView reloadData];//重新刷新
            } else {
                NSString *resp_desc = respDict[kYM_RESPDESC];
                showDefaultAlert(resp_id, resp_desc);
            }
        }
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [hud hideAnimated:YES];
            showDefaultAlert(@"提示",@"网络不给力，请检查网络设置");
        });
    }];
}

@end
