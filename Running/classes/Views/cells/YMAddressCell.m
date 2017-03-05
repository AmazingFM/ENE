//
//  YMAddressCell.m
//  Running
//
//  Created by 张永明 on 16/10/2.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMAddressCell.h"

#import "YMUtil.h"
#import "YMLabel.h"

#define kAddressBtnTag 1000
@interface YMAddressCell()
{
    UILabel *_nameLabel;
    UILabel *_telenumLabel;
    YMLabel *_addressLabel;
    UIButton *_selectBtn;
    UIButton *_editBtn;
    UIButton *_deleteBtn;
    
    UIView *_line;
}
@end

@implementation YMAddressCell

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _nameLabel.font = kYMBigFont;
        _nameLabel.backgroundColor = [UIColor clearColor];
        _nameLabel.textColor = [UIColor blackColor];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.minimumScaleFactor = 0.8;
        _nameLabel.adjustsFontSizeToFitWidth = YES;
        
        _telenumLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _telenumLabel.font = kYMBigFont;
        _telenumLabel.backgroundColor = [UIColor clearColor];
        _telenumLabel.textColor = [UIColor blackColor];
        _telenumLabel.textAlignment = NSTextAlignmentLeft;
        
        _addressLabel = [[YMLabel alloc] initWithFrame:CGRectZero];
        _addressLabel.font = kYMNormalFont;
        _addressLabel.numberOfLines = 2;
        _addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
        _addressLabel.textAlignment = NSTextAlignmentLeft;
        _addressLabel.textColor = rgba(102, 102, 102, 1);;
        [_addressLabel setVerticalAlignment:VerticalAlignmentTop];
        
        _line = [[UIView alloc] initWithFrame:CGRectZero];
        _line.backgroundColor = [UIColor lightGrayColor];
        
        _selectBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _selectBtn.backgroundColor = [UIColor clearColor];
        _selectBtn.tag = kAddressBtnTag;
        [_selectBtn setImage:[UIImage imageNamed:@"icon-checkoff-round"] forState:UIControlStateNormal];
        [_selectBtn setImage:[UIImage imageNamed:@"icon-checkon-round"] forState:UIControlStateSelected];
        [_selectBtn setTitle:@"设为默认" forState:UIControlStateNormal];
        [_selectBtn setTitle:@"默认地址" forState:UIControlStateSelected];
        [_selectBtn setTitleEdgeInsets:UIEdgeInsetsMake(0, 5, 0, 0)];
        [_selectBtn setTitleColor:rgba(102, 102, 102, 1) forState:UIControlStateNormal];
        [_selectBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateSelected];
        _selectBtn.titleLabel.font = kYMSmallFont;
        _selectBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_selectBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
        
        _editBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _editBtn.backgroundColor = [UIColor clearColor];
        [_editBtn setImage:[UIImage imageNamed:@"icon-edit"] forState:UIControlStateNormal];
        [_editBtn setTitle:@"编辑" forState:UIControlStateNormal];
        [_editBtn setTitleColor:rgba(102, 102, 102, 1) forState:UIControlStateNormal];
        _editBtn.titleLabel.font = kYMSmallFont;
        _editBtn.tag = kAddressBtnTag+1;
        _editBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_editBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

        _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _deleteBtn.backgroundColor = [UIColor clearColor];
        [_deleteBtn setImage:[UIImage imageNamed:@"icon-del"] forState:UIControlStateNormal];
        _deleteBtn.titleLabel.font = kYMSmallFont;
        [_deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
        [_deleteBtn setTitleColor:rgba(102, 102, 102, 1) forState:UIControlStateNormal];
        _deleteBtn.tag = kAddressBtnTag+2;
        _deleteBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        [_deleteBtn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];

        [self addSubview:_nameLabel];
        [self addSubview:_telenumLabel];
        [self addSubview:_addressLabel];
        [self addSubview:_selectBtn];
        [self addSubview:_editBtn];
        [self addSubview:_deleteBtn];
        [self addSubview:_line];
    }
    return self;
}

- (void)setAddressItem:(YMAddressItem *)addressItem
{
    _addressItem = addressItem;
    CGSize frameSize = addressItem.size;
    
    float offsety = 0;
    CGSize tmpSize = [YMUtil sizeWithFont:_addressItem.address.delivery_name withFont:kYMBigFont];
    _nameLabel.frame = CGRectMake(kYMBorderMargin, 0, 100, tmpSize.height+10);
    _telenumLabel.frame = CGRectMake(CGRectGetMaxX(_nameLabel.frame)+10, 0, 150, tmpSize.height+10);
    _nameLabel.text = _addressItem.address.delivery_name;
    _telenumLabel.text = _addressItem.address.contact_no;
    
    offsety += tmpSize.height+10.f;
    tmpSize = [YMUtil sizeWithFont:@"测试地址" withFont:kYMNormalFont];
    _addressLabel.frame = CGRectMake(kYMBorderMargin, offsety+5.f, frameSize.width-2*kYMBorderMargin, tmpSize.height*2);
    YMCity *city = _addressItem.address.city;
    _addressLabel.text = [NSString stringWithFormat:@"%@%@%@%@", city.province,city.city,city.town,_addressItem.address.delivery_addr];

    offsety += 2*tmpSize.height+10.f;
    _line.frame = CGRectMake(kYMBorderMargin, offsety, frameSize.width-2*kYMBorderMargin, 1);
    
    offsety += 1.f;
    tmpSize = [YMUtil sizeWithFont:@"测试" withFont:kYMSmallFont];
    _selectBtn.frame = CGRectMake(kYMBorderMargin, offsety, 100, tmpSize.height+10.f);
    if ([_addressItem.address.status intValue]==0) {
        _selectBtn.selected = YES;
    } else {
        _selectBtn.selected = NO;
    }
    
    _deleteBtn.frame = CGRectMake(frameSize.width-(tmpSize.width+30)-kYMBorderMargin, offsety, tmpSize.width+30, tmpSize.height+10.f);
    
    _editBtn.frame = CGRectMake(frameSize.width-2*(tmpSize.width+30)-kYMBorderMargin-30, offsety, tmpSize.width+30, tmpSize.height+10.f);
}
- (void)btnClick:(UIButton *)sender
{
    YMAddressAction type = YMAddressActionDefault;
    if (sender.tag==kAddressBtnTag) {
        if (sender.isSelected) {
            return;
        }
        type = YMAddressActionDefault;
        
    } else if (sender.tag==kAddressBtnTag+1) {
        type = YMAddressActionEdit;
    } else if (sender.tag==kAddressBtnTag+2) {
        type = YMAddressActionDelete;
    }
    
    if ([self.delegate respondsToSelector:@selector(modifyAddress:withType:)]) {
        [self.delegate modifyAddress:self.addressItem withType:type];
    }
}
@end
