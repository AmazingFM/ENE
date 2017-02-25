//
//  YMRatingBar.h
//  Running
//
//  Created by 张永明 on 2017/2/24.
//  Copyright © 2017年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMRatingBarDelegate <NSObject>

- (void)ratingBarValue:(NSInteger)score;

@end

@interface YMRatingBar : UIView

@property (nonatomic, weak) id<YMRatingBarDelegate> delegate;
@end

@interface YMSimpleRatingBar : UIView
- (instancetype)initWithFrame:(CGRect)frame  andStarSize:(CGSize)size withValue:(int)score;
@end
