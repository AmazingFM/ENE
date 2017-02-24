//
//  YMImageLoadView.h
//  Running
//
//  Created by 张永明 on 2017/2/24.
//  Copyright © 2017年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMImageLoadViewDelegate <NSObject>

- (void)imageDidSelected:(UIImageView *)imageView withPos:(NSInteger)index;
- (void)imageLoadFrameChange:(CGRect)frame;

@end

@interface YMImageLoadView : UIView

@property (nonatomic) int number;
@property (nonatomic) int maxCount;
@property (nonatomic, retain) NSMutableArray *images;
@property (nonatomic, retain) NSMutableArray *imagesDataList;
@property (nonatomic, weak) id<YMImageLoadViewDelegate> delegate;

- (instancetype)initWithFrame:(CGRect)frame withMaxCount:(int)maxCount ;

@end
