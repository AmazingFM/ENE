//
//  YMBenefitBoard.m
//  Running
//
//  Created by 张永明 on 16/10/7.
//  Copyright © 2016年 ming. All rights reserved.
//

#import "YMBenefitBoard.h"

#import "UIView+Util.h"
#import "UUChart.h"

#import "YMUtil.h"
#import "YMCommon.h"

@implementation YMSjView

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetRGBStrokeColor(context, 1, 1, 1, 0);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, 5, 5);
    CGContextAddLineToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, 10, 0);
    CGContextClosePath(context);
    
    UIColor *topColor = rgba(249, 80, 85, 1);
    [topColor setFill];
    CGContextDrawPath(context, kCGPathFillStroke);
}

@end


@interface YMBenefitBoard()
{
    CGRect myFrame;
    UIColor *topColor;
    UIColor *bottomColor;
    
    UILabel *benifitLabel;
    UILabel *monthAmtLabel;
    
    UILabel *totalAmtLabel;
    UILabel *totalBenefitLabel;
}
@end

@implementation YMBenefitBoard

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor greenColor];
        myFrame = frame;
        topColor = rgba(249, 80, 85, 1);
        bottomColor = rgba(234, 65, 70, 1);
        
        UIView *topView = [[UIView alloc] initWithFrame:CGRectZero];
        topView.backgroundColor = topColor;
        
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 100, 35)];
        titleLabel.textColor = [UIColor whiteColor];
        titleLabel.font = [UIFont systemFontOfSize:17];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.text = @"本月收益";
        titleLabel.centerX = myFrame.size.width/2;
        
        UIButton *questionB = [UIButton buttonWithType:UIButtonTypeCustom];
        questionB.frame = CGRectMake(myFrame.size.width-10-20, (35-20)/2, 20, 20);
        questionB.backgroundColor = [UIColor clearColor];
        [questionB setBackgroundImage:[UIImage imageNamed:@"rc-question"] forState:UIControlStateNormal];
        questionB.contentHorizontalAlignment = UIControlContentHorizontalAlignmentRight;
        [questionB addTarget:self action:@selector(tips:) forControlEvents:UIControlEventTouchUpInside];

        CGSize size = [YMUtil sizeWithFont:@"累计交易(笔)" withFont:[UIFont systemFontOfSize:25]];
        benifitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(titleLabel.frame), myFrame.size.width, size.height)];
        benifitLabel.textColor = [UIColor whiteColor];
        benifitLabel.font = [UIFont systemFontOfSize:25];
        benifitLabel.textAlignment = NSTextAlignmentCenter;
        benifitLabel.backgroundColor = [UIColor clearColor];
        benifitLabel.text = @"-.-元";
        benifitLabel.centerX = myFrame.size.width/2;
        
        size = [YMUtil sizeWithFont:@"累计交易(元)" withFont:[UIFont systemFontOfSize:13]];
        NSString *str = [NSString stringWithFormat:@"本月交易：%@笔", @"-.-"];
        monthAmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(benifitLabel.frame)+10, myFrame.size.width, size.height)];
        monthAmtLabel.textColor = [UIColor whiteColor];
        monthAmtLabel.font = [UIFont systemFontOfSize:13];
        monthAmtLabel.textAlignment = NSTextAlignmentCenter;
        monthAmtLabel.backgroundColor = [UIColor clearColor];
        monthAmtLabel.text = str;
        monthAmtLabel.centerX = myFrame.size.width/2;

        
        [topView addSubview:titleLabel];
        [topView addSubview:questionB];
        [topView addSubview:benifitLabel];
        [topView addSubview:monthAmtLabel];
        topView.frame = CGRectMake(0, 0, myFrame.size.width,CGRectGetMaxY(monthAmtLabel.frame)+10);
        
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(topView.frame), myFrame.size.width,  myFrame.size.height-CGRectGetMaxY(topView.frame))];
        bottomView.backgroundColor = bottomColor;
        
        CGSize size1 = [YMUtil sizeWithFont:@"累计交易(笔)" withFont:[UIFont systemFontOfSize:15]];
        CGFloat padding = (50-size1.height*2-5)/2;
        
        totalAmtLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, padding, 100, size1.height)];
        totalAmtLabel.textColor = [UIColor whiteColor];
        totalAmtLabel.font = [UIFont systemFontOfSize:15];
        totalAmtLabel.textAlignment = NSTextAlignmentCenter;
        totalAmtLabel.backgroundColor = [UIColor clearColor];
        totalAmtLabel.centerX = myFrame.size.width/4;
        totalAmtLabel.text = @"-.-";
        
        UILabel *amtDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, padding+size1.height+5, 100, size1.height)];
        amtDescLabel.textColor = [UIColor whiteColor];
        amtDescLabel.text = @"累计交易(笔)";
        amtDescLabel.font = [UIFont systemFontOfSize:15];
        amtDescLabel.textAlignment = NSTextAlignmentCenter;
        amtDescLabel.backgroundColor = [UIColor clearColor];
        amtDescLabel.centerX = myFrame.size.width/4;
        [bottomView addSubview:totalAmtLabel];
        [bottomView addSubview:amtDescLabel];
        
        totalBenefitLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, padding, 100, size1.height)];
        totalBenefitLabel.textColor = [UIColor whiteColor];
        totalBenefitLabel.font = [UIFont systemFontOfSize:15];
        totalBenefitLabel.textAlignment = NSTextAlignmentCenter;
        totalBenefitLabel.backgroundColor = [UIColor clearColor];
        totalBenefitLabel.centerX = myFrame.size.width*3/4;
        totalBenefitLabel.text = @"-.-";
        
        UILabel *benefitDescLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, padding+size1.height+5, 100, size1.height)];
        benefitDescLabel.textColor = [UIColor whiteColor];
        benefitDescLabel.text = @"累计收益(元)";
        benefitDescLabel.font = [UIFont systemFontOfSize:15];
        benefitDescLabel.textAlignment = NSTextAlignmentCenter;
        benefitDescLabel.backgroundColor = [UIColor clearColor];
        benefitDescLabel.centerX = myFrame.size.width*3/4;
        [bottomView addSubview:totalBenefitLabel];
        [bottomView addSubview:benefitDescLabel];

        [self addSubview:topView];
        [self addSubview:bottomView];
        
        YMSjView *sjView = [[YMSjView alloc] initWithFrame:CGRectMake(myFrame.size.width/2-5,CGRectGetMaxY(topView.frame),10, 5)];
        sjView.backgroundColor = [UIColor clearColor];
        [self addSubview:sjView];
    }
    return self;
}

- (void)setProfit:(YMMyProfit *)profit
{
    NSString *str;
    str = [NSString stringWithFormat:@"%@元", profit.month_amt];
    benifitLabel.text = str;
    str = [NSString stringWithFormat:@"本月交易：%@笔", profit.month_count];
    monthAmtLabel.text = str;
    totalAmtLabel.text = profit.sum_count;
    totalBenefitLabel.text = profit.sum_amt;
}

- (void)tips:(UIButton *)sender
{
    if ([self.delegate respondsToSelector:@selector(showTips)]) {
        [self.delegate showTips];
    }
}
@end

@interface YMBenefitChart() <UUChartDataSource>
{
    UUChart *chartView;
    CGRect myFrame;
    UIView *detailView;
    
    NSMutableArray<ProfitItem *> *dayBenifits;
}

@end

@implementation YMBenefitChart

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        
        myFrame = frame;
        
        CGFloat leftPadding = 15.f;
        UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding, 0, 100, 34)];
        titleLabel.textColor = rgba(57, 57, 57, 1);
        titleLabel.font = [UIFont systemFontOfSize:15];
        titleLabel.textAlignment = NSTextAlignmentLeft;
        titleLabel.backgroundColor = [UIColor whiteColor];
        titleLabel.text = @"月度收益";
        
        UIView *line = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, 34, myFrame.size.width-leftPadding, 1)];
        line.backgroundColor = rgba(221, 221, 221, 1);
        
        [self addSubview:line];
        [self addSubview:titleLabel];
        
//        CGSize size = [YMUtil sizeWithFont:@"笔数" withFont:[UIFont systemFontOfSize:11]];
//        CGSize size1 = [YMUtil sizeWithFont:@"笔数" withFont:[UIFont systemFontOfSize:15]];
//        CGFloat detailViewHeight =  size.height+size1.height+20;
//        detailView = [[UIView alloc] initWithFrame:CGRectMake(0, 35, myFrame.size.width,detailViewHeight)];
//        detailView.backgroundColor = [UIColor whiteColor];
//        
//        CGFloat offsetx = 0;
//        
//        for (int i=0; i<2; i++) {
//            UILabel *bsLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding+offsetx, 5, 100, size.height)];
//            bsLabel.textColor = [UIColor lightGrayColor];
//            bsLabel.font = [UIFont systemFontOfSize:11];
//            bsLabel.textAlignment = NSTextAlignmentLeft;
//            bsLabel.backgroundColor = [UIColor clearColor];
//            bsLabel.text = (i==0)?@"笔数(笔)":@"金额(元)";
//            
//            UILabel *amtLabel = [[UILabel alloc] initWithFrame:CGRectMake(leftPadding+offsetx, CGRectGetMaxY(bsLabel.frame)+5, 100, size1.height)];
//            amtLabel.tag = 100+i;
//            amtLabel.textColor = [UIColor redColor];
//            amtLabel.font = [UIFont systemFontOfSize:15];
//            amtLabel.textAlignment = NSTextAlignmentLeft;
//            amtLabel.backgroundColor = [UIColor clearColor];
//            amtLabel.text = @"-.-";
//            
//            [detailView addSubview:bsLabel];
//            [detailView addSubview:amtLabel];
//            
//            offsetx += (myFrame.size.width+leftPadding)/2;
//        }
//        
//        UIView *line2 = [[UIView alloc] initWithFrame:CGRectMake((myFrame.size.width+leftPadding)/2, 10, 1,  detailViewHeight-20)];
//        line2.backgroundColor = rgba(221, 221, 221, 1);
//        [detailView addSubview:line2];
//        
//        UIView *line1 = [[UIView alloc] initWithFrame:CGRectMake(leftPadding, CGRectGetMaxY(detailView.frame), myFrame.size.width-leftPadding, 1)];
//        line1.backgroundColor = rgba(221, 221, 221, 1);
//        


//        [self addSubview:line1];
//        [self addSubview:detailView];
        
        chartView = [[UUChart alloc]initWithFrame:CGRectMake(0, line.frame.origin.y+1, [UIScreen mainScreen].bounds.size.width, frame.size.height-line.frame.origin.y+1) dataSource:self style:UUChartStyleLine];
        [chartView showInView:self];
        
        dayBenifits = [NSMutableArray new];
    }
    return self;
}

- (void)setProfit:(YMMyProfit *)profit
{
    UILabel *countLabel = [detailView viewWithTag:100];
    countLabel.text = profit.month_count;
    
    UILabel *amtLabel = [detailView viewWithTag:101];
    amtLabel.text = profit.month_amt;
    
    [dayBenifits removeAllObjects];
    [dayBenifits addObjectsFromArray:profit.profit_list];
    [chartView strokeChart];
}

#pragma mark - @required
//横坐标标题数组
- (NSArray *)chartConfigAxisXLabel:(UUChart *)chart
{
    NSMutableArray *titleArr = [NSMutableArray new];
    
    for (ProfitItem *item in dayBenifits) {
        [titleArr addObject:item.date];
    }

    return titleArr;

}
//数值多重数组
- (NSArray *)chartConfigAxisYValue:(UUChart *)chart
{
    NSMutableArray *amtArr = [NSMutableArray new];
    NSMutableArray *countArr = [NSMutableArray new];
    for (ProfitItem *item in dayBenifits) {
        [amtArr addObject:item.occur_amt];
        [countArr addObject:item.occur_count];
    }
    
    return @[amtArr];
}

#pragma mark - @optional
//颜色数组
- (NSArray *)chartConfigColors:(UUChart *)chart
{
    return @[[UUColor red]];
}
//显示数值范围
- (CGRange)chartRange:(UUChart *)chart
{
    float low = 0;
    float high = 0;
    for (ProfitItem *item in dayBenifits) {
        if (high<[item.occur_amt floatValue]) {
            high = [item.occur_amt floatValue];
        }
    }

    return CGRangeMake(high, low);
}

#pragma mark 折线图专享功能

//标记数值区域
- (CGRange)chartHighlightRangeInLine:(UUChart *)chart
{
    return CGRangeZero;
}

//判断显示横线条
- (BOOL)chart:(UUChart *)chart showHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)chart:(UUChart *)chart showMaxMinAtIndex:(NSInteger)index
{
    return YES;
}

@end
