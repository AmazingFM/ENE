//
//  YMMainSearchBar.h
//  Running
//
//  Created by 张永明 on 2017/5/4.
//  Copyright © 2017年 ming. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YMSearchBarDelegate <NSObject>

- (void)searchBarAction;

@end

@interface YMSearchBar : UIView
{
    UIView *_bgView;
    UILabel *_titleLab;
}
@property (nonatomic, retain) NSString *placeholder;
@property(nonatomic,weak)id <YMSearchBarDelegate> delegate;

-(void)setBGViewAlpha:(float)alpha;
@end
