//
//  YMCell.m
//  Running
//
//  Created by freshment on 16/9/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMCell.h"

#import "YMGlobal.h"
#import "YMCommon.h"
#import "YMUtil.h"

#import "UIView+Util.h"

@implementation YMBaseCell
@end

@interface YMRCFieldCell() <UITextFieldDelegate>
{
    UITextField *_textField;
}
@end

@implementation YMRCFieldCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [super setBackgroundColor:[UIColor clearColor]];
        
        _textField  = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.textAlignment=NSTextAlignmentLeft;
        _textField.font=kYMFieldFont;
        _textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
        _textField.autocorrectionType = UITextAutocorrectionTypeDefault;
        _textField.returnKeyType=UIReturnKeyDone;
        _textField.keyboardType=UIKeyboardTypeNamePhonePad;
        _textField.contentVerticalAlignment=UIControlContentVerticalAlignmentCenter;
        [_textField addTarget:self action:@selector(textFieldChanged:) forControlEvents:UIControlEventEditingChanged];
        [_textField addTarget:self action:@selector(textFieldDone:) forControlEvents:UIControlEventEditingDidEndOnExit];
        _textField.delegate=self;
        [self addSubview:_textField];
        
        
    }
    return self;
}

- (void)setItem:(YMFieldCellItem *)item
{
    [super setItem:item];
    if (item.secureTextEntry) {
        _textField.secureTextEntry = YES;
    }
    
    _textField.textAlignment = item.anchor;
    if(item.showClear) {
        _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    } else {
        _textField.clearButtonMode = UITextFieldViewModeNever;
    }
    
    CGSize size = [YMUtil sizeWithFont:@"确认密码" withFont:kYMNormalFont];
    if ([item.key isEqualToString:@"verifycode"]) {
        CGSize tmpSize = [YMUtil sizeWithFont:@"获取验证码" withFont:kYMNormalFont];
        _textField.frame = CGRectMake(size.width+30, 0, g_screenWidth-2*kYMBorderMargin-30-size.width-tmpSize.width-30, 44);
    } else {
        _textField.frame = CGRectMake(size.width+30, 0, g_screenWidth-2*kYMBorderMargin-30-size.width-kYMBorderMargin, 44);
    }
    
    self.textLabel.font = kYMNormalFont;
    self.textLabel.text = item.title;
    
    if (item.value==nil || item.value.length==0) {
        NSString *tips;
        if (item.placeholder!=nil &&item.placeholder.length>0) {
            tips = item.placeholder;
        } else {
            tips = [NSString stringWithFormat:@"请输入你的%@", item.title];
        }
        
        NSMutableAttributedString *passplaceholder = [[NSMutableAttributedString alloc]initWithString:tips];
        [passplaceholder addAttribute:NSForegroundColorAttributeName
                                value:[UIColor grayColor]
                                range:NSMakeRange(0, tips.length)];
        [passplaceholder addAttribute:NSFontAttributeName
                                value:[UIFont systemFontOfSize:15]
                                range:NSMakeRange(0, tips.length)];
        _textField.attributedPlaceholder = passplaceholder;
    } else {
        _textField.text = item.value;
    }
}

//字符控制
#pragma mark -
#pragma mark UITextFieldDelegate

-(void)textFieldDone:(UITextField*)textField{
    [textField resignFirstResponder];
}

-(void)textFieldChanged:(UITextField*)textField{
    YMFieldCellItem* fieldItem=(YMFieldCellItem*)self.item;
    fieldItem.fieldText=textField.text;
    fieldItem.value = textField.text;
    if(self.delegate&&[self.delegate respondsToSelector:@selector(viewValueChanged:withIndexPath:)]){
        [self.delegate viewValueChanged:_textField.text withIndexPath:fieldItem.indexPath];
    }
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)textEntered{
    unichar c = [textEntered characterAtIndex:[textEntered length]-1];
    if(c==0||c=='\n'){
        return YES;
    }
    YMFieldCellItem* fieldItem=(YMFieldCellItem*)self.item;
    int actionLen=fieldItem.actionLen;
    if(actionLen>0){
        if([textField.text length]+[textEntered length]>actionLen){
            return NO;
        }
    }
    
    if(fieldItem.fieldType!=YMFieldTypeUnlimited){
        NSCharacterSet *cs  = nil;
        BOOL isMatch=NO;
        if(fieldItem.fieldType==YMFieldTypeNumber){
            cs=[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet];
        }else if(fieldItem.fieldType==YMFieldTypeCharater){
            cs=[[NSCharacterSet characterSetWithCharactersInString:@"0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
        }else if(fieldItem.fieldType==YMFieldTypePassword){
            cs=[[NSCharacterSet characterSetWithCharactersInString:@"!#%&*0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"] invertedSet];
        }
        NSString *filtered = [[textEntered componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL basicTest = [textEntered isEqualToString:filtered];
        //数字校验
        
        if(isMatch){
            NSString *temp;
            //        NSString *regex=@"^\\d*(\\d+)?$";
            NSString *regex=@"^\\d*(\\d+\\.\\d*)?$";
            temp = [textField.text stringByReplacingCharactersInRange:range withString:textEntered];
            NSPredicate *filter=[NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
            isMatch=[filter evaluateWithObject:temp];
            //数字校验
            return (basicTest && isMatch);
        }else {
            return basicTest;
        }
    }
    
    return YES;
}

@end

@interface YMRCRadioCell()
{
    NSMutableArray *_buttonArr;
}

@end

@implementation YMRCRadioCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = [UIColor clearColor];
        _buttonArr = [NSMutableArray array];
    }
    return self;
}

- (void)setItem:(YMBaseCellItem *)item
{
    [super setItem:item];
    
    YMRadioCellItem *radioItem = (YMRadioCellItem *)item;
    
    CGSize size = [YMUtil sizeWithFont:@"确认密码" withFont:kYMNormalFont];
    
    UIView *backView = [self viewWithTag:1000];
    if (backView==nil) {
        backView = [[UIView alloc] initWithFrame:CGRectMake(size.width+30, 0, g_screenWidth-2*kYMBorderMargin-30-size.width, 44)];
        backView.backgroundColor = [UIColor clearColor];
        backView.tag = 1000;
        [self addSubview:backView];
        
        float perwidth = backView.width/radioItem.titleItems.count;
        
        
        for (int i=0; i<radioItem.titleItems.count; i++) {
            NSString *title = radioItem.titleItems[i];
            
            CGSize titleSize = [YMUtil sizeWithFont:title withFont:kYMNormalFont];
            CGFloat btnW=titleSize.height+5;
            UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
            btn.tag = 100+i;
            btn.frame = CGRectMake(i*perwidth,(44-btnW)/2,btnW, btnW);
            
            
            [btn setBackgroundImage:[UIImage imageNamed:@"icon-checkoff"] forState:UIControlStateNormal];
            [btn setBackgroundImage:[UIImage imageNamed:@"icon-checkon"] forState:UIControlStateSelected];
            [btn addTarget:self action:@selector(btnClick:) forControlEvents:UIControlEventTouchUpInside];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(i*perwidth+btnW+10, 0, titleSize.width, 44)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.text = title;
            titleLabel.textAlignment = NSTextAlignmentLeft;
            titleLabel.font = kYMNormalFont;
            
            [_buttonArr addObject:btn];
            
            [backView addSubview:btn];
            [backView addSubview:titleLabel];
        }
    }
    
    if (radioItem.selectedIndex>=0) {
        UIButton *hitBtn = _buttonArr[radioItem.selectedIndex];
        [self btnClick:hitBtn];
    }
    
    self.textLabel.font = kYMNormalFont;
    self.textLabel.text = item.title;
}

- (void)btnClick:(UIButton *)sender
{
    YMRadioCellItem *radioItem = (YMRadioCellItem *)self.item;
    radioItem.selectedIndex = (int)sender.tag-100;
    sender.selected = YES;
    
    for (UIButton *btn in _buttonArr) {
        if (btn.tag!=sender.tag) {
            if (btn.isSelected) {
                btn.selected = NO;
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(radioButtonSelect:withIndexPath:)]) {
        [self.delegate radioButtonSelect:radioItem.selectedIndex withIndexPath:radioItem.indexPath];
    }
}
@end

@interface YMRCDateCell(){
    UIButton*       _dateBtn;
    UIDatePicker*   _datePickerView;
    UIView*         _datePanelView;
    UIButton*       _hideBtn;
    
    NSDateFormatter* _dateFormatter;
    
}
@end

@implementation YMRCDateCell


-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self=[super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self){
        _dateBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [_dateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _dateBtn.contentHorizontalAlignment=UIControlContentHorizontalAlignmentRight;
        _dateBtn.titleLabel.font = kYMNormalFont;
        [_dateBtn addTarget:self action:@selector(showDatePanel:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_dateBtn];
    }
    return self;
}

-(void)setItem:(YMBaseCellItem *)item{
    [super setItem:item];
    if([item isKindOfClass:[YMDateCellItem class]]){
        YMDateCellItem* dateItem=(YMDateCellItem*)item;
        
        if (dateItem.showValue.length==0) {
            [_dateBtn setTitle:@"请选择日期" forState:UIControlStateNormal];
            [_dateBtn setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        } else {
            [_dateBtn setTitle:dateItem.showValue forState:UIControlStateNormal];
            [_dateBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        }
    }
    
    CGSize size = [YMUtil sizeWithFont:@"确认密码" withFont:kYMNormalFont];
    _dateBtn.frame = CGRectMake(size.width+30, 0, g_screenWidth-2*kYMBorderMargin-30-size.width-kYMBorderMargin, 44);
    
    self.textLabel.font = kYMNormalFont;
    self.textLabel.text = item.title;
}

- (UIView *)windowView {
    return g_mainWindow;
}

-(void)dealloc{
    [_hideBtn removeFromSuperview];
    [_datePanelView removeFromSuperview];
}

-(void)showDatePanel:(UIButton*)btn{
    if(_datePickerView==nil){
        _hideBtn=[[UIButton alloc] initWithFrame:CGRectMake(0,0,g_screenWidth,g_screenHeight)];
        _hideBtn.alpha=0.1f;
        _hideBtn.backgroundColor=[UIColor lightGrayColor];
        [_hideBtn addTarget:self action:@selector(dismissDatePanel) forControlEvents:UIControlEventTouchUpInside];
        
        _datePickerView=[[UIDatePicker alloc] initWithFrame:CGRectMake(kYMPadding,0,g_screenWidth-2*kYMPadding,200)];
        _datePickerView.datePickerMode=UIDatePickerModeDate;
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"zh_CN"];//设置为中
        _datePickerView.locale = locale;
        [_datePickerView addTarget:self action:@selector(datePickerChanged:) forControlEvents:UIControlEventValueChanged];
        
        UIButton* confirmBtn=[UIButton buttonWithType:UIButtonTypeCustom];
        [confirmBtn setTitle:@"确认" forState:UIControlStateNormal];
        [confirmBtn setTitle:@"确认" forState:UIControlStateHighlighted];
        confirmBtn.backgroundColor= [YMUtil colorWithHex:0xffcc02];
        confirmBtn.frame=CGRectMake(kYMPadding,198,g_screenWidth-4*kYMPadding,40);
        [confirmBtn addTarget:self action:@selector(confirmClicked) forControlEvents:UIControlEventTouchUpInside];
        confirmBtn.layer.cornerRadius=5.f;
        _dateFormatter = [[NSDateFormatter alloc] init];
        [_dateFormatter setDateFormat:@"yyyy-MM-dd"];
        
        _datePanelView=[[UIView alloc] initWithFrame:CGRectMake(kYMPadding,g_screenHeight,g_screenWidth-2*kYMPadding, 250)];
        _datePanelView.backgroundColor=[UIColor whiteColor];
        _datePanelView.layer.cornerRadius=5.f;
        _datePanelView.layer.masksToBounds=YES;
        [_datePanelView addSubview:_datePickerView];
        [_datePanelView addSubview:confirmBtn];
        
        if(self.windowView){
            [self.windowView addSubview:_hideBtn];
            [self.windowView addSubview:_datePanelView];
        }
    }
    
    if(_dateBtn.titleLabel.text.length>=8&&![_dateBtn.titleLabel.text isEqualToString:@"请选择日期"]){
        NSDate* date = [_dateFormatter dateFromString:_dateBtn.titleLabel.text];
        [_datePickerView setDate:date];
    }
    
    [UIView animateWithDuration:0.3f animations:^{
        _hideBtn.hidden=NO;
        CGRect dateFrame=_datePanelView.frame;
        dateFrame.origin.y-=_datePanelView.frame.size.height;
        _datePanelView.frame=dateFrame;
    } completion:^(BOOL finished) {
    }];
}

-(void)confirmClicked{
    [self datePickerChanged:_datePickerView];
    [self dismissDatePanel];
}

-(void)dismissDatePanel{
    [UIView animateWithDuration:0.3f animations:^{
        _hideBtn.hidden=YES;
        CGRect dateFrame=_datePanelView.frame;
        dateFrame.origin.y+=dateFrame.size.height;
        _datePanelView.frame=dateFrame;
    } completion:^(BOOL finished) {
        
    }];
}

-(void)datePickerChanged:(UIDatePicker*)datePicker{
    NSString* dateValue=[_dateFormatter stringFromDate:datePicker.date];
    
    [_dateBtn setTitle:dateValue forState:UIControlStateNormal];
    [_dateBtn setTitle:dateValue forState:UIControlStateHighlighted];
    if([self.item isKindOfClass:[YMDateCellItem class]]){
        YMDateCellItem* dateItem=(YMDateCellItem*)self.item;
        dateItem.showValue = dateValue;
        if(self.delegate&&[self.delegate respondsToSelector:@selector(viewValueChanged:withIndexPath:)]){
            [self.delegate viewValueChanged:dateItem.value withIndexPath:dateItem.indexPath];
        }
    }
}

@end

