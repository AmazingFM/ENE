//
//  YMAddressView.m
//  Running
//
//  Created by freshment on 16/9/15.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMAddressView.h"

#import "YMGlobal.h"
#import "YMCommon.h"

#import "YMUtil.h"

@interface YMAddressView() <UIGestureRecognizerDelegate>
{
    UILabel *_personNameLabel;
    UILabel *_telenumLabel;
    UIButton *_iconBtn;
    UILabel *_addressLabel;
    UIImageView *_arrowImg;
    
    UILabel *_tipsLabel;
    CGSize size;
}
@end


@implementation YMAddressView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tap:)];
        tapGesture.numberOfTapsRequired=1;
        tapGesture.numberOfTouchesRequired=1;
        tapGesture.delegate = self;
        [self addGestureRecognizer:tapGesture];
        
        size = frame.size;
        _personNameLabel = [[ UILabel alloc] initWithFrame:CGRectZero];
        _personNameLabel.font = kYMBigFont;
        
        _telenumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _telenumLabel.font = kYMNormalFont;

        _iconBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_iconBtn setImage:[UIImage imageNamed:@"location"] forState:UIControlStateNormal];
        _iconBtn.frame = CGRectMake(5,size.height/2, 30, size.height/2);
        _iconBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        
        float offsetx = CGRectGetMaxX(_iconBtn.frame);
        _addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(kYMPadding+offsetx, size.height/2, size.width-70-offsetx, size.height/2)];
        _addressLabel.font = kYMNormalFont;
        _addressLabel.numberOfLines = 0;
        _addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _addressLabel.textAlignment = NSTextAlignmentLeft;
        
        _arrowImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"icon_more"]];
        _arrowImg.frame = CGRectMake(0, 0, 30, 30);
        _arrowImg.center = CGPointMake(size.width-30, size.height/2);
        _arrowImg.contentMode = UIViewContentModeScaleToFill;
        
        _tipsLabel = [[UILabel alloc] initWithFrame:CGRectMake(kYMPadding+offsetx,0,self.frame.size.width-kYMPadding-offsetx,self.frame.size.height)];
        _tipsLabel.tag=1000;
        _tipsLabel.text = @"没有默认地址,请去添加地址!";
        _tipsLabel.font = kYMBigFont;
        _tipsLabel.textColor = [UIColor blackColor];
        _tipsLabel.textAlignment = NSTextAlignmentLeft;
        _tipsLabel.hidden = YES;
        
        [self addSubview:_personNameLabel];
        [self addSubview:_telenumLabel];
        [self addSubview:_iconBtn];
        [self addSubview:_addressLabel];
        [self addSubview:_arrowImg];
        
        [self addSubview:_tipsLabel];
    }
    return self;
}
- (void)setAddress:(YMAddress *)address
{
    if (address==nil) {
        _tipsLabel.hidden = NO;
        _personNameLabel.hidden = YES;
        _telenumLabel.hidden = YES;
        _addressLabel.hidden = YES;
        
        _iconBtn.frame = CGRectMake(5,size.height/4, 30, size.height/2);
        return;
    }
    
    _iconBtn.frame = CGRectMake(5,size.height/2, 30, size.height/2);
    
    _tipsLabel.hidden = YES;
    _personNameLabel.hidden = NO;
    _telenumLabel.hidden = NO;
//    _iconBtn.hidden = NO;
    _addressLabel.hidden = NO;

    _address = address;
    
    size = [YMUtil sizeWithFont:[NSString stringWithFormat:@"联系人：%@", address.delivery_name] withFont:kYMBigFont];
    _personNameLabel.frame = CGRectMake(kYMPadding, 0, size.width, self.frame.size.height/2);
    _personNameLabel.text = [NSString stringWithFormat:@"联系人：%@", address.delivery_name];
    
    size = [YMUtil sizeWithFont:@"13773845735" withFont:kYMNormalFont];
    _telenumLabel.frame = CGRectMake(CGRectGetMaxX(_personNameLabel.frame)+kYMBorderMargin, 0, size.width, self.frame.size.height/2);
    _telenumLabel.text = address.contact_no;
    
    YMCity *city = address.city;
    _addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@", city.province,city.city,city.town,address.delivery_addr];
}

- (void)tap:(UITapGestureRecognizer *)gesture
{
    if ([self.delegate respondsToSelector:@selector(didClick)]) {
        [self.delegate didClick];
    }
}
@end
